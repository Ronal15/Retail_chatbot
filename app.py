import streamlit as st
import requests
import json
from streamlit.components.v1 import html

# Set page configuration with custom icon and layout
st.set_page_config(
    page_title="Retail Chatbot",
    page_icon="🛍️",
    layout="centered",
    initial_sidebar_state="collapsed"
)

# Custom CSS for styling
st.markdown("""
    <style>
        /* Main background */
        .stApp {
            background: linear-gradient(135deg, #f5f7fa 0%, #e4edf5 100%);
            background-attachment: fixed;
        }
        
        /* Title styling */
        .title-text {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 2.5rem;
            font-weight: 700;
            color: #2c3e50;
            text-align: center;
            margin-bottom: 0.5rem;
            text-shadow: 1px 1px 3px rgba(0,0,0,0.1);
        }
        
        /* Subtitle styling */
        .subtitle-text {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 1.2rem;
            font-weight: 400;
            color: #7f8c8d;
            text-align: center;
            margin-bottom: 2rem;
        }
        
        /* Chat container */
        .chat-container {
            background-color: white;
            border-radius: 20px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            padding: 1.5rem;
            max-height: 60vh;
            overflow-y: auto;
            margin-bottom: 1.5rem;
        }
        
        /* User message bubble */
        .user-message {
            background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);
            color: white;
            border-radius: 18px 18px 0 18px;
            padding: 12px 16px;
            margin: 8px 0;
            max-width: 80%;
            margin-left: auto;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        
        /* Assistant message bubble */
        .assistant-message {
            background: linear-gradient(135deg, #ecf0f1 0%, #dfe6e9 100%);
            color: #2c3e50;
            border-radius: 18px 18px 18px 0;
            padding: 12px 16px;
            margin: 8px 0;
            max-width: 80%;
            margin-right: auto;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        
        /* Chat input */
        .stChatInput {
            background-color: white;
            border-radius: 25px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            padding: 0.5rem 1rem;
        }
        
        /* Footer */
        .footer {
            text-align: center;
            color: #7f8c8d;
            font-size: 0.9rem;
            margin-top: 1.5rem;
        }
    </style>
""", unsafe_allow_html=True)

# Header with title and subtitle
st.markdown('<h1 class="title-text">Retail Chatbot</h1>', unsafe_allow_html=True)
st.markdown('<p class="subtitle-text">A one-stop solution for all your orders, complaints, and recommendations</p>', unsafe_allow_html=True)

rasa_endpoint = "http://localhost:5005/webhooks/rest/webhook"

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = [
        {"role": "assistant", "content": "Hello! I'm your retail assistant. How can I help you today? 😊"}
    ]

# Create a container for the chat messages
chat_container = st.container()

# Display chat messages
with chat_container:
    st.markdown('<div class="chat-container" id="chat-container">', unsafe_allow_html=True)
    
    # Display only the latest messages
    for message in st.session_state.messages:
        if message["role"] == "user":
            st.markdown(f'<div class="user-message">{message["content"]}</div>', unsafe_allow_html=True)
        else:
            st.markdown(f'<div class="assistant-message">{message["content"]}</div>', unsafe_allow_html=True)
    
    st.markdown('</div>', unsafe_allow_html=True)

# Chat input
if prompt := st.chat_input("Type your message here..."):
    # Add only one user message to chat history
    st.session_state.messages.append({"role": "user", "content": prompt})
    
    # Immediately display only the new user message
    with chat_container:
        st.markdown('<div class="chat-container" id="chat-container">', unsafe_allow_html=True)
        
        # Display all messages including the new one
        for message in st.session_state.messages:
            if message["role"] == "user":
                st.markdown(f'<div class="user-message">{message["content"]}</div>', unsafe_allow_html=True)
            else:
                st.markdown(f'<div class="assistant-message">{message["content"]}</div>', unsafe_allow_html=True)
        
        # Add a temporary "thinking" message
        thinking_msg = st.empty()
        thinking_msg.markdown('<div class="assistant-message">Thinking...</div>', unsafe_allow_html=True)
        
        st.markdown('</div>', unsafe_allow_html=True)

    # Get response from Rasa
    payload = {"sender": "user", "message": prompt}
    try:
        response = requests.post(rasa_endpoint, json=payload)
        response.raise_for_status()
        rasa_response = response.json()

        if rasa_response:
            bot_message = rasa_response[0]["text"]
            # Remove the "Thinking..." message
            thinking_msg.empty()
            
            # Add bot response to history
            st.session_state.messages.append({"role": "assistant", "content": bot_message})
            
            # Update chat display with bot response
            with chat_container:
                st.markdown('<div class="chat-container" id="chat-container">', unsafe_allow_html=True)
                for message in st.session_state.messages:
                    if message["role"] == "user":
                        st.markdown(f'<div class="user-message">{message["content"]}</div>', unsafe_allow_html=True)
                    else:
                        st.markdown(f'<div class="assistant-message">{message["content"]}</div>', unsafe_allow_html=True)
                st.markdown('</div>', unsafe_allow_html=True)

        else:
            # Remove the "Thinking..." message
            thinking_msg.empty()
            
            error_msg = "I'm sorry, I didn't understand that. Could you please rephrase?"
            st.session_state.messages.append({"role": "assistant", "content": error_msg})
            
            with chat_container:
                st.markdown('<div class="chat-container" id="chat-container">', unsafe_allow_html=True)
                for message in st.session_state.messages:
                    if message["role"] == "user":
                        st.markdown(f'<div class="user-message">{message["content"]}</div>', unsafe_allow_html=True)
                    else:
                        st.markdown(f'<div class="assistant-message">{message["content"]}</div>', unsafe_allow_html=True)
                st.markdown('</div>', unsafe_allow_html=True)

    except requests.exceptions.RequestException as e:
        # Remove the "Thinking..." message
        thinking_msg.empty()
        
        error_msg = f"Error connecting to chatbot service: {str(e)[:50]}..."
        st.session_state.messages.append({"role": "assistant", "content": error_msg})
        
        with chat_container:
            st.markdown('<div class="chat-container" id="chat-container">', unsafe_allow_html=True)
            for message in st.session_state.messages:
                if message["role"] == "user":
                    st.markdown(f'<div class="user-message">{message["content"]}</div>', unsafe_allow_html=True)
                else:
                    st.markdown(f'<div class="assistant-message">{message["content"]}</div>', unsafe_allow_html=True)
            st.markdown('</div>', unsafe_allow_html=True)

# Footer
st.markdown("""
    <div class="footer">
        <p>Powered by Rasa | Streamlit | PostgreSQL</p>
    </div>
""", unsafe_allow_html=True)

# Scroll to bottom of chat
st.markdown(
    """
    <script>
        // Scroll to bottom of chat container
        function scrollToBottom() {
            const container = document.getElementById('chat-container');
            container.scrollTop = container.scrollHeight;
        }
        
        // Scroll on initial load and after each update
        window.addEventListener('load', scrollToBottom);
        window.addEventListener('DOMContentUpdated', scrollToBottom);
    </script>
    """,
    unsafe_allow_html=True
)