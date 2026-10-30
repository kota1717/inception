FROM debian:bookworm

RUN apt-get update && apt-get install -y mariadb-server &&\
		rm -rf /var/lib/apt/lists/*
# 外部からの接続を許可する設定に変更（デフォルトは 127.0.0.1 のみ許可）
RUN sed -i 's/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

COPY ./entry-point.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# PID / ソケットファイル用の置き場を作成し、mysql ユーザーに権限付与
RUN mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

ENTRYPOINT ["entrypoint.sh"]

# FROM: ベースイメージを指定する
# WORKDIR: 作業ディレクトリを設定する
# COPY: ローカルファイルをコンテナ内にコピーする
# RUN: コマンドを実行する（パッケージのインストール）
# CMD: コンテナが起動されたときに実行されるデフォルトのコマンドを指定
# ENTRYPOINT: コンテナに引数を渡しても絶対に最初にコマンドやスクリプトを実行できる
