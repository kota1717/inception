# 永続化データパス
VOLUME = /home/ikota/data
COMPOSE = docker compose -f srcs/docker-compose.yml

all:	up

# @はコマンドを非表示にする
up:	setup
	@sudo mkdir -p $(VOLUME)/mariadb
	@sudo mkdir -p $(VOLUME)/wordpress
	@sudo chmod -R 755 $(VOLUME)/mariadb
	@sudo chmod -R 755 $(VOLUME)/wordpress
	@$(COMPOSE) up -d --build

setup:
	@if [ ! -f .env ]; then \
					cp srcs/.env.example srcs/.env; \
					echo ".env generated from .env.example"; \
	fi
	@mkdir -p secrets
	@if [ ! -f secrets/db_password.txt ]; then \
					tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 16 > secrets/db_password.txt; \
	fi
	@if [ ! -f secrets/db_root_password.txt ]; then \
		tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 16 > secrets/db_root_password.txt; \
	fi
	@if [ ! -f secrets/wp_admin_password.txt ]; then \
		tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 16 > secrets/wp_admin_password.txt; \
	fi
	@if [ ! -f secrets/wp_user_password.txt ]; then \
		tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 16 > secrets/wp_user_password.txt; \
	fi

down:
	@$(COMPOSE) down

stop :
	@$(COMPOSE) stop

restart:
	@$(COMPOSE) restart

start :
	@$(COMPOSE) start

logs:
	@$(COMPOSE) logs -f

clean:
	@$(COMPOSE) down --rmi all --volumes --remove-orphans

fclean: clean
	@rm -f srcs/.env
	@rm -rf secrets/
	@rm -rf $(VOLUME)/mariadb
	@rm -rf $(VOLUME)/wordpress
	@docker system prune -a --volumes -f

re: fclean up
