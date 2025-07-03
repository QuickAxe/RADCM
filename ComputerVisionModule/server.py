from http.server import BaseHTTPRequestHandler, HTTPServer
import json


class Server(BaseHTTPRequestHandler):

    def __init__(self, messageQue):
        self.messageQue = messageQue

    # using this method below to be able to have this class with custom args for its init method
    # https://stackoverflow.com/questions/21631799/how-can-i-pass-parameters-to-a-requesthandler
    # all hail stackoverflow
    def __call__(self, *args, **kwargs):
        """Handle a request."""
        super().__init__(*args, **kwargs)

    def do_POST(self):
        content_length = int(self.headers["Content-Length"])
        post_data = self.rfile.read(content_length)

        self.send_header("Content-type", "text/html")
        self.end_headers()

        data = json.loads(post_data)

        message = ""

        if data["command"] == "start":

            if self.messageQue.empty():
                # if there's no previous "start survey" message in the queue

                self.send_response(200)
                self.messageQue.put("start")
                message = "got command successfully yayy"

            elif not self.messageQue.empty() and self.messageQue.queue[0] == "stop":
                self.send_response(400)
                message = "Start command given, but previous survey is still being stopped, please wait..."

            else:
                self.send_response(400)
                message = "Start command given, but survey already going on, dummy"

        elif data["command"] == "stop":
            # stop survey, if it's going on, otherwise return an error message and stuff

            if self.messageQue.empty():
                # what on earth, trying to stop a survey that isn't even happening !!
                self.send_response(400)
                message = "Stop command given, but no survey currently going on, dummy"

            elif not self.messageQue.empty() and self.messageQue.queue[0] == "stop":
                self.send_response(400)
                message = "Stop command given, but previous survey is still being stopped, please wait..."

            else:
                # valid stop command, do the needful
                # remove start message from queue
                self.send_response(200)
                message = "got command successfully yayy"

                self.messageQue.get()
                self.messageQue.put("stop")

        elif data["command"] == "sendImages":
            if not self.messageQue.empty() and self.messageQue.queue[0] == "start":
                self.send_response(400)
                message = "SendImages command given, but previous survey is still going on, please end survey first..."
            else:
                self.messageQue.put("sendImages")
                self.send_response(200)
                message = "got command successfully hurrah"

        else:
            self.send_response(400)
            message = "wrong command sent, what are you on friendo? (send me some too, instead of whatever message you sent)"

        #  Write the message to the response body
        self.wfile.write(message.encode())


def runServer(messageQue, port=3333):

    server_class = HTTPServer

    handler_class = Server(messageQue)
    server_address = ("0.0.0.0", port)

    httpd = server_class(server_address, handler_class)
    print("Starting httpd...")
    httpd.serve_forever()


if __name__ == "__main__":
    from queue import Queue

    messageQue = Queue()
    runServer(messageQue)
