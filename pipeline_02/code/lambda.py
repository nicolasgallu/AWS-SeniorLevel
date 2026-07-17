import requests
import os


phone_number = os.getenv('PHONE_NUMBER')
token = os.getenv('WHATSAPP_TOKEN')


def enviar_mensaje_whapi():
    url = "https://gate.whapi.cloud/messages/text"
    payload = {
        "to": phone_number,
        "body": "HOLA DESDE AWS"
    }
    headers = {
        "accept": "application/json",
        "content-type": "application/json",
        "authorization": f"Bearer {token}"
    }
    requests.post(url, json=payload, headers=headers)


def lambda_handler(event, context):
    return enviar_mensaje_whapi()
