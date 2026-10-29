#!/bin/bash
# 🚀 Script de Despliegue - FlowState
# Uso: ./scripts/deploy.sh [backend|frontend|all]

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="$PROJECT_ROOT/apps/api"
FRONTEND_DIR="$PROJECT_ROOT/apps/web"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  🚀 FlowState Deployment Script${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}\n"

# Funciones auxiliares
check_env_file() {
    local env_file="$1"
    local component="$2"
    
    if [ ! -f "$env_file" ]; then
        echo -e "${YELLOW}⚠️  No se encontró $env_file${NC}"
        echo -e "${YELLOW}    Crea uno basado en .env.example${NC}\n"
        return 1
    fi
    
    echo -e "${GREEN}✓${NC} Archivo de variables encontrado: $env_file"
    return 0
}

validate_env_vars() {
    local env_file="$1"
    local required_vars=("$@")
    
    for var in "${required_vars[@]:1}"; do
        if ! grep -q "^$var=" "$env_file" && ! grep -q "^export $var=" "$env_file"; then
            echo -e "${RED}✗${NC} Variable faltante: $var"
            return 1
        fi
    done
    
    return 0
}

deploy_backend() {
    echo -e "\n${BLUE}>>> BACKEND (Go + Docker)${NC}\n"
    
    # Verificar variables de entorno
    if ! check_env_file "$PROJECT_ROOT/.env.local" "backend"; then
        return 1
    fi
    
    # Validar variables críticas
    required_vars=("DATABASE_URL" "JWT_SECRET")
    if ! validate_env_vars "$PROJECT_ROOT/.env.local" "${required_vars[@]}"; then
        echo -e "${RED}✗ Variables de entorno incompletas${NC}\n"
        return 1
    fi
    
    echo -e "${GREEN}✓${NC} Variables de entorno validadas\n"
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}✗ Docker no está instalado${NC}\n"
        return 1
    fi
    
    echo -e "${GREEN}✓${NC} Docker disponible\n"
    
    # Build local
    echo -e "${BLUE}📦 Construyendo imagen Docker...${NC}"
    cd "$BACKEND_DIR"
    
    # Si tienes docker-compose
    if [ -f "$BACKEND_DIR/docker-compose.yml" ]; then
        docker-compose build
    else
        # Build manual
        docker build -t flowstate-api:latest .
        echo -e "${GREEN}✓${NC} Imagen construida: flowstate-api:latest\n"
    fi
    
    # Instrucciones para push a Render/Railway
    echo -e "${YELLOW}📤 Próximos pasos para desplegar:${NC}"
    echo -e "   1. Push a GitHub: git push origin main"
    echo -e "   2. Render detectará automáticamente el Dockerfile"
    echo -e "   3. O usa Railway.app para despliegue automático\n"
}

deploy_frontend() {
    echo -e "\n${BLUE}>>> FRONTEND (Next.js)${NC}\n"
    
    # Verificar variables
    if ! check_env_file "$FRONTEND_DIR/.env.local" "frontend"; then
        echo -e "${YELLOW}    Crea $FRONTEND_DIR/.env.local con:${NC}"
        echo -e "    ${BLUE}NEXT_PUBLIC_API_URL=https://tu-backend.onrender.com${NC}\n"
        return 1
    fi
    
    echo -e "${GREEN}✓${NC} Variables de entorno configuradas\n"
    
    # Verificar dependencias
    cd "$FRONTEND_DIR"
    
    if [ ! -d "node_modules" ]; then
        echo -e "${BLUE}📦 Instalando dependencias...${NC}"
        npm install || pnpm install || yarn install
    fi
    
    echo -e "\n${BLUE}🔨 Construyendo Next.js...${NC}"
    npm run build || pnpm build || yarn build
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Build completado exitosamente\n"
    else
        echo -e "${RED}✗ Build falló${NC}\n"
        return 1
    fi
    
    # Instrucciones para Vercel
    echo -e "${YELLOW}📤 Para desplegar en Vercel:${NC}"
    echo -e "   1. git push origin main"
    echo -e "   2. Ve a vercel.com"
    echo -e "   3. Importa el repositorio"
    echo -e "   4. Root directory: apps/web"
    echo -e "   5. Agrega NEXT_PUBLIC_API_URL en variables\n"
}

# Main
DEPLOY_TARGET="${1:-all}"

case "$DEPLOY_TARGET" in
    backend)
        deploy_backend
        ;;
    frontend)
        deploy_frontend
        ;;
    all)
        deploy_backend
        deploy_frontend
        ;;
    *)
        echo -e "${RED}Uso: $0 [backend|frontend|all]${NC}\n"
        exit 1
        ;;
esac

echo -e "${GREEN}✓ Script completado${NC}\n"
echo -e "${BLUE}📚 Más información: Lee DEPLOYMENT.md${NC}\n"
