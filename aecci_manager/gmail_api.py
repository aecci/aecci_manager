import re
import base64
import os.path
from datetime import datetime

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/gmail.readonly", "https://www.googleapis.com/auth/gmail.modify"]

def get_message_date_time(service, message_id):
    try:
        # Retrieve the message object
        message = service.users().messages().get(userId='me', id=message_id).execute()

        # Extract the date and time from the message headers
        for header in message['payload']['headers']:
            if header['name'] == 'Date':
                date_time_string = header['value']
                # Convert the date and time string to a Python datetime object
                date_time = datetime.strptime(date_time_string, '%a, %d %b %Y %H:%M:%S %z')
                return date_time
    except HttpError as error:
        print(f"An error occurred: {error}")
        return None

def remove_label(service, label_name, email_id):
    try:
        # Add label to email
        service.users().messages().modify(
            userId="me", id=email_id, body={"removeLabelIds": [label_name]}
        ).execute()
    except HttpError as error:
        print(f"Se produjo un error: {error}")

def add_label(service, label_name, email_id):
    try:
        # Add label to email
        service.users().messages().modify(
            userId="me", id=email_id, body={"addLabelIds": [label_name]}
        ).execute()
    except HttpError as error:
        print(f"Se produjo un error: {error}")

def get_labels(service, labels_names):
    try:
        # Search for labels with especified names
        label = service.users().labels().list(userId='me').execute()
        labels = {}
        for l in label['labels']:
            for name in labels_names:
                if l['name'] == name:
                    labels[name] = l['id']
        return labels
    except HttpError as error:
        print(f"Se produjo un error: {error}")
        return None

def get_msg_data(service, msg_id):
    msg_data = (
        service.users()
        .messages()
        .get(userId="me", id=msg_id, format="full")
        .execute()
    )
    code_msg = msg_data["payload"]["parts"][0]["body"]["data"]
    decode_msg = str(base64.urlsafe_b64decode(code_msg))
    client = str(re.findall(r"Nombre cliente origen:\s*([a-zA-Z _]*)", decode_msg)[0]).replace('_', ' ')
    amount = float(re.findall(r"Monto:\s*([0-9.,]*)", decode_msg)[0].replace(',', ''))
    # TODO: return object SINPE
    return (client.title(), amount, get_message_date_time(service, msg_id), msg_id)

def get_msg_with_label(service, label):
    try:
        sinpes = []
        # Get messages with the label SINPES
        messages = service.users().messages().list(userId='me', labelIds=label, maxResults=7).execute()

        if not messages["resultSizeEstimate"]:
            print(f"No hay mensajes con la etiqueta.")
            return []
        else:
            # TODO: improve velocity with parallelism
            for msg in messages["messages"]:
                data = get_msg_data(service, msg["id"])
                sinpes.append(data)
            return sinpes

    except HttpError as error:
        print(f"Se produjo un error: {error}")
        return []

def start_service():
    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists("token.json"):
        creds = Credentials.from_authorized_user_file("token.json", SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file("credentials.json", SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open("token.json", "w") as token:
            token.write(creds.to_json())
    # API configuration
    service = build('gmail', 'v1', credentials=creds)
    return service
