from flask import Flask, request, render_template, jsonify
from elasticsearch import Elasticsearch
from transformers import AutoTokenizer, AutoModel
import torch
import torch.nn.functional as F
from dotenv import load_dotenv
import os

app = Flask(__name__)

# Load environment variables from .env file
load_dotenv()

# Elasticsearch Configuration
ES_HOST = "https://8f1e167febbe4037920efd8b721af527.rb-ece.rbesz01.com:9243"
ES_API_KEY = "Vm1XeXpwTUJyYmZqdWZNejBmSlk6Y1ItUGRkVE1TNUNmQTBvNFNZMnZ2UQ=="
VECTOR_INDEX_NAME = "html_embeddings"  # The index we created with vectors

# Initialize Elasticsearch
es_client = Elasticsearch(
    ES_HOST,
    api_key=ES_API_KEY,
    verify_certs=False
)

class EmbeddingGenerator:
    def __init__(self, model_name='sentence-transformers/all-MiniLM-L6-v2'):
        # Explicitly set clean_up_tokenization_spaces to True
        self.tokenizer = AutoTokenizer.from_pretrained(
            model_name, 
            clean_up_tokenization_spaces=True
        )
        self.model = AutoModel.from_pretrained(model_name)
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        self.model.to(self.device)

    def generate_embedding(self, text: str) -> list:
        self.model.eval()
        with torch.no_grad():
            # Add clean_up_tokenization_spaces parameter here as well
            inputs = self.tokenizer(
                text, 
                padding=True, 
                truncation=True, 
                max_length=512, 
                return_tensors="pt",
                clean_up_tokenization_spaces=True
            )
            inputs = {k: v.to(self.device) for k, v in inputs.items()}
            
            outputs = self.model(**inputs)
            
            attention_mask = inputs['attention_mask']
            token_embeddings = outputs.last_hidden_state
            input_mask_expanded = attention_mask.unsqueeze(-1).expand(token_embeddings.size()).float()
            embeddings = torch.sum(token_embeddings * input_mask_expanded, 1) / torch.clamp(input_mask_expanded.sum(1), min=1e-9)
            
            embeddings = F.normalize(embeddings, p=2, dim=1)
            return embeddings[0].cpu().numpy().tolist()

# Initialize the embedding generator
embedding_generator = EmbeddingGenerator()

def get_elasticsearch_results(query):
    """
    Retrieves relevant documents using vector similarity search with improved relevance filtering
    """
    query_vector = embedding_generator.generate_embedding(query)
    
    script_query = {
        "script_score": {
            "query": {"match_all": {}},
            "script": {
                "source": "cosineSimilarity(params.query_vector, 'embedding') + 1.0",
                "params": {"query_vector": query_vector}
            }
        }
    }

    try:
        result = es_client.search(
            index=VECTOR_INDEX_NAME,
            body={
                "size": 3,  # Get more results initially
                "query": script_query,
                "_source": ["content", "filename"],
                "min_score": 1.3  # Minimum relevance score
            }
        )
        
        # Filter and sort by relevance
        hits = result["hits"]["hits"]
        relevant_hits = [hit for hit in hits if hit["_score"] > 1.4]  # Stricter filtering
        
        # Sort by score and return top 3
        relevant_hits.sort(key=lambda x: x["_score"], reverse=True)
        return relevant_hits[:3]
        
    except Exception as e:
        print(f"Error in Elasticsearch query: {str(e)}")
        return []

    try:
        result = es_client.search(
            index=VECTOR_INDEX_NAME,
            body={
                "size": 3,  # Number of results to return
                "query": script_query,
                "_source": ["content", "filename"]  # Fields to return
            }
        )
        
        hits = result["hits"]["hits"]
        return [hit for hit in hits if hit["_score"] > 1.2]  # Filter by similarity threshold
    except Exception as e:
        print(f"Error in Elasticsearch query: {str(e)}")
        return []

def create_llm_prompt(results, question):
    """
    Creates a structured prompt using the vector search results.
    """
    context = ""
    filenames = []

    for hit in results:
        content = hit["_source"].get("content", "")
        context += f"{content}\n"
        filename = hit["_source"].get("filename", "")
        if filename:
            filenames.append(filename)

    prompt = f"""Instructions for processing this data and question:

Data:
{context}

Please follow these rules:
- Be a friendly Bot who greets and treats others politely.
- Read the context carefully and answer the question concisely and accurately.
- Answer ONLY from the given data, DO NOT hallucinate.
- Use the same keywords found in the provided data whenever possible.
- Present the answer in a well-structured markdown format.
- If the requested information is not found in the data, clearly state that.

Question:
{question}"""

    return prompt, filenames

@app.route("/")
def home():
    return render_template("index1.html")

@app.route("/chat", methods=["POST"])
def chat():
    user_query = request.json.get("query")
    try:
        # Handle greetings directly
        lower_query = user_query.lower().strip()
        if lower_query in ['hello', 'hi', 'hey', 'greetings']:
            return jsonify({
                "answer": "Hello! I'm here to help you with any questions. How can I assist you today?",
                "references": []
            })
        
        # Get semantic search results
        elasticsearch_results = get_elasticsearch_results(user_query)
        
        # No results found
        if not elasticsearch_results:
            return jsonify({
                "answer": "I apologize, but I couldn't find any specific information about that in my knowledge base. Could you please rephrase your question?",
                "references": []
            })
        
        # Since we're not using the LLM client anymore, we'll format the response directly
        response = format_response(elasticsearch_results, user_query)
        
        return jsonify({
            "answer": response,
            "references": [hit["_source"].get("filename", "") for hit in elasticsearch_results]
        })

    except Exception as e:
        print(f"Error in chat endpoint: {str(e)}")
        return jsonify({
            "answer": "I apologize, but I'm having trouble processing your request. Please try again.",
            "references": []
        }), 500

def format_response(results, query):
    """
    Format the response based on the search results
    """
    # Get the most relevant result
    top_result = results[0]["_source"]["content"]
    
    # Create a concise response
    response = f"Based on the available information:\n\n{top_result[:500]}..."
    
    return response

if __name__ == "__main__":
    app.run(debug=True)