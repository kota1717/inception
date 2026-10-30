FROM debian:bookworm

RUN apt-get update && apt-get install -y  \
		php-fpm \
		php-mysql \
		curl \
		&& rm -rf /var/lib/apt/lists/*

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|g' /etc/php/8.2/fpm/pool.d/www.conf

# PHP-FPMの実行に必要なソケットディレクトリを作成
RUN mkdir -p /run/php

# PHP-FPMをフォアグラウンドで起動
ENTRYPOINT ["entrypoint.sh"]
