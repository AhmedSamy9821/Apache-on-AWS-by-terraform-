resource "aws_s3_bucket" "remote_state_s3" {
  bucket = "remote-state-s3-bucket"
}
resource "aws_s3_bucket_versioning" "versioning_enabled" {
  bucket = aws_s3_bucket.remote_state_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_dynamodb_table" "lock-dynamodb-table" {
  name           = "Lock_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}


terraform {
  backend "s3" {
    bucket         = "remote-state-s3-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"

    dynamodb_table = "Lock_table"
    encrypt = true
  }
}
