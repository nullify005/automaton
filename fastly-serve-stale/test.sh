#!/bin/bash

while [ 1 ]; do
  TS=$(date)
  CODE=$(curl -s -o /dev/null -w "%{http_code}" http://fastly-serve-stale-test-v1.cdn.9pub.io/cached.html)
  echo ${TS}: ${CODE}
  sleep 2
done
