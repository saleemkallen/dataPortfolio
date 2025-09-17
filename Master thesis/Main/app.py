from flask import Flask, request, render_template, jsonify
import textwrap
from elasticsearch import Elasticsearch
from openai import AzureOpenAI

app = Flask(__name__)

# Elasticsearch client
from elasticsearch import Elasticsearch
from elastic_transport import RequestsHttpNode
from openai import AzureOpenAI
import textwrap
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
from dotenv import load_dotenv
import os


load_dotenv()
ES_HOST = os.getenv('ES_HOST')
ES_API_KEY = os.getenv('ES_API_KEY')
AZRE_ENDPOINT=os.getenv('AZRE_ENDPOINT')
AZURE_API_KEY=os.getenv('AZURE_API_KEY')
AZURE_API_VERSION=os.getenv('AZURE_API_VERSION')

es_client= Elasticsearch(
    ES_HOST,
    api_key=ES_API_KEY
)


client = AzureOpenAI(
    azure_endpoint=AZRE_ENDPOINT,
    api_key=AZURE_API_KEY,
    api_version=AZURE_API_VERSION
)

#AZURE_DEPLOYMENT_NAME = "gpt-4o"
AZURE_DEPLOYMENT_NAME = "gpt-35-turbo"


index_source_fields = {
    "on_prem_test": ["body_content"]
}

def get_elasticsearch_results(query):
    """
    Retrieves relevant documents from Elasticsearch.
    """
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
        "size": 3 #change the size to 1,3,5,10 as per the requirement
    }

    result = es_client.search(index="on_prem_test", body=es_query)
    hits = result["hits"]["hits"]
    return [hit for hit in hits if hit["_source"].get("body_content", "").strip()]

def create_azure_openai_prompt(results):
    context = ""
    canonical_urls = []

    for hit in results:
        source_field = index_source_fields.get(hit["_index"], [])[0]
        hit_context = hit["_source"].get(source_field, "")
        context += f"{hit_context}\n"

        # Append canonical URL if available
        canonical_url = hit["_source"].get("canonical_url", "No URL provided")
        canonical_urls.append(canonical_url)

    prompt = f"""
  Instructions:
  
  - You are an assistant for question-answering tasks.
  - Answer questions truthfully and factually using only the context presented.
  - If you don't know the answer, just say that you don't know, don't make up an answer.
  - You must always cite the document where the answer was extracted using inline academic citation style [], using the position.
  - Use markdown format for code examples.
  - You are correct, factual, precise, and reliable.
  

  Context:
  {context}

  
  """

    return prompt, canonical_urls

def generate_azure_openai_completion(prompt, question):
    try:
        response = client.chat.completions.create(
            model=AZURE_DEPLOYMENT_NAME,
            messages=[
                {"role": "system", "content": prompt},
                {"role": "user", "content": question}
            ],
            temperature=0.0,
            max_tokens=5000,
            top_p=0.95,
            frequency_penalty=0,
            presence_penalty=0,
            stop=None
        )
        return response.choices[0].message.content
    except Exception as e:
        return f"An error occurred: {str(e)}"

@app.route("/")
def home():
    return render_template("index1.html")

@app.route("/chat", methods=["POST"])
def chat():
    user_query = request.json.get("query")  # Get the query from the request JSON
    try:
        # Debug: Print the incoming query
        print("User Query:", user_query)

        # Get results from Elasticsearch
        elasticsearch_results = get_elasticsearch_results(user_query)
        print("Elasticsearch Results:", elasticsearch_results)

        # Create prompt and get canonical URLs
        context_prompt, canonical_urls = create_azure_openai_prompt(elasticsearch_results)
        print("Generated Prompt:", context_prompt)
        print("Canonical URLs:", canonical_urls)

        # Generate response from OpenAI
        answer = generate_azure_openai_completion(context_prompt, user_query)
        print("OpenAI Answer:", answer)

        # Format the answer and references
        wrapped_answer = textwrap.fill(answer, width=80)
        references = "\n".join(canonical_urls)

        # Return JSON response
        return jsonify({
            "answer": wrapped_answer,
            "references": canonical_urls
        })
    except Exception as e:
        # Handle errors and return a JSON error response
        print("Error:", str(e))
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True)

# def main():
#     print("Welcome to the Q&A system. Type 'x' to quit.")

#     while True:
#         question = input("\nEnter your question (or 'x' to quit): ")

#         if question.lower() == 'x':
#             print("\nThank you for using the Q&A system. Goodbye!")
#             break

#         try:
#             elasticsearch_results = get_elasticsearch_results(question)
#             context_prompt = create_azure_openai_prompt(elasticsearch_results)
#             answer = generate_azure_openai_completion(context_prompt, question)

#             print("\nAnswer:")
#             wrapped_answer = textwrap.fill(answer, width=180)
#             print(wrapped_answer)
#         except Exception as e:
#             print(f"\nAn error occurred: {str(e)}")

#         print("\n" + "=" * 80)

# if __name__ == "__main__":
#     main()