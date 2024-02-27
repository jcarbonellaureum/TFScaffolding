resource "random_string" "resource_id" {
  length  = 8
  lower   = true
  special = false
  upper   = false
  numeric = false
}

resource "aws_s3_bucket" "terraform_state" {
  bucket            = "tf-state-${random_string.resource_id.result}"
  force_destroy     = true
}

resource "aws_s3_bucket_versioning" "terraform_state_bucket_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_bucket_sse" {
  bucket = aws_s3_bucket.terraform_state.id

   rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name              = "terraform-state-locking-${random_string.resource_id.result}"
  billing_mode      = "PAY_PER_REQUEST"
  hash_key          = "LockID"
  attribute {
    name            = "LockID"
    type            = "S"
  }
}