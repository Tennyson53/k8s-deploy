#!/bin/bash

docker stop kube-proxy
docker rm kube-proxy

rm -r /etc/flanneld/
rm -r /etc/kubernetes/

rm /lib/systemd/system/after-docker.service
rm /lib/systemd/system/flanneld.service
rm /lib/systemd/system/kubelet.service


rm /usr/local/bin/flanneld
rm /usr/local/bin/kubelet
rm /usr/local/bin/mk-docker-opts.sh

flanneldPID=`ps -ef | grep flanneld | grep root | grep -v grep | awk '{print $2}'`
kill $flanneldPID

kubeletPID=`ps -ef | grep kubelet | grep root | grep -v grep | awk '{print $2}'`
kill $kubeletPID
