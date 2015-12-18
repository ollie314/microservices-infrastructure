#!/bin/bash
set -ex

control_ip=$1
worker_ip=$2

# Add control and worker to hosts file if they aren't there
grep -q "control-01" /etc/hosts || echo "$control_ip   control-01" >> /etc/hosts
grep -q "worker-001" /etc/hosts || echo "$worker_ip    worker-001" >> /etc/hosts

# Ensure hosts are reachable before executing Ansible
for host in control-01 worker-001; do
  if ! ping -c 3 "$host" > /dev/null; then
    echo "Couldn't ping $host from provisioning VM ($(hostname))."
    exit 1
  fi
done

yum makecache
# enable EPEL and get sshpass if it's not already installed
if ! sshpass; then
  curl -O http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
  rpm -ivh epel-release-7-5.noarch.rpm
  yum install -y --enablerepo=epel sshpass
fi

# Install required packages if they aren't already present
for pkg in gcc python-virtualenv libselinux-python; do
  yum list installed "$pkg" || yum install -y "$pkg"
done
pip --version || easy_install pip

# Make a new python virtualenv
if ! source /tmp/env/bin/activate; then
  cd /tmp
  virtualenv env --system-site-packages
  env/bin/pip install -r /vagrant/requirements.txt
  source env/bin/activate
fi

cd /vagrant

# security.yml and ssl/ are stored in a directory that is preserved across
# reboots/reloads/rsyncs
semi_permanent=/security-backup
mkdir -p "$semi_permanent"

if [ ! -f security.yml ] || [ ! -d ssl/ ]; then
  # If there are backups, restore them here
  if [ -f $semi_permanent/security.yml ] && [ -d $semi_permanent/ssl/ ]; then
    cp    $semi_permanent/security.yml .
    cp -a $semi_permanent/ssl .
  else
    # Otherwise, create new ones and back them up
    ./security-setup --enable=false
    cp    security.yml $semi_permanent
    cp -a ssl $semi_permanent
  fi
fi

# construct a valid inventory for these two hosts
cat <<EOF > ./vagrant/inventory
# All playbook variables can be overwritten in playbooks, so only defaults can
# be set here
control-01  public_ipv4=$control_ip  private_ipv4=$control_ip  ansible_ssh_host=$control_ip  role=control
worker-001  public_ipv4=$worker_ip  private_ipv4=$worker_ip  ansible_ssh_host=$worker_ip  role=worker

[role=control]
control-01

[role=control:vars]
consul_is_server=true

[role=worker]
worker-001

[role=worker:vars]
consul_is_server=false

[dc=vagrantdc]
control-01
worker-001

[dc=vagrantdc:vars]
ansible_ssh_user=vagrant
ansible_ssh_pass=vagrant
consul_dc=vagrantdc
provider=virtualbox
publicly_routable=true
EOF

ansible-playbook terraform.sample.yml -e @security.yml -i ./vagrant/inventory
