# RDS - Redshift - Spectrum comparision

This laboratory aims to compare efficiency of different AWS services for data storing and querying. In our case, we choose:
1. Amazon RDS (Relational Database Service)
2. Amazon Redshift
3. Amazon Redshift Spectrum

Laboratory was run on AWS Academy Learner Lab using Terraform and following limitations/settings:

RDS:
- Engine: PostgreSQL
- InstanceType: t4g.medium
- VolumeSize: 50
- EnhancedMonitoring: Disable

Redshift:
- InstanceType: dc2.large

## Setup

You can setup whole infrastructure for the lab using following command:

```
cd ./terraform
terraform init
terraform apply
```

Next you need to update endpoints in load_data.py and run_query.py. Fill them with proper links to databases and your S3 bucket:

```
REDSHIFT_ENDPOINT = "adzd-redshift.csc8zrctvguu.us-east-1.redshift.amazonaws.com"
RDS_ENDPOINT = "adzd-rds.ccysse78nitj.us-east-1.rds.amazonaws.com"
CUSTOM_BUCKET_NAME = "f51ba52c905f32b7876aa129842d4db3dcab06e1"
```

OpenAQ data requires changing content-encoding, so we need to copy it firstly to our own S3 bucket. Unfortunately there were problems with copying data from OpenAQ bucket - you can see commented out section in `terraform/main.tf` from 118 to 138 line. You need to use AWS CLI and command from line 139 (of course replace `${bucket_name}`):

```
aws s3 cp --content-encoding gzip --recursive s3://openaq-data-archive/records/csv.gz/locationid=2178/year=2022/month=05/ s3://${bucket_name}/records/csv.gz/locationid=2178/year=2022/month=05/
```

After that try to install all required libs and execute both Python scripts:

```
python3 -m venv adzd-env
source adzd-env/bin/activate
pip install -r requirements.txt
python3 load_data.py
python3 run_query.py
```

> **WARNING**: in case of errors when creating Spectrum external schema, try to run below part in Amazon Redshift Query Editor:
```
create external schema if not exists myspectrum_schema
from data catalog 
database 'myspectrum_db' 
iam_role 'arn:aws:iam::847382997868:role/LabRole'
create external database if not exists;
COMMIT;
```

## Further modifications

In case you wanted to test some other CSV dataset, adjust scripts in `./SQL` directory. Additionally maybe you won't need any coping to your S3 bucket, because data would have proper encoding by default - then import data directly from public S3 bucket.


> **IMPORTANT**: in case of RDS you need import every single GZIP file separately - that is the reason for that FOREACH loop in `./SQL/rds/sql`.
