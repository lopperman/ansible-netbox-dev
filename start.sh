#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse command line arguments
MODE="start"
case "$1" in
    --rebuild)
        MODE="rebuild"
        ;;
    --clean)
        MODE="clean"
        ;;
    --restart)
        MODE="restart"
        ;;
    --help|-h)
        echo "Usage: $0 [OPTION]"
        echo ""
        echo "Options:"
        echo "  (no args)    Start existing containers or create if they don't exist"
        echo "  --rebuild    Rebuild containers (keeps volumes)"
        echo "  --clean      Remove everything (containers, volumes, images) and rebuild"
        echo "  --restart    Restart running containers"
        echo "  --help       Show this help message"
        exit 0
        ;;
    "")
        MODE="start"
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        echo "Use --help to see available options"
        exit 1
        ;;
esac

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

# Handle different modes
case "$MODE" in
    clean)
        echo -e "${YELLOW}Cleaning up everything (containers, volumes, and images)...${NC}"
        docker compose down -v --rmi all
        echo -e "${GREEN}✓ Cleanup complete${NC}"
        echo ""
        echo "Building and starting fresh..."
        docker compose up -d --build
        ;;
    rebuild)
        echo -e "${YELLOW}Rebuilding containers (keeping volumes)...${NC}"

        # Get container names from docker-compose.yml
        CONTAINER_NAMES=$(docker compose ps -a --format '{{.Name}}' 2>/dev/null)

        # Also check for containers with known names from docker-compose.yml
        KNOWN_CONTAINERS="ansible-dev netbox netbox-postgres netbox-redis semaphore semaphore-postgres"

        # Remove containers by name (handles orphaned containers)
        echo "Removing existing containers..."
        for container in $KNOWN_CONTAINERS; do
            if docker ps -a --format '{{.Names}}' | grep -q "^${container}$"; then
                echo "  - Removing container: $container"
                docker rm -f $container 2>/dev/null || true
            fi
        done

        # Also run docker compose down to clean up networks and any compose-managed resources
        docker compose down 2>/dev/null || true

        # Remove images for services we're rebuilding (only the custom-built ones)
        echo "Removing old images..."
        docker rmi ansible-netbox-dev-ansible 2>/dev/null || true

        echo -e "${GREEN}✓ Cleanup complete${NC}"
        echo ""
        echo "Building and starting..."
        docker compose up -d --build
        ;;
    restart)
        echo "Restarting all services..."
        docker compose restart
        ;;
    start)
        echo "Starting all services..."
        docker compose up -d
        ;;
esac

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
echo -e "  • Semaphore (Ansible UI): ${YELLOW}http://localhost:3001${NC}"
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
