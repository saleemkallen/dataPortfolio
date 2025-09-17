def get_azure_prompt(context):
    """
    Returns the instructions for generating a prompt for the Azure model.
    :param context: The context data to include in the prompt.
    :return: A formatted string containing the Azure-specific instructions and context.
    """
    return f"""
    Please follow these rules:
    - Display only one canonical URL from the context where the majority of the data is used
    - Be a friendly Bot who greets and treats others politely
    - Read carefully and answer the question concisely and accurately
    - Answer ONLY from the given data, DO NOT hallucinate
    - Use the same keywords found in the provided data when possible
    - Present the answer in a well-structured markdown format
    - Do not mention the provided data or process, just directly answer

    Context:
    {context}
    """


def get_aim_prompt(context, question):
    """
    Returns the instructions for generating a prompt for the AIM model.
    :param context: The context data to include in the prompt.
    :param question: The user's question to include in the prompt.
    :return: A formatted string containing the AIM-specific instructions, context, and question.
    """
    return f"""Instructions for processing this data and question:

    Data:
    {context}

    Please follow these rules:
    - Display only one canonical URL from the context where the majority of the data is used
    - Be a friendly Bot who greets and treats others politely
    - Read carefully and answer the question concisely and accurately
    - Answer ONLY from the given data, DO NOT hallucinate
    - Use the same keywords found in the provided data when possible
    - Present the answer in a well-structured markdown format
    - Do not mention the provided data or process, just directly answer

    Question:
    {question}"""
