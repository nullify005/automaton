#!/usr/bin/env python3

import http.server
import socketserver
import time

PORT = 8000


class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """."""

    def do_GET(self):
        """."""
        time.sleep(60)


# main
Handler = MyHTTPRequestHandler
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    httpd.serve_forever()
