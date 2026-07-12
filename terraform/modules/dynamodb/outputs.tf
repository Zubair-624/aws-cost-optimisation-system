#----------Cost Data Table----------

# Name of the cost_data table - passed to Lambda as TABLE_NAME_COST_DATA env variable
output "cost_data_table_name" {
  value = aws_dynamodb_table.cost_data.name
}

# ARN of the cost_data table - used in IAM policy to grant Lambda read/write access
output "cost_data_table_arn" {
  value = aws_dynamodb_table.cost_data.arn
}

#----------Anomalies Table----------

# Name of the anomalies table - passed to Lambda as TABLE_NAME_ANOMALIES env variable
output "anomalies_table_name" {
  value = aws_dynamodb_table.anomalies.name
}

# ARN of the anomalies table - used in IAM policy to grant Lambda read/write access
output "anomalies_table_arn" {
  value = aws_dynamodb_table.anomalies.arn
}

#----------Recommendations Table----------

# Name of the recommendations table - passed to Lambda as TABLE_NAME_RECOMMENDATIONS env variable
output "recommendations_table_name" {
  value = aws_dynamodb_table.recommendations.name
}

# ARN of the recommendations table - used in IAM policy to grant Lambda read/write access
output "recommendations_table_arn" {
  value = aws_dynamodb_table.recommendations.arn
}