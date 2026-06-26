# Developer Documentation

## Prerequisites
- VirtualBox with an Alpine Linux VM
- Docker and docker-cli-compose installed on the VM
- Git

## Evaluation Setup

### 1. SSH into the VM
From the host machine:
```bash
ssh -X krepo@10.x.x.x
```

### 2. Configure the host domain
Run this on the **host machine** (not the VM):
```bash
echo "127.0.0.1 krepo.42.fr" | sudo tee -a /etc/hosts
```

### 3. Clone the repository
```bash
git clone <repo_url> ~/Inception
cd ~/Inception
```

### 4. Create secrets
```bash
mkdir -p ~/inception/secrets
printf 'YOUR_DB_PASSWORD'       > ~/inception/secrets/db_password.txt
printf 'YOUR_DB_ROOT_PASSWORD'  > ~/inception/secrets/db_root_password.txt
printf 'YOUR_WP_ADMIN_PASSWORD' > ~/inception/secrets/wp_admin_password.txt
printf 'YOUR_WP_USER_PASSWORD'  > ~/inception/secrets/wp_user_password.txt
```

### 5. Create the .env file
```bash
cat > ~/inception/srcs/.env << 'EOF'
# paste content here
EOF
```

### 6. Transfer files from local to VM (if needed)
```bash
scp -r sanity krepo@10.x.x.x:/home/krepo/
```

### 7. Build and start
```bash
make all
```

## Makefile Usage
| Target       | Description                              |
|--------------|------------------------------------------|
| `make all`   | Build images and start all containers    |
| `make up`    | Start containers with rebuild            |
| `make down`  | Stop and remove containers               |
| `make clean` | Remove containers, volumes and images    |
| `make fclean`| Full clean including build cache         |
| `make re`    | Full rebuild from scratch                |
| `make logs`  | Show container logs                      |
| `make status`| Show container status                    |

## Data Persistence
Volume data is stored on the host at:
- `/home/krepo/data/mariadb`
- `/home/krepo/data/wordpress`

These persist across restarts and reboots.
To fully reset, run `make fclean` and delete these directories.
