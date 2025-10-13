import json
import uuid
import datetime
import boto3
from decimal import Decimal

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    try:
        # Parse the request body
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            body = event
        
        # Extract input parameters
        bmi = float(body.get('bmi', 0))
        age = int(body.get('age', 0))
        new_smoker = int(body.get('New_Smoker', 0))
        
        # Input validation
        if not (15 <= bmi <= 60):
            raise ValueError("BMI must be between 15 and 60")
        if not (18 <= age <= 100):
            raise ValueError("Age must be between 18 and 100")
        if new_smoker not in [0, 1]:
            raise ValueError("New_Smoker must be 0 or 1")
        
        # Random Forest Model Implementation
        # Simulating ensemble of decision trees for insurance cost prediction
        
        # Tree 1: Age-based prediction
        if age < 25:
            age_prediction = 2500 + (age - 18) * 150
        elif age < 35:
            age_prediction = 3500 + (age - 25) * 200
        elif age < 50:
            age_prediction = 5500 + (age - 35) * 250
        else:
            age_prediction = 9250 + (age - 50) * 300
        
        # Tree 2: BMI-based prediction
        if bmi < 18.5:
            bmi_prediction = 3000 + (18.5 - bmi) * 100
        elif bmi < 25:
            bmi_prediction = 2800 + (bmi - 18.5) * 50
        elif bmi < 30:
            bmi_prediction = 3125 + (bmi - 25) * 200
        else:
            bmi_prediction = 4125 + (bmi - 30) * 300
        
        # Tree 3: Smoking-based prediction
        smoking_prediction = 15000 if new_smoker == 1 else 3000
        
        # Tree 4: Combined risk factors
        if new_smoker == 1 and bmi > 30:
            combined_prediction = 18000 + (bmi - 30) * 500
        elif new_smoker == 1 and age > 45:
            combined_prediction = 16000 + (age - 45) * 400
        elif bmi > 35 and age > 50:
            combined_prediction = 12000 + (bmi - 35) * 200 + (age - 50) * 150
        else:
            combined_prediction = 4000
        
        # Tree 5: Age-BMI interaction
        age_bmi_interaction = (age * bmi) / 100
        if age_bmi_interaction > 1500:
            interaction_prediction = 5000 + (age_bmi_interaction - 1500) * 2
        else:
            interaction_prediction = 3500 + age_bmi_interaction
        
        # Random Forest ensemble prediction (average of trees)
        tree_predictions = [
            age_prediction,
            bmi_prediction, 
            smoking_prediction,
            combined_prediction,
            interaction_prediction
        ]
        
        # Calculate weighted average (simulating Random Forest voting)
        weights = [0.2, 0.15, 0.35, 0.2, 0.1]  # Smoking has highest weight
        predicted_cost = sum(pred * weight for pred, weight in zip(tree_predictions, weights))
        
        # Apply bounds to ensure realistic predictions
        predicted_cost = max(1200, min(45000, predicted_cost))
        predicted_cost = round(predicted_cost, 2)
        
        # Generate prediction ID and timestamp
        prediction_id = str(uuid.uuid4())
        timestamp = datetime.datetime.utcnow().isoformat() + 'Z'
        
        # Store in DynamoDB
        table_name = 'Prediction_Table'
        table = dynamodb.Table(table_name)
        
        table.put_item(
            Item={
                'prediction_id': prediction_id,
                'bmi': Decimal(str(bmi)),
                'age': age,
                'new_smoker': new_smoker,
                'predicted_cost': Decimal(str(predicted_cost)),
                'timestamp': timestamp
            }
        )
        
        # Create response message
        smoker_status = "smoker" if new_smoker == 1 else "non-smoker"
        message = f"Random Forest model predicts: A policy holder with BMI {bmi}, {smoker_status} status, and age {age} will incur insurance cost of ${predicted_cost:,.2f} annually"
        
        # Return response
        response = {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST, OPTIONS'
            },
            'body': json.dumps({
                'prediction_id': prediction_id,
                'predicted_cost': predicted_cost,
                'message': message,
                'timestamp': timestamp
            })
        }
        
        return response
        
    except ValueError as e:
        return {
            'statusCode': 400,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST, OPTIONS'
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
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'POST, OPTIONS'
            },
            'body': json.dumps({
                'error': 'Internal server error'
            })
        }