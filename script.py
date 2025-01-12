import time
import psycopg2

def measure_query_time(connection, query):
    start_time = time.time()
    with connection.cursor() as cursor:
        cursor.execute(query)
    execution_time = time.time() - start_time
    return execution_time

def load_query_from_file(file_path):
    with open(file_path, 'r') as file:
        return file.read()
    
spectrum_query = load_query_from_file('./SQL/spectrum_query.sql')
query = load_query_from_file('./SQL/query.sql')

# 1. Redshift
redshift_conn = psycopg2.connect(
    dbname='redshift',
    user='awsuser',
    password='Adzd1234*',
    host='your_redshift_endpoint',
    port=5439
)

# 2. RDS
rds_conn = psycopg2.connect(
    dbname='postgres',
    user='postgres',
    password='Adzd1234*',
    host='your_rds_endpoint',
    port=5432 
)

# 3. Redshift Spectrum 

redshift_spectrum_time = measure_query_time(redshift_conn, spectrum_query)
print("Redshift Spectrum Time:", redshift_spectrum_time)
redshift_time = measure_query_time(redshift_conn, query)
print("Redshift Time:", redshift_time)
rds_time = measure_query_time(rds_conn, query)
print("RDS Time:", rds_time)

redshift_conn.close()
rds_conn.close()