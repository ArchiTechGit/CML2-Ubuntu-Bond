#/!/bin/sh

# Create shell script

if test -d /opt/fixbond; then
  echo "Directory exists."
else
  echo "Directory does not exist. Creating directory."
  mkdir /opt/fixbond
fi
cd /opt/fixbond/
cat <<EOF > fixbond.sh
#!/bin/sh
ip link set ens3 down
ip link set ens4 down
ethtool -s ens3 autoneg off speed 1000 duplex full
ethtool -s ens4 autoneg off speed 1000 duplex full
ip link set ens3 up
ip link set ens4 up
netplan apply
#
cat /proc/net/bonding/bond0
EOF

chmod +x fixbond.sh

# Create service to run on boot
cd /etc/systemd/system/
cat <<EOF > /etc/systemd/system/fixbond.service
[Unit]
After=network.target

[Service]
ExecStart=/opt/fixbond/fixbond.sh

[Install]
WantedBy=default.target
EOF

chmod 664 /etc/systemd/system/fixbond.service
chown root:root /etc/systemd/system/fixbond.service

# Reload and enable service
systemctl daemon-reload
systemctl enable fixbond.service
service fixbond start


