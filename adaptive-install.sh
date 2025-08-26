#!/bin/bash

# Adaptive Installation Script
# Reads architecture.yml and installs only what's needed

set -e

echo "🔍 Adaptive Installation Based on Architecture"
echo "=============================================="

# Check if architecture is defined
if [ ! -f ".claude/architecture.yml" ]; then
    echo "⚠️  No architecture defined yet!"
    echo ""
    echo "Please run one of these first:"
    echo "  1. In Claude: /define-architecture"
    echo "  2. Or use preset: ./adaptive-install.sh --preset full-stack"
    echo ""
    
    # Offer presets
    echo "Available presets:"
    echo "  • api-only     - Backend API service"
    echo "  • full-stack   - Web app with API"
    echo "  • data-pipeline - Data processing"
    echo "  • static-site  - Frontend only"
    echo ""
    
    if [ "$1" == "--preset" ] && [ -n "$2" ]; then
        PRESET=$2
        echo "Using preset: $PRESET"
        
        # Generate architecture.yml based on preset
        mkdir -p .claude
        case $PRESET in
            "api-only")
                cat > .claude/architecture.yml << 'EOF'
project:
  type: "api"
  
stack:
  backend:
    language: "python"
    framework: "fastapi"
    packages: ["fastapi", "sqlalchemy", "alembic", "psycopg2-binary", "python-dotenv", "uvicorn"]
  database:
    primary: "postgresql"
    cache: "redis"
    
structure:
  create_dirs: ["apps/api", "migrations", "tests"]
  ignore_dirs: ["apps/web", "mobile"]
  
development:
  ports:
    api: 8000
    db: 5432
    redis: 6379
EOF
                ;;
                
            "full-stack")
                cat > .claude/architecture.yml << 'EOF'
project:
  type: "full-stack"
  
stack:
  backend:
    language: "python"
    framework: "fastapi"
    packages: ["fastapi", "sqlalchemy", "alembic", "psycopg2-binary", "redis", "celery"]
  frontend:
    language: "typescript"
    framework: "nextjs"
    packages: ["react", "tailwindcss", "axios", "@tanstack/react-query"]
  database:
    primary: "postgresql"
    cache: "redis"
    
structure:
  create_dirs: ["apps/api", "apps/web", "infrastructure"]
  
development:
  ports:
    api: 8000
    web: 3000
    db: 5432
    redis: 6379
EOF
                ;;
                
            "data-pipeline")
                cat > .claude/architecture.yml << 'EOF'
project:
  type: "data-pipeline"
  
stack:
  backend:
    language: "python"
    framework: "fastapi"
    packages: ["pandas", "sqlalchemy", "celery", "redis", "boto3"]
  processing:
    scheduler: "airflow"
    packages: ["apache-airflow", "pandas", "numpy", "scikit-learn"]
  database:
    primary: "postgresql"
    warehouse: "postgresql"
    
structure:
  create_dirs: ["pipelines", "apps/api", "data", "notebooks"]
  
development:
  ports:
    api: 8000
    airflow: 8080
    db: 5432
EOF
                ;;
                
            "static-site")
                cat > .claude/architecture.yml << 'EOF'
project:
  type: "static-site"
  
stack:
  frontend:
    language: "typescript"
    framework: "nextjs"
    packages: ["react", "tailwindcss", "framer-motion"]
    
structure:
  create_dirs: ["apps/web", "public"]
  ignore_dirs: ["apps/api", "migrations"]
  
development:
  ports:
    web: 3000
EOF
                ;;
                
            *)
                echo "Unknown preset: $PRESET"
                exit 1
                ;;
        esac
        
        echo "✅ Architecture defined using $PRESET preset"
    else
        exit 1
    fi
fi

# Read architecture
echo ""
echo "📖 Reading architecture configuration..."

# Parse YAML (simple extraction for key values)
BACKEND_LANG=$(grep -A2 "backend:" .claude/architecture.yml | grep "language:" | awk '{print $2}' | tr -d '"')
FRONTEND_LANG=$(grep -A2 "frontend:" .claude/architecture.yml | grep "language:" | awk '{print $2}' | tr -d '"')
DATABASE=$(grep -A2 "database:" .claude/architecture.yml | grep "primary:" | awk '{print $2}' | tr -d '"')
CACHE=$(grep -A2 "database:" .claude/architecture.yml | grep "cache:" | awk '{print $2}' | tr -d '"')

echo "  Backend: ${BACKEND_LANG:-none}"
echo "  Frontend: ${FRONTEND_LANG:-none}"
echo "  Database: ${DATABASE:-none}"
echo "  Cache: ${CACHE:-none}"

# Create necessary directories
echo ""
echo "📁 Creating project structure..."

# Parse and create directories from architecture.yml
if grep -q "create_dirs:" .claude/architecture.yml; then
    # Extract directories to create (simple parsing)
    grep -A10 "create_dirs:" .claude/architecture.yml | grep "^    - " | while read -r line; do
        DIR=$(echo $line | sed 's/^    - //' | tr -d '"')
        if [ ! -d "$DIR" ]; then
            mkdir -p "$DIR"
            echo "  ✅ Created $DIR"
        fi
    done
fi

# Install Backend Dependencies
if [ "$BACKEND_LANG" == "python" ]; then
    echo ""
    echo "🐍 Installing Python dependencies..."
    
    # Create virtual environment if needed
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        echo "  ✅ Created Python virtual environment"
    fi
    
    # Activate virtual environment
    source venv/bin/activate || . venv/Scripts/activate
    
    # Upgrade pip
    pip install --upgrade pip setuptools wheel
    
    # Generate requirements.txt based on architecture
    if [ ! -f "requirements.txt" ]; then
        echo "# Auto-generated from architecture.yml" > requirements.txt
        
        # Extract packages from architecture.yml
        grep -A20 "backend:" .claude/architecture.yml | grep -A15 "packages:" | grep "^      - " | while read -r line; do
            PACKAGE=$(echo $line | sed 's/^      - //' | tr -d '"')
            echo "$PACKAGE" >> requirements.txt
        done
        
        echo "  ✅ Generated requirements.txt"
    fi
    
    # Install packages
    pip install -r requirements.txt
    echo "  ✅ Python packages installed"
fi

# Install Frontend Dependencies
if [ "$FRONTEND_LANG" == "typescript" ] || [ "$FRONTEND_LANG" == "javascript" ]; then
    echo ""
    echo "📦 Installing Node.js dependencies..."
    
    # Check for web app directory
    if [ -d "apps/web" ]; then
        cd apps/web
        
        # Generate package.json if needed
        if [ ! -f "package.json" ]; then
            npm init -y
            
            # Add packages from architecture
            grep -A20 "frontend:" ../../.claude/architecture.yml | grep -A15 "packages:" | grep "^      - " | while read -r line; do
                PACKAGE=$(echo $line | sed 's/^      - //' | tr -d '"')
                npm install --save $PACKAGE
            done
            
            echo "  ✅ Generated package.json and installed packages"
        else
            npm install
            echo "  ✅ Node packages installed"
        fi
        
        cd ../..
    fi
fi

# Setup Database
if [ "$DATABASE" == "postgresql" ]; then
    echo ""
    echo "🐘 Setting up PostgreSQL..."
    
    # Create docker-compose for database if not exists
    if [ ! -f "docker-compose.yml" ]; then
        cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: app_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
EOF
        
        if [ "$CACHE" == "redis" ]; then
            cat >> docker-compose.yml << 'EOF'

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
EOF
        fi
        
        echo "  ✅ Created docker-compose.yml"
    fi
    
    # Start database services
    echo "  Starting database services..."
    docker-compose up -d db redis 2>/dev/null || echo "  ℹ️  Docker not running or services already up"
fi

# Generate .env file
if [ ! -f ".env" ]; then
    echo ""
    echo "🔧 Generating .env file..."
    
    cat > .env << EOF
# Auto-generated from architecture
NODE_ENV=development

EOF
    
    # Add database URL if needed
    if [ "$DATABASE" == "postgresql" ]; then
        cat >> .env << EOF
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/app_db
EOF
    fi
    
    # Add Redis URL if needed
    if [ "$CACHE" == "redis" ]; then
        cat >> .env << EOF
REDIS_URL=redis://localhost:6379/0
EOF
    fi
    
    # Add ports from architecture
    API_PORT=$(grep -A5 "ports:" .claude/architecture.yml | grep "api:" | awk '{print $2}')
    WEB_PORT=$(grep -A5 "ports:" .claude/architecture.yml | grep "web:" | awk '{print $2}')
    
    if [ -n "$API_PORT" ]; then
        echo "API_PORT=$API_PORT" >> .env
    fi
    
    if [ -n "$WEB_PORT" ]; then
        echo "WEB_PORT=$WEB_PORT" >> .env
    fi
    
    echo "  ✅ Generated .env file"
fi

# Create Makefile for common commands
if [ ! -f "Makefile" ]; then
    echo ""
    echo "📝 Generating Makefile..."
    
    cat > Makefile << 'EOF'
# Auto-generated Makefile based on architecture

.PHONY: help dev test build clean

help:
	@echo "Available commands:"
	@echo "  make dev    - Start development environment"
	@echo "  make test   - Run tests"
	@echo "  make build  - Build for production"
	@echo "  make clean  - Clean up"

EOF
    
    # Add dev command based on architecture
    echo "dev:" >> Makefile
    if [ "$DATABASE" == "postgresql" ]; then
        echo "	docker-compose up -d db redis" >> Makefile
    fi
    if [ "$BACKEND_LANG" == "python" ]; then
        echo "	cd apps/api && uvicorn main:app --reload &" >> Makefile
    fi
    if [ "$FRONTEND_LANG" == "typescript" ]; then
        echo "	cd apps/web && npm run dev &" >> Makefile
    fi
    echo "	@echo 'Development environment started'" >> Makefile
    
    echo "  ✅ Generated Makefile"
fi

echo ""
echo "=============================================="
echo "✅ Adaptive installation complete!"
echo ""
echo "Your architecture-specific environment is ready:"

if [ "$BACKEND_LANG" == "python" ]; then
    echo "  • Python backend with $BACKEND_FRAMEWORK"
fi
if [ "$FRONTEND_LANG" == "typescript" ]; then
    echo "  • TypeScript frontend with $FRONTEND_FRAMEWORK"
fi
if [ "$DATABASE" == "postgresql" ]; then
    echo "  • PostgreSQL database"
fi
if [ "$CACHE" == "redis" ]; then
    echo "  • Redis cache"
fi

echo ""
echo "Next steps:"
echo "  1. Run 'make dev' to start development"
echo "  2. Open Claude and start building"
echo ""
echo "Happy coding! 🚀"