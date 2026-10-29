FROM debian:bookworm

RUN apt-get update && apt-get install -y  \
		php-fpm \
		php-mysql \
		curl

COPY www.conf /etc/php/8.2/fpm/pool.d/.
COPY script.sh .

RUN chmod +x script.sh

CMD ["./script.sh"]
