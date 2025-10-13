import json
import boto3
import pickle
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler
import uuid
from datetime import datetime
import os

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(table_name)

# Load and train model (using your methodology)
def create_model():
    # Sample data based on your insurance_1.csv structure
    data = {
        'bmi': [27.9, 33.77, 33.0, 22.705, 28.88, 25.74, 33.44, 27.74, 29.83, 25.84],
        'New_Smoker': [1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        'age': [19, 18, 28, 33, 32, 31, 46, 37, 37, 60],
        'charges': [16884.924, 1725.5523, 4449.462, 21984.47061, 3866.8552, 3756.6216, 8240.5896, 7281.5056, 6406.4107, 28923.13692]
    }
    
    df = pd.DataFrame(data)
    X = df[['bmi', 'New_Smoker', 'age']]
    y = df['charges']
    
    # Scale the features
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X)
    
    # Train Random Forest model (using your parameters)
    rf = RandomForestRegressor(n_estimators=4, max_depth=3, random_state=0)
    rf.fit(X_scaled, y)
    
    return rf, scaler

# Initialize model and scaler
model, scaler = create_model()

def lambda_handler(event, context):
    try:
        # Handle CORS preflight
        if event['httpMethod'] == 'OPTIONS':
            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
                    'Access-Control-Allow-Methods': 'POST,OPTIONS'
                },
                'body': ''
            }
        
        # Parse request body
        body = json.loads(event['body'])
        bmi = float(body['bmi'])
        new_smoker = int(body['New_Smoker'])
        age = int(body['age'])
        
        # Validate inputs
        if not (15 <= bmi <= 60):
            raise ValueError("BMI must be between 15 and 60")
        if new_smoker not in [0, 1]:
            raise ValueError("New_Smoker must be 0 or 1")
        if not (18 <= age <= 100):
            raise ValueError("Age must be between 18 and 100")
        
        # Prepare data for prediction
        input_data = np.array([[bmi, new_smoker, age]])
        input_scaled = scaler.transform(input_data)
        
        # Make prediction
        prediction = model.predict(input_scaled)[0]
        prediction_rounded = round(prediction, 2)
        
        # Generate unique ID and timestamp
        prediction_id = str(uuid.uuid4())
        timestamp = datetime.utcnow().isoformat()
        
        # Store prediction in DynamoDB
        table.put_item(
            Item={
                'prediction_id': prediction_id,
                'timestamp': timestamp,
                'bmi': bmi,
                'new_smoker': new_smoker,
                'age': age,
                'predicted_cost': prediction_rounded
            }
        )
        
        # Return response
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'prediction_id': prediction_id,
                'predicted_cost': prediction_rounded,
                'message': f'A policy holder with BMI {bmi}, smoker status {new_smoker}, and age {age} will incur insurance cost of ${prediction_rounded:,.2f}',
                'timestamp': timestamp
            })
        }
        
    except ValueError as e:
        return {
            'statusCode': 400,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': str(e)
            })
        }
    
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': 'Internal server error'
            })
        }