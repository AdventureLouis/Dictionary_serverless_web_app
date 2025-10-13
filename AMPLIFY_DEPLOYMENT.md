# AWS Amplify Deployment Guide

## 🚀 Amplify Deployment Steps

### 1. Apply Terraform Configuration
```bash
cd terraform
terraform apply
```

### 2. Connect GitHub Repository to Amplify

#### Option A: Using AWS Console
1. Go to [AWS Amplify Console](https://console.aws.amazon.com/amplify/)
2. Find your app: "Insurance Cost Prediction"
3. Click "Connect branch"
4. Choose GitHub as source
5. Authorize AWS Amplify to access your GitHub
6. Select your repository
7. Select branch: `main`
8. Configure build settings:
   - Build command: `echo "No build required"`
   - Base directory: `/` (root)
   - Publish directory: `frontend`

#### Option B: Using AWS CLI
```bash
# Get your Amplify App ID
AMPLIFY_APP_ID=$(terraform output -raw amplify_app_id)

# Connect GitHub repository (replace with your repo URL)
aws amplify create-branch \
  --app-id $AMPLIFY_APP_ID \
  --branch-name main \
  --description "Main production branch"
```

### 3. Deploy Frontend Files

#### Manual Upload (Quick Start)
```bash
# Create a zip file of frontend
cd frontend
zip -r ../frontend.zip .
cd ..

# Upload to Amplify (replace APP_ID with actual ID)
aws amplify create-deployment \
  --app-id YOUR_AMPLIFY_APP_ID \
  --branch-name main \
  --file-map file://frontend.zip
```

#### GitHub Integration (Recommended)
1. Push your code to GitHub repository
2. Amplify will automatically detect changes
3. Automatic deployments on every push to main branch

## 📁 Frontend Structure for Amplify

```
frontend/
├── index.html          # Main application page
├── result.html         # Results display page
└── (any additional assets)
```

## 🔧 Amplify Configuration

### Build Specification
```yaml
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
```

### Environment Variables
- `API_ENDPOINT`: Automatically set to your API Gateway URL

### Custom Rules
- SPA redirect: `/<*>` → `/index.html` (404 status)

## 🌐 Access Your Application

After deployment, your application will be available at:
```
https://main.YOUR_AMPLIFY_DOMAIN.amplifyapp.com
```

Get the exact URL:
```bash
terraform output amplify_app_url
```

## 🔄 Continuous Deployment

### Automatic Deployments
- Every push to `main` branch triggers automatic deployment
- Build logs available in Amplify Console
- Rollback capability for failed deployments

### Manual Deployments
```bash
# Trigger manual deployment
aws amplify start-job \
  --app-id YOUR_AMPLIFY_APP_ID \
  --branch-name main \
  --job-type RELEASE
```

## 📊 Monitoring & Logs

### Access Logs
- Go to Amplify Console
- Select your app
- View build history and logs
- Monitor deployment status

### Metrics Available
- Build duration
- Deploy frequency  
- Error rates
- Traffic analytics

## 💰 Amplify Pricing

- **Build minutes**: $0.01 per build minute
- **Hosting**: $0.15 per GB served
- **Storage**: $0.023 per GB stored per month
- **Free tier**: 1,000 build minutes, 15 GB served per month

## 🔧 Troubleshooting

### Common Issues

1. **Build Fails**
   - Check build logs in Amplify Console
   - Verify frontend files are in correct directory
   - Ensure no build dependencies are missing

2. **API Connection Issues**
   - Verify API_ENDPOINT environment variable
   - Check CORS configuration in API Gateway
   - Confirm API Gateway is deployed

3. **Custom Domain Issues**
   - DNS propagation can take up to 48 hours
   - Verify SSL certificate status
   - Check domain verification

### Useful Commands
```bash
# List Amplify apps
aws amplify list-apps

# Get app details
aws amplify get-app --app-id YOUR_APP_ID

# List branches
aws amplify list-branches --app-id YOUR_APP_ID

# Get deployment status
aws amplify list-jobs --app-id YOUR_APP_ID --branch-name main
```

---

**Benefits of Amplify Deployment:**
- ✅ **CI/CD Pipeline**: Automatic deployments from Git
- ✅ **Global CDN**: Fast content delivery worldwide
- ✅ **SSL Certificate**: Automatic HTTPS
- ✅ **Custom Domains**: Easy domain configuration
- ✅ **Branch Deployments**: Multiple environments
- ✅ **Rollback**: Easy deployment rollbacks