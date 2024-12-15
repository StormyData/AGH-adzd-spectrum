create external schema myspectrum_schema 
from data catalog 
database 'myspectrum_db' 
iam_role 'arn:aws:iam::847382997868:role/LabRole'
create external database if not exists;

create external table myspectrum_schema.air_quality_data (
    _location_id INTEGER,
    sensors_id INTEGER,
    location VARCHAR(255),
    datetime TIMESTAMP,
    lat NUMERIC(8, 6),
    lon NUMERIC(9, 6),
    parameter VARCHAR(50),
    units VARCHAR(50),
    value NUMERIC(10, 2)
)
PARTITIONED BY (location_id INTEGER, year INTEGER, month INTEGER)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3://openaq-data-archive/records/csv.gz/';


alter table myspectrum_schema.air_quality_data add
partition(location_id=2178, year=2022, month=05) 
location 's3://openaq-data-archive/records/csv.gz/locationid=2178/year=2022/month=05/';