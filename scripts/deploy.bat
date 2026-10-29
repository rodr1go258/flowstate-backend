@echo off
REM 🚀 Script de Despliegue - FlowState (Windows)
REM Uso: deploy.bat [backend|frontend|all]

setlocal enabledelayedexpansion

set "PROJECT_ROOT=%~dp0.."
set "BACKEND_DIR=%PROJECT_ROOT%\apps\api"
set "FRONTEND_DIR=%PROJECT_ROOT%\apps\web"

echo.
echo ═══════════════════════════════════════
echo   🚀 FlowState Deployment Script
echo ═══════════════════════════════════════
echo.

REM Verificar archivos .env
if not exist "%PROJECT_ROOT%\.env.local" (
    echo ⚠️  No se encontró .env.local
    echo    Crea uno basado en .env.example
    echo.
    exit /b 1
)

echo ✓ Archivo de variables encontrado

REM Main
set "TARGET=%1"
if "%TARGET%"=="" set "TARGET=all"

if "%TARGET%"=="backend" goto deploy_backend
if "%TARGET%"=="frontend" goto deploy_frontend
if "%TARGET%"=="all" goto deploy_all
goto usage

:deploy_backend
echo.
echo ^>^>^> BACKEND (Go + Docker)
echo.

REM Verificar Docker
docker --version >nul 2>&1
if errorlevel 1 (
    echo ✗ Docker no está instalado
    exit /b 1
)

echo ✓ Docker disponible
echo.
echo 📦 Construyendo imagen Docker...

cd /d "%BACKEND_DIR%"
docker build -t flowstate-api:latest .

if errorlevel 1 (
    echo ✗ Build falló
    exit /b 1
)

echo.
echo ✓ Imagen construida: flowstate-api:latest
echo.
echo 📤 Próximos pasos para desplegar:
echo    1. Push a GitHub: git push origin main
echo    2. Render detectará automáticamente el Dockerfile
echo    3. O usa Railway.app para despliegue automático
echo.
exit /b 0

:deploy_frontend
echo.
echo ^>^>^> FRONTEND (Next.js)
echo.

if not exist "%FRONTEND_DIR%\.env.local" (
    echo ⚠️  No se encontró .env.local en apps/web
    echo    Crea apps/web\.env.local con:
    echo    NEXT_PUBLIC_API_URL=https://tu-backend.onrender.com
    echo.
    exit /b 1
)

echo ✓ Variables de entorno configuradas
echo.

cd /d "%FRONTEND_DIR%"

if not exist "node_modules" (
    echo 📦 Instalando dependencias...
    call npm install
    if errorlevel 1 exit /b 1
)

echo.
echo 🔨 Construyendo Next.js...
call npm run build
if errorlevel 1 exit /b 1

echo.
echo ✓ Build completado exitosamente
echo.
echo 📤 Para desplegar en Vercel:
echo    1. git push origin main
echo    2. Ve a vercel.com
echo    3. Importa el repositorio
echo    4. Root directory: apps/web
echo    5. Agrega NEXT_PUBLIC_API_URL en variables
echo.
exit /b 0

:deploy_all
call :deploy_backend
if errorlevel 1 exit /b 1
call :deploy_frontend
if errorlevel 1 exit /b 1
echo.
echo ✓ Script completado
echo.
echo 📚 Más información: Lee DEPLOYMENT.md
echo.
exit /b 0

:usage
echo Uso: %0 [backend^|frontend^|all]
exit /b 1
