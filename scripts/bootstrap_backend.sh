#!/bin/bash

#-----Stop the script immediately when an error occurs-----
set -euo pipefail

#----------Section 1: Config/Configuration----------
AWS_PROFILE="zubair-devops"
AWS_REGION="us-east-1"

BUCKET_NAME="zubair-tf-state-project002"
DYNAMODB_NAME="terraform-state-lock-project002"

#----------Section 2: S3 Bucket----------

#-----General Configuration: Box-----
echo "----- [S3] Creating S3 Bucket: ${BUCKET_NAME}-----"
aws s3api create-bucket \
    --bucket "${BUCKET_NAME}" \
    --region "${AWS_REGION}" \
    --profile "${AWS_PROFILE}" 

#-----Block Public Access settings for this bucket-----
echo "----- [S3] Blocking All Public Access-----"
aws s3api put-public-access-block \
    --bucket "${BUCKET_NAME}" \
    --public-access-block-configuration \
    '{"BlockPublicAcls":true, "BlockPublicPolicy":true, "IgnorePublicAcls":true, "RestrictPublicBuckets":true}' \
    --region "${AWS_REGION}" \
    --profile "${AWS_PROFILE}"

#-----Bucket Versioning-----
echo "----- [S3] Bucker Version Enable-----"
aws s3api put-bucket-versioning \
    --bucket "${BUCKET_NAME}" \
    --versioning-configuration Status=Enabled \
    --region "${AWS_REGION}" \
    --profile "${AWS_PROFILE}"

#-----Default encryption: Box-----
echo "-----Default Encryption(SSE-S3) Enable-----"
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}' \
    --region "${AWS_REGION}" \
    --profile "$AWS_PROFILE"    

#---------------Section 3: DynamoDB Table---------------    

#-----Table details: Box-----
echo "----- [DynamoDB] Creating DynamoDB Table: ${DYNAMODB_NAME}-----"
aws dynamodb create-table \
    --table-name "${DYNAMODB_NAME}" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "${AWS_REGION}" \
    --profile "${AWS_PROFILE}"

#---
# Click -> [Create table]
#---

# Wait for DynamoDB to confirm the table is ready before continuing.
# Stop waiting after 60 seconds to avoid the script getting stuck forever.
echo "----- [DynamoDB] Waiting for table to become active-----"
timeout 60 aws dynamodb wait table-exists \
    --table-name "${DYNAMODB_NAME}" \
    --region "${AWS_REGION}" \
    --profile "${AWS_PROFILE}"

#---------------Section 4: Confirmation Output---------------    
echo "--------------------------------------------------"
echo "Bootstrap Successfully Complete"
echo "S3 Bucket: ${BUCKET_NAME}"
echo "DynamoDB Table: ${DYNAMODB_NAME}"
echo "Region: ${AWS_REGION}"
echo "AWS Profile: ${AWS_PROFILE}"
echo "--------------------------------------------------"