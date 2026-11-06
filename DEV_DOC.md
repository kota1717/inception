# DEV_DOC.md - Developer Documentation

This document provides guidelines for developers to set up, build, manage, and inspect the Inception infrastructure stack from scratch.

## 1. Development Environment Setup

### Prerequisites

Ensure the host system (Linux / Debian) meets the following requirements:

- **Docker Engine** (v20.10 or higher)
- **Docker Compose** (v2.0 or higher)
- **GNU Make**

### Configuration Files & Directory Structure

The repository follows a strict directory structure as mandated by the subject:

```text
.
├── Makefile
├── DEV_DOC.md
├── README.md
├── USER_DOC.md
├── secrets/               # Auto-generated or custom secret files
|    ├── db_password.txt
|    ├── db_root_password.txt
|    ├── wp_admin_password.txt
|    └── wp_user_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env
    ├── .env.example
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        |   ├── entrypoint.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── nginx.conf
        |   ├── entrypoint.sh
        └── wordpress/
            ├── Dockerfile
            ├── entrypoint.sh
```

### Initializing Environment & Secrets

1. **Clone the Repository:**
   ```bash
   git clone <repository_url> inception && cd inception
   ```

2. **Configure Environment Variables (`srcs/.env`):**
   Create or verify `srcs/.env` with non-sensitive configurations:
   ```env
   DOMAIN_NAME=<login>.42.fr
   MYSQL_DATABASE=wordpress
   MYSQL_USER=wp_user
   WP_ADMIN_USER=admin_user
   WP_ADMIN_EMAIL=admin@example.com
   WP_USER_NAME=normal_user
   WP_USER_EMAIL=user@example.com
   ```

3. **Automatic Directory & Secrets Generation:**
   Running `make` automatically creates necessary persistent data directories under `/home/<login>/data/` and generates secure, random password files inside `srcs/secrets/` if they do not already exist.

   *Note for Developers:* If you wish to set custom credentials, you can manually create or overwrite the plain-text password files in `srcs/secrets/` before starting the containers:
   * `srcs/secrets/db_root_password.txt`
   * `srcs/secrets/db_password.txt`
   * `srcs/secrets/wp_admin_password.txt`
   * `srcs/secrets/wp_user_password.txt`

## 2. Building and Running the Project

All orchestration is managed through the root `Makefile`, which invokes `docker compose` with `srcs/docker-compose.yml`.

### Primary Commands

- **Build and Start (Detached):**
  ```bash
  make
  ```
  *(Creates data host directories, generates secrets if missing, builds image layers, and starts containers in the background.)*

- **Force Rebuild:**
  ```bash
  make re
  ```
  *(Stops running services, removes containers/images/volumes, and executes a clean build.)*

- **Stop Containers (Preserve Data):**
  ```bash
  make down
  ```
  *(Stops containers and removes network attachments, leaving volume directories and generated secrets intact.)*

- **Clean Containers and Images:**
  ```bash
  make clean
  ```

- **Full Cleanup (Including Volumes and Data Directories):**
  ```bash
  make fclean
  ```

## 3. Container & Volume Management Commands

Developers can inspect and manage running resources using standard Docker tools:

### Container Operations

- **View Active Containers:**
  ```bash
  docker ps
  ```

- **View Real-Time Logs:**
  ```bash
  docker logs -f inception_nginx
  docker logs -f inception_wordpress
  docker logs -f inception_mariadb
  ```

- **Execute Interactive Shell Inside Containers:**
  ```bash
  docker exec -it inception_nginx sh
  docker exec -it inception_wordpress bash
  docker exec -it inception_mariadb bash
  ```

### Volume Operations

- **Inspect Mounted Volumes:**
  ```bash
  docker volume ls
  docker volume inspect srcs_wordpress_data
  docker volume inspect srcs_mariadb_data
  ```

## 4. Data Persistence & Storage Architecture

Data persistence is guaranteed by bind-mounting host directories into containers via `srcs/docker-compose.yml`.

### Storage Locations

1. **WordPress Files:**
   * **Host Path:** `/home/<login>/data/wordpress`
   * **Container Path:** `/var/www/html` inside `inception_wordpress`
   * **Contents:** WordPress core files, `wp-config.php`, user uploads, themes, and plugins.

2. **MariaDB Database Files:**
   * **Host Path:** `/home/<login>/data/mariadb`
   * **Container Path:** `/var/lib/mysql` inside `inception_mariadb`
   * **Contents:** MySQL/MariaDB database tables, logs, and system schemas.

### Verifying Persistence

To confirm data survives container destruction:

1. Create a post or comment in WordPress.
2. Destroy containers using `make down` (or `docker compose down`).
3. Re-launch the stack using `make`.
4. Reload the site to confirm the post/comment remains intact on disk at `/home/<login>/data/`.

## 5. Database Inspection & Management

### Logging Into MariaDB Container

To interact with the database directly, connect to the `inception_mariadb` container via `docker exec`:

1. **Access container shell using root credentials:**
   ```bash
   docker exec -it inception_mariadb mariadb -u root -p
   ```
   *(Enter the root password defined in `srcs/secrets/db_root_password.txt` when prompted.)*

2. **Access container shell using the WordPress database user:**
   ```bash
   docker exec -it inception_mariadb mariadb -u <MYSQL_USER> -p
   ```
   *(Enter the password defined in `srcs/secrets/db_password.txt` when prompted.)*

### Verifying Database Content & Tables

Run the following SQL queries inside the MariaDB prompt to verify that the database is properly initialized and not empty:

```sql
-- List available databases
SHOW DATABASES;

-- Select the WordPress database
USE wordpress;

-- Display generated WordPress tables (expecting ~12 tables such as wp_posts, wp_users)
SHOW TABLES;

-- Inspect configured site URL to confirm initialization
SELECT option_name, option_value FROM wp_options WHERE option_name = 'siteurl';

-- Exit MariaDB prompt
EXIT;
```

### One-Line Non-Interactive Inspection

For quick verification during evaluation without entering the interactive prompt:

```bash
docker exec -it inception_mariadb mariadb -u root -p"$(cat srcs/secrets/db_root_password.txt)" -e "USE wordpress; SHOW TABLES;"
```
