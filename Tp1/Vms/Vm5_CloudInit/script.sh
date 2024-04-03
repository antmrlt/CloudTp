sudo echo 'nameserver 1.1.1.1' > /etc/resolv.conf

sudo dnf update -y

sudo dnf install -y cloud-init

sudo systemctl enable cloud-init