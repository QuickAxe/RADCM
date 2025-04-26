from http.server import BaseHTTPRequestHandler, HTTPServer
import json 


class Server(BaseHTTPRequestHandler):     

    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        
        data = json.loads(post_data)

        if data["command"] == "start":
            #! spawn a thread that'll take pictures with gps location 
            pass



def run(server_class=HTTPServer, handler_class=Server, port=8000):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print('Starting httpd...')
    httpd.serve_forever()

if __name__ == "__main__":
    run()
