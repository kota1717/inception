*This project has been created as part of the 42 curriculum by ikota.*

## Description
This project aims to learn how to set up infrastructure and manage containers using Docker Compose. It builds a web service utilizing NGINX, WordPress, and MariaDB.

- Nginx: an HTTP web server, Known for flexibility and high performance with low resource utilization.
- WordPress: a popular content management system (CMS) that powers over 40% of all websites on the internet. It allows users to manage their websites without needing extensive coding knowledge.
- MariaDB: open source relational database management system. It’s one of the most popular database servers in the world.

### Main design choices

**Separation of Concerns (Single Responsibility Principle)**
Since a container is essentially an isolated process, it is best practice to run only one service per container. The benefits of this architecture include:

- **Scalability:** Each service can be scaled or updated independently.
- **Enhanced Security:** Even if a vulnerability is exploited in one container, the isolation prevents the breach from spreading to other containers.
- **Clear Dependencies:** The relationships and dependencies between services become explicit and easier to manage.

**Security and Secrets Management**
Implemented TLSv1.2 and TLSv1.3 protocols in NGINX. Confidential data, such as database passwords, is securely provided to containers using Docker secrets, while non-sensitive environment variables are handled via a `.env` file.

**Data Persistence**
Ensured data persistence by utilizing Docker named volumes. The database and static website files are stored persistently at specific directory paths on the host machine.

### Comparisons

**Virtual Machines vs Docker**
A Virtual Machine (VM) uses a guest OS to emulate an entire hardware system. In contrast, Docker uses containers, which are essentially isolated processes running directly on the host OS. This isolation is achieved using Linux kernel features like namespaces. Because Docker containers share the host's kernel and do not require a guest OS, they are significantly lighter and faster than VMs.

**Secrets vs Environment Variables**
Storing confidential data in environment variables poses significant security risks. Therefore, this project strictly utilizes Docker Secrets for sensitive information.
Docker Secrets mount sensitive data as read-only files inside the container at `/run/secrets/<secret_name>`. The `docker-compose.yml` file explicitly defines which services have access to which secrets, ensuring strict access control.

The primary risks of managing secrets with environment variables include:
- **Process Exposure:** It is difficult to track or restrict which child processes inherit environment variables.
- **Accidental Leaks:** Applications often dump all environment variables for debugging purposes, risking the exposure of secrets in plain text.
- **Crash Logs:** Environment variables are frequently recorded in log files or memory dumps when an application crashes.

**Docker Network vs Host Network**
Docker Network (Bridge) provides an isolated internal network for containers. Since containers run in isolated namespaces, they cannot see each other by default. A Docker network bridges this gap. Its most significant advantage is the built-in DNS resolution, which allows containers to communicate using their container names rather than static IP addresses.

In contrast, using the **Host Network** mode removes network isolation, meaning containers share the host machine's IP address and network namespace. This approach can cause port conflicts and lacks automatic service discovery (DNS).

**Docker Volumes vs Bind Mounts**
Bind mounts are a mechanism that directly maps a specific path on the host machine's file system to a directory inside a Docker container.

The primary difference from Docker volumes is the entity managing the host directories and files. With Docker volumes, Docker automatically creates and manages the directory in a secure area on the host (e.g., `/var/lib/docker/volumes/`). In contrast, bind mounts are user-managed; an error will occur if the specified path does not exist on the host OS.

Bind Mounts の例：

```yaml
services:
  frontend:
    image: node:lts
    volumes:
      - type: bind
        source: ./static
        target: /opt/app/static
volumes:
  myapp:
```

## Instructions
Navigate to the root directory of the project and run the following command to build and start the application:

```bash
make up
```

To access WordPress, enter the following URL into your browser:
`https://localhost`

A warning screen stating "Your connection is not private" will appear. You can safely ignore this. Click on "Advanced" (or equivalent) and proceed to the site to open WordPress.

To remove the containers and the created directories, execute:

```bash
make fclean # or make clean
```

## Resources
- [Docker Compose tutorial series](https://knowledge.sakura.ad.jp/21387/)
- [Docker reference](https://docs.docker.com/reference)
- [Understanding Linux namespaces](https://container-security.dev/namespace/)
- [PHP-FPM configuration](https://qiita.com/kotarella1110/items/634f6fafeb33ae0f51dc)
- [Relationship between ENTRYPOINT and CMD](https://tech.enechange.co.jp/entry/2022/10/25/100000)
- [Meaning of Bind Address](https://keens.github.io/blog/2016/02/24/bind_addressnoimigayouyakuwakatta/)
- [Handling SIGTERM when running as PID 1](https://ngzm.hateblo.jp/entry/2017/08/22/185224)
- [About Docker restart policies](https://yk5656.hatenablog.com/entry/20201122/1605970800)
- [Inception project guide](https://zenn.dev/mizusato27/scraps/44a8c2ac6be067)
- [What are Bind mounts?](https://docs.docker.jp/storage/bind-mounts.html)

* **AI Usage:** I used an AI assistant (Google Gemini) primarily for debugging and translating conceptual drafts into English. Specifically, I utilized it to:
  1. Debugging Docker Compose & Configuration Issues:
    Diagnosed runtime errors, network misconfigurations, and volume mount issues (e.g., verifying Docker Compose v2 syntax, bind mount paths, and service dependency ordering).

  2. Automating & Debugging Environment Setup:
    Resolved path reference errors in Makefile and debugged shell script execution flows used for secret generation and dynamic container initialization.
