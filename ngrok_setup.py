from pyngrok import ngrok
import os
import time

def start_ngrok(port=5005):
    # Terminate existing tunnels
    ngrok.kill()
    
    # Create new HTTP tunnel
    public_url = ngrok.connect(f"http://localhost:5005", bind_tls=True).public_url
    print(f" * Rasa server available at: {public_url}")
    
    # Set environment variable for Streamlit
    os.environ["RASA_ENDPOINT"] = public_url if public_url is not None else ""
    
    return public_url

if __name__ == "__main__":
    ngrok_auth = os.getenv("NGROK_AUTH_TOKEN", "")
    if ngrok_auth:
        ngrok.set_auth_token(ngrok_auth)
    
    start_ngrok()
    # Keep the tunnel open
    while True:
        time.sleep(60)