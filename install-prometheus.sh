# Instalando Prometheus
echo -e "\u001b[32mInstalling Prometheus...\u001b[m\r\n"
kubectl create -f ~/files/dashboard-external-NodePort.yaml
kubectl create -f https://raw.githubusercontent.com/coreos/prometheus-operator/release-0.15/bundle.yaml
sleep 15
kubectl create -f ~/rook/cluster/examples/kubernetes/monitoring/service-monitor.yaml
sleep 15
kubectl create -f ~/rook/cluster/examples/kubernetes/monitoring/prometheus.yaml
sleep 30
kubectl create -f ~/rook/cluster/examples/kubernetes/monitoring/prometheus-service.yaml
