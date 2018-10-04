# Clonando repositorios Git
#echo -e "\u001b[32mClone the Git Repository\u001b[m\r\n"
#git clone https://github.com/rook/rook.git
#git clone https://github.com/erickeliseo/files.git

# Cambiando permisos al setup.sh
#chmod u+x files/setup-rook_cluster.sh

# Instalando Rook y Habilitando el Monitoreo
echo -e "\u001b[32mWait for Kubernetes and Rook to be ready\u001b[m\r\n"
kubectl create -f ~/rook/cluster/examples/kubernetes/ceph/operator.yaml
sleep 15
kubectl create -f ~/rook/cluster/examples/kubernetes/ceph/cluster.yaml
sleep 15

# Instalando Prometheus
echo -e "\u001b[32mPrometheus\u001b[m\r\n"
kubectl create -f ~/files/dashboard-external-NodePort.yaml
sleep 15
kubectl create -f https://raw.githubusercontent.com/coreos/prometheus-operator/release-0.15/bundle.yaml
sleep 15
kubectl create -f ~/rook/cluster/examples/kubernetes/monitoring/service-monitor.yaml
sleep 15
kubectl create -f ~/rook/cluster/examples/kubernetes/monitoring/prometheus.yaml
sleep 15
kubectl create -f ~/rook/cluster/examples/kubernetes/monitoring/prometheus-service.yaml

# Extraer configuracion de Prometheus e insertar en ~/files/grafana-helm-values.yaml
#export URL=http://"$(kubectl -n rook-ceph -o jsonpath={.status.hostIP} get pod prometheus-rook-prometheus-0):9090"
#sed -i "s|url:|url: $URL|g" ~/files/grafana-helm-values.yaml

## Instalando Grafana
#echo -e "\u001b[32mGrafana\u001b[m\r\n"
#kubectl create -f ~/files/grafana-external-NodePort.yaml
#helm install --name grafana-rook-cluster stable/grafana -f ~/files/grafana-helm-values.yaml
