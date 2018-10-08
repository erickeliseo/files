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

# ----------------
#Instalando Dashboards
kubectl cp ~/files/grafana-dashboard-Ceph-Cluster-2842.json $PODGRAFANA:tmp/
sleep 10
kubectl exec -it $PODGRAFANA -- bash -c "cd /tmp ; curl --user admin:strongpassword 'http://localhost:3000/api/dashboards/db' -X POST -H 'Content-Type:application/json;charset=UTF-8' --data-binary @./grafana-dashboard-Ceph-Cluster-2842.json"
