#!/bin/bash

# Health check script for Orderly application
# Can be used with Docker HEALTHCHECK or monitoring systems

set -e

# Configuration
APP_URL="${APP_URL:-http://localhost:5000}"
TIMEOUT="${TIMEOUT:-10}"
MAX_RETRIES="${MAX_RETRIES:-3}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Health check function
check_health() {
    local url="$1"
    local timeout="$2"
    
    if curl -f -s --max-time "$timeout" "$url" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Main health check
main() {
    log_info "Starting health check for Orderly application..."
    
    local retries=0
    local success=false
    
    while [ $retries -lt $MAX_RETRIES ]; do
        if check_health "$APP_URL/health" "$TIMEOUT"; then
            log_info "Health check passed ✓"
            success=true
            break
        else
            retries=$((retries + 1))
            log_warning "Health check failed (attempt $retries/$MAX_RETRIES)"
            
            if [ $retries -lt $MAX_RETRIES ]; then
                sleep 2
            fi
        fi
    done
    
    if [ "$success" = false ]; then
        log_error "Health check failed after $MAX_RETRIES attempts"
        exit 1
    fi
    
    # Additional checks
    log_info "Performing additional checks..."
    
    # Check database connectivity (if endpoint exists)
    if check_health "$APP_URL/api/v1/health/db" "$TIMEOUT"; then
        log_info "Database connectivity check passed ✓"
    else
        log_warning "Database connectivity check failed or endpoint not available"
    fi
    
    # Check Redis connectivity (if endpoint exists)
    if check_health "$APP_URL/api/v1/health/redis" "$TIMEOUT"; then
        log_info "Redis connectivity check passed ✓"
    else
        log_warning "Redis connectivity check failed or endpoint not available"
    fi
    
    log_info "All health checks completed successfully!"
}

# Execute main function
main "$@"
