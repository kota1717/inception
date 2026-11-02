# USER_DOC.md - User & Administrator Guide

This document explains how to run, manage, and verify the services provided by this infrastructure stack.

## 1. Provided Services (Services in the Stack)

This infrastructure stack delivers a secure, containerized WordPress publishing environment built with Docker Compose:

* **Nginx (TLS/SSL Proxy):**
  Acts as the sole HTTPS entry point (Port 443). Handles TLS v1.2/v1.3 termination and securely proxies web requests to WordPress.

* **WordPress (Application Server):**
  Runs the WordPress core application using PHP-FPM on Port 9000 (isolated internally).

* **MariaDB (Database):**
  Database management system running on Port 3306 (isolated internally). Persists all site data and configurations.

## 2. Start and Stop the Project

All operational commands are executed from the root of the repository via `Makefile`.

* **Start the stack:**
  ```bash
  make
  # or
  make up
  ```
  *Building images and starting containers in detached mode.*

* **Stop the stack (preserving data):**
  ```bash
  make down
  # or
  make stop
  ```
  *Stops and removes containers while keeping database and website data intact in `/home/<login>/data/`.*

* **Reset & Clean Rebuild (Warning: Data Reset):**
  ```bash
  make re
  ```
  *Cleans containers, images, and volumes before performing a fresh initialization.*

## 3. Access the Website and Administration Panel

### Prerequisites for Access
Replace `<login>` with your 42 user login name. Add the domain to your host/local `/etc/hosts` file (or access directly via local IP if `/etc/hosts` cannot be modified):
```text
127.0.0.1 <login>.42.fr
```

### Access URLs
* **Public Website:**
  `https://<login>.42.fr` (or `https://127.0.0.1`)
* **WordPress Administration Panel:**
  `https://<login>.42.fr/wp-admin` (or `https://127.0.0.1/wp-admin`)

> **Note on SSL Warning:**
> The site uses a self-signed TLS certificate. If your browser shows a security warning, expand **Advanced** and click **Proceed to <login>.42.fr (unsafe)** 

## 4. Locate and Manage Credentials & Secrets

Environment variables and secret credentials are handled securely via environment configuration files and Docker secrets.

### Non-Sensitive Settings (`srcs/.env`)
General configurations such as user names, database names, and domain definitions are stored in `srcs/.env`:
* **MariaDB Database & User:** `MYSQL_DATABASE`, `MYSQL_USER`
* **WordPress Users:** `WP_ADMIN_USER`, `WP_ADMIN_EMAIL`, `WP_USER_NAME`, `WP_USER_EMAIL`

### Sensitive Credentials (`secrets/` directory)
Sensitive passwords must be managed using secret files located under the `secrets/` directory (or passed via Docker secrets):
* **MariaDB Root Password:** `secrets/db_root_password.txt`
* **MariaDB User Password:** `secrets/db_password.txt`
* **WordPress Admin Password:** `secrets/wp_admin_password.txt`
* **WordPress User Password:** `secrets/wp_user_password.txt`

### Managing Credentials
To update or modify passwords and user information:
1. Update the appropriate file in `secrets/` or modify `srcs/.env`.
2. Re-initialize the stack with `make re` to apply changes on a clean environment.

## 5. Check Service Health and Status

Run the following commands on the host machine to verify that all services are operational:

### A. Check Container Status
```bash
docker ps
```
*Verification:* Ensure `nginx`, `wordpress`, and `mariadb` containers all show a status of **`Up`**.

### B. Verify Internal Network Connectivity
Run inter-container port checks from within the containers:
```bash
# Verify Nginx can reach WordPress (Port 9000)
docker exec -it inception_nginx nc -zv wordpress 9000

# Verify WordPress can reach MariaDB (Port 3306)
docker exec -it inception_wordpress nc -zv mariadb 3306
```
*Verification:* Both commands should report an **open / succeeded** connection.

### C. Verify HTTPS Response
Test local HTTPS connectivity and TLS certificate response:
```bash
curl -kv https://<login>.42.fr
# or
curl -kv https://localhost
```
*Verification:* The response should return an `HTTP/1.1 200 OK` or `302` header along with WordPress HTML output.
