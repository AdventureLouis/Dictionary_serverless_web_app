#!/bin/bash

# Simple Amplify Deployment
set -e

APP_NAME="insurance-cost-prediction"
APP_ID="d2oa4zxr4127cx"

echo "🚀 Deploying frontend to Amplify..."

# Create deployment package
echo "📦 Creating deployment package..."
cd frontend
zip -r ../frontend_deploy.zip . -x "*.DS_Store"
cd ..

# Create branch if it doesn't exist
echo "🌿 Setting up main branch..."
aws amplify create-branch \
    --app-id "$APP_ID" \
    --branch-name "main" \
    --framework "Web" || echo "Branch may already exist"

# Start deployment
echo "🔄 Starting deployment..."
aws amplify start-deployment \
    --app-id "$APP_ID" \
    --branch-name "main" \
    --source-url "file://$(pwd)/frontend_deploy.zip"

echo "✅ Deployment initiated!"
echo "🌐 Your app will be available at: https://main.d2oa4zxr4127cx.amplifyapp.com"

# Clean up
rm frontend_deploy.zip