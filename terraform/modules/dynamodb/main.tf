#--------------------------------------------------------------------------
# CostGuard - DynamoDB Module
# Creates 3 tables:
# 1. cost_data -> Daily AWS costs for each AWS service from Cost Explorer
# 2. anomalies -> Unusual or unexpected cost increases flagged for alerting
# 3. recommendations -> Cost-saving suggestions for EC2 instances from CloudWatch
#--------------------------------------------------------------------------

#----------Table 1: Cost Data----------
# This is the heart of the project
# Stores daily AWS costs from Cost Explorer
# This is the main historical cost data. It grows every day
resource "aws_dynamodb_table" "cost_data" {

  #-----Table Details-----
  name = "${var.project_name}_cost_data" # e.g. costguard_cost_data

  #-----Keys-----
  # partition key: AWS service name e.g. "Amazon EC2"
  hash_key  = "service" 
  attribute {
    name = "service"
    type = "S"
  }

  # sort key: date the cost was recorded e.g. "2025-06-28"
  range_key = "date"                      
  attribute {
    name = "date"
    type = "S"
  }


  #-----Table Class-----
  table_class = "STANDARD"

  #-----Billing-----
  # No capacity planning needed; pay per read/write
  billing_mode = "PAY_PER_REQUEST"

  #-----Encryption at Rest-----
  # Encrypts all data using AWS-managed key (free)
  server_side_encryption {
    enabled = true
  }

  #-----TTL: auto-delete records older than 90 days-----
  # Lambda writes a Unix epoch timestamp into ttl_expire field
  # DynamoDB automatically deletes the item when that time passes
  ttl {
    attribute_name = "ttl_expire"
    enabled        = true
  }

  #-----Deletion Protection-----
  # Prevents accidental terraform destroy wiping all cost history
  deletion_protection_enabled = true

  tags = {
    Name = "${var.project_name}_cost_data"
  }

}

#----------Table 2: Anomalies----------
# An anomaly means something unusual happened to costs
# The system stores anomalies so we know what needs attention
resource "aws_dynamodb_table" "anomalies" {

  #-----Table Details-----
  name = "${var.project_name}_anomalies" # e.g. costguard_anomalies

  #-----Keys-----
  # partition key: unique ID per anomaly event (UUID)
  hash_key  = "anomaly_id"    
  attribute {
    name = "anomaly_id"
    type = "S"
  }
  
  # sort key: ISO timestamp when spike was detected               
  range_key = "detected_at"               
  attribute {
    name = "detected_at"
    type = "S"
  }

  #-----Table Class-----
  table_class = "STANDARD"

  #-----Billing-----
  billing_mode = "PAY_PER_REQUEST"

  #-----Encryption at Rest-----
  server_side_encryption {
    enabled = true
  }

  #-----TTL-----
  # Auto-expire anomaly records after 90 days
  ttl {
    attribute_name = "ttl_expire"
    enabled        = true
  }

  #-----Deletion Protection-----
  deletion_protection_enabled = true

  tags = {
    Name = "${var.project_name}_anomalies"
  }

}

#----------Table 3: Recommendations----------
# Stores suggestions to save money on EC2 instances
# Recommendations are based on CloudWatch CPU monitoring data
resource "aws_dynamodb_table" "recommendations" {

  #-----Table Details-----
  name = "${var.project_name}_recommendations"  # e.g. costguard_recommendations

  #-----Keys-----
  # partition key: EC2 instance ID e.g. "i-0abc123"
  hash_key  = "resource_id"      
  attribute {
    name = "resource_id"
    type = "S"
  }


  # sort key: timestamp the recommendation was created
  range_key = "created_at"                      
  attribute {
    name = "created_at"
    type = "S"
  }

  #-----Table Class-----
  table_class = "STANDARD"

  #-----Billing-----
  billing_mode = "PAY_PER_REQUEST"

  #-----Encryption at Rest-----
  server_side_encryption {
    enabled = true
  }

  #-----TTL-----
  # Auto-expire old recommendations after 90 days
  ttl {
    attribute_name = "ttl_expire"
    enabled        = true
  }

  #-----Deletion Protection-----
  deletion_protection_enabled = true

  tags = {
    Name = "${var.project_name}_recommendations"
  }

}