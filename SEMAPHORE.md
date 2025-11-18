# Semaphore - Ansible Web UI Guide

Semaphore provides a modern web interface to run and manage your Ansible playbooks and roles.

## Access Semaphore

Open your browser to: **http://localhost:3001**

**Default Login:**
- Username: `admin`
- Password: `admin`

## First Time Setup

### 1. Create a Project

Once logged in, you'll need to set up your first project:

1. Click **"New Project"**
2. Fill in:
   - **Name:** My Ansible Project
   - **Alert:** (optional)
3. Click **"Create"**

### 2. Add a Key Store (SSH/Credentials)

For localhost testing, add a "None" key:

1. Go to **Key Store** (in project view)
2. Click **"New Key"**
3. Select **"None"** as the type
4. **Name:** Local Connection
5. Click **"Create"**

### 3. Add a Repository

Tell Semaphore where your playbooks are:

1. Go to **Repositories**
2. Click **"New Repository"**
3. Fill in:
   - **Name:** Playbooks
   - **URL:** `file:///ansible`
   - **Branch:** `main` (or leave empty)
   - **Key:** Select "None" or the key you created
4. Click **"Create"**

Note: Since your playbooks are mounted in the container, we use `file:///ansible` as the path.

### 4. Add an Inventory

1. Go to **Environment** → **Inventory**
2. Click **"New Inventory"**
3. Select **"File"** as inventory type
4. Fill in:
   - **Name:** Local Inventory
   - **Inventory:** Paste the contents of your inventory file or use:
   ```ini
   [local]
   localhost ansible_connection=local
   ```
   - **Key:** Select the key you created
5. Click **"Create"**

Alternatively, you can use **Static Inventory** and point to: `/ansible/inventory/hosts`

### 5. Create a Task Template

This is where you define which playbook to run:

1. Go to **Task Templates**
2. Click **"New Template"**
3. Fill in:
   - **Name:** Test Connection
   - **Playbook Filename:** `playbooks/test_connection.yml`
   - **Inventory:** Select "Local Inventory"
   - **Repository:** Select "Playbooks"
   - **Environment:** (leave empty or add variables)
4. Click **"Create"**

### 6. Run Your First Playbook

1. Click on the template you created
2. Click **"Run"** button
3. Watch the real-time output!

## Example Templates to Create

### Template 1: Test Connection
- **Name:** Test Connection
- **Playbook:** `playbooks/test_connection.yml`
- **Description:** Test basic Ansible connectivity

### Template 2: Deploy Netbox Devices
- **Name:** Deploy Netbox Devices
- **Playbook:** `playbooks/deploy_netbox_devices.yml`
- **Description:** Create devices in Netbox

### Template 3: Your Custom Role
- **Name:** Run My Role
- **Playbook:** Create a playbook that uses your role
- **Description:** Test your custom role

## Directory Structure in Semaphore

Semaphore sees your files at:
```
/ansible/
├── playbooks/
│   ├── test_connection.yml
│   └── deploy_netbox_devices.yml
├── roles/
│   └── netbox_device/
└── inventory/
    └── hosts
```

When creating templates, use paths relative to `/ansible/`:
- Playbook: `playbooks/test_connection.yml`
- Roles are auto-discovered from `/ansible/roles/`

## Features You Can Use

### 1. **Run Playbooks**
- Click and run with a button
- Real-time console output
- Color-coded task results

### 2. **Schedule Tasks**
- Set up cron-like schedules
- Automated playbook execution
- No manual intervention needed

### 3. **Task History**
- View all past runs
- Check logs and outputs
- Debug failed runs

### 4. **Environment Variables**
- Define variables per template
- Override defaults
- Secure credential storage

### 5. **RBAC (Role-Based Access)**
- Add team members
- Control who can run what
- Audit trail of all actions

### 6. **Notifications**
- Slack integration
- Email alerts
- Webhook notifications

## Common Use Cases

### Running a Playbook

1. Navigate to **Task Templates**
2. Click the template name
3. Click **"Run"**
4. Watch real-time output
5. View results and logs

### Editing a Template

1. Go to **Task Templates**
2. Click the pencil icon next to template
3. Modify settings
4. Save changes

### Viewing Task History

1. Go to **Task History** or **Dashboard**
2. Click on any task to see:
   - Full output
   - Duration
   - Success/failure status
   - Who ran it and when

## Inventory Options

### Option 1: Static File (Recommended)
Point to your existing inventory:
```
Type: File
Path: /ansible/inventory/hosts
```

### Option 2: Inline Inventory
Paste inventory directly:
```ini
[local]
localhost ansible_connection=local

[webservers]
web1.example.com
web2.example.com
```

### Option 3: Dynamic Inventory
Use a script that generates inventory (advanced)

## Adding Your Playbooks

### Method 1: Edit on Host
Your playbooks are in:
```
/Users/[username]/projects/ansible-netbox-dev/playbooks/
```

Edit them with your favorite editor, and they're immediately available in Semaphore!

### Method 2: Use Ansible Container
```bash
make shell
cd /ansible/playbooks
vi my_new_playbook.yml
```

Semaphore will see the new playbook automatically.

## Tips and Tricks

1. **Start Simple**
   - Begin with the test_connection.yml playbook
   - Verify everything works before complex playbooks

2. **Use Variables**
   - Define environment variables in templates
   - Override role defaults easily

3. **Check Logs**
   - If a playbook fails, click the task to see full output
   - Semaphore shows the exact same output as CLI

4. **Organize Templates**
   - Use clear naming conventions
   - Add descriptions to templates
   - Group related templates

5. **Test First**
   - Always test playbooks in CLI first
   - Then create Semaphore templates
   - Easier to debug in CLI

## Troubleshooting

### Playbook Not Found
- Ensure path is relative to `/ansible/`
- Check that file exists: `make shell` then `ls /ansible/playbooks/`

### Permission Denied
- Check that Semaphore container has access to volumes
- Restart: `make down && make up`

### Connection Failed
- For localhost, use `ansible_connection=local` in inventory
- For remote hosts, ensure SSH keys are properly configured in Key Store

### Can't See My Roles
- Roles must be in `/ansible/roles/` directory
- Semaphore auto-discovers roles from this path
- No special configuration needed

## Semaphore vs CLI

**Use Semaphore for:**
- Running playbooks with a click
- Scheduled/automated runs
- Sharing with team members
- Viewing historical runs
- Non-technical users

**Use CLI for:**
- Developing and testing playbooks
- Debugging issues
- Quick iterations
- Learning Ansible
- Molecule testing

**Best Practice:** Develop in CLI, deploy in Semaphore!

## View Logs

From host machine:
```bash
make logs-semaphore
```

## Resources

- Semaphore Docs: https://docs.semaphoreui.com/
- Your playbooks: `/Users/[username]/projects/ansible-netbox-dev/playbooks/`
- Access URL: http://localhost:3001

## Next Steps

1. Log in to Semaphore at http://localhost:3001
2. Create your first project
3. Set up inventory and repository
4. Create a template for `test_connection.yml`
5. Run it and see the magic!

Happy Ansible automating with Semaphore!
