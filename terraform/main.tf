terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.42.0"
    }
    random = {
        source = "hashicorp/random"
        version = ">=3.6.3"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
data "aws_vpc" "this" {
  default = true
}

data "aws_subnets" "this" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}
data "aws_iam_role" "this" {
  name = "LabRole"
}

resource "aws_db_subnet_group" "this" {
  name = "adzd-rds"
  subnet_ids = data.aws_subnets.this.ids
}

resource "aws_security_group" "rds" {
  name = "adzd-rds"

  vpc_id = data.aws_vpc.this.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port  = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  allocated_storage                     = 50
  backup_retention_period               = 0
  db_subnet_group_name                  = aws_db_subnet_group.this.name
  deletion_protection                   = false
  engine                                = "postgres"
  engine_version                        = "16.3"
  identifier                            = "adzd-rds"
  instance_class                        = "db.t4g.medium"
  multi_az                              = false
  password                              = "Adzd1234*"
  port                                  = 5432
  publicly_accessible                   = true
  skip_final_snapshot                   = true
  storage_encrypted                     = true
  storage_type                          = "gp2"
  username                              = "postgres"
  vpc_security_group_ids                = [aws_security_group.rds.id]
}

resource "aws_db_instance_role_association" "this" {
    db_instance_identifier = aws_db_instance.this.identifier
    feature_name           = "s3Import"
    role_arn               = data.aws_iam_role.this.arn
}


resource "aws_redshift_cluster" "this" {
  cluster_identifier = "adzd-redshift"
  database_name      = "redshift"
  master_username    = "awsuser"
  master_password    = "Adzd1234*"
  node_type          = "dc2.large"
  cluster_type       = "multi-node"
  port               = 5439
  number_of_nodes    = 2
  skip_final_snapshot = true
  default_iam_role_arn = data.aws_iam_role.this.arn
  iam_roles = [data.aws_iam_role.this.arn]
}

resource "random_id" "name" {
  byte_length = 20
}

resource "aws_s3_bucket" "this" {
    bucket = random_id.name.hex
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# resource "aws_s3_bucket_object" "name" {
  
# }

data "aws_s3_objects" "this" {
  bucket = "openaq-data-archive"
  prefix = "records/csv.gz/locationid=2178/year=2022/month=05/"
}

resource "aws_s3_object_copy" "this" {
  for_each = toset(data.aws_s3_objects.this.keys)

  bucket = aws_s3_bucket.this.bucket
  key    = each.value
  source = "openaq-data-archive/${each.value}"

  acl = "bucket-owner-full-control"

  content_encoding = "gzip"
}

output "custom_bucket_name" {
  value = aws_s3_bucket.this.bucket
}