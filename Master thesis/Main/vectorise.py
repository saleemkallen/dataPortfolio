from bs4 import BeautifulSoup
from transformers import AutoTokenizer, AutoModel
import torch
from elasticsearch import Elasticsearch
import os
import numpy as np
from typing import List, Dict
import torch.nn.functional as F

class DocumentEmbedder:
    def __init__(self, model_name: str = 'sentence-transformers/all-MiniLM-L6-v2'):
        """
        Initialize the embedder with a HuggingFace model.
        """
        print(f"Loading model: {model_name}")
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModel.from_pretrained(model_name)
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        print(f"Using device: {self.device}")
        self.model.to(self.device)
        
    def extract_text_from_html(self, html_content: str) -> str:
        """Extract readable text from HTML content"""
        soup = BeautifulSoup(html_content, 'html.parser')
        # Remove script and style elements
        for script in soup(["script", "style"]):
            script.decompose()
        return soup.get_text(separator=' ', strip=True)
    
    def create_embedding(self, text: str) -> np.ndarray:
        """Create embedding for a text using the model"""
        self.model.eval()
        with torch.no_grad():
            inputs = self.tokenizer(text, padding=True, truncation=True, 
                                  max_length=512, return_tensors="pt")
            inputs = {k: v.to(self.device) for k, v in inputs.items()}
            
            outputs = self.model(**inputs)
            
            # Mean pooling
            attention_mask = inputs['attention_mask']
            token_embeddings = outputs.last_hidden_state
            input_mask_expanded = attention_mask.unsqueeze(-1).expand(token_embeddings.size()).float()
            embeddings = torch.sum(token_embeddings * input_mask_expanded, 1) / torch.clamp(input_mask_expanded.sum(1), min=1e-9)
            
            embeddings = F.normalize(embeddings, p=2, dim=1)
            return embeddings[0].cpu().numpy()

class ElasticsearchHandler:
    def __init__(self, url: str, api_key: str):
        """Initialize Elasticsearch connection"""
        self.es = Elasticsearch(
            url,
            api_key=api_key,
            verify_certs=False  # Add this if you have SSL certificate verification issues
        )
        print("Testing Elasticsearch connection...")
        if self.es.ping():
            print("Successfully connected to Elasticsearch")
        else:
            raise ConnectionError("Could not connect to Elasticsearch")
        
    def create_index(self, index_name: str):
        """Create Elasticsearch index with mapping for vectors"""
        mapping = {
            "mappings": {
                "properties": {
                    "content": {"type": "text"},
                    "embedding": {
                        "type": "dense_vector",
                        "dims": 384  # Dimension for all-MiniLM-L6-v2
                    },
                    "filename": {"type": "keyword"}
                }
            }
        }
        if not self.es.indices.exists(index=index_name):
            self.es.indices.create(index=index_name, body=mapping)
            print(f"Created index: {index_name}")
    
    def index_document(self, index_name: str, doc_id: str, document: Dict):
        """Index a document with its embedding"""
        try:
            self.es.index(index=index_name, id=doc_id, body=document)
            print(f"Successfully indexed document: {doc_id}")
        except Exception as e:
            print(f"Error indexing document {doc_id}: {str(e)}")

def process_html_files(directory: str, embedder: DocumentEmbedder, es_handler: ElasticsearchHandler, index_name: str):
    """Process all HTML files in a directory"""
    # Create index if it doesn't exist
    es_handler.create_index(index_name)
    
    # Count total files
    html_files = [f for f in os.listdir(directory) if f.endswith('.html')]
    total_files = len(html_files)
    print(f"Found {total_files} HTML files to process")
    
    # Process each HTML file
    for i, filename in enumerate(html_files, 1):
        file_path = os.path.join(directory, filename)
        print(f"\nProcessing file {i}/{total_files}: {filename}")
        
        try:
            # Read HTML file
            with open(file_path, 'r', encoding='utf-8') as f:
                html_content = f.read()
            
            # Extract text
            text_content = embedder.extract_text_from_html(html_content)
            print(f"Extracted {len(text_content)} characters of text")
            
            # Create embedding
            embedding = embedder.create_embedding(text_content)
            print(f"Created embedding with shape: {embedding.shape}")
            
            # Prepare document
            document = {
                'filename': filename,
                'content': text_content,
                'embedding': embedding.tolist()
            }
            
            # Index document
            es_handler.index_document(index_name, filename, document)
            
        except Exception as e:
            print(f"Error processing {filename}: {str(e)}")

if __name__ == "__main__":
    # Configuration
    HTML_DIR = r" path_to_the_file"
    ES_URL = ES_HOST
    ES_API_KEY = ES_API_KEY
    INDEX_NAME = "html_embeddings"
    
    try:
        # Initialize components
        print("Initializing components...")
        embedder = DocumentEmbedder()
        es_handler = ElasticsearchHandler(ES_URL, ES_API_KEY)
        
        # Process files
        print(f"\nStarting to process files from: {HTML_DIR}")
        process_html_files(HTML_DIR, embedder, es_handler, INDEX_NAME)
        
        print("\nProcessing completed successfully!")
        
    except Exception as e:
        print(f"An error occurred: {str(e)}")
