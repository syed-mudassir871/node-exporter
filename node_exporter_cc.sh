#!/bin/bash

# Author: Ali Armaghan
# Role: Site Reliability Engineer
# Company: Cooperative Computing Company

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update package lists
apt update

# Install necessary packages
apt install -y curl wget tar

# Create a system user for Prometheus Node Exporter
useradd --no-create-home --shell /bin/false node_exporter

# Download Prometheus Node Exporter
NODE_EXPORTER_VERSION="1.7.0" # Change this to the latest version if needed
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Extract the downloaded file
tar -xzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

# Move Node Exporter binary to /usr/local/bin and set permissions
mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Clean up
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64

# Create systemd service file for Node Exporter
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to detect the new service
systemctl daemon-reload

# Start Node Exporter and enable it to start on boot
systemctl start node_exporter
systemctl enable node_exporter

echo "Prometheus Node Exporter has been installed successfully!"