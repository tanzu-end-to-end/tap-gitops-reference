
sudo apt-get update

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
export HOMEBREW_INSTALL_FROM_API=1
export NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /home/jeff/.profile
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/jeff/.profile
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

sudo apt-get install -y build-essential
sudo apt-get install -y wget 
sudo apt-get install -y netcat 
  brew install kubectl
  brew install kind
  brew install k9s

 sudo usermod -aG docker $USER
 sudo usermod -aG docker $USER
cat > tap-cluster.yaml << EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: tap-kind-cluster
nodes:
- role: control-plane
- role: worker
EOF

kind create cluster --config tap-cluster.yaml --image kindest/node:v1.23.0 
sudo cp ytt /usr/local/bin/ytt && sudo chmod a+x /usr/local/bin/ytt
sudo cp kapp /usr/local/bin/kapp && sudo chmod a+x /usr/local/bin/kapp
sudo cp kbld /usr/local/bin/kbld && sudo chmod a+x /usr/local/bin/kbld

export INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:54bf611711923dccd7c7f10603c846782b90644d48f1cb570b43a082d18e23b9
export INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com 
export INSTALL_REGISTRY_USERNAME=jellin@pivotal.io
export INSTALL_REGISTRY_PASSWORD=CXlkyyQA389i!

cd $HOME/tanzu-cluster-essentials
	./install.sh --yes

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

docker network inspect -f '{{.IPAM.Config}}' kind

cat > ip-config.yaml << EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: example
  namespace: metallb-system
spec:
  addresses:
  - 172.18.255.200-172.18.255.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: empty
  namespace: metallb-system
EOF


wget https:/s/github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v0.43.2/kctrl-linux-amd64
sudo mv kctrl-linux-amd64 /usr/bin/kctrl
chmod a+x /usr/bin/kctrl

mkdir -p dev/tap
cd dev/tap
git clone https://github.com/tanzu-end-to-end/tap-gitops-reference

export PARAMS_YAML=~/dev/tap/tap-gitops-reference/params.yaml 
kubectl apply -f tanzu-standard.yaml 


for port in 80 443
do
    node_port=$(kubectl get service -n tanzu-system-ingress envoy -o=jsonpath="{.spec.ports[?(@.port == ${port})].nodePort}")

    docker run -d  \
      --publish 0.0.0.0:${port}:${port} \
      --link tap-kind-cluster-control-plane \
      --network="kind" \
      alpine/socat -dd \
      tcp-listen:${port},fork,reuseaddr tcp-connect:172.18.0.3:${node_port}
done
