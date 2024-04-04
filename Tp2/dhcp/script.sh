#!/bin/bash

sudo echo 'nameserver 1.1.1.1' > /etc/resolv.conf

sudo dnf install dhcp-server -y

echo 'subnet 10.0.2.0 netmask 255.255.255.0 {
    range 10.1.1.100 10.1.1.200;
    option routers 10.1.1.1;
    option domain-name-servers 1.1.1.1;

    class "pxeclients" {
        match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
        next-server 10.1.1.11;
        filename "pxelinux.0";
    }
}' > /etc/dhcp/dhcpd.conf

sudo systemctl start dhcpd

sudo firewall-cmd --add-service=dhcp --permanent

sudo firewall-cmd --reload

sudo dnf install tftp-server -y

sudo systemctl enable --now tftp.socket