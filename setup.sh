#/!/bin/sh


# Create shell script
mkdir /opt/fixbond && cd /opt/fixbond
touch fixbond.sh
echo <<EOF
ip link set ens3 down
ip link set ens4 down
ethtool -s ens3 autoneg off speed 1000 duplex full
ethtool -s ens4 autoneg off speed 1000 duplex full
ip link set ens3 up
ip link set ens4 up
netplan apply
#
cat /proc/net/bonding/bond0
EOF > fixbond.sh

chmod +x fixbond.sh

# Create service to run on boot
touch /etc/systemd/system/fixbond.service 
echo <<EOF
[Unit]
After=network.target

[Service]
ExecStart=/opt/fixbond/fixbond.sh

[Install]
WantedBy=default.target
EOF > /etc/systemd/system/fixbond.service
chmod 664 /etc/systemd/system/fixbond.service
chown root:root /etc/systemd/system/fixbond.service

# Reload and enable service
systemctl daemon-reload
systemctl enable fixbond.service


