CREATE EXTENSION aws_s3 CASCADE;
CREATE TABLE air_quality_data (
    location_id INTEGER NOT NULL,
    sensors_id INTEGER NOT NULL,
    location TEXT NOT NULL,
    datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    lat NUMERIC(8, 6) NOT NULL,
    lon NUMERIC(9, 6) NOT NULL,
    parameter VARCHAR(50) NOT NULL,
    units VARCHAR(50) NOT NULL,
    value NUMERIC(10, 2) NOT NULL
);
SELECT aws_s3.table_import_from_s3(
   'air_quality_data',
   '', 
   '(FORMAT csv, HEADER match, DELIMITER '','', QUOTE ''"'', ESCAPE ''\'')',
   '<CUStoM_BUCKET_NAME>', 'records/csv.gz/locationid=2178/year=2022/month=05/location-2178-20220510.csv.gz', 'us-east-1'
);

select * from air_quality_data;