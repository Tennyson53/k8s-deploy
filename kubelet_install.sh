#!/bin/bash

if [ ! -n "$1" ];
then
  echo "No IP_address has been input. exit."
  exit
fi
IP_Address=$1
#1.install docker

if which docker;
then
  echo 'docker has been installed'
else
  echo 'Installing docker'  
  wget -qO- https://get.docker.com/ | sh
fi
dockerVersion=`docker --version | cut -d'.' -f2`
if [ $dockerVersion -eq 12 ]
then
 cp -f ./etc/docker.service-1.12 /lib/systemd/system/docker.service
else
 cp -f ./etc/docker.service-1.11 /lib/systemd/system/docker.service
fi

#2.install flanneld service
cp ./service/after-docker.service /lib/systemd/system/
cp ./service/flanneld.service /lib/systemd/system/
if [ ! -x "/etc/flanneld" ];
then
  mkdir /etc/flanneld
fi

if [ -f "/etc/flanneld/flanneld.conf" ]; 
then
  rm /etc/flanneld/flanneld.conf
fi
cp ./etc/flanneld.conf /etc/flanneld/

cp ./bin/flanneld /usr/local/bin/
cp ./bin/mk-docker-opts.sh /usr/local/bin/
systemctl daemon-reload
sleep 1
systemctl enable flanneld.service
systemctl start flanneld.service
sleep 1
systemctl enable docker.service
#systemctl enable after-docker.service
systemctl restart docker.service
sleep 1

#3.write certification file
#if [ -f "./config/ca_file/make-node-keys.sh" ]; 
#then
#  rm ./config/ca_file/make-node-keys.sh
#fi
#cat << EOF > ./config/ca_file/make-node-keys.sh
#/bin/bash
#openssl genrsa -out /etc/kubernetes/ca_file/node/kubelet.key 2048
#openssl req -new -key /etc/kubernetes/ca_file/node/kubelet.key -subj "/CN=$IP_Address" -out /etc/kubernetes/ca_file/node/kubelet.csr -config /etc/kubernetes/ca_file/openssl.cnf
#openssl x509 -req -in /etc/kubernetes/ca_file/node/kubelet.csr -CA /etc/kubernetes/ca_file/master/ca.crt -CAkey /etc/kubernetes/ca_file/master/ca.key -CAcreateserial   -extensions v3_req -extfile /etc/kubernetes/ca_file/openssl.cnf -out /etc/kubernetes/ca_file/node/kubelet.crt -days 10000
#EOF

#4.install kubelet service
cp ./service/kubelet.service /lib/systemd/system/
#if [ ! -x "/etc/kubernetes" ];
#then
#mkdir /etc/kubernetes
#fi

if [ -x "/etc/kubernetes" ];
then
  rm -r /etc/kubernetes
fi
cp -r ./kubernetes /etc/
#chmod 777 /etc/kubernetes/ca_file/make-node-keys.sh
#exec /etc/kubernetes/ca_file/make-node-keys.sh
# certification
openssl genrsa -out /etc/kubernetes/ca_file/node/kubelet.key 2048
openssl req -new -key /etc/kubernetes/ca_file/node/kubelet.key -subj "/CN=$1" -out /etc/kubernetes/ca_file/node/kubelet.csr -config /etc/kubernetes/ca_file/openssl.cnf
openssl x509 -req -in /etc/kubernetes/ca_file/node/kubelet.csr -CA /etc/kubernetes/ca_file/master/ca.crt -CAkey /etc/kubernetes/ca_file/master/ca.key -CAcreateserial   -extensions v3_req -extfile /etc/kubernetes/ca_file/openssl.cnf -out /etc/kubernetes/ca_file/node/kubelet.crt -days 10000

cat << EOF > /etc/kubernetes/kubelet
###
# kubernetes kubelet (minion) config

# The address for the info server to serve on (set to 0.0.0.0 or "" for all interfaces)
KUBELET_ADDRESS="--address=0.0.0.0"

# The port for the info server to serve on
KUBELET_PORT="--port=10250"

# You may leave this blank to use the actual hostname
KUBELET_HOSTNAME="--hostname-override=$IP_Address"

# location of the api-server
KUBELET_API_SERVER="--api-servers=https://192.168.53.151"

# Add your own!
KUBELET_ARGS1="--cluster-dns=10.254.0.100"
KUBELET_ARGS2="--cluster-domain=enn.cn"
KUBELET_ARGS3="--kubeconfig=/etc/kubernetes/node-kubeconfig"
KUBELET_ARGS4="--pod-infra-container-image=index.alauda.cn/googlecontainer/pause-amd64:3.0"
EOF

cp ./bin/kubelet /usr/local/bin/
systemctl daemon-reload
sleep 1
systemctl enable kubelet.service
systemctl start kubelet.service
sleep 1



#4.install kubelet-proxy container
sleep 1
./bin/kubeproxy.sh 


