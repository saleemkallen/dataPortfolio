from flask import Flask, request, render_template, jsonify
from elasticsearch import Elasticsearch
from openai import AzureOpenAI
from dotenv import load_dotenv
import os
import requests
from instructions import get_azure_prompt, get_aim_prompt  # Import instruction functions

app = Flask(__name__)

# AIM Client Class
class CustomLLM:
    def __init__(self, endpoint, api_key, model_id):
        self.endpoint = endpoint
        self.api_key = api_key
        self.model_id = model_id
        self.session_key = None

    def generate_completion(self, prompt, retry=True):
        lower_prompt = prompt.lower().strip()
        if lower_prompt in ['hello', 'hi', 'hey', 'greetings']:
            return "Hello! I am the Stages chatbot. I'm here to help you with any questions. How can I assist you today?"

        json_body = {
            "api_key": self.api_key,
            "user_message": prompt,
            "session_key": self.session_key if self.session_key else "",
            "ai_model_id": self.model_id,
        }

        response = requests.post(
            self.endpoint,
            json=json_body,
            headers={"Content-Type": "application/json"}
        )

        if response.status_code == 200:
            result = response.json()
            if result.get('session_key'):
                self.session_key = result['session_key']
            return result.get('content', '')
        elif response.status_code == 500 and retry:
            self.session_key = None
            return self.generate_completion(prompt, retry=False)
        else:
            raise Exception(f"LLM request failed with status code {response.status_code}")

    def reset_session(self):
        self.session_key = None


def get_elasticsearch_results(query, es_client):
    es_query = {
        "query": {
            "multi_match": {
                "query": query,
                "fields": [
                    "body_content",
                    "title",
                    "headings",
                    "index._index",
                    "index._type"
                ],
                "type": "best_fields",
                "tie_breaker": 0.3
            }
        },
        "size": 3
    }
    result = es_client.search(index="on_prem_test", body=es_query)
    hits = result["hits"]["hits"]
    return [hit for hit in hits if hit["_source"].get("body_content", "").strip()]


def create_prompt(results, question, index_source_fields, model_type="azure"):
    """
    Creates a prompt for the LLM based on the results and the model type.
    :param results: The search results from Elasticsearch.
    :param question: The user's question.
    :param index_source_fields: Mapping of index names to source fields.
    :param model_type: The type of model to create the prompt for ("azure" or "aim").
    :return: A tuple of (prompt, canonical_urls).
    """
    context = ""
    canonical_urls = []

    for hit in results:
        source_field = index_source_fields.get(hit["_index"], [])[0]
        hit_context = hit["_source"].get(source_field, "")
        context += f"{hit_context}\n"
        canonical_url = hit["_source"].get("canonical_url", "")
        if canonical_url and canonical_url != "No URL provided":
            canonical_urls.append(canonical_url)

    # Use the appropriate instruction function based on the model type
    if model_type == "azure":
        prompt = get_azure_prompt(context)
    else:
        prompt = get_aim_prompt(context, question)

    return prompt, canonical_urls


@app.route("/")
def home():
    aim_client.reset_session()
    return render_template("index1.html")


@app.route("/chat", methods=["POST"])
def chat():
    data = request.json
    user_query = data.get("query")
    model_type = data.get("model", "azure")  # Default to azure if not specified

    try:
        lower_query = user_query.lower().strip()
        if lower_query in ['hello', 'hi', 'hey', 'greetings']:
            return jsonify({
                "answer": "Hello! I am the Stages chatbot. I'm here to help you with any questions. How can I assist you today?",
                "references": []
            })

        elasticsearch_results = get_elasticsearch_results(user_query, es_client)

        if not elasticsearch_results:
            return jsonify({
                "answer": "I apologize, but I couldn't find any specific information about that in my knowledge base. Could you please ask a more specific question?",
                "references": []
            })

        prompt, canonical_urls = create_prompt(elasticsearch_results, user_query, index_source_fields, model_type)

        if model_type == "azure":
            response = azure_client.chat.completions.create(
                model=AZURE_DEPLOYMENT_NAME,
                messages=[
                    {"role": "system", "content": prompt},
                    {"role": "user", "content": user_query}
                ],
                temperature=0.0,
                max_tokens=5000,
                top_p=0.95,
                frequency_penalty=0,
                presence_penalty=0,
                stop=None
            )
            answer = response.choices[0].message.content
        else:
            answer = aim_client.generate_completion(prompt)

        return jsonify({
            "answer": answer,
            "references": canonical_urls if canonical_urls else []
        })
    except Exception as e:
        print(f"Error in chat endpoint: {str(e)}")
        return jsonify({
            "answer": "I apologize, but I'm having trouble processing your request. Please try again.",
            "references": []
        }), 500


if __name__ == "__main__":
    # Load environment variables
    load_dotenv()

    # Configuration variables
    ES_HOST = os.getenv('ES_HOST')
    ES_API_KEY = os.getenv('ES_API_KEY')
    AZURE_ENDPOINT = os.getenv('AZURE_ENDPOINT')
    AZURE_API_KEY = os.getenv('AZURE_API_KEY')
    AZURE_API_VERSION = os.getenv('AZURE_API_VERSION')
    AIM_API_ENDPOINT = os.getenv('AIM_API_ENDPOINT')
    AIM_API_KEY = os.getenv('AIM_API_KEY')
    AZURE_DEPLOYMENT_NAME = "gpt-35-turbo"
    AIM_MODEL_ID = 9

    # Initialize Elasticsearch client
    es_client = Elasticsearch(
        ES_HOST,
        api_key=ES_API_KEY
    )

    # Initialize Azure OpenAI client
    azure_client = AzureOpenAI(
        azure_endpoint=AZURE_ENDPOINT,
        api_key=AZURE_API_KEY,
        api_version=AZURE_API_VERSION
    )

    # Initialize AIM client
    aim_client = CustomLLM(AIM_API_ENDPOINT, AIM_API_KEY, AIM_MODEL_ID)

    # Elasticsearch index field mapping
    index_source_fields = {
        "on_prem_test": ["body_content"]
    }

    # Start the Flask app
    app.run(debug=True, host="0.0.0.0", port=5000)
