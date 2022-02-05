#!/bin/bash

openssl req -newkey rsa:4096 \
              -x509 \
              -sha256 \
              -days 365 \
              -nodes \
              -out localhost.crt \
              -keyout localhost.key
