# Quick Start Guide

## Your Environment is Ready!

All services are running and Molecule testing is working perfectly. Here's how to use your new Ansible development environment.

## What's Running

```bash
# Check status
docker compose ps

# You should see:
# - ansible-dev (your development container)
# - semaphore (Ansible web UI)
# - netbox (network management UI)
# - semaphore-postgres (Semaphore database)
# - netbox-postgres (Netbox database)
# - netbox-redis (cache)
```

## Web Interfaces

- **Semaphore (Ansible UI):** http://localhost:3000 (admin/admin)
- **Netbox:** http://localhost:8000 (admin/admin)

## Quick Start

### Start Everything

```bash
# Easy way - use the start script
./start.sh

# Or use make
make up
```

### Stop Everything

```bash
# Easy way - use the stop script
./stop.sh

# Or use make
make down
```

## Quick Commands

### From Your Host Machine (Mac)

```bash
# Access Ansible container shell
make shell

# Run a test playbook
make test

# Run Molecule tests
make molecule-converge   # Fast: create and run tests
make molecule-verify     # Verify tests only
make molecule-test       # Full test cycle (slower)
make molecule-destroy    # Clean up test containers

# View logs
make logs                # All services
make logs-netbox         # Just Netbox
make logs-semaphore      # Just Semaphore

# Stop everything
make down

# Start everything
make up
```

### Inside the Ansible Container

```bash
# First, enter the container
make shell

# Then run commands inside:

# List available roles
ls -la /ansible/roles/

# Run playbooks
ansible-playbook /ansible/playbooks/test_connection.yml

# Work with Molecule
cd /ansible/roles/netbox_device
molecule test           # Full test
molecule converge       # Quick test
molecule verify         # Run verifications
molecule list           # See test instances

# Create a new role
cd /ansible/roles
ansible-galaxy role init my_new_role
```

## Access Netbox

Open your browser to: http://localhost:8000

- Username: `admin`
- Password: `admin`

Netbox is automatically connected to your Ansible container via:
- URL: `http://netbox:8000`
- API Token: `0123456789abcdef0123456789abcdef01234567`

## Example Workflow

### 1. Test Existing Role

```bash
# From host
make shell

# Inside container
cd /ansible/roles/netbox_device
molecule converge
molecule verify
```

### 2. Create a New Role

```bash
# From host
make shell

# Inside container
cd /ansible/roles
ansible-galaxy role init webserver

# Add Molecule
cd webserver
molecule init scenario -d docker

# Edit the role
vi tasks/main.yml

# Test it
molecule converge
molecule verify
```

### 3. Run a Playbook

```bash
# From host
make shell

# Inside container
cd /ansible/playbooks
ansible-playbook deploy_netbox_devices.yml
```

## Verified Working

All tests pass successfully:

```
PLAY RECAP *********************************************************************
instance                   : ok=5    changed=0    unreachable=0    failed=0
```

The sample role:
- Creates test containers using Docker
- Runs your Ansible role
- Verifies the results
- Cleans up automatically

## Next Steps

1. **Explore the sample role**: `roles/netbox_device/`
2. **Create your own roles** for network automation
3. **Add Molecule tests** to ensure quality
4. **Integrate with Netbox** for real network management
5. **Build playbooks** for common tasks

## Troubleshooting

If something isn't working:

```bash
# Restart everything
make down
make up

# View logs
make logs

# Rebuild container (if you changed Dockerfile)
make build
make down
make up
```

## Tips

- Keep a shell open in the Ansible container for fast iteration
- Use `molecule converge` instead of `molecule test` during development (faster)
- Test with multiple OS distributions by changing `MOLECULE_DISTRO` env var
- The Docker socket is mounted, so Molecule can create test containers
- All your work in `ansible/`, `roles/`, and `playbooks/` persists on your Mac

## Documentation

See `README.md` for complete documentation, troubleshooting, and advanced usage.

Enjoy your Ansible + Molecule + Netbox development environment!
