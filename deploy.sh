#!/bin/bash

# Insurance Cost Prediction AWS Deployment Script
# This script deploys the complete infrastructure using Terraform

set -e

echo "🚀 Starting Insurance Cost Prediction Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_requirements() {
    print_status "Checking requirements..."
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_success "All requirements met!"
}

# Prepare Lambda deployment package
prepare_lambda() {
    print_status "Preparing Lambda deployment package..."
    
    cd lambda
    
    # Create a temporary directory for the deployment package
    rm -rf deployment_package
    mkdir deployment_package
    
    # Copy Lambda function code
    cp lambda_function.py deployment_package/
    
    # Install dependencies
    if [ -f requirements.txt ]; then
        print_status "Installing Python dependencies..."
        pip install -r requirements.txt -t deployment_package/
    fi
    
    cd ..
    print_success "Lambda package prepared!"
}

# Deploy infrastructure
deploy_infrastructure() {
    print_status "Deploying infrastructure with Terraform..."
    
    cd terraform
    
    # Initialize Terraform
    print_status "Initializing Terraform..."
    terraform init
    
    # Plan deployment
    print_status "Planning deployment..."
    terraform plan -out=tfplan
    
    # Apply deployment
    print_status "Applying deployment..."
    terraform apply tfplan
    
    # Get outputs
    print_success "Infrastructure deployed successfully!"
    echo ""
    print_status "Deployment outputs:"
    terraform output
    
    cd ..
}

# Update frontend with API endpoint
update_frontend() {
    print_status "Updating frontend with API endpoint..."
    
    cd terraform
    API_URL=$(terraform output -raw api_gateway_predict_url)
    cd ..
    
    # Update the API endpoint in the frontend
    sed -i.bak "s|YOUR_API_GATEWAY_URL_HERE/predict|${API_URL}|g" frontend/index.html
    
    print_success "Frontend updated with API endpoint: ${API_URL}"
}

# Deploy frontend to Amplify
deploy_frontend() {
    print_status "Frontend deployment instructions:"
    echo ""
    print_warning "Manual steps required for Amplify deployment:"
    echo "1. Push your code to a GitHub repository"
    echo "2. Connect the repository to AWS Amplify in the AWS Console"
    echo "3. Set the build settings to use the 'frontend' directory as the root"
    echo "4. Deploy the application"
    echo ""
    print_status "Alternatively, you can host the frontend files locally or on any web server."
}

# Main deployment function
main() {
    echo "=================================================="
    echo "🏥 Insurance Cost Prediction AWS Deployment"
    echo "=================================================="
    echo ""
    
    check_requirements
    prepare_lambda
    deploy_infrastructure
    update_frontend
    deploy_frontend
    
    echo ""
    print_success "🎉 Deployment completed successfully!"
    echo ""
    print_status "Next steps:"
    echo "1. Test your API endpoint using the URL provided above"
    echo "2. Deploy your frontend to Amplify or host it elsewhere"
    echo "3. Update the frontend API endpoint if needed"
    echo ""
    print_status "Your insurance cost prediction app is ready to use!"
}

# Run main function
main