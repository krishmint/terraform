import json
import boto3
import gzip
import base64
from datetime import datetime
import logging

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('${dynamodb_table}')

def handler(event, context):
    """
    Lambda function to process CloudTrail logs and extract session information
    """
    try:
        # Decode and decompress the log data
        cw_data = event['awslogs']['data']
        compressed_payload = base64.b64decode(cw_data)
        uncompressed_payload = gzip.decompress(compressed_payload)
        log_data = json.loads(uncompressed_payload)
        
        # Process each log event
        for log_event in log_data['logEvents']:
            try:
                # Parse the CloudTrail event
                message = json.loads(log_event['message'])
                
                # Extract relevant information
                event_name = message.get('eventName', '')
                user_identity = message.get('userIdentity', {})
                source_ip = message.get('sourceIPAddress', '')
                event_time = message.get('eventTime', '')
                user_agent = message.get('userAgent', '')
                
                # Determine username
                username = None
                if user_identity.get('type') == 'IAMUser':
                    username = user_identity.get('userName')
                elif user_identity.get('type') == 'AssumedRole':
                    username = user_identity.get('arn', '').split('/')[-1]
                elif user_identity.get('type') == 'Root':
                    username = 'root'
                
                if not username:
                    continue
                
                # Process login events
                if event_name == 'ConsoleLogin':
                    response_elements = message.get('responseElements', {})
                    console_login = response_elements.get('ConsoleLogin', 'Success')
                    
                    if console_login == 'Success':
                        # Record login session
                        session_data = {
                            'username': username,
                            'session_id': f"{username}-{int(datetime.now().timestamp())}",
                            'login_time': event_time,
                            'ip_address': source_ip,
                            'user_agent': user_agent,
                            'session_type': 'console_login',
                            'ttl': int(datetime.now().timestamp()) + (30 * 24 * 60 * 60)  # 30 days TTL
                        }
                        
                        table.put_item(Item=session_data)
                        logger.info(f"Recorded login for user: {username}")
                
                # Process API calls and other activities
                elif event_name in ['AssumeRole', 'GetSessionToken', 'CreateAccessKey', 'DeleteAccessKey']:
                    activity_data = {
                        'username': username,
                        'session_id': f"{username}-activity-{int(datetime.now().timestamp())}",
                        'login_time': event_time,
                        'ip_address': source_ip,
                        'user_agent': user_agent,
                        'activity': event_name,
                        'session_type': 'api_activity',
                        'ttl': int(datetime.now().timestamp()) + (30 * 24 * 60 * 60)  # 30 days TTL
                    }
                    
                    table.put_item(Item=activity_data)
                    logger.info(f"Recorded activity {event_name} for user: {username}")
                
            except Exception as e:
                logger.error(f"Error processing log event: {str(e)}")
                continue
        
        return {
            'statusCode': 200,
            'body': json.dumps('Successfully processed CloudTrail logs')
        }
        
    except Exception as e:
        logger.error(f"Error processing CloudTrail logs: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error processing logs: {str(e)}')
        }