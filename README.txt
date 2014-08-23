lxc-create -n NAME -t debian -- -r wheezy
cd /var/lib/lxc/NAME/
vi config

add the following:
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = br0
lxc.network.ipv4 = 10.255.0.X/24
lxc.network.hwaddr = 00:00:00:00:00:0X
lxc.network.ipv4.gateway = 10.255.0.1

update the address and hwaddr's last digit to the number of the container

vi rootfs/etc/network/interfaces

change the iface to:
auto eth0
iface eth0 inet static
    address 10.255.0.X
    netmask 255.255.255.0
    gateway 10.255.0.1

start the container in the background:
lxc-start -d -n NAME

ssh root@10.255.0.X (password is "root")
passwd root, replace it and record it
replace /etc/apt/sources.list with

deb http://ftp.bg.debian.org/debian wheezy main contrib non-free
deb-src http://ftp.bg.debian.org/debian wheezy main contrib non-free

deb http://security.debian.org/ wheezy/updates main
deb-src http://security.debian.org/ wheezy/updates main

# wheezy-updates, previously known as 'volatile'
deb http://debian.ludost.net/debian/ wheezy-updates main
deb-src http://debian.ludost.net/debian/ wheezy-updates main

apt-get update
apt-get -y dist-upgrade
apt-get -y install vim iputils-ping python python-pip gcc libc6-dev python-dev git


exit the container

vi /etc/rc.local, add
iptables -t nat -A PREROUTING -i eth0 -p tcp -m tcp --dport 220X -j DNAT --to-destination 10.255.0.X:22

run the iptables command 

