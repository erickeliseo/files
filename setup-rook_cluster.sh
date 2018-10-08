# Instalando Rook
echo -e "\u001b[32mWait for Kubernetes and Rook to be ready\u001b[m\r\n"
kubectl create -f ~/rook/cluster/examples/kubernetes/ceph/operator.yaml
sleep 10
kubectl create -f ~/rook/cluster/examples/kubernetes/ceph/cluster.yaml
