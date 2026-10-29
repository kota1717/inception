FROM debian:bookworm

RUN apt-get update && apt-get install -y  \
		php-fpm \
		php-mysql \
		curl \
		&& rm -rf /var/lib/apt/lists/*

RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|g' /etc/php/8.2/fpm/pool.d/www.conf

# PHP-FPMの実行に必要なソケットディレクトリを作成
RUN mkdir -p /run/php

# PHP-FPMをフォアグラウンドで起動
CMD ["php-fpm8.2", "-F"]
