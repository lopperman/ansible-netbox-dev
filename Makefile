.PHONY: help build up down shell test molecule-test clean logs

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build the Ansible container
	docker compose build ansible

up: ## Start all services (Ansible, Netbox, Semaphore, PostgreSQL, Redis)
	docker compose up -d
	@echo "Waiting for services to be ready..."
	@sleep 15
	@echo ""
	@echo "Services are running!"
	@echo "  Semaphore UI: http://localhost:3000 (admin/admin)"
	@echo "  Netbox UI: http://localhost:8000 (admin/admin)"
	@echo "  Ansible container: docker compose exec ansible bash"

down: ## Stop all services
	docker compose down

destroy: ## Stop and remove all containers, networks, and volumes
	docker compose down -v

shell: ## Open a shell in the Ansible container
	docker compose exec ansible /bin/bash

test: ## Run a test playbook
	docker compose exec ansible ansible-playbook /ansible/playbooks/test_connection.yml

molecule-test: ## Run Molecule tests for the netbox_device role
	docker compose exec ansible bash -c "cd /ansible/roles/netbox_device && molecule test"

molecule-converge: ## Run Molecule converge (without destroying)
	docker compose exec ansible bash -c "cd /ansible/roles/netbox_device && molecule converge"

molecule-verify: ## Run Molecule verify
	docker compose exec ansible bash -c "cd /ansible/roles/netbox_device && molecule verify"

molecule-destroy: ## Destroy Molecule test instances
	docker compose exec ansible bash -c "cd /ansible/roles/netbox_device && molecule destroy"

logs: ## Show logs from all services
	docker compose logs -f

logs-netbox: ## Show Netbox logs
	docker compose logs -f netbox

logs-semaphore: ## Show Semaphore logs
	docker compose logs -f semaphore

clean: ## Clean up temporary files
	find . -type f -name '*.pyc' -delete
	find . -type d -name '__pycache__' -delete
	find . -type d -name '.pytest_cache' -delete
