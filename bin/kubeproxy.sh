docker run -d \
  --net=host \
  --name=kube-proxy \
  --privileged \
  --restart=always \
  -v /etc/kubernetes:/etc/kubernetes \
  index.alauda.cn/googlecontainer/kube-proxy-amd64:v1.3.0-beta.1 \
  kube-proxy \
  --master=https://192.168.53.151:443 \
  --kubeconfig=/etc/kubernetes/proxyconfig \
  --logtostderr=true --v=0
