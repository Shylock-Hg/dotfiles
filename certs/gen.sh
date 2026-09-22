#! /usr/bin/env bash

################################ sign cert by CA ############################
# Generate a new 2048-bit RSA private key (can omit -aes256 if you don't need encryption)

readonly CERT_NAME=shylockhg.me

openssl genrsa -out ${CERT_NAME}.key 2048
openssl req -new -key ${CERT_NAME}.key -out ${CERT_NAME}.csr
openssl x509 -req -days 365 -sha256 \
    -in ${CERT_NAME}.csr \
    -CA ca.crt \
    -CAkey ca.key \
    -CAcreateserial \
    -extfile ${CERT_NAME}_ext.cnf \
    -extensions ${CERT_NAME}_cert \
    -out ${CERT_NAME}.crt
