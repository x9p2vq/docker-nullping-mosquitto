FROM alpine:latest
LABEL maintainer "Jason Mitchell <jason@nullping.net>"
LABEL description="secure mosquitto server"


# create necessary user and group first
RUN addgroup -g 10004 -S mqtt
RUN adduser -G mqtt -H -D -S -u 10004 mqtt

# update image and install required packages
RUN apk --no-cache update && apk --no-cache add mosquitto openssl

# setup unbound directories and files
RUN mkdir -p /nullping
COPY ./config /nullping
COPY ./entrypoint.sh /entrypoint.sh

# expose necesssary ports
EXPOSE 8883/tcp

# final steps and clean up
RUN rm -rf /var/cache/apk/*
RUN chown -R -f -c mqtt:mqtt /nullping
RUN chown mqtt:mqtt ./entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

