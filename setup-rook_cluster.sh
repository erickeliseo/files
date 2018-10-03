# Clonando repositorios Git
#echo -e "\u001b[32mClone the Git Repository\u001b[m\r\n"
#git clone https://github.com/rook/rook.git
#git clone https://github.com/erickeliseo/files.git

# Cambiando permisos al setup.sh
#chmod u+x files/setup-rook_cluster.sh

# Instalando Rook y Habilitando el Monitoreo
echo -e "\u001b[32mWait for Kubernetes and Rook to be ready\u001b[m\r\n"
kubectl create -f ~/rook/cluster/examples/kubernetes/ceph/operator.yaml
kubectl create -f ~/rook/cluster/examples/kubernetes/ceph/cluster.yaml

# Instalando Prometheus
kubectl create -f ~/files/dashboard-external-NodePort.yaml
kubectl create -f https://raw.githubusercontent.com/coreos/prometheus-operator/release-0.15/bundle.yaml
kubectl create -f ~/rook/cluster/examples/kubernetes/monitoring/service-monitor.yaml
kubectl create -f ~/rook/cluster/examples/kubernetes/monitoring/prometheus.yaml
kubectl create -f ~/rook/cluster/examples/kubernetes/monitoring/prometheus-service.yaml

## Instalando Grafana
kubectl create -f ~/files/grafana-external-NodePort.yaml
helm init
helm install --name grafana-rook-cluster stable/grafana -f ~/files/grafana-helm-values.yaml
