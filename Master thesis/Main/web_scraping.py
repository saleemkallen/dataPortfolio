import os
import time
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
import hashlib

# Function to check if a URL should be processed
def should_process_url(url, prefix):
    """
    Checks if a URL should be processed based on the prefix.
    :param url: The URL to check.
    :param prefix: The required prefix for valid URLs.
    :return: True if the URL starts with the prefix, False otherwise.
    """
    return isinstance(url, str) and url.startswith(prefix)

# Function to generate a safe filename
def get_safe_filename(url):
    """
    Generates a sanitized, safe filename for a given URL.
    :param url: The URL to convert into a filename.
    :return: A sanitized filename string.
    """
    name = url.split('/')[-1]  # Extract the last part of the URL
    if not name:  # Generate a hash-based name if no name exists
        name = hashlib.md5(url.encode()).hexdigest()
    return ''.join(c for c in name if c.isalnum() or c in '._-')[:50]  # Sanitize the filename

# Function to save a webpage locally
def save_page_locally(url, output_dir, driver):
    """
    Saves the HTML content of a webpage locally.
    :param url: The URL to save.
    :param output_dir: The directory where the file will be saved.
    :param driver: The Selenium WebDriver instance.
    :return: True if the page was saved successfully, False otherwise.
    """
    try:
        print(f"Saving page: {url}")
        driver.get(url)  # Navigate to the URL
        time.sleep(5)  # Wait for the page to load

        # Save the HTML content
        html_content = driver.page_source

        # Add the canonical URL in a <link> tag inside the <head> section
        canonical_tag = f'<link rel="canonical" href="{url}">\n'
        if "<head>" in html_content:
            html_content_with_canonical = html_content.replace("<head>", f"<head>\n{canonical_tag}", 1)
        else:
            html_content_with_canonical = f"<head>\n{canonical_tag}</head>\n" + html_content
        
        # Generate a safe filename
        safe_filename = url.replace(":", "_").replace("/", "_").replace("?", "_").replace("#", "_") + ".html"
        file_path = os.path.join(output_dir, safe_filename)

        # Write the HTML content with the canonical URL to the file
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(html_content_with_canonical)

        print(f"Saved HTML with canonical URL: {file_path}")
        return True

    except Exception as e:
        print(f"Error saving page {url}: {str(e)}")
        return False

# Function to get all links from the current page
def get_all_links(driver, pdf_links):
    """
    Extracts all links and PDF links from the current page.
    :param driver: The Selenium WebDriver instance.
    :param pdf_links: A set to store discovered PDF links.
    :return: A set of non-PDF links from the page.
    """
    links = set()
    elements = driver.find_elements(By.XPATH, "//a | //*[@onclick] | //*[@role='button']")
    
    for element in elements:
        try:
            href = element.get_attribute("href")
            if href:
                if href.lower().endswith('.pdf'):
                    pdf_links.add(href)  # Store PDF links
                else:
                    links.add(href)
                continue

            # For clickable elements without href, simulate a click
            element.click()
            time.sleep(1)
            
            current_url = driver.current_url
            if not current_url.lower().endswith('.pdf'):
                links.add(current_url)
            driver.back()  # Navigate back
            time.sleep(1)
                
        except:
            continue  # Ignore elements that cannot be clicked
    
    return links

# Recursive function to scrape process pages
def scrape_process_pages(url, driver, output_dir, process_url_prefix, visited_links, pdf_links, depth=0, max_depth=10):
    """
    Recursively processes pages, saves their content, and follows their links.
    :param url: The URL to process.
    :param driver: The Selenium WebDriver instance.
    :param output_dir: Directory to save pages.
    :param process_url_prefix: The URL prefix to filter links.
    :param visited_links: A set of already visited links.
    :param pdf_links: A set to store discovered PDF links.
    :param depth: Current recursion depth.
    :param max_depth: Maximum allowed recursion depth.
    """
    if not should_process_url(url, process_url_prefix) or url in visited_links or depth > max_depth:
        return  # Stop processing if the URL is invalid or already visited
    
    print(f"\nProcessing page {len(visited_links) + 1}: {url}")
    visited_links.add(url)
    
    try:
        save_page_locally(url, output_dir, driver)  # Save the current page
        links = get_all_links(driver, pdf_links)  # Extract links from the page
        print(f"Found {len(links)} links on {url}")
        
        for link in links:  # Recursively process links
            if link not in visited_links:
                scrape_process_pages(link, driver, output_dir, process_url_prefix, visited_links, pdf_links, depth + 1, max_depth)
                
    except Exception as e:
        print(f"Error processing {url}: {str(e)}")

# Main execution
if __name__ == "__main__":
    # Configuration parameters
    main_url = "https://stages.bshg.com/stages/#/workspace/672/_vv/process/process/_T6T_EGunui6o7fnsxSZL2g"
    process_url_prefix = "https://stages.bshg.com/stages/#/workspace/672/_vv/process/"
    output_dir = r"your_path"
    pdf_links_file = os.path.join(output_dir, "pdf_links.txt")
    visited_links = set()
    pdf_links = set()
    
    os.makedirs(output_dir, exist_ok=True)  # Ensure output directory exists
    
    # Set up Selenium WebDriver
    options = webdriver.ChromeOptions()
    options.add_argument("--start-maximized")
    options.add_argument("--disable-popup-blocking")
    options.add_argument("--disable-notifications")
    service = Service(r"C:\Program Files (x86)\chromedriver-win64\chromedriver.exe")
    driver = webdriver.Chrome(service=service, options=options)
    
    try:
        # Start scraping
        scrape_process_pages(main_url, driver, output_dir, process_url_prefix, visited_links, pdf_links)
        
        # Save processed URLs and PDF links
        with open(os.path.join(output_dir, "processed_urls.txt"), "w", encoding="utf-8") as f:
            for url in visited_links:
                f.write(f"{url}\n")
        
        with open(pdf_links_file, "w", encoding="utf-8") as f:
            for url in pdf_links:
                f.write(f"{url}\n")
        
        print(f"\nTotal pages processed: {len(visited_links)}")
        print(f"PDF links found: {len(pdf_links)}")
        print(f"Pages saved to: {output_dir}")
        
    finally:
        driver.quit()  # Ensure WebDriver is closed
