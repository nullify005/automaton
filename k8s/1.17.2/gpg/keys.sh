#!/bin/bash

gpg -r "nullify005 saltstack" --export-secret-keys --armor > gpg/saltstack.key
