#/bin/bash

openssl genrsa -out master/ca.key 2048
openssl req -x509 -new -nodes -key master/ca.key -subj "/CN=enn.cn" -days 10000 -out master/ca.crt



openssl genrsa -out master/server.key 2048
openssl req -new -key master/server.key -subj "/CN=192.168.53.151" -out master/server.csr -config openssl.cnf
openssl x509 -req -in master/server.csr -CA master/ca.crt -CAkey master/ca.key -CAcreateserial -extensions v3_req -extfile openssl.cnf -out master/server.crt -days 10000



openssl genrsa -out master/cs_client.key 2048
openssl req -new -key master/cs_client.key -subj "/CN=192.168.53.151" -out master/cs_client.csr -config openssl.cnf
openssl x509 -req -in master/cs_client.csr -CA master/ca.crt -CAkey master/ca.key -CAcreateserial -extensions v3_req -extfile openssl.cnf  -out master/cs_client.crt -days 1000
