To create a customer local CA and self-signed cert, modify these files and add the following volume mapping in the [docker-compose.yml]( https://github.com/x9p2vq/docker-nullping-mosquitto/docker-compose.yaml).

"./data/ssl:/runtime/mosquitto/ssl"

When you restart the container (or bring it up for the first time) it will create the ca and mqtt server certs in **./data/ssl**.
