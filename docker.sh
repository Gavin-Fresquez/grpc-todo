#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

print_info() {
  echo -e "${YELLOW}→ $1${NC}"
}

# Function to check if docker compose is available
check_docker_compose() {
  if command -v docker-compose &>/dev/null; then
    COMPOSE_CMD="docker-compose"
  elif docker compose version &>/dev/null; then
    COMPOSE_CMD="docker compose"
  else
    print_error "Docker Compose is not installed!"
    exit 1
  fi
}

# Start services
start() {
  print_info "Starting services..."
  $COMPOSE_CMD up -d
  if [ $? -eq 0 ]; then
    print_success "Services started successfully"
    status
  else
    print_error "Failed to start services"
  fi
}

# Stop services
stop() {
  print_info "Stopping services..."
  $COMPOSE_CMD down
  if [ $? -eq 0 ]; then
    print_success "Services stopped successfully"
  else
    print_error "Failed to stop services"
  fi
}

# Restart services
restart() {
  print_info "Restarting services..."
  stop
  start
}

# Rebuild and restart
rebuild() {
  print_info "Rebuilding and restarting services..."
  $COMPOSE_CMD down
  $COMPOSE_CMD build --no-cache
  $COMPOSE_CMD up -d
  if [ $? -eq 0 ]; then
    print_success "Services rebuilt and started successfully"
    status
  else
    print_error "Failed to rebuild services"
  fi
}

# Show logs
logs() {
  print_info "Showing logs (Ctrl+C to exit)..."
  $COMPOSE_CMD logs -f
}

# Show status
status() {
  print_info "Service status:"
  $COMPOSE_CMD ps
}

# Clean up everything
clean() {
  print_info "Cleaning up containers, volumes, and images..."
  read -p "Are you sure? This will remove all data! (y/N): " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    $COMPOSE_CMD down -v --rmi all
    print_success "Cleanup completed"
  else
    print_info "Cleanup cancelled"
  fi
}

# Show help
show_help() {
  echo "Usage: ./docker.sh [command]"
  echo ""
  echo "Commands:"
  echo "  start      - Start all services"
  echo "  stop       - Stop all services"
  echo "  restart    - Restart all services"
  echo "  rebuild    - Rebuild and restart all services"
  echo "  logs       - Show and follow logs"
  echo "  status     - Show service status"
  echo "  clean      - Remove all containers, volumes, and images"
  echo "  help       - Show this help message"
  echo ""
  echo "Examples:"
  echo "  ./docker.sh start"
  echo "  ./docker.sh logs"
  echo "  ./docker.sh rebuild"
}

# Main script logic
check_docker_compose

case "$1" in
start)
  start
  ;;
stop)
  stop
  ;;
restart)
  restart
  ;;
rebuild)
  rebuild
  ;;
logs)
  logs
  ;;
status)
  status
  ;;
clean)
  clean
  ;;
help | --help | -h | "")
  show_help
  ;;
*)
  print_error "Unknown command: $1"
  echo ""
  show_help
  exit 1
  ;;
esac
