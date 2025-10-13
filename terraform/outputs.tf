output "api_gateway_url" {
  description = "URL of the API Gateway endpoint"
  value       = "https://${aws_api_gateway_rest_api.prediction_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
}

output "api_gateway_predict_url" {
  description = "Full URL for the predict endpoint"
  value       = "https://${aws_api_gateway_rest_api.prediction_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}/predict"
}

output "amplify_app_url" {
  description = "URL of the Amplify hosted application"
  value       = "https://${aws_amplify_branch.main.branch_name}.${aws_amplify_app.insurance_app.default_domain}"
}

output "lambda_deployment_bucket" {
  description = "S3 bucket for Lambda deployment packages"
  value       = aws_s3_bucket.lambda_deployment.id
}

output "amplify_app_id" {
  description = "Amplify App ID"
  value       = aws_amplify_app.insurance_app.id
}

output "frontend_deployment_bucket" {
  description = "S3 bucket for frontend deployment packages"
  value       = aws_s3_bucket.frontend_deploy.id
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table storing predictions"
  value       = aws_dynamodb_table.predictions.name
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.prediction_function.function_name
}

