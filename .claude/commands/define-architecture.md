---
name: define-architecture
description: Define project architecture and generate appropriate dev environment
tools: [Read, Write, Edit]
---

# Architecture Definition

Define your project's architecture BEFORE installing dependencies. This determines what gets installed and how the project is structured.

## Usage

```bash
# Interactive architecture definition
/define-architecture

# From existing spec
/define-architecture --from-spec spec.md

# Quick presets
/define-architecture --preset api-only
/define-architecture --preset full-stack
/define-architecture --preset data-pipeline
```

## Process

1. **Analyze Requirements**: Read spec or ask questions
2. **Detect Patterns**: Identify architecture needs
3. **Select Stack**: Choose appropriate technologies
4. **Generate Config**: Create architecture.yml
5. **Setup Environment**: Generate install scripts

## Architecture Decision Points

### Core Questions
1. **What are you building?**
   - API service only
   - Web application with UI
   - Data processing pipeline
   - Mobile app with backend
   - CLI tool
   - Library/SDK

2. **Data Requirements**
   - Simple CRUD → PostgreSQL
   - Document store → MongoDB
   - Time series → TimescaleDB
   - Graph data → Neo4j
   - Key-value → Redis
   - No database → File/Memory

3. **Real-time Needs**
   - None → REST API
   - Websockets → Socket.io
   - Server-sent events → SSE
   - Pub/Sub → Redis/Kafka
   - Streaming → Kafka/Pulsar

4. **Scale Expectations**
   - Prototype → Monolith
   - Small team → Modular monolith
   - High traffic → Microservices
   - Global → Edge/CDN

5. **Deployment Target**
   - Local only → Docker Compose
   - Cloud → AWS/GCP/Azure
   - Serverless → Lambda/Vercel
   - Kubernetes → k8s configs
   - Edge → Cloudflare Workers

## Output: architecture.yml

```yaml
# .claude/architecture.yml
project:
  name: "My App"
  type: "full-stack"
  description: "E-commerce platform"

stack:
  backend:
    language: "python"
    framework: "fastapi"
    version: "3.11"
    packages:
      - fastapi
      - sqlalchemy
      - alembic
      - redis
      - celery
    
  frontend:
    language: "typescript"
    framework: "nextjs"
    version: "14"
    packages:
      - react
      - tailwindcss
      - react-query
      - zod
    
  database:
    primary: "postgresql"
    version: "15"
    cache: "redis"
    search: "elasticsearch"  # if needed
    
  infrastructure:
    containerization: "docker"
    orchestration: "docker-compose"  # or kubernetes
    ci_cd: "github-actions"
    monitoring: "prometheus"  # optional

structure:
  create_dirs:
    - apps/api
    - apps/web
    - apps/worker  # if async jobs
    - infrastructure
    - scripts
    
  ignore_dirs:
    - mobile  # not needed
    - desktop  # not needed

development:
  ports:
    api: 8000
    web: 3000
    db: 5432
    redis: 6379
    
  environment:
    - DATABASE_URL
    - REDIS_URL
    - SECRET_KEY
    - API_URL

testing:
  framework:
    backend: "pytest"
    frontend: "jest"
    e2e: "playwright"
    
deployment:
  strategy: "blue-green"
  platform: "railway"  # or aws, gcp, etc.
```

## Architecture Presets

### API-Only
```yaml
type: "api"
stack:
  backend: fastapi/express/django
  database: postgresql
  cache: redis
no_frontend: true
```

### Full-Stack SaaS
```yaml
type: "saas"
stack:
  backend: fastapi
  frontend: nextjs
  database: postgresql
  auth: auth0/clerk
  payments: stripe
```

### Data Pipeline
```yaml
type: "data-pipeline"
stack:
  orchestrator: airflow/prefect
  processing: pandas/spark
  storage: s3/gcs
  database: warehouse
```

### Real-time App
```yaml
type: "realtime"
stack:
  backend: fastapi
  frontend: nextjs
  websockets: socket.io
  pubsub: redis
  database: postgresql
```

### Machine Learning
```yaml
type: "ml-platform"
stack:
  training: pytorch/tensorflow
  serving: fastapi/mlflow
  data: postgresql/s3
  compute: gpu-enabled
```

## Impact on Installation

Based on architecture, generates:

### Custom requirements.txt
```python
# Generated for your architecture
fastapi==0.104.1
sqlalchemy==2.0.23
redis==5.0.1
# ML-specific (if needed)
torch==2.1.0
transformers==4.35.0
```

### Custom package.json
```json
{
  "dependencies": {
    // Only what you need
    "next": "14.0.0",
    "react": "18.2.0"
  }
}
```

### Custom docker-compose.yml
```yaml
services:
  # Only services you need
  api:
    build: ./apps/api
  db:
    image: postgres:15
  # No unused services
```

## Integration with Dev Environment

After architecture definition:

```bash
# 1. Architecture creates config
/define-architecture → architecture.yml

# 2. Install script reads architecture
./install.sh → reads architecture.yml → installs only needed deps

# 3. Make commands adapt
make dev → starts only defined services
make test → runs only relevant tests
```

## Best Practices

1. **Define architecture FIRST** - Before any code
2. **Start simple** - You can always add services
3. **Match your skills** - Choose familiar tech
4. **Consider maintenance** - Boring > Exciting
5. **Plan for growth** - But don't over-engineer

## Examples

### Simple API
```bash
/define-architecture --preset api-only
# Creates: PostgreSQL + FastAPI + Docker
```

### Modern SaaS
```bash
/define-architecture --preset saas
# Creates: Next.js + FastAPI + PostgreSQL + Redis + Stripe
```

### Data Platform
```bash
/define-architecture --preset data-pipeline
# Creates: Airflow + PostgreSQL + S3 + Pandas
```