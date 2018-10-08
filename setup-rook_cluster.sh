# Clonando repositorios Git
#echo -e "\u001b[32mClone the Git Repository\u001b[m\r\n"
#git clone https://github.com/rook/rook.git
#git clone https://github.com/erickeliseo/files.git

# Cambiando permisos al setup.sh
#chmod u+x files/setup-rook_cluster.sh

export FILESPATH=~/files/
export ROOTCEPHPATH=~/rook/cluster/examples/kubernetes/ceph
export ROOTCEPHMONPATH=~/rook/cluster/examples/kubernetes/monitoring
# Instalando Rook y Habilitando el Monitoreo
echo -e "\u001b[32mWait for Kubernetes and Rook to be ready\u001b[m\r\n"
kubectl create -f ~/rook/cluster/examples/kubernetes/ceph/operator.yaml
sleep 5
kubectl create -f ~/rook/cluster/examples/kubernetes/ceph/cluster.yaml
30
# Instalando Prometheus
echo -e "\u001b[32mPrometheus\u001b[m\r\n"
kubectl create -f ~/files/dashboard-external-NodePort.yaml
kubectl create -f https://raw.githubusercontent.com/coreos/prometheus-operator/release-0.15/bundle.yaml
sleep 60
kubectl create -f ~/rook/cluster/examples/kubernetes/monitoring/service-monitor.yaml
sleep 60
kubectl create -f ~/rook/cluster/examples/kubernetes/monitoring/prometheus.yaml
sleep 60
kubectl create -f ~/rook/cluster/examples/kubernetes/monitoring/prometheus-service.yaml
sleep 60

# Extraer configuracion de Prometheus e insertar en ~/files/grafana-helm-values.yaml
export URL=http://"$(kubectl -n rook-ceph -o jsonpath={.status.hostIP} get pod prometheus-rook-prometheus-0):9090"
sed -i "s|url:|url: $URL|g" ~/files/grafana-helm-values.yaml
echo -e "\u001b[32mURLGRAFANA = $URL\u001b[m\r\n"

## Instalando Grafana
echo -e "\u001b[32mGrafana\u001b[m\r\n"
kubectl create -f ~/files/grafana-external-NodePort.yaml
helm install --name grafana-rook-cluster stable/grafana -f ~/files/grafana-helm-values.yaml
sleep 90
# Extraer POD y URL de Grafana
# Otra forma de Exportar el nombre del POD:
#export POD_NAME=$(kubectl get pods --namespace default -l "app=grafana-rook-cluster,component=" -o jsonpath="{.items[0].metadata.name}")
export PODGRAFANA=$(kubectl get pods | grep grafana-rook-cluster | awk '{print $1}')
export URLGRAFANA=http://"$(kubectl  -o jsonpath={.status.hostIP} get pod "$(kubectl get pods | grep grafana-rook-cluster | awk '{print $1}')")":3000
echo -e "\u001b[32mPODGRAFANA = $PODGRAFANA\u001b[m\r\n"
echo -e "\u001b[32mURLGRAFANA = $URLGRAFANA\u001b[m\r\n"

# Instalando Dashboard de Rook en Grafana
# Descarga el JSON del Dashboard 2842
# De esta forma no funciono el Katacoda: kubectl exec -it $PODGRAFANA  curl https://grafana.com/api/dashboards/2842/revisions/7/download > /tmp/grafana-dashboard-Ceph-Cluster-2842.json
#kubectl exec -it $PODGRAFANA  -- bash -c "curl https://grafana.com/api/dashboards/2842/revisions/7/download > /tmp/grafana-dashboard-Ceph-Cluster-2842.json"
#sleep 10

# Elimina la primera linea /tmp/grafana-dashboard-Ceph-Cluster-2842.json
#kubectl exec -it $PODGRAFANA -- bash -c "sed -i '82d' /tmp/grafana-dashboard-Ceph-Cluster-2842.json"
#sleep 2
#kubectl exec -it $PODGRAFANA -- bash -c "sed -i '82i \      \"dashboard\": \"Prometheus\"\' /tmp/grafana-dashboard-Ceph-Cluster-2842.json"
#sleep 2
#kubectl exec -it $PODGRAFANA -- bash -c "sed -i '1d' /tmp/grafana-dashboard-Ceph-Cluster-2842.json"

# Inserta linea /tmp/grafana-dashboard-Ceph-Cluster-2842.json
#kubectl exec -it $PODGRAFANA -- bash -c "sed -i '1i \"\dashboard\"\: {' /tmp/grafana-dashboard-Ceph-Cluster-2842.json"

# Inserta linea /tmp/grafana-dashboard-Ceph-Cluster-2842.json
#kubectl exec -it $PODGRAFANA -- bash -c "sed -i '1i {' /tmp/grafana-dashboard-Ceph-Cluster-2842.json"

# Inserta linea /tmp/grafana-dashboard-Ceph-Cluster-2842.json
#kubectl exec -it $PODGRAFANA -- bash -c "echo "}" >> /tmp/grafana-dashboard-Ceph-Cluster-2842.json"

#kubectl exec -it $PODGRAFANA -- bash -c "sed -i 's/${DS_PROMETHEUS-INFRA}/Prometheus/g' /tmp/grafana-dashboard-Ceph-Cluster-2842.json"

# ----------------
kubectl cp ~/files/grafana-dashboard-Ceph-Cluster-2842.json $PODGRAFANA:tmp/
sleep 10
kubectl exec -it $PODGRAFANA -- bash -c "cd /tmp ; curl --user admin:strongpassword 'http://localhost:3000/api/dashboards/db' -X POST -H 'Content-Type:application/json;charset=UTF-8' --data-binary @./grafana-dashboard-Ceph-Cluster-2842.json"
