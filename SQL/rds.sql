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
-- SELECT aws_s3.table_import_from_s3(
--    'air_quality_data',
--    '', 
--    '(FORMAT csv, HEADER match, DELIMITER '','', QUOTE ''"'', ESCAPE ''\'')',
--    '<CUStoM_BUCKET_NAME>', 'records/csv.gz/locationid=2178/year=2022/month=05/location-2178-20220510.csv.gz', 'us-east-1'
-- );


DO $$
DECLARE
    file_endings TEXT[] := ARRAY['03', '05', '07', '09', '10', '11', '12', '13', '14', '16', '17', '18', '19' ,'21', '24', '25', '26', '27', '28', '30', '31'];
    file_ending TEXT;
    s3_path TEXT;
BEGIN
    FOREACH file_ending IN ARRAY file_endings
    LOOP
        s3_path := FORMAT(
            'records/csv.gz/locationid=2178/year=2022/month=05/location-2178-202205%s.csv.gz',
            file_ending
        );

        -- Import pliku z podanym zakończeniem
        EXECUTE $a$ 
            SELECT aws_s3.table_import_from_s3(
                'air_quality_data',
                '', 
                '(FORMAT csv, HEADER match, DELIMITER '','', QUOTE ''"'', ESCAPE ''\'')',
                '<CUSTOM_BUCKET_NAME>', $1, 'us-east-1'
            ) 
        $a$ USING s3_path;

        -- Opcjonalnie: logowanie postępu
        RAISE NOTICE 'Zaimportowano plik: %', s3_path;
    END LOOP;
END $$;