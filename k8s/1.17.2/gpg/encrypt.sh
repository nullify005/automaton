#!/bin/bash

echo -ne "${@}" | gpg --armor --batch --trust-model always --encrypt -r "nullify005 saltstack"
