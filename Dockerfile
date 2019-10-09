FROM alpine:3.8
RUN apk add --no-cache bash nodejs npm
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
