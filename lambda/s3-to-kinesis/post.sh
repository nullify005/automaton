#!/bin/bash

set -ex

curl -X POST -d @json http://127.0.0.1:8080/_bulk
