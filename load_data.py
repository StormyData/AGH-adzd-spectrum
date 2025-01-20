import time
import psycopg2

REDSHIFT_ENDPOINT = "adzd-redshift.csc8zrctvguu.us-east-1.redshift.amazonaws.com"
RDS_ENDPOINT = "adzd-rds.ccysse78nitj.us-east-1.rds.amazonaws.com"
CUSTOM_BUCKET_NAME = "f51ba52c905f32b7876aa129842d4db3dcab06e1"


def measure_query_time(connection, query):
    start_time = time.time()
    with connection.cursor() as cursor:
        cursor.execute(query)
    execution_time = time.time() - start_time
    return execution_time

def load_query_from_file(file_path):
    with open(file_path, 'r') as file:
        return file.read()
    
spectrum_query = load_query_from_file('./SQL/spectrum.sql')
rds_query = load_query_from_file('./SQL/rds.sql').replace('<CUSTOM_BUCKET_NAME>', CUSTOM_BUCKET_NAME)
redshift_query = load_query_from_file('./SQL/redshift.sql')

# 1. Redshift
redshift_conn = psycopg2.connect(
    dbname='dev',
    user='awsuser',
    password='Adzd1234*',
    host=REDSHIFT_ENDPOINT,
    port=5439
)


# 2. RDS
rds_conn = psycopg2.connect(
    dbname='postgres',
    user='postgres',
    password='Adzd1234*',
    host=RDS_ENDPOINT,
    port=5432 
)

redshift_spectrum_time = measure_query_time(redshift_conn, spectrum_query)
print("Redshift Spectrum Time:", redshift_spectrum_time)
redshift_time = measure_query_time(redshift_conn, redshift_query)
print("Redshift Time:", redshift_time)
rds_time = measure_query_time(rds_conn, rds_query)
print("RDS Time:", rds_time)


redshift_conn.close()
rds_conn.close()
