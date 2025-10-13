#!/bin/bash

# Automated Frontend Deployment to AWS Amplify
set -e

echo "🚀 Deploying frontend updates to Amplify..."

# Get Amplify app ID (you'll need to set this)
AMPLIFY_APP_ID="${AMPLIFY_APP_ID:-}"

if [ -z "$AMPLIFY_APP_ID" ]; then
    echo "❌ Error: AMPLIFY_APP_ID environment variable not set"
    echo "Please set it with: export AMPLIFY_APP_ID=your-app-id"
    echo "You can find your app ID in the Amplify console URL"
    exit 1
fi

# Create deployment package
echo "📦 Creating deployment package..."
cd frontend
zip -r ../frontend_deploy.zip . -x "*.DS_Store"
cd ..

# Deploy to Amplify
echo "🔄 Deploying to Amplify..."
aws amplify start-deployment \
    --app-id "$AMPLIFY_APP_ID" \
    --branch-name main \
    --source-url "file://$(pwd)/frontend_deploy.zip"

echo "✅ Frontend deployment initiated!"
echo "Check Amplify console for deployment status"

# Clean up
rm frontend_deploy.zip