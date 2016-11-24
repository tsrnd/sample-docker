#!/bin/bash

# Generate server certificate
openssl genrsa -out server.key 4096
openssl req -new -x509 -days 365 -key server.key -out server.crt

# Generate client certificate
openssl genrsa -out client.key 4096
openssl req -new -key client.key -out client.csr

# self-signed
openssl x509 -req -days 365 -in client.csr -CA server.crt -CAkey server.key -set_serial 01 -out client.crt

# Convert client key to PKCS (for browsers)
openssl pkcs12 -export -clcerts -in client.crt -inkey client.key -out client.p12
# Make sure you enter an export password. Otherwise, you may be unable to import it to your browser.
