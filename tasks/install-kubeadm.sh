#!/bin/bash

set -eu

CNI_VERSION="v0.6.0"
sudo mkdir -p /opt/cni/bin
sudo curl -L "https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" | sudo tar -C /opt/cni/bin -xz

CRICTL_VERSION="v1.11.1"
sudo mkdir -p /opt/bin
sudo curl -L "https://github.com/kubernetes-incubator/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" | sudo tar -C /opt/bin -xz

RELEASE="$(curl -sSL https://dl.k8s.io/release/stable.txt)"

cd /opt/bin
sudo curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/${RELEASE}/bin/linux/amd64/{kubeadm,kubelet,kubectl}
sudo chmod +x {kubeadm,kubelet,kubectl}

sudo curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/kubelet.service" | sudo bash -c 'sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service'
sudo mkdir -p /etc/systemd/system/kubelet.service.d
sudo curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/10-kubeadm.conf" | sudo bash -c 'sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf'

sudo systemctl enable kubelet

/opt/bin/kubeadm config images pull
