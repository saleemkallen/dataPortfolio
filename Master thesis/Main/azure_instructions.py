def get_llm_prompt(context, question):
    """
    Returns a structured LLM prompt.
    :param context: The context data extracted from Elasticsearch.
    :param question: The user's question.
    :return: A formatted string containing instructions and the context.
    """
    return f"""Instructions for processing this data and question:

    Data:
    {context}

    - Be a friendly Bot who greets and treats others politely.
    - Read carefully and answer the question concisely and accurately.
    - Answer ONLY from the data given, please DO NOT hallucinate.
    - Use the same keywords found in the provided data when possible.
    - Present the answer in a well-structured markdown format.
    - Clearly state if information is not found in the data.
    
    Question:
    {question}"""
