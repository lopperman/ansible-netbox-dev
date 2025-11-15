# Ansible + Molecule + Netbox + Semaphore Development Environment

This project provides a complete Docker-based development environment for creating, testing, and managing Ansible playbooks and roles with Molecule, featuring a modern web UI (Semaphore) and integration with Netbox for network automation.

## Status: ✅ Fully Operational

All services are configured and tested:
- ✅ **Semaphore** - Web UI for running Ansible playbooks (http://localhost:3000)
- ✅ **Netbox** - Network device management (http://localhost:8000)
- ✅ **Ansible CLI** - Complete development environment with Molecule
- ✅ **Molecule** - Automated role testing verified working
- ✅ **PostgreSQL & Redis** - All databases healthy

**Quick Start:** Run `./start.sh` to launch everything!

## Architecture

```
molecule_ans/
├── start.sh                    # Start all services script
├── stop.sh                     # Stop all services script
├── docker-compose.yml          # Orchestrates all services
├── Dockerfile.ansible          # Ansible + Molecule container
├── Makefile                    # Helper commands
├── ansible/                    # Ansible working directory
│   ├── ansible.cfg            # Ansible configuration
│   └── inventory/             # Inventory files
├── roles/                      # Ansible roles
│   └── netbox_device/         # Example role with Molecule tests
│       ├── defaults/
│       ├── tasks/
│       └── molecule/
│           └── default/       # Molecule test scenario
└── playbooks/                  # Ansible playbooks
```

## Services

1. **Semaphore** - Modern Ansible Web UI:
   - Access: http://localhost:3000
   - Credentials: admin/admin
   - Run playbooks through web interface
   - Task scheduling and history
   - See SEMAPHORE.md for setup guide

2. **Ansible Container** - CLI development environment with:
   - Ansible Core 2.15.5
   - Molecule 6.0.3 (with Docker driver)
   - Ansible Lint
   - PyNetbox (Python Netbox API client)
   - Docker socket mounted for Molecule testing

3. **Netbox** - Network source of truth:
   - Access: http://localhost:8000
   - Credentials: admin/admin
   - API Token: 0123456789abcdef0123456789abcdef01234567

4. **PostgreSQL** - Database backend (for Netbox and Semaphore)

5. **Redis** - Caching and queuing for Netbox

## Quick Start

### 1. Start the Environment

```bash
# Easy way - use the start script
./start.sh

# Or use make
make up

# Or manually:
docker compose up -d
```

The start script provides a nice output showing all service URLs and commands.

Wait about 30 seconds for all services to fully initialize.

### 2. Access the Ansible Container

```bash
# Open a shell in the Ansible container
make shell

# Or manually:
docker compose exec ansible /bin/bash
```

### 3. Run Your First Test

```bash
# Inside the Ansible container or from host:
make test

# This runs the test_connection.yml playbook
```

### 4. Test with Molecule

```bash
# Run full Molecule test suite
make molecule-test

# Or step by step:
make molecule-converge  # Create instance and run role
make molecule-verify    # Run verification tests
make molecule-destroy   # Clean up test instances
```

## Working with Ansible

### Running Playbooks

From your host machine:
```bash
# Test connectivity
docker compose exec ansible ansible-playbook /ansible/playbooks/test_connection.yml

# Deploy devices to Netbox
docker compose exec ansible ansible-playbook /ansible/playbooks/deploy_netbox_devices.yml
```

From inside the container:
```bash
make shell
cd /ansible/playbooks
ansible-playbook test_connection.yml
```

### Creating New Roles

```bash
# Enter the container
make shell

# Create a new role
cd /ansible/roles
ansible-galaxy role init my_new_role

# Add Molecule testing
cd my_new_role
molecule init scenario -d docker
```

### Testing Roles with Molecule

Molecule workflow:
```bash
cd /ansible/roles/netbox_device

# Full test cycle
molecule test

# Development workflow (faster):
molecule create      # Create test instance
molecule converge    # Run the role
molecule verify      # Run verification tests
# Make changes to your role...
molecule converge    # Test changes
molecule verify      # Verify again
molecule destroy     # Clean up when done
```

## Working with Netbox

### Access Netbox UI

Open http://localhost:8000 in your browser:
- Username: `admin`
- Password: `admin`

### Using Netbox API from Ansible

The `netbox.netbox` collection is pre-installed. Example usage:

```yaml
- name: Create a device in Netbox
  netbox.netbox.netbox_device:
    netbox_url: "{{ netbox_url }}"
    netbox_token: "{{ netbox_token }}"
    data:
      name: "switch-01"
      device_role: "access-switch"
      device_type: "cisco-2960"
      site: "datacenter-1"
    state: present
    validate_certs: false
```

Environment variables are automatically set in the Ansible container:
- `NETBOX_URL`: http://netbox:8000
- `NETBOX_TOKEN`: 0123456789abcdef0123456789abcdef01234567

## Molecule Testing Details

### Test Structure

Each role can have multiple Molecule scenarios in `molecule/`:
- `molecule.yml` - Main configuration (platforms, driver, provisioner)
- `converge.yml` - Playbook that runs your role
- `verify.yml` - Tests to verify role worked correctly

### Docker Driver Configuration

Molecule uses the Docker driver to spin up test containers. The configuration connects to your Docker daemon via the mounted socket and uses the same network as Netbox, allowing integration testing.

Key settings in `molecule.yml`:
- Uses `geerlingguy/docker-*-ansible` images (Systemd-enabled)
- Connects to external network `molecule_ans_ansible-net`
- Can communicate with Netbox service

### Writing Tests

Add tests in `molecule/default/verify.yml`:

```yaml
- name: Verify
  hosts: all
  tasks:
    - name: Check service is running
      ansible.builtin.service:
        name: nginx
        state: started
      check_mode: true
      register: service_status

    - name: Assert service is running
      ansible.builtin.assert:
        that: not service_status.changed
```

## Common Commands

```bash
# Start environment
./start.sh          # Recommended - shows nice output
make up             # Alternative

# Stop environment
./stop.sh           # Recommended
make down           # Alternative

# View logs
make logs           # All services
make logs-netbox    # Netbox only
make logs-semaphore # Semaphore only

# Access Ansible shell
make shell

# Run tests
make test           # Run test playbook
make molecule-test  # Full Molecule test suite

# Clean up everything
make destroy        # Remove all data and volumes
```

## Development Workflow

1. **Start the environment**: `./start.sh` (or `make up`)
2. **Access Semaphore** at http://localhost:3000 for web-based playbook execution
3. **Create/modify roles** in `roles/` directory
4. **Test with Molecule**: `make molecule-test`
5. **Create playbooks** in `playbooks/` directory
6. **Run playbooks**: Via Semaphore UI or `make test` from CLI
7. **Integrate with Netbox** at http://localhost:8000 for network device management

## Customization

### Add Python Packages

Edit `Dockerfile.ansible` and add to the pip install command:
```dockerfile
RUN pip install --no-cache-dir \
    ansible-core==2.15.5 \
    your-package-here
```

Then rebuild: `make build`

### Add Ansible Collections

Edit `Dockerfile.ansible`:
```dockerfile
RUN ansible-galaxy collection install \
    community.general \
    your.collection
```

### Environment Variables

Create a `.env` file in the project root:
```bash
NETBOX_TOKEN=your-custom-token
MOLECULE_DISTRO=ubuntu2204
```

## Troubleshooting

### Netbox not accessible
```bash
# Check Netbox logs
make logs-netbox

# Restart services
make down && make up
```

### Molecule can't connect to Docker
- Ensure Docker socket is mounted in `docker-compose.yml`
- Check Docker is running: `docker ps`

### Permission issues
```bash
# Fix file permissions
sudo chown -R $USER:$USER .
```

### Network issues
```bash
# Recreate network
docker compose down
docker network prune
make up
```

## Tips

1. **Use the Makefile** - All common operations have make targets
2. **Keep shell open** - Keep an Ansible container shell open for faster iteration
3. **Molecule is fast** - Use `converge` instead of full `test` during development
4. **Check logs** - `make logs` helps debug issues
5. **Netbox API** - Use the Netbox UI to explore the API documentation

## Next Steps

- Explore the sample `netbox_device` role
- Create your own roles for network device management
- Build playbooks for common network tasks
- Integrate with your actual Netbox instance (change NETBOX_URL)
- Add more Molecule scenarios for different test cases

## Documentation

- **QUICKSTART.md** - Quick reference guide with common commands
- **SEMAPHORE.md** - Complete Semaphore setup and usage guide
- **start.sh / stop.sh** - Convenient scripts to manage the environment

## Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Molecule Documentation](https://molecule.readthedocs.io/)
- [Semaphore Documentation](https://docs.semaphoreui.com/)
- [Netbox Documentation](https://docs.netbox.dev/)
- [Netbox Ansible Collection](https://github.com/netbox-community/ansible_modules)
