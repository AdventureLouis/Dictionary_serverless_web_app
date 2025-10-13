# DynamoDB Table
resource "aws_dynamodb_table" "predictions" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "prediction_id"

  attribute {
    name = "prediction_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  global_secondary_index {
    name            = "timestamp-index"
    hash_key        = "timestamp"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = "${var.app_name}-predictions"
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.app_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for DynamoDB access
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name = "${var.app_name}-lambda-dynamodb-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.predictions.arn,
          "${aws_dynamodb_table.predictions.arn}/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
  role       = aws_iam_role.lambda_role.name
}

# S3 bucket for Lambda deployment packages
resource "aws_s3_bucket" "lambda_deployment" {
  bucket_prefix = "lambda-deploy-"
}

resource "aws_s3_bucket_versioning" "lambda_deployment_versioning" {
  bucket = aws_s3_bucket.lambda_deployment.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_deployment_encryption" {
  bucket = aws_s3_bucket.lambda_deployment.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lambda function code (simplified)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/simple_lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_deployment.id
  key    = "lambda_function.zip"
  source = data.archive_file.lambda_zip.output_path
  etag   = filemd5(data.archive_file.lambda_zip.output_path)
}

# Lambda function
resource "aws_lambda_function" "prediction_function" {
  s3_bucket        = aws_s3_bucket.lambda_deployment.id
  s3_key           = aws_s3_object.lambda_zip.key
  function_name    = "${var.app_name}-prediction"
  role            = aws_iam_role.lambda_role.arn
  handler         = "simple_lambda_function.lambda_handler"
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.predictions.name
    }
  }

  depends_on = [aws_s3_object.lambda_zip]
}

# API Gateway
resource "aws_api_gateway_rest_api" "prediction_api" {
  name = "${var.app_name}-api"
}

resource "aws_api_gateway_resource" "predict_resource" {
  rest_api_id = aws_api_gateway_rest_api.prediction_api.id
  parent_id   = aws_api_gateway_rest_api.prediction_api.root_resource_id
  path_part   = "predict"
}

resource "aws_api_gateway_method" "predict_method" {
  rest_api_id   = aws_api_gateway_rest_api.prediction_api.id
  resource_id   = aws_api_gateway_resource.predict_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "predict_options" {
  rest_api_id   = aws_api_gateway_rest_api.prediction_api.id
  resource_id   = aws_api_gateway_resource.predict_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.prediction_api.id
  resource_id = aws_api_gateway_resource.predict_resource.id
  http_method = aws_api_gateway_method.predict_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.prediction_function.invoke_arn
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.prediction_api.id
  resource_id = aws_api_gateway_resource.predict_resource.id
  http_method = aws_api_gateway_method.predict_options.http_method

  type = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "predict_response" {
  rest_api_id = aws_api_gateway_rest_api.prediction_api.id
  resource_id = aws_api_gateway_resource.predict_resource.id
  http_method = aws_api_gateway_method.predict_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_method_response" "options_response" {
  rest_api_id = aws_api_gateway_rest_api.prediction_api.id
  resource_id = aws_api_gateway_resource.predict_resource.id
  http_method = aws_api_gateway_method.predict_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.prediction_api.id
  resource_id = aws_api_gateway_resource.predict_resource.id
  http_method = aws_api_gateway_method.predict_options.http_method
  status_code = aws_api_gateway_method_response.options_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_deployment" "prediction_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.options_integration,
    aws_api_gateway_integration_response.options_integration_response,
  ]

  rest_api_id = aws_api_gateway_rest_api.prediction_api.id
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.prediction_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.prediction_api.id
  stage_name    = "prod"
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.prediction_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.prediction_api.execution_arn}/*/*"
}

# S3 bucket for frontend deployment (kept for compatibility)
resource "aws_s3_bucket" "frontend_deploy" {
  bucket_prefix = "amplify-deploy-"
}

# AWS Amplify App
resource "aws_amplify_app" "insurance_app" {
  name = "Insurance Cost Prediction"

  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - echo "No build required for static site"
        build:
          commands:
            - echo "Building static site"
      artifacts:
        baseDirectory: /
        files:
          - '**/*'
  EOT

  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

  environment_variables = {
    API_ENDPOINT = "https://${aws_api_gateway_rest_api.prediction_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
  }
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.insurance_app.id
  branch_name = "main"
  stage       = "PRODUCTION"
}

# Create updated frontend files with correct API endpoint
resource "local_file" "updated_frontend_index" {
  content = templatefile("${path.module}/../frontend/index.html", {
    api_endpoint = "https://${aws_api_gateway_rest_api.prediction_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}/predict"
  })
  filename = "${path.module}/temp_frontend/index.html"
}

resource "local_file" "updated_frontend_result" {
  content  = file("${path.module}/../frontend/result.html")
  filename = "${path.module}/temp_frontend/result.html"
}

# Create updated frontend zip
data "archive_file" "updated_frontend_zip" {
  depends_on = [
    local_file.updated_frontend_index,
    local_file.updated_frontend_result
  ]
  type        = "zip"
  source_dir  = "${path.module}/temp_frontend"
  output_path = "${path.module}/updated_frontend.zip"
}

# Automated Amplify deployment
resource "null_resource" "amplify_deployment" {
  depends_on = [
    aws_amplify_app.insurance_app,
    aws_amplify_branch.main,
    data.archive_file.updated_frontend_zip
  ]

  triggers = {
    frontend_hash = data.archive_file.updated_frontend_zip.output_base64sha256
    api_endpoint  = "https://${aws_api_gateway_rest_api.prediction_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
    app_id        = aws_amplify_app.insurance_app.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e
      echo "Starting Amplify deployment..."
      
      # Stop any running jobs first
      echo "Checking for running jobs..."
      RUNNING_JOBS=$(aws amplify list-jobs \
        --app-id ${aws_amplify_app.insurance_app.id} \
        --branch-name main \
        --region ${var.aws_region} \
        --query 'jobSummaries[?status==`PENDING` || status==`RUNNING`].jobId' \
        --output text 2>/dev/null || echo "")
      
      if [ ! -z "$RUNNING_JOBS" ]; then
        echo "Stopping running jobs: $RUNNING_JOBS"
        for job_id in $RUNNING_JOBS; do
          aws amplify stop-job \
            --app-id ${aws_amplify_app.insurance_app.id} \
            --branch-name main \
            --job-id "$job_id" \
            --region ${var.aws_region} >/dev/null 2>&1 || true
        done
        sleep 3
      fi
      
      # Create deployment and capture output
      DEPLOYMENT_OUTPUT=$(aws amplify create-deployment \
        --app-id ${aws_amplify_app.insurance_app.id} \
        --branch-name main \
        --region ${var.aws_region} 2>/dev/null || echo "failed")
      
      if [ "$DEPLOYMENT_OUTPUT" = "failed" ]; then
        echo "Deployment creation failed, retrying..."
        sleep 5
        DEPLOYMENT_OUTPUT=$(aws amplify create-deployment \
          --app-id ${aws_amplify_app.insurance_app.id} \
          --branch-name main \
          --region ${var.aws_region})
      fi
      
      # Extract upload URL and job ID using jq if available, otherwise use grep
      if command -v jq >/dev/null 2>&1; then
        UPLOAD_URL=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.zipUploadUrl')
        JOB_ID=$(echo "$DEPLOYMENT_OUTPUT" | jq -r '.jobId')
      else
        UPLOAD_URL=$(echo "$DEPLOYMENT_OUTPUT" | grep -o '"zipUploadUrl":"[^"]*' | cut -d'"' -f4)
        JOB_ID=$(echo "$DEPLOYMENT_OUTPUT" | grep -o '"jobId":"[^"]*' | cut -d'"' -f4)
      fi
      
      echo "Job ID: $JOB_ID"
      echo "Uploading frontend files..."
      
      # Upload frontend files with retry
      for i in {1..3}; do
        if curl -X PUT "$UPLOAD_URL" \
          -H "Content-Type: application/zip" \
          --data-binary @${data.archive_file.updated_frontend_zip.output_path} \
          --max-time 30 --retry 2; then
          echo "Upload successful"
          break
        else
          echo "Upload attempt $i failed, retrying..."
          sleep 5
        fi
      done
      
      echo "Starting deployment job..."
      aws amplify start-deployment \
        --app-id ${aws_amplify_app.insurance_app.id} \
        --branch-name main \
        --job-id "$JOB_ID" \
        --region ${var.aws_region}
      
      echo "Amplify deployment initiated successfully!"
    EOT
  }

  # Cleanup on destroy
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${path.module}/temp_frontend ${path.module}/updated_frontend.zip"
  }
}