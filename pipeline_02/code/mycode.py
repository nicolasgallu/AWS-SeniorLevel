import requests
import boto3
import json

def get_weather(token, location, days=None, dt=None, endpoint=None):
    base_url = "https://api.weatherapi.com/v1/"
    params = {"key": token, "q":location}
    headers = {}

    if endpoint == 'forecast':
        params.update({"days": days})
    elif endpoint == 'history':
        params.update({"dt": dt})
 
    base_url = base_url + endpoint + '.json' 
    response = requests.get(url=base_url, params=params, headers=headers)
    response.raise_for_status()
    print(f"processing {endpoint} done.")
    return {endpoint: response.json()}

locations = ['Tierra del Fuego']
days_forecast = [2]
dates = ['2026-07-16']
token = "8b8c4f3c02be4c40964170107252302"

information = []

#obtenemos data clima x location
for location in locations:
    current_weather = get_weather(token, location, days=None, dt=None, endpoint="current")
    location = get_weather(token, location, days=None, dt=None, endpoint="search") 
    information.append(current_weather)
    information.append(location)
    #a nivel de location  buscamos forecast & history
    for days in days_forecast:  
        forecast = get_weather(token, location, days=days, dt=None, endpoint="forecast")
        information.append(forecast)
    for dt in dates:
        historical = get_weather(token, location, days=None, dt=dt, endpoint="history")
        information.append(historical)


#print(information)
s3_client = boto3.client('s3')
s3_bucket_name = "anweather-datalake-projects-6817346630270909-us-east-2"
project_pipeline_name = "pipeline-weather-data"
batch_id = "1"
s3_object_key =f"{project_pipeline_name}/list_locations_dates_to_process_data_batch_{batch_id}.json"
#s3_object = s3_client.get_object(bucket=s3_bucket_name, key=s3_object_key)

s3_client.put_object(Bucket=s3_bucket_name, Key=s3_object_key, Body=json.dumps(information))
