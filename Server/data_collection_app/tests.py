from django.test import TestCase
import json
import random
import requests

def random_sensor_data(num_anomalies=2):
    source = random.choice(["mobile", "jimmy"])
    anomaly_data = []
    
    for _ in range(num_anomalies):
        latitude = round(random.uniform(15, 15.6), 6)  
        longitude = round(random.uniform(73.9, 74.4), 6)  
        
        
        window = [[round(random.uniform(1.0, 10.0), 2) for _ in range(3)] for _ in range(200)]
        
        anomaly_data.append({
            "latitude": latitude,
            "longitude": longitude,
            "window": window
        })
    
    request_json = {
        "source": source,
        "anomaly_data": anomaly_data
    }
    
    return request_json 


request_payload = random_sensor_data()

# print(json.dumps(request_payload, indent=1))
print("Locations")
for anomaly in request_payload['anomaly_data']:
    print(anomaly['latitude'], anomaly['longitude'])

url = f"http://127.0.0.1:8000/api/anomalies/sensors/"
r = requests.post(url, json = request_payload)
print(r.status_code)
print(r.json())