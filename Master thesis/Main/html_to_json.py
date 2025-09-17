import os
import json
from bs4 import BeautifulSoup
from datetime import datetime

def process_html_file(file_path):
    """
    Extracts data from a single HTML file and organizes it into a structured document.
    :param file_path: Path to the HTML file.
    :return: A dictionary containing extracted data or None if an error occurs.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()

        # Parse HTML content
        soup = BeautifulSoup(content, 'lxml')

        # Extract URL information from canonical tag
        canonical_tag = soup.find('link', rel='canonical')
        canonical_url = canonical_tag['href'] if canonical_tag and canonical_tag.get('href') else "N/A"

        # Extract metadata and content
        title = soup.title.string if soup.title else "N/A"
        meta_description = soup.find('meta', attrs={'name': 'description'})
        meta_keywords = soup.find('meta', attrs={'name': 'keywords'})

        # Extract links
        links = [link.get('href') for link in soup.find_all('a') if link.get('href')]

        # Extract headings
        headings = [tag.text.strip() for tag in soup.find_all(['h1', 'h2', 'h3', 'h4', 'h5', 'h6'])]

        # Extract all text content
        body_content = soup.get_text(strip=True, separator="\n")

        # Prepare document structure
        document = {
            "id": os.path.splitext(os.path.basename(file_path))[0],  # Unique ID based on filename
            "url": canonical_url,
            "canonical_url": canonical_url,
            "url_host": canonical_url.split('/')[2] if "://" in canonical_url else "N/A",
            "url_path": "/" + "/".join(canonical_url.split('/')[3:]) if "://" in canonical_url else "N/A",
            "url_path_dir1": "/" + canonical_url.split('/')[3] if "://" in canonical_url and len(canonical_url.split('/')) > 3 else "N/A",
            "url_path_dir2": "/" + canonical_url.split('/')[4] if "://" in canonical_url and len(canonical_url.split('/')) > 4 else "N/A",
            "url_path_dir3": "/" + canonical_url.split('/')[5] if "://" in canonical_url and len(canonical_url.split('/')) > 5 else "N/A",
            "url_port": "80",  # Adjust if port information is available
            "url_scheme": canonical_url.split(':')[0] if "://" in canonical_url else "N/A",
            "title": title,
            "meta_description": meta_description['content'] if meta_description else "N/A",
            "meta_keywords": meta_keywords['content'] if meta_keywords else "N/A",
            "body_content": body_content,
            "links": links,
            "headings": headings,
            "last_crawled_at": datetime.utcnow().isoformat()
        }

        return document

    except Exception as e:
        print(f"Error processing file {file_path}: {e}")
        return None
        
if __name__ == "__main__":
    """
    Main entry point of the script. Processes HTML files, extracts content,
    and saves the data into a JSON file.
    """
    # Input and output paths
    input_folder = r"Your_path"
    output_file = r"Your_path"
    index_name = "Your_index_name"

    # List to store all documents
    documents = []

    # Process all HTML files in the input folder
    for filename in os.listdir(input_folder):
        if filename.endswith(".html"):
            file_path = os.path.join(input_folder, filename)
            print(f"Processing file: {filename}")

            # Process the HTML file
            document = process_html_file(file_path)

            if document:
                documents.append(document)

    # Prepare the bulk JSON format for Elasticsearch
    bulk_data = []
    for doc in documents:
        bulk_data.append({"index": {"_index": index_name, "_type": "_doc"}})  # Index metadata
        bulk_data.append(doc)

    # Save the data to a single JSON file
    with open(output_file, 'w', encoding='utf-8') as json_file:
        for entry in bulk_data:
            json.dump(entry, json_file, ensure_ascii=False)
            json_file.write('\n')

    print(f"\nAll data has been combined and saved to {output_file}")
