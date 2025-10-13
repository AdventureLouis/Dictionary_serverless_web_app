# 🏥 Insurance Cost Prediction - AWS Serverless Web Application

A fully serverless web application that predicts insurance costs using machine learning, built with AWS services and deployed using Infrastructure as Code (Terraform).

## 🌐 Live Demo

**Application URL:** https://main.d1mq5ruhmrrrpg.amplifyapp.com

## 🚀 Features

- **Real-time Predictions**: Instant insurance cost estimates based on user input
- **Responsive Design**: Works seamlessly on desktop and mobile devices
- **Serverless Architecture**: Fully managed AWS infrastructure with automatic scaling
- **Machine Learning**: Random Forest model for accurate cost predictions
- **Data Persistence**: All predictions stored in DynamoDB for analytics

## 🏗️ Architecture

```
Frontend (Amplify) → API Gateway → Lambda Function → DynamoDB
                                      ↓
                               Machine Learning Model
```

### AWS Services Used

- **AWS Amplify** - Frontend hosting and deployment
- **Amazon API Gateway** - REST API endpoint
- **AWS Lambda** - Serverless compute for ML predictions
- **Amazon DynamoDB** - NoSQL database for storing results
- **Amazon S3** - Static asset storage and deployment packages
- **AWS IAM** - Security and access management
- **Terraform** - Infrastructure as Code

## 📊 Input Parameters

- **BMI** (Body Mass Index): 15-60 range
- **Age**: 18-100 years
- **Smoking Status**: 0 (Non-smoker) or 1 (Smoker)

## 🛠️ Project Structure

```
├── frontend/                 # Web application files
│   ├── index.html           # Main interface
│   └── result.html          # Results display
├── lambda/                  # AWS Lambda functions
│   ├── lambda_function.py   # Main prediction logic
│   ├── model_data.py        # ML model implementation
│   └── requirements.txt     # Python dependencies
├── terraform/               # Infrastructure as Code
│   ├── main.tf             # AWS resources definition
│   ├── variables.tf        # Input variables
│   ├── outputs.tf          # Output values
│   └── provider.tf         # AWS provider config
├── Insurance_Cost_Prediction.ipynb  # ML model development
├── insurance_1.csv         # Training dataset
└── deploy.sh              # Deployment script
```

## 🚀 Quick Start

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- Python 3.9+

### Deployment

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Dictionary_serverless_web_app
   ```

2. **Deploy infrastructure**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

3. **Access your application**
   - The deployment script will output your application URL
   - API endpoint will be automatically configured

## 🔧 Manual Deployment

### 1. Deploy AWS Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. Update Frontend Configuration

The API endpoint is automatically configured during deployment.

### 3. Test the Application

Visit the Amplify URL provided in the Terraform outputs.

## 📈 API Usage

### Prediction Endpoint

**POST** `/predict`

```json
{
  "bmi": 25.5,
  "age": 30,
  "New_Smoker": 0
}
```

**Response:**
```json
{
  "predicted_cost": 4500.25,
  "message": "Prediction completed successfully",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

## 🧠 Machine Learning Model

- **Algorithm**: Random Forest
- **Features**: BMI, Age, Smoking Status
- **Training Data**: 1,338 insurance records
- **Preprocessing**: Feature encoding and normalization

## 🔒 Security Features

- **IAM Roles**: Least privilege access for Lambda functions
- **CORS Configuration**: Secure cross-origin requests
- **Input Validation**: Server-side data validation
- **Encrypted Storage**: DynamoDB encryption at rest

## 📊 Monitoring & Analytics

- **CloudWatch Logs**: Lambda function monitoring
- **DynamoDB Metrics**: Database performance tracking
- **API Gateway Metrics**: Request/response monitoring

## 💰 Cost Optimization

- **Serverless Architecture**: Pay only for what you use
- **DynamoDB On-Demand**: Automatic scaling without provisioning
- **Lambda Pricing**: Charged per request and execution time
- **S3 Lifecycle Policies**: Automated cost optimization

## 🔄 CI/CD Pipeline

The project uses Terraform for Infrastructure as Code, enabling:
- **Reproducible Deployments**: Consistent infrastructure across environments
- **Version Control**: Track infrastructure changes
- **Automated Updates**: Easy updates and rollbacks

## 📝 Environment Variables

Key configuration values are managed through Terraform variables:
- AWS region settings
- Resource naming conventions
- Environment-specific configurations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Troubleshooting

### Common Issues

1. **Deployment Fails**: Check AWS credentials and permissions
2. **API Errors**: Verify Lambda function logs in CloudWatch
3. **Frontend Issues**: Check browser console for JavaScript errors

### Support

For issues and questions:
- Check CloudWatch logs for Lambda errors
- Verify API Gateway configuration
- Review Terraform state for infrastructure issues

## 📚 Additional Resources

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Amplify Documentation](https://docs.aws.amazon.com/amplify/)

---

## Architecture
![Architecture](https://github.com/user-attachments/assets/a76ed2a7-ad53-47ef-81db-45dd3f736f2e)
