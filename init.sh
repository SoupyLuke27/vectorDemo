#!/bin/bash
# this is where our app will live
mkdir /opt/app 
cd /opt/app

# creating app and requirements
cat << EOF > /opt/app/reqs.txt
tmdbv3api==1.7.7
EOF
cat << EOF > /opt/app/api.py
#!/usr/bin/env python3

"""
Very simple HTTP server in python for logging requests
Usage::
    ./server.py [<port>]
"""

from tmdbv3api import TMDb
from tmdbv3api import Movie
from tmdbv3api import TV

from http.server import BaseHTTPRequestHandler, HTTPServer
import logging

from urllib.parse import urlsplit
from urllib.parse import parse_qs


class HttpHandler(BaseHTTPRequestHandler):
    def _set_response(self, *, http_status):
        self.send_response(http_status)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def _write_body_line(self, line):
        self.wfile.write(f"{line}<br/>".encode('utf-8'))

    def do_GET(self):
        logging.info("GET request,\nPath: %s\nHeaders:\n%s\n", str(self.path), str(self.headers))

        tmdb = TMDb()

        split_url = urlsplit(self.path)

        if (split_url.path == '/tv'):
            query = parse_qs(split_url.query)
            logging.info(query)
            if 'name' in query:
                tv_results = TV().search(query['name'][0])
                
                self._set_response(http_status=200)
                [  self._write_body_line(t.name) for t in tv_results ]
            else:
                self._set_response(http_status=400)
                self._write_body_line("Missing 'name' query parameter")
        elif (split_url.path == '/movies/popular'):
            self._set_response(http_status=200)
            [ self._write_body_line(m.title) for m in Movie().popular() ]
        else:
            self._set_response(http_status=200)
            self._write_body_line(f"GET request for {self.path}")
            self._write_body_line("Examples:")
            self._write_body_line("&emsp;/tv?name=Breaking%20Bad")
            self._write_body_line("&emsp;/movies/popular")


def run(server_class=HTTPServer, port=8080):
    logging.basicConfig(level=logging.INFO)
    server_address = ('', port)
    httpd = server_class(server_address, HttpHandler)
    logging.info('Starting httpd...\n')
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    logging.info('Stopping httpd...\n')

if __name__ == '__main__':
    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
        run()
EOF
chmod +x /opt/app/api.py

# Installing requirements
apt update
apt install python3-pip -y
pip3 install -r reqs.txt


# set api key
export TMDB_API_KEY=$1
echo "TMDB_API_KEY='$1'" >> /etc/environment
# Creating service

cat << EOF > /etc/systemd/system/vectordemo.service
[Unit]
Description= demo service
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=1
User=xenu
ExecStart=/opt/app/api.py

[Install]
WantedBy=multi-user.target
EOF

# start
systemctl enable vectordemo
systemctl start vectordemo