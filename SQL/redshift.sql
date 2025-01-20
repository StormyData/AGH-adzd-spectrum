CREATE TABLE public.air_quality_data (
    location_id INTEGER NOT NULL,
    sensors_id INTEGER NOT NULL,
    location VARCHAR(255) NOT NULL,
    datetime TIMESTAMP NOT NULL,
    lat NUMERIC(8, 6) NOT NULL,
    lon NUMERIC(9, 6) NOT NULL,
    parameter VARCHAR(50) NOT NULL,
    units VARCHAR(50) NOT NULL,
    value NUMERIC(10, 2) NOT NULL
)
DISTSTYLE KEY -- Use KEY distribution to co-locate data based on location_id
DISTKEY (location_id) -- Distribution key for optimal joins
SORTKEY (datetime);   -- Sort key for efficient time-based queries


COPY public.air_quality_data
FROM 's3://openaq-data-archive/records/csv.gz/locationid=2178/year=2022/month=05/'
IAM_ROLE 'arn:aws:iam::847382997868:role/LabRole'
CSV
GZIP
IGNOREHEADER 1
TIMEFORMAT 'auto';

COMMIT;