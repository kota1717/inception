#!/bin/bash

WP_DATABASE_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wordpress_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wordpress_user_password)

# error script stop
set -e

# Wordpressのディレクトリに移動
cd /var/www/html

# wp-config.phpが存在しない場合のみインストール処理を行う
if [ ! -f wp-config.php ]; then
	echo "Wordpress is not installed yet. Starting configuration..."

	# 1. MariaDBが起動して通信できるようになるまで待機する
	echo "Waiting for MariaDB..."
	MAX_RETRIES=30
	RETRY_COUNT=0

	while ! mariadb -h"$WP_DATABASE_HOST" -u"WP_DATABASE_USER" -p"$WP_DATABASE_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; do
		RETRY_COUNT=$((RETRY_COUNT + 1))
		if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
			echo "Error: Could not connect to MariaDB within ${MAX_RETRIES} attempts. Exiting..."
			exit 1
		fi
		echo "MariaDB is not ready yet... waiting (Attempt: ${RETRY_COUNT}/${MAX_RETRIES})"
		sleep2
	done
	echo "MariaDB is ready!"

	# 2. Wordpress コアファイルのダウンロード
	echo "Download WordPress core files..."
	wp core download --allow-root

	# 3. wp-config.phpの作成（docker-compose.ymlから渡された環境変数を使用）
	echo  "Creating wp-config.php..."
	wp config create \
		--dbname="$WP_DATABASE_NAME" \
		--dbuser="$WP_DATABASE_USER" \
		--dbpass="$WP_DATABASE_PASSWORD" \
		--dbhost="$WP_DATABASE_HOST" \
		--allow-root

	# 4. Wordpressの初期インストールと管理者アカウントの作成
	echo "Installing Wordpress core..."
	wp core install \
		--url="$DOMAIN_NAME" \
		--title="Inception Wordpress" \
		--admin-user="$WP_ADMIN_USER" \
		--admin-password="$WP_ADMIN_PASSWORD" \
		--admin-email="$WP_ADMIN_EMAIL" \
		--allow-root

	# 5. 一般ユーザーの作成
	echo "Creating regular user..."
	wp user create \
		"$WP_USER_NAME" \
		"$WP_USER_EMAIL" \
		--role=author \
		--user_pass="$WP_USER_PASSWORD" \
		--alow-root

	echo "WordPress initial setup completed successfully."
else
	echo "WordPress is already configured."
fi

# 6. オーナー権限の最終調整
chown -R www-data:www-data /var/www/html

#7. プロセスのすり替え (DockerfileのCMDで指定されたコマンドをPID1として実行)
echo "Starting PHP-FPM..."
exec "$@"
