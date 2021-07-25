#!/bin/sh

# set script name for loggin purposes.
me=$(basename $0)

# ssl directory that contains ca and server keys/certs
dir_ssl="/runtime/mosquitto/ssl"
if [ ! -d "$dir_ssl" ]; then
  echo "$me: creating ssl directory for locally generated ca and server certificates."
  mkdir -p $dir_ssl
fi

# setup runtime environment
mkdir -p /runtime/mosquitto /runtime/mosquitto/data
cp -R -u /nullping/* /runtime/mosquitto/.

# check for ca certificate
CA_CERT=0
if [ -f "$dir_ssl/ca.crt" ]; then
  CA_CERT=1
fi

# check for mqtt server certificate
MQTT_CERT=0
if [ -f "$dir_ssl/mqtt.crt" ]; then
  MQTT_CERT=1
fi

# check for mqtt server key
MQTT_KEY=0
if [ -f "$dir_ssl/mqtt.key" ]; then
  MQTT_KEY=1
fi

# do cert generation if not certs found
if [ $CA_CERT -gt 0 ] && [ $MQTT_CERT -gt 0 ] && [ $MQTT_KEY -gt 0 ]; then
  echo "$me: found ca cert and mqtt server key/cert. skipping key/cert generation!"
else
  echo "$me: missing ca cert and mqtt server key/cert. proceeding with key/cert generation!"
  if [ -f "$dir_ssl/ca-cert.conf" ]; then
    CA_CERT_CONF="$dir_ssl/ca-cert.conf"
  else
    CA_CERT_CONF="/nullping/ca-cert.conf"
  fi
  if [ -f "$dir_ssl/mqtt-cert.conf" ]; then
    MQTT_CERT_CONF="$dir_ssl/mqtt-cert.conf"
  else
    MQTT_CERT_CONF="/nullping/mqtt-cert.conf"
  fi

  echo "$me: found ca-certs.conf and mqtt-certs.conf files."
  echo "$me: proceeding to create self-signed certificates based on ca-certs.conf and mqtt-certs.conf."
  openssl req -new -x509 -days 3650 -config $CA_CERT_CONF -keyout $dir_ssl/ca.key -out $dir_ssl/ca.crt
  openssl req -new -config $MQTT_CERT_CONF -keyout $dir_ssl/mqtt.key -out $dir_ssl/mqtt.csr
  openssl x509 -req -in $dir_ssl/mqtt.csr -CA $dir_ssl/ca.crt -CAkey $dir_ssl/ca.key -CAcreateserial -out $dir_ssl/mqtt.crt -days 3650 -sha256
fi


# reset to default password if missing.
if [ ! -f "/runtime/mosquitto/shadow" ] && [ ! -f "/runtime/mosquitto/passwd" ]; then
  echo "$me: no shadow file found. creating shadow file with default username and password."
  echo "root:root" > /runtime/mosquitto/shadow
  mosquitto_passwd -U /runtime/mosquitto/shadow
fi

# generate new password file if present.
if [ -f "/runtime/mosquitto/passwd" ]; then
  echo "$me: found new password file. generating shadow file amd replacing existing file."
  mosquitto_passwd -U /runtime/mosquitto/passwd
  mv /runtime/mosquitto/passwd /runtime/mosquitto/shadow
fi


# ensure runtime permissions are correct.
chown -R -f -c mqtt:mqtt /runtime/mosquitto

# Start Mosquitto Broker
#
# Usage: mosquitto [-c config_file] [-d] [-h] [-p port]
# 
#  -c : specify the broker config file.
#  -d : put the broker into the background after starting.
#  -h : display this help.
#  -p : start the broker listening on the specified port.
#       Not recommended in conjunction with the -c option.
#  -v : verbose mode - enable all logging types. This overrides
#       any logging options given in the config file.
# 
# See https://mosquitto.org/ for more information.
# 
echo "$me: starting mosquitto broker..."
/usr/sbin/mosquitto -c /runtime/mosquitto/mosquitto.conf 
