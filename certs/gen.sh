#! /usr/bin/env bash

############################### sign CA ###############################
# Generate a 4096-bit RSA private key and encrypt it with a passphrase
#openssl genrsa -aes256 -out ca.key 4096

# Create the Certificate Signing Request (CSR)
#openssl req -new -key ca.key -out ca.csr

# Self-sign the CSR to create the Root Certificate
##openssl x509 -req -days 3650 -sha256 -in ca.csr -signkey ca.key -out ca.crt -config ca.cnf
#openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt
  -config ca.cnf

################################ sign cert by CA ############################
# Generate a new 2048-bit RSA private key (can omit -aes256 if you don't need encryption)
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr
openssl x509 -req -days 365 -sha256 \
    -in server.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial \
    -extfile server_ext.cnf \
    -extensions server_cert \
    -out server.crt
