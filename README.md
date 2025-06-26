Tools Needed:
RASA: Version : 3.6.21
PostgreSQL: Version 15
Streamlit: Version: 1.22.0
Python Version: 3.10

FYI: Please note that due to large file, model could not be uploaded.

Install this folder and initialise rasa by switching on your virtual environment.
Follow below commands:
py -3.10 -m venv rasa-env
.\rasa-env\Scripts\activate
echo rasa==3.6.21 > requirements.txt
pip install -r .\requirements.txt
pip install -r .\requirements.txt
pip install rasa
rasa --version
$env:Path += ";C:\Users\star\Desktop\chatbot\rasa-env\Scripts"
rasa init
pip install psycopg2-binary python-dotenv rasa-sdk
In the same terminal run below:
rasa shell
In a new terminal run below command:
rasa run -p 5005 --enable-api --cors "*"
In a new terminal run below command:
streamlit run app.py  
