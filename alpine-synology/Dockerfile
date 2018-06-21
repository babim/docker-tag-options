FROM babim/apache:alpine

RUN deluser xfs && delgroup www-data && \
    addgroup -g 1023 www-data && adduser -D -H -G www-data -s /bin/false -u 1024 www-data