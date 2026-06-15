# Developer Documentation

## Prerequisites
- VirtualBox with an Alpine Linux VM
- Docker and docker-cli-compose installed on the VM
- Git

## Setup
1. Clone the repository inside the VM
2. Create secrets files (see secrets/README.md)
3. Add krepo.42.fr to /etc/hosts on the host machine

## Makefile usage
make all	- Build images and start all containers
make up		- Start containers with rebuild
make down	- Stop and remove containers
make clean	- Remove containers volumes and images
make fclean	- Full clean including build cache
make re		- Full rebuild from scratch
make logs	- Show container logs
make status	- Show container status

## Data persistence
Volume data is stored on host at:
- /home/krepo/data/mariadb
- /home/krepo/data/wordpress

These presist across restarts and reboots.
To fully reset run make fclean and delete these directories.
