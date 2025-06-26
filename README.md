Tools Needed:
RASA: Version : 3.6.21
PostgreSQL: Version 15
Streamlit: Version: 1.22.0
Python Version: 3.10

FYI: Please note that due to large file, model could not be uploaded.

Install this folder and initialise rasa by switching on your virtual environment.

Follow below commands:

Step 1: py -3.10 -m venv rasa-env
Step 2: .\rasa-env\Scripts\activate
Step 3: echo rasa==3.6.21 > requirements.txt
Step 4: pip install -r .\requirements.txt
Step 5: pip install -r .\requirements.txt
Step 6: pip install rasa
Step 7: rasa --version
$env:Path += ";C:\Users\star\Desktop\chatbot\rasa-env\Scripts"
Step 8: rasa init
Step 9: pip install psycopg2-binary python-dotenv rasa-sdk
Step 10: In the same terminal run below:
rasa shell
Step 11: In a new terminal run below command:
rasa run -p 5005 --enable-api --cors "*"
Step 12: In a new terminal run below command:
streamlit run app.py  
