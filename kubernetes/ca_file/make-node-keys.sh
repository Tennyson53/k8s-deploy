#/bin/bash
openssl genrsa -out /etc/kubernetes/ca_file/node/kubelet.key 2048
openssl req -new -key /etc/kubernetes/ca_file/node/kubelet.key -subj "/CN=192.168.53.179" -out /etc/kubernetes/ca_file/node/kubelet.csr -config /etc/kubernetes/ca_file/openssl.cnf
openssl x509 -req -in /etc/kubernetes/ca_file/node/kubelet.csr -CA /etc/kubernetes/ca_file/master/ca.crt -CAkey /etc/kubernetes/ca_file/master/ca.key -CAcreateserial   -extensions v3_req -extfile /etc/kubernetes/ca_file/openssl.cnf -out /etc/kubernetes/ca_file/node/kubelet.crt -days 10000
