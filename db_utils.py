# Database connection helper (save as db_utils.py in actions folder)
# Database connection helper (save as db_utils.py in actions folder)
def get_db_connection():
    import os
    from dotenv import load_dotenv
    import psycopg2
    load_dotenv()
    
    return psycopg2.connect(
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT")
    )