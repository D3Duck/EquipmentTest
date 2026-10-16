# Equipment Hire

A portfolio equipment-hire application built with Svelte 5, Go/Fiber, PostgreSQL, Atlas, Docker, and Caddy. It demonstrates role-based access, physical inventory, transactional booking, real-time updates, testing, and cloud deployment.

[Live demo](https://testequipment.duckdns.org/)

## Demo accounts

Sign in with `customer1`, `customer2`, `employee`, `storeadmin`, or `admin`. Every demo account uses the fictional password `password`.

## Run locally

The committed configuration contains demo-only local values.

```bash
docker compose up --build --detach
docker compose ps
```

## Deploy to Azure or AWS

Pushes to `main` publish `ghcr.io/d3duck/equipmenttest:<commit-sha>`. Both cloud flows use the same PostgreSQL, migration, application, and Caddy HTTPS stack.

On an Ubuntu VM, point the domain at the VM, allow inbound TCP 22, 80, and 443, clone this repository to `/opt/equipment-app`, and run the matching command from that directory:

| Provider | First deployment | Later updates |
| --- | --- | --- |
| Azure | `sudo DOMAIN=your-domain.example.com bash scripts/bootstrap-azure.sh` | `sudo bash scripts/deploy-azure.sh` |
| AWS EC2 | `sudo DOMAIN=your-domain.example.com bash scripts/bootstrap-ec2.sh` | `sudo bash scripts/deploy-ec2.sh` |

Before an update, run `git pull --ff-only origin main`; the deployment script uses the checked-out commit SHA as the application image tag.

Bootstrap installs Docker when needed, generates the root-only production configuration, and starts the stack. Updates back up PostgreSQL, apply migrations, replace the application image, and run health checks. Keep PostgreSQL and the application port private; Caddy is the public entry point.

See [Development and deployment](<documentation/dev documentation.md>) for GitHub Container Registry authentication, firewall details, verification, backups, and rollback.

## Documentation

- [Product scope and acceptance criteria](<documentation/plan document.md>)
- [Authentication API](<documentation/authentication API.md>)
- [Catalogue API](<documentation/catalogue API.md>)
