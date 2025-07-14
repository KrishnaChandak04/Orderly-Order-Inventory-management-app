#!/bin/bash

# Orderly Setup Script
# Automates the initial setup process for new installations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PYTHON_MIN_VERSION="3.8"
PROJECT_NAME="Orderly"

# Functions
print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════╗"
    echo "║          Orderly Setup Script            ║"
    echo "║     Inventory Management System          ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

check_python_version() {
    print_step "Checking Python version..."
    
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        print_status "Found Python $PYTHON_VERSION"
        
        # Check if version is >= 3.8
        if python3 -c "import sys; exit(0 if sys.version_info >= (3, 8) else 1)"; then
            print_status "Python version is compatible ✓"
        else
            print_error "Python 3.8 or higher is required"
            exit 1
        fi
    else
        print_error "Python3 is not installed"
        exit 1
    fi
}

check_pip() {
    print_step "Checking pip..."
    
    if command -v pip3 &> /dev/null; then
        print_status "pip3 is available ✓"
    elif command -v pip &> /dev/null; then
        print_status "pip is available ✓"
    else
        print_error "pip is not installed"
        exit 1
    fi
}

create_virtual_environment() {
    print_step "Creating virtual environment..."
    
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        print_status "Virtual environment created ✓"
    else
        print_warning "Virtual environment already exists"
    fi
    
    # Activate virtual environment
    source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null || {
        print_error "Failed to activate virtual environment"
        exit 1
    }
    
    print_status "Virtual environment activated ✓"
}

install_dependencies() {
    print_step "Installing Python dependencies..."
    
    pip install --upgrade pip
    pip install -r requirements.txt
    
    print_status "Dependencies installed ✓"
}

setup_environment() {
    print_step "Setting up environment configuration..."
    
    if [ ! -f ".env" ]; then
        cp .env.example .env
        print_status "Environment file created from template"
        
        # Generate a random secret key
        SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
        
        # Update .env file with generated secret key
        if command -v sed &> /dev/null; then
            sed -i "s/your-secret-key-here-change-in-production/$SECRET_KEY/" .env
            print_status "Secret key generated and updated ✓"
        else
            print_warning "Please manually update SECRET_KEY in .env file"
        fi
        
        print_warning "Please review and update .env file with your configuration"
    else
        print_warning ".env file already exists"
    fi
}

create_directories() {
    print_step "Creating necessary directories..."
    
    mkdir -p instance
    mkdir -p logs
    mkdir -p backups
    mkdir -p uploads
    
    print_status "Directories created ✓"
}

setup_database() {
    print_step "Setting up database..."
    
    # Initialize database migrations
    if [ ! -d "migrations" ]; then
        flask db init
        print_status "Database migrations initialized ✓"
    fi
    
    # Run migrations
    flask db upgrade
    print_status "Database migrations applied ✓"
}

check_optional_services() {
    print_step "Checking optional services..."
    
    # Check Redis
    if command -v redis-server &> /dev/null; then
        print_status "Redis server is available ✓"
    else
        print_warning "Redis server not found (optional, but recommended for production)"
        echo "  To install Redis:"
        echo "  - Ubuntu/Debian: sudo apt install redis-server"
        echo "  - CentOS/RHEL: sudo yum install redis"
        echo "  - macOS: brew install redis"
    fi
    
    # Check PostgreSQL
    if command -v psql &> /dev/null; then
        print_status "PostgreSQL client is available ✓"
    else
        print_warning "PostgreSQL not found (optional, SQLite is used by default)"
    fi
}

display_next_steps() {
    echo
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}                    Setup Complete!                     ${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
    echo
    echo -e "${BLUE}Next Steps:${NC}"
    echo
    echo "1. Review and update configuration:"
    echo "   ${YELLOW}nano .env${NC}"
    echo
    echo "2. Start the application:"
    echo "   ${YELLOW}python run.py${NC}"
    echo
    echo "3. Open your browser to:"
    echo "   ${YELLOW}http://localhost:5000${NC}"
    echo
    echo "4. Login with default credentials:"
    echo "   Username: ${YELLOW}admin${NC}"
    echo "   Password: ${YELLOW}adminpass${NC}"
    echo "   ${RED}⚠️ Change the default password immediately!${NC}"
    echo
    echo -e "${BLUE}Optional Enhancements:${NC}"
    echo "• Install Redis for better performance"
    echo "• Configure PostgreSQL for production"
    echo "• Set up SSL certificates"
    echo "• Configure email settings for reports"
    echo
    echo -e "${BLUE}Documentation:${NC}"
    echo "• README.md - Complete setup guide"
    echo "• API documentation at /api/v1/docs (when available)"
    echo
    echo -e "${GREEN}Thank you for using $PROJECT_NAME!${NC}"
}

# Main setup process
main() {
    print_header
    
    print_status "Starting $PROJECT_NAME setup process..."
    echo
    
    check_python_version
    check_pip
    create_virtual_environment
    install_dependencies
    setup_environment
    create_directories
    setup_database
    check_optional_services
    
    display_next_steps
}

# Check if running in project directory
if [ ! -f "requirements.txt" ]; then
    print_error "This script must be run from the project root directory"
    print_error "Make sure you're in the directory containing requirements.txt"
    exit 1
fi

# Execute main function
main "$@"
