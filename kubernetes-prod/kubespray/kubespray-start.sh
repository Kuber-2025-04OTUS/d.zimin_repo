#!/bin/sh

# https://github.com/kubernetes-sigs/kubespray

# Clone kubespray repo
git clone https://github.com/kubernetes-sigs/kubespray.git kubespray && cd kubespray && git checkout v2.28.0

docker run --rm -it --mount type=bind,source="$(pwd)"/inventory/sample,dst=/inventory \
  --mount type=bind,source="${HOME}"/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
  quay.io/kubespray/kubespray:v2.28.0 bash

ansible -i /inventory/inventory.ini all -b -m shell -a "rm -f /var/lib/apt/lists/lock"

ansible-playbook -i /inventory/inventory.ini --private-key /root/.ssh/id_rsa cluster.yml