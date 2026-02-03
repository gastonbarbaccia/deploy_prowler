#!/bin/bash
set -e

# Variables
PUBLIC_HOST=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

apt update -y
apt upgrade -y

# Docker
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

apt update -y
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker
until docker info >/dev/null 2>&1; do sleep 3; done

usermod -aG docker ubuntu

# Prowler
cd /home/ubuntu
git clone https://github.com/gastonbarbaccia/prowler_custom.git
cd prowler_custom

# .env dinámico
cat <<ENV > .env
#### Important Note ####
# This file is used to store environment variables for the Prowler App.

#### Prowler UI Configuration ####
PROWLER_UI_VERSION="stable"
AUTH_URL=http://${PUBLIC_HOST}:3000
API_BASE_URL=http://prowler-api:8080/api/v1
NEXT_PUBLIC_API_BASE_URL=http://prowler-api:8080/api/v1
NEXT_PUBLIC_API_DOCS_URL=http://prowler-api:8080/api/v1/docs
AUTH_TRUST_HOST=true
UI_PORT=3000
AUTH_SECRET="N/c6mnaS5+SWq81+819OrzQZlmx1Vxtp/orjttJSmw8="
NEXT_PUBLIC_GOOGLE_TAG_MANAGER_ID=""

#### MCP Server ####
PROWLER_MCP_VERSION=stable
PROWLER_MCP_SERVER_URL=http://mcp-server:8000/mcp

#### Code Review Configuration ####
CODE_REVIEW_ENABLED=true

#### Prowler API Configuration ####
PROWLER_API_VERSION="stable"

POSTGRES_HOST=postgres-db
POSTGRES_PORT=5432
POSTGRES_ADMIN_USER=prowler_admin
POSTGRES_ADMIN_PASSWORD=postgres
POSTGRES_USER=prowler
POSTGRES_PASSWORD=postgres
POSTGRES_DB=prowler_db

# Neo4j
NEO4J_HOST=neo4j
NEO4J_PORT=7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=neo4j_password
NEO4J_DBMS_MAX__DATABASES=1000
NEO4J_SERVER_MEMORY_PAGECACHE_SIZE=1G
NEO4J_SERVER_MEMORY_HEAP_INITIAL__SIZE=1G
NEO4J_SERVER_MEMORY_HEAP_MAX__SIZE=1G
NEO4J_POC_EXPORT_FILE_ENABLED=true
NEO4J_APOC_IMPORT_FILE_ENABLED=true
NEO4J_APOC_IMPORT_FILE_USE_NEO4J_CONFIG=true
NEO4J_PLUGINS=["apoc"]
NEO4J_DBMS_SECURITY_PROCEDURES_ALLOWLIST=apoc.*
NEO4J_DBMS_SECURITY_PROCEDURES_UNRESTRICTED=apoc.*
NEO4J_DBMS_CONNECTOR_BOLT_LISTEN_ADDRESS=0.0.0.0:7687
ATTACK_PATHS_FINDINGS_BATCH_SIZE=1000

# Celery
TASK_RETRY_DELAY_SECONDS=0.1
TASK_RETRY_ATTEMPTS=5

# Valkey
VALKEY_HOST=valkey
VALKEY_PORT=6379
VALKEY_DB=0

# Django
DJANGO_TMP_OUTPUT_DIRECTORY="/tmp/prowler_api_output"
DJANGO_FINDINGS_BATCH_SIZE=1000
DJANGO_ALLOWED_HOSTS=*
DJANGO_BIND_ADDRESS=0.0.0.0
DJANGO_PORT=8080
DJANGO_DEBUG=False
DJANGO_SETTINGS_MODULE=config.django.production
DJANGO_LOGGING_FORMATTER=human_readable
DJANGO_LOGGING_LEVEL=INFO
DJANGO_WORKERS=4
DJANGO_ACCESS_TOKEN_LIFETIME=30
DJANGO_REFRESH_TOKEN_LIFETIME=1440
DJANGO_CACHE_MAX_AGE=3600
DJANGO_STALE_WHILE_REVALIDATE=60
DJANGO_MANAGE_DB_PARTITIONS=True
DJANGO_TOKEN_SIGNING_KEY=""
DJANGO_TOKEN_VERIFYING_KEY=""
DJANGO_SECRETS_ENCRYPTION_KEY="oE/ltOhp/n1TdbHjVmzcjDPLcLA41CVI/4Rk+UB5ESc="
DJANGO_BROKER_VISIBILITY_TIMEOUT=86400
DJANGO_THROTTLE_TOKEN_OBTAIN=50/minute

# Sentry
SENTRY_ENVIRONMENT=local
SENTRY_RELEASE=local
NEXT_PUBLIC_SENTRY_ENVIRONMENT=local

#### Prowler release ####
NEXT_PUBLIC_PROWLER_RELEASE_VERSION=v5.16.0

# OAuth
SOCIAL_GOOGLE_OAUTH_CALLBACK_URL=http://${PUBLIC_HOST}:3000/api/auth/callback/google
SOCIAL_GITHUB_OAUTH_CALLBACK_URL=http://${PUBLIC_HOST}:3000/api/auth/callback/github
SAML_SSO_CALLBACK_URL=http://${PUBLIC_HOST}:3000/api/auth/callback/saml

# RSS
RSS_FEED_SOURCES='[{"id":"prowler-releases","name":"Prowler Releases","type":"github_releases","url":"https://github.com/prowler-cloud/prowler/releases.atom","enabled":true}]'
ENV


sudo docker compose up -d
