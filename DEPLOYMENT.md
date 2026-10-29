# 🚀 Guía de Despliegue - FlowState

## Resumen Rápido

Este proyecto consta de 3 componentes:

1. **Backend** (Go + PostgreSQL en InsForge)
2. **Frontend** (Next.js)
3. **Base de datos** (PostgreSQL en InsForge - ya existe)

---

## 📋 Pre-requisitos

- [ ] Cuenta en [Render.com](https://render.com) o [Railway.app](https://railway.app)
- [ ] Cuenta en [Vercel](https://vercel.com)
- [ ] Proyecto creado en [InsForge](https://insforge.dev)
- [ ] `DATABASE_URL` de InsForge (PostgreSQL)
- [ ] `JWT_SECRET` generado (mínimo 32 caracteres)
- [ ] Credenciales de Google OAuth (si usas autenticación)
- [ ] Clave API de OpenRouter (si usas IA)
- [ ] Repositorio GitHub con este código

---

## 🔧 Paso 1: Preparar Variables de Entorno

### 1.1 Backend (.env.local en la raíz del proyecto)

```bash
# Base de datos
DATABASE_URL=postgresql://user:pass@host:5432/flowstate

# Autenticación
JWT_SECRET=tu_clave_de_32_caracteres_generada_con_openssl
ACCESS_TTL=15m
REFRESH_TTL=168h

# Servidor
PORT=8080
LOG_LEVEL=info
ENV=production
CORS_ORIGINS=https://tudominio.com,https://app.tudominio.com

# OAuth Google
GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com

# OpenRouter (IA)
OPENROUTER_API_KEY=sk-xxx
OPENROUTER_MODEL=openai/gpt-4o-mini
```

### 1.2 Frontend (apps/web/.env.local)

```bash
NEXT_PUBLIC_API_URL=https://api.tudominio.com
```

---

## 🚀 Paso 2: Desplegar Backend (Go + Dockerfile)

### Opción A: Render.com (Recomendado)

1. **Conecta tu repositorio:**
   - Ve a [dashboard.render.com](https://dashboard.render.com)
   - Conecta GitHub
   - Crea nuevo "Web Service"
   - Selecciona tu repositorio

2. **Configura el servicio:**
   - **Name**: `flowstate-api`
   - **Root Directory**: `apps/api`
   - **Runtime**: Docker
   - **Build Command**: (déjalo en blanco, usa Dockerfile)
   - **Start Command**: (déjalo en blanco, usa Dockerfile)

3. **Agrega variables de entorno:**
   - Click en "Environment"
   - Agrega cada variable de `DATABASE_URL`, `JWT_SECRET`, etc.

4. **Deploy:**
   - El despliegue comienza automáticamente
   - Tu API estará en: `https://flowstate-api.onrender.com`

### Opción B: Railway.app

1. Ve a [railway.app](https://railway.app)
2. Crea nuevo proyecto → Conecta GitHub
3. Selecciona carpeta: `apps/api`
4. Railway detectará automáticamente el Dockerfile
5. Agrega las variables de entorno
6. Deploy automático

---

## 🎨 Paso 3: Desplegar Frontend (Next.js)

### Opción A: Vercel (Recomendado para Next.js)

1. **Conecta el repositorio:**
   - Ve a [vercel.com](https://vercel.com)
   - Click "Add New Project"
   - Importa tu repositorio GitHub

2. **Configura el proyecto:**
   - **Project Name**: `flowstate-web`
   - **Root Directory**: `apps/web`

3. **Agrega variables de entorno:**
   - En "Environment Variables"
   - `NEXT_PUBLIC_API_URL` = `https://tu-backend.onrender.com` (o el dominio de tu API)

4. **Deploy:**
   - Vercel despliega automáticamente
   - Tu app estará en: `https://flowstate-web.vercel.app`

### Opción B: Render.com

Puedes desplegar ambos (backend + frontend) en Render si lo prefieres.

---

## 🔗 Paso 4: Configurar CORS y Conexiones

### Actualiza tu Backend con los dominios correctos

Cuando tengas URLs finales:

1. Actualiza la variable de entorno `CORS_ORIGINS` en tu backend con:
   ```
   https://flowstate-web.vercel.app,https://tudominio.com
   ```

2. En el frontend, actualiza `.env.local`:
   ```
   NEXT_PUBLIC_API_URL=https://tu-backend.onrender.com
   ```

3. Si usas OAuth Google, agrega en Google Cloud Console:
   - Authorized origins: `https://flowstate-web.vercel.app`
   - Authorized redirect URIs: `https://flowstate-web.vercel.app/auth/callback`

---

## 🗄️ Paso 5: Base de Datos (InsForge)

Ya deberías tener PostgreSQL en InsForge. Solo asegúrate de:

1. Que `DATABASE_URL` sea correcto y válido
2. Ejecutar migraciones en producción (ver siguiente sección)

---

## 🔄 Paso 6: Ejecutar Migraciones en Producción

Las migraciones SQL están en `/migrations/`. Necesitas:

### Opción A: CLI de golang-migrate

```bash
# Instala migrate
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# Ejecuta migraciones
migrate -path ./migrations -database "$DATABASE_URL" up
```

### Opción B: Ejecutar SQL manualmente

1. Copia el contenido de `migrations/20260623172511_flowstate-init.sql`
2. Conéctate a tu base de datos InsForge
3. Ejecuta el SQL en la consola/editor de InsForge
4. Verifica que las tablas se crearon

### Opción C: Desde el backend (recomendado)

Agrega a tu código Go (solo en startup si `ENV=production`):

```go
// Pseudocódigo - adapta a tu estructura
if cfg.Env == "production" {
    migrate.NewPool(pool)
    // o ejecutar migraciones automáticamente
}
```

---

## ✅ Checklist de Despliegue

- [ ] Variables de entorno completadas en `.env.example`
- [ ] Backend desplegado en Render/Railway/otra plataforma
- [ ] Frontend desplegado en Vercel
- [ ] Database conectada y migraciones ejecutadas
- [ ] CORS configurado en backend
- [ ] OAuth Google configurado (si aplica)
- [ ] OpenRouter API key configurada (si usas IA)
- [ ] Dominio personalizado configurado (opcional)
- [ ] SSL/HTTPS verificado
- [ ] Tests en producción completados
- [ ] Logs monitoreados

---

## 🧪 Verificar Despliegue

```bash
# 1. Backend health check
curl https://tu-backend.onrender.com/health

# 2. Frontend disponible
curl https://flowstate-web.vercel.app

# 3. API authentication
curl -X POST https://tu-backend.onrender.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test"}'
```

---

## 🐛 Solución de Problemas

### Backend no inicia
- Verifica `DATABASE_URL` es válido
- Verifica `JWT_SECRET` existe y no está vacío
- Revisa logs en Render/Railway dashboard

### Frontend no conecta a API
- Verifica `NEXT_PUBLIC_API_URL` es correcto
- Verifica CORS en backend permite el dominio del frontend
- Revisa consola del navegador en DevTools

### Migraciones fallan
- Verifica permiso de usuario en PostgreSQL
- Verifica que el SQL es válido
- Ejecuta manualmente en editor de InsForge

---

## 📚 Referencias

- [Documentación Go](https://go.dev)
- [Documentación Next.js](https://nextjs.org)
- [Render Deployment Docs](https://docs.render.com)
- [Vercel Deployment Docs](https://vercel.com/docs)
- [InsForge Docs](https://insforge.dev/docs)

---

**¿Necesitas ayuda con un paso específico?** Menciona cuál y te lo explico en detalle.
