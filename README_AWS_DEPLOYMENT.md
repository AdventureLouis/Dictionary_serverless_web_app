# Insurance Cost Prediction - AWS Deployment

This project deploys your Insurance Cost Prediction machine learning model to AWS using Terraform, creating a complete serverless architecture with automated AWS Amplify hosting.

## 🏗️ Architecture Overview

The deployment creates the following AWS resources:

- **AWS Lambda**: Hosts your prediction algorithm for real-time predictions
- **API Gateway**: REST API with CORS enabled for frontend communication
- **DynamoDB**: Stores all prediction results with timestamps and recovery
- **AWS Amplify**: Automated frontend hosting with CI/CD pipeline
- **S3 Buckets**: Lambda deployment packages and frontend staging
- **IAM Roles & Policies**: Secure access controls with least-privilege

## 📋 Prerequisites

Before deploying, ensure you have:

1. **AWS CLI** installed and configured
   ```bash
   aws configure
   ```

2. **Terraform** installed (version >= 1.0)
   ```bash
   # macOS
   brew install terraform
   
   # Or download from: https://www.terraform.io/downloads
   ```

3. **Python 3.9+** with pip
4. **AWS Account** with appropriate permissions

## 🚀 Quick Deployment

### Fully Automated Deployment

Deploy everything with a single command:

```bash
cd terraform
terraform init
terraform apply
```

This will automatically:
- Create AWS Amplify app with automated deployment
- Upload Lambda function code to S3
- Deploy Lambda function from S3 (no size limits)
- Package and deploy frontend files to Amplify
- Configure API Gateway with CORS
- Set up DynamoDB with point-in-time recovery
- Inject API endpoints into frontend automatically
- Output live application URL for immediate use

## 📁 Project Structure

```
├── terraform/
│   ├── provider.tf          # Terraform & AWS provider configuration
│   ├── variables.tf         # Input variables & defaults
│   ├── main.tf              # Main infrastructure resources
│   ├── outputs.tf           # Output values & URLs
│   ├── lambda_function.zip  # Generated Lambda package
│   └── frontend.zip         # Generated frontend package
├── lambda/
│   ├── simple_lambda_function.py # Lightweight prediction algorithm
│   ├── lambda_function.py   # Original ML model (backup)
│   ├── model_data.py        # Model training data
│   ├── requirements.txt     # Python dependencies
│   └── deployment_package/  # Heavy ML dependencies (unused)
├── frontend/
│   ├── index.html          # Modern prediction interface
│   └── result.html         # Results display page
├── deploy.sh               # Legacy deployment script (optional)
├── Insurance_Cost_Prediction.ipynb # Jupyter notebook
├── insurance_1.csv         # Training data
├── ARCHITECTURE.md         # System architecture documentation
├── AMPLIFY_DEPLOYMENT.md   # Amplify deployment guide
├── AWS_SERVICES_ARCHITECTURE.md # AWS services topology
└── README_AWS_DEPLOYMENT.md # This file
```

## 🎯 Features

### Prediction Algorithm
- **Lightweight prediction model** optimized for serverless deployment
- **Mathematical algorithm** based on BMI, age, and smoking factors
- **Input validation** for BMI (15-60), Age (18-100), Smoking Status (0/1)
- **Real-time predictions** via serverless Lambda
- **No heavy ML dependencies** for fast cold starts

### Modern Web Interface
- **Responsive design** that works on all devices
- **Gradient backgrounds** and modern UI components
- **Real-time validation** and error handling
- **Loading states** and success animations
- **Accessible design** with proper ARIA labels

### Data Storage
- **DynamoDB integration** stores all predictions in "Prediction_Table"
- **Unique prediction IDs** for tracking
- **Timestamps** for audit trails
- **Point-in-time recovery** enabled for data protection
- **Scalable** pay-per-request billing

### AWS Amplify Integration
- **Automated frontend deployment** with CI/CD pipeline
- **Global CDN** for fast content delivery
- **SSL certificates** automatically provisioned
- **Environment variable injection** for API endpoints
- **Build and deployment automation** via Terraform
- **No manual deployment steps** required

### S3 Integration
- **Lambda deployment bucket** with versioning and encryption
- **Frontend staging bucket** for Amplify deployment
- **Automated package uploads** via Terraform

## 🔧 Configuration

### Environment Variables

The Lambda function uses these environment variables:
- `DYNAMODB_TABLE`: Name of the DynamoDB table (auto-configured)

### API Endpoints

After deployment, you'll have:
- **Prediction API**: `POST /predict`
- **CORS enabled** for web browser access

### Input Format

Send POST requests to `/predict` with:
```json
{
  "bmi": 25.5,
  "New_Smoker": 0,
  "age": 30
}
```

### Response Format

```json
{
  "prediction_id": "uuid-string",
  "predicted_cost": 5234.56,
  "message": "A policy holder with BMI 25.5, smoker status 0, and age 30 will incur insurance cost of $5,234.56",
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

## 🌐 Frontend Access

### Automated Amplify Hosting

The frontend is automatically deployed to AWS Amplify with global CDN and SSL. After running `terraform apply`, access your application using the `amplify_app_url` output.

**Live Application URL:**
```bash
terraform output amplify_app_url
```

### Local Testing (Optional)

```bash
cd frontend
python -m http.server 8000
# Visit http://localhost:8000
```

## 📊 Monitoring & Logs

- **CloudWatch Logs**: Lambda function logs
- **API Gateway Metrics**: Request/response metrics
- **DynamoDB Metrics**: Read/write capacity and throttling

## 💰 Cost Estimation

This serverless architecture is very cost-effective:

- **Lambda**: ~$0.20 per 1M requests
- **API Gateway**: ~$3.50 per 1M requests
- **DynamoDB**: Pay-per-request (very low for typical usage)
- **Amplify Hosting**: ~$0.15 per GB served + $0.01 per build minute
- **S3 Storage**: ~$0.023 per GB/month for deployment packages
- **CloudWatch**: Minimal logging costs

**Estimated Monthly Cost: $5-15 for moderate usage**

## 🔒 Security Features

- **IAM roles** with least-privilege access
- **CORS configuration** for secure browser access
- **Input validation** to prevent malicious data
- **Error handling** without exposing sensitive information

## 🧪 Testing

Test your API endpoint:

```bash
curl -X POST https://your-api-gateway-url/predict \
  -H "Content-Type: application/json" \
  -d '{
    "bmi": 25.5,
    "New_Smoker": 0,
    "age": 30
  }'
```

## 🔄 Updates & Maintenance

To update your model or frontend:

1. **Update Lambda**: Modify `lambda/simple_lambda_function.py` and run `terraform apply`
2. **Update Frontend**: Modify files in `frontend/` and run `terraform apply` (auto-deploys to Amplify)
3. **Update Infrastructure**: Modify Terraform files and run `terraform apply`
4. **Update Variables**: Modify `terraform/variables.tf` for configuration changes
5. **CI/CD Updates**: Connect GitHub repository for automatic deployments

## 🆘 Troubleshooting

### Common Issues

1. **"Access Denied" errors**: Check AWS credentials and permissions
2. **Lambda timeout**: Increase timeout in `terraform/variables.tf`
3. **CORS errors**: Ensure API Gateway CORS is properly configured
4. **Frontend not loading**: Check Amplify build logs and deployment status
5. **API connection issues**: Verify environment variables in Amplify
6. **Build failures**: Check Amplify Console for detailed build logs

### Useful Commands

```bash
# Check Terraform state
terraform show

# View Lambda logs
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/insurance"

# Test API Gateway
curl -X POST $(terraform output -raw api_gateway_predict_url) \
  -H "Content-Type: application/json" \
  -d '{"bmi": 25.5, "New_Smoker": 0, "age": 30}'

# Check Amplify deployment status
aws amplify list-jobs --app-id $(terraform output -raw amplify_app_id) --branch-name main

# View Amplify app details
aws amplify get-app --app-id $(terraform output -raw amplify_app_id)
```

## 🧹 Cleanup

To remove all resources:

```bash
cd terraform
terraform destroy
```

## 📞 Support

If you encounter issues:

1. Check the deployment logs
2. Verify AWS credentials and permissions
3. Ensure all prerequisites are installed
4. Review the Terraform plan before applying

## 📊 Terraform Outputs

After deployment, you'll receive:
- `api_gateway_url`: Base API Gateway URL
- `api_gateway_predict_url`: Direct prediction endpoint URL
- `amplify_app_url`: Live Amplify application URL
- `amplify_app_id`: Amplify App ID for CLI operations
- `dynamodb_table_name`: DynamoDB table name
- `lambda_function_name`: Lambda function name
- `lambda_deployment_bucket`: S3 bucket for Lambda packages
- `frontend_deployment_bucket`: S3 bucket for frontend staging

---

## 🏗️ AWS Services Used

| Service | Purpose | Configuration |
|---------|---------|---------------|
| **AWS Amplify** | Frontend hosting & CI/CD | Global CDN, SSL, automated builds |
| **AWS Lambda** | Serverless compute | Python 3.11, 512MB, 30s timeout |
| **API Gateway** | REST API endpoint | CORS enabled, prod stage |
| **DynamoDB** | NoSQL database | Pay-per-request, point-in-time recovery |
| **S3** | Storage (2 buckets) | Lambda deployment, frontend staging |
| **IAM** | Security & access | Roles, policies, least-privilege |
| **CloudWatch** | Monitoring & logs | Lambda logs, API metrics |

**Total: 7 AWS Services, 13+ Resources**

---

**🎉 Congratulations!** Your Insurance Cost Prediction app is now deployed on AWS with enterprise-grade scalability, security, and automated Amplify hosting with global CDN!