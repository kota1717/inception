FROM debian:bookworm

RUN apt-get update && apt-get install -y \
		nginx \
		openssl \
		&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=JP/ST=Tokyo/L=Inception/O=42/OU=42/CN=ikota.42.fr/UID=ikota"

COPY ./nginx.conf /etc/nginx/sites-available/default

CMD ["nginx", "-g", "daemon off;"]
