#!/bin/bash

python3 /usr/local/bin/timeout.py &
exec nginx -g 'daemon off;'
