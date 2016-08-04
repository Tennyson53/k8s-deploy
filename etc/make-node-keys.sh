#/bin/bash
openssl genrsa -out node/kubelet.key 2048
openssl req -new -key node/kubelet.key -subj "/CN=192.168.53.148" -out node/kubelet.csr -config openssl.cnf
openssl x509 -req -in node/kubelet.csr -CA master/ca.crt -CAkey master/ca.key -CAcreateserial   -extensions v3_req -extfile openssl.cnf -out node/kubelet.crt -days 10000
