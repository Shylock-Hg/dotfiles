#! /usr/bin/env bash

############################### sign CA ###############################
# Generate a 4096-bit RSA private key and encrypt it with a passphrase
openssl genrsa -aes256 -out ca.key 4096

# Create the Certificate Signing Request (CSR)
openssl req -new -key ca.key -out ca.csr

# Self-sign the CSR to create the Root Certificate
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt -config ca.cnf
