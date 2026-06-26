DATA_DIR		:= $(HOME)/data
MARIADB_DIR		:= $(DATA_DIR)/mariadb
WORDPRESS_DIR	:= $(DATA_DIR)/wordpress
DOCKER_COMPOSE	:= ./srcs/docker-compose.yml

all:
	mkdir -p $(MARIADB_DIR)
	mkdir -p $(WORDPRESS_DIR)
	docker compose -f $(DOCKER_COMPOSE) up --build -d

up:
	docker compose -f $(DOCKER_COMPOSE) up --build -d

down:
	docker compose -f $(DOCKER_COMPOSE) down

clean:
	docker compose -f $(DOCKER_COMPOSE) down -v --rmi all --remove-orphans

fclean: clean
	sudo rm -rf $(HOME)/data/mariadb/
	sudo rm -rf $(HOME)/data/wordpress/
	docker system prune -af

logs:
	docker compose -f $(DOCKER_COMPOSE) logs

status:
	docker compose -f $(DOCKER_COMPOSE) ps

re: fclean all

.PHONY: all up down clean fclean logs status re
