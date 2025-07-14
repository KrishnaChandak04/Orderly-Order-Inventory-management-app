#!/bin/bash

# Orderly Application Deployment Script
# This script automates the deployment process for production

set -e  # Exit on any error

echo "🚀 Starting Orderly deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="/opt/orderly"
BACKUP_DIR="/opt/orderly/backups"
PYTHON_VERSION="3.9"
SERVICE_NAME="orderly"

# Functions
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        exit 1
    fi
    
    # Check Python version
    if ! python3 --version | grep -q "Python $PYTHON_VERSION"; then
        print_error "Python $PYTHON_VERSION is required"
        exit 1
    fi
    
    # Check if project directory exists
    if [[ ! -d "$PROJECT_DIR" ]]; then
        print_error "Project directory $PROJECT_DIR does not exist"
        exit 1
    fi
    
    print_status "Prerequisites check passed ✓"
}

backup_database() {
    print_status "Creating database backup..."
    
    mkdir -p "$BACKUP_DIR"
    BACKUP_FILE="$BACKUP_DIR/orderly_backup_$(date +%Y%m%d_%H%M%S).sql"
    
    if [[ -f "$PROJECT_DIR/.env" ]]; then
        source "$PROJECT_DIR/.env"
        
        if [[ $DATABASE_URL == postgresql* ]]; then
            pg_dump "$DATABASE_URL" > "$BACKUP_FILE"
        elif [[ $DATABASE_URL == mysql* ]]; then
            mysqldump --single-transaction --routines --triggers "$DATABASE_URL" > "$BACKUP_FILE"
        else
            cp "$PROJECT_DIR/instance/site.db" "$BACKUP_DIR/site_backup_$(date +%Y%m%d_%H%M%S).db"
        fi
        
        print_status "Database backup created: $BACKUP_FILE"
    else
        print_warning "No .env file found, skipping database backup"
    fi
}

update_code() {
    print_status "Updating application code..."
    
    cd "$PROJECT_DIR"
    
    # Pull latest changes
    git fetch origin
    git reset --hard origin/main
    
    # Install/update dependencies
    pip install -r requirements.txt
    
    print_status "Code updated successfully ✓"
}

run_migrations() {
    print_status "Running database migrations..."
    
    cd "$PROJECT_DIR"
    flask db upgrade
    
    print_status "Database migrations completed ✓"
}

restart_services() {
    print_status "Restarting services..."
    
    # Restart application service
    sudo systemctl restart "$SERVICE_NAME"
    sudo systemctl restart "${SERVICE_NAME}-celery"
    sudo systemctl restart "${SERVICE_NAME}-celery-beat"
    
    # Restart nginx
    sudo systemctl reload nginx
    
    print_status "Services restarted ✓"
}

health_check() {
    print_status "Performing health check..."
    
    sleep 5  # Wait for services to start
    
    # Check if application is responding
    if curl -f -s http://localhost/health > /dev/null; then
        print_status "Health check passed ✓"
    else
        print_error "Health check failed"
        exit 1
    fi
}

cleanup_old_backups() {
    print_status "Cleaning up old backups..."
    
    # Keep only last 7 days of backups
    find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete
    find "$BACKUP_DIR" -name "*.db" -mtime +7 -delete
    
    print_status "Old backups cleaned up ✓"
}

# Main deployment process
main() {
    print_status "Starting deployment process..."
    
    check_prerequisites
    backup_database
    update_code
    run_migrations
    restart_services
    health_check
    cleanup_old_backups
    
    print_status "🎉 Deployment completed successfully!"
    print_status "Application is now running at: https://your-domain.com"
}

# Execute main function
main "$@"
