#!/bin/bash

# Clone the iot-docker repository from GitHub
git clone https://github.com/DO-Solutions/iot-docker

# Change directory to iot-docker and checkout the main branch
cd iot-docker && git checkout master 

# Set environment variables with random values and modify docker-compose.yml and telegraf.conf
# with these values for InfluxDB and Grafana configuration
export INFLUXDB_ADMIN_TOKEN=$(openssl rand -hex 24)
export INFLUXDB_USERNAME=$(openssl rand -hex 16)
export INFLUXDB_PASSWORD=$(openssl rand -hex 16)
sed -i 's/DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=/DOCKER_INFLUXDB_INIT_ADMIN_TOKEN='$INFLUXDB_ADMIN_TOKEN'/g' docker-compose.yml
sed -i 's/DOCKER_INFLUXDB_INIT_USERNAME=/DOCKER_INFLUXDB_INIT_USERNAME='$INFLUXDB_USERNAME'/g' docker-compose.yml
sed -i 's/DOCKER_INFLUXDB_INIT_PASSWORD=/DOCKER_INFLUXDB_INIT_PASSWORD='$INFLUXDB_PASSWORD'/g' docker-compose.yml
sed -i 's/token = ""/token = "'$INFLUXDB_ADMIN_TOKEN'"/g' telegraf.conf
echo '      token: '"$INFLUXDB_ADMIN_TOKEN" >> grafana-provisioning/datasources/automatic.yml

# Run docker-compose in detached mode
docker-compose up -d

# Sleep for 10 seconds to allow InfluxDB and Grafana to start
# Securely generate Grafana admin password and reset it
sleep 10
export GRAFANA_PASSWORD=$(openssl rand -hex 16)
docker exec grafana grafana-cli admin reset-admin-password "$GRAFANA_PASSWORD"
mkdir /iot-docker
echo $GRAFANA_PASSWORD > /iot-docker/grafanapassword.txt
