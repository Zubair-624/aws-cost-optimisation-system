terraform {
    backend "s3" {

        # which S3 bucket to use
        bucket = "zubair-tf-state-project002"

        # which DynamoDB table handles locking
        dynamodb_table = "terraform-state-lock-project002"

        # which AWS region the bucket is in
        region = "us-east-1"

        # filename inside that bucket
        key = "terraform.tfstate"

        # encrypt the state file at rest in S3
        # Make sure the state file is encrypted when it's sitting inside the S3 bucket
        encrypt = true
      
    }
}