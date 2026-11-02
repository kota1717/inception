FROM debian:bookworm

RUN apt-get update && apt-get install -y  \
		php8.2-fpm \
		php8.2-mysql \
		php8.2-curl \
		php8.2-gd \
		php8.2-intl \
		php8.2-mbstring \
		php8.2-xml \
		php8.2-zip \
		mariadb-client \
		netcat-openbsd \
		curl \
		&& rm -rf /var/lib/apt/lists/*

# WP-CLIのダウンロードと配置
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# listen設定変更　9000番ポート
RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|g' /etc/php/8.2/fpm/pool.d/www.conf

# entyr
COPY entrypoint.sh /usr/local/bin
RUN chmod +x /usr/local/bin/entrypoint.sh

# PHP-FPMの実行に必要なソケットディレクトリを作成
RUN mkdir -p /run/php

WORKDIR /var/www/html

EXPOSE 9000

# PHP-FPMをフォアグラウンドで起動
ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm8.2", "-F"]
