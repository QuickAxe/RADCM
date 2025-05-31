import json
from channels.generic.websocket import AsyncWebsocketConsumer


class AnomalyUpdatesConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.group_name = "anomaly_updates"

        # Join the anomaly updates group
        await self.channel_layer.group_add(
            self.group_name, self.channel_name
        )
        
        # Accept the WebSocket connection
        await self.accept()

    async def disconnect(self, close_code):
        # leave group
        await self.channel_layer.group_discard(
            self.group_name, self.channel_name
        )

    async def receive(self, text_data):
        data = json.loads(text_data)
        message = data['message']

        event = {
            'type': 'anomaly_update',
            'message': message
        }
        
        # Send the message to the group
        await self.channel_layer.group_send(
            self.group_name,
            event
        )
        
    async def send_message(self, event):
        message = event['message']
        
        # Send the message to WebSocket
        await self.send(text_data=json.dumps({
            'message': message
        }))