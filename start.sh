#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Ansible + Molecule + Netbox + Semaphore${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${YELLOW}Error: Docker is not running!${NC}"
    echo "Please start Docker Desktop and try again."
    exit 1
fi

echo -e "${GREEN}✓ Docker is running${NC}"
echo ""

# Start all services
echo "Starting all services..."
docker compose up -d

if [ $? -ne 0 ]; then
    echo -e "${YELLOW}Error: Failed to start services${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Services started successfully${NC}"
echo ""

# Wait for services to be ready
echo "Waiting for services to initialize (15 seconds)..."
sleep 15

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ All Services Are Ready!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check container status
echo -e "${BLUE}Container Status:${NC}"
docker compose ps

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Access Your Services${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Web Interfaces:${NC}"
echo -e "  • Semaphore (Ansible UI): ${YELLOW}http://localhost:3000${NC}"
echo -e "    Login: admin / admin"
echo ""
echo -e "  • Netbox (Network Mgmt):  ${YELLOW}http://localhost:8000${NC}"
echo -e "    Login: admin / admin"
echo ""
echo -e "${GREEN}Command Line:${NC}"
echo -e "  • Ansible Shell:  ${YELLOW}make shell${NC}"
echo -e "  • Run Playbook:   ${YELLOW}make test${NC}"
echo -e "  • Molecule Test:  ${YELLOW}make molecule-converge${NC}"
echo ""
echo -e "${GREEN}View Logs:${NC}"
echo -e "  • All Services:   ${YELLOW}make logs${NC}"
echo -e "  • Semaphore:      ${YELLOW}make logs-semaphore${NC}"
echo -e "  • Netbox:         ${YELLOW}make logs-netbox${NC}"
echo ""
echo -e "${GREEN}Stop Services:${NC}"
echo -e "  • Stop All:       ${YELLOW}make down${NC}"
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Happy Automating!${NC}"
echo -e "${BLUE}========================================${NC}"
