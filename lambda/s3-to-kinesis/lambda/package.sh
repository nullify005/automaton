#!/bin/bash

set -ex

if [ -e s3-to-kinesis.zip ]; then rm -f s3-to-kinesis.zip; fi
zip -r s3-to-kinesis.zip s3-to-kinesis.rb vendor
