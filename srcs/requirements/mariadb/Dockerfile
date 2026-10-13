FROM debian:bookworm

RUN: apt-get update && \
		 apt-get install -y mariadb-server \

		 
COPY:


ENTRYPOINT ["entry-point.sh"]

# Dockerfile　Dockerイメージをビルドするための設計図

# FROM: ベースイメージを指定する
# WORKDIR: 作業ディレクトリを設定する
# COPY: ローカルファイルをコンテナ内にコピーする
# RUN: コマンドを実行する（パッケージのインストール）
# CMD: コンテナが起動されたときに実行されるデフォルトのコマンドを指定
# ENTRYPOINT: コンテナに引数を渡しても絶対に最初にコマンドやスクリプトを実行できる
