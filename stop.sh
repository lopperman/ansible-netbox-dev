#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Stopping All Services${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Stop all services
echo "Stopping containers..."
docker compose down

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ All services stopped successfully${NC}"
    echo ""
    echo -e "To remove all data (volumes), run:"
    echo -e "  ${YELLOW}docker compose down -v${NC}"
else
    echo ""
    echo -e "${RED}✗ Error stopping services${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}To start again, run:${NC}"
echo -e "  ${YELLOW}./start.sh${NC}"
echo -e "  or"
echo -e "  ${YELLOW}make up${NC}"
echo ""
