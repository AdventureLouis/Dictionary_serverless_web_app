#!/bin/bash

# Complete Amplify Setup and Deployment
set -e

APP_NAME="insurance-cost-prediction"
REGION="us-east-1"

echo "🚀 Setting up Amplify app and deploying frontend..."

# Create Amplify app
echo "📱 Creating Amplify app..."
AMPLIFY_APP_ID=$(aws amplify create-app \
    --name "$APP_NAME" \
    --region "$REGION" \
    --query 'app.appId' \
    --output text)

echo "✅ Created Amplify app with ID: $AMPLIFY_APP_ID"

# Create deployment package
echo "📦 Creating deployment package..."
cd frontend
zip -r ../frontend_deploy.zip . -x "*.DS_Store"
cd ..

# Deploy frontend
echo "🔄 Deploying frontend..."
DEPLOYMENT_ID=$(aws amplify create-deployment \
    --app-id "$AMPLIFY_APP_ID" \
    --branch-name "main" \
    --query 'jobId' \
    --output text)

# Upload the zip file
echo "📤 Uploading frontend files..."
aws amplify start-deployment \
    --app-id "$AMPLIFY_APP_ID" \
    --branch-name "main" \
    --job-id "$DEPLOYMENT_ID" \
    --source-url "file://$(pwd)/frontend_deploy.zip"

# Get the app URL
APP_URL=$(aws amplify get-app \
    --app-id "$AMPLIFY_APP_ID" \
    --query 'app.defaultDomain' \
    --output text)

echo "✅ Deployment complete!"
echo "🌐 Your app is available at: https://$AMPLIFY_APP_ID.amplifyapp.com"
echo "📝 App ID: $AMPLIFY_APP_ID (save this for future deployments)"

# Clean up
rm frontend_deploy.zip

# Save app ID for future use
echo "export AMPLIFY_APP_ID=$AMPLIFY_APP_ID" > .amplify_config