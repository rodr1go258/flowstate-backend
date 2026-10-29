# 🚀 Despliegue en Render.com - Guía Visual Paso a Paso

## 📌 Resumen

Render.com es una plataforma moderna que despliega **Docker** automáticamente. Tu backend Go compilado en un contenedor, listo en ~5 minutos.

---

## 🎯 Paso 1: Preparativos (2 min)

### 1.1 Verificar Dockerfile

Abre `apps/api/Dockerfile` y verifica que existe:

```dockerfile
FROM golang:1.26-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 go build -o /server ./cmd/server

FROM alpine:3.21
RUN apk add --no-cache ca-certificates
WORKDIR /app
COPY --from=builder /server .
EXPOSE 8080
CMD ["/app/server"]
```

✅ Si está así, perfecto.

### 1.2 Verificar que el código está en GitHub

```bash
git remote -v
# Debería mostrar: origin  https://github.com/tuusuario/backend-integrador-sistemas2-main.git

git push  # Asegúrate de que todo esté actualizado en main
```

### 1.3 Prepara las Variables de Entorno

Necesitarás tener listos estos valores:

```
DATABASE_URL=postgresql://user:password@host.insforge.app:5432/flowstate
JWT_SECRET=tu_clave_secreta_de_32_caracteres_minimo
GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com (opcional)
OPENROUTER_API_KEY=sk-xxx (opcional)
```

---

## 🔑 Paso 2: Crear Cuenta en Render (1 min)

### 2.1 Ir a Render.com

1. Ve a **https://render.com**
2. Click **"Get Started"** (arriba a la derecha)
3. Selecciona **"Sign up with GitHub"**
4. Autoriza Render en GitHub
5. Confirma tu email

✅ Cuenta creada.

---

## 📁 Paso 3: Crear Nuevo Web Service (1 min)

### 3.1 Dashboard de Render

Una vez logueado, deberías ver el Dashboard.

Click en el botón **"New +"** (arriba a la derecha) → **"Web Service"**

### 3.2 Conectar GitHub

1. En "Connect a repository", deberías ver tu repositorio listado
2. Busca `backend-integrador-sistemas2-main`
3. Click **"Connect"** al lado

Si no aparece:
1. Click **"Configure account"** en GitHub
2. Autoriza Render a acceder a más repositorios
3. Vuelve a Render y recarga

✅ Repositorio conectado.

---

## ⚙️ Paso 4: Configurar el Servicio

Deberías ver la pantalla "Create a new Web Service". Aquí es crítico:

### 4.1 Nombre y Región

```
Name: flowstate-api
Region: North America (Virginia) o la más cercana a ti
```

### 4.2 Environment

```
Environment: Docker
```

Render detecta automáticamente tu Dockerfile ✓

### 4.3 Plan

```
Plan: Free (o Starter si quieres, pero Free sirve para MVP)
```

**Importante:** 
- Free tier: 750 horas/mes compartidas (suficiente para 1 servicio 24/7)
- Instancias se "despiertan" cuando inactivas (5-30 segundos)

### 4.4 Build Settings (Verifica)

Debería mostrar:

```
Build Command: (vacío - usa Dockerfile)
Start Command: (vacío - usa Dockerfile)
Dockerfile: ./Dockerfile
```

✅ Si está así, continúa.

---

## 🔐 Paso 5: Variables de Entorno (CRÍTICO)

### 5.1 Agregar Variables

En la sección "Environment", haz scroll hasta encontrar **"Environment Variables"**.

Click **"Add Environment Variable"** para cada una:

#### Variable 1: DATABASE_URL
```
Key:   DATABASE_URL
Value: postgresql://user:password@host.insforge.app:5432/flowstate
```

> Reemplaza `user`, `password`, `host` con tus credenciales de InsForge.

#### Variable 2: JWT_SECRET
```
Key:   JWT_SECRET
Value: TU_CLAVE_SECRETA_DE_32_CARACTERES
```

> Genera con: `openssl rand -base64 32` en tu terminal

#### Variable 3: PORT
```
Key:   PORT
Value: 8080
```

#### Variable 4: ENV
```
Key:   ENV
Value: production
```

#### Variable 5: LOG_LEVEL
```
Key:   LOG_LEVEL
Value: info
```

#### Variable 6: CORS_ORIGINS
```
Key:   CORS_ORIGINS
Value: http://localhost:3000
```

> Cambiaremos esto después cuando tengas Vercel.

#### Variables Opcionales

Si tienes credenciales, agrégalas:

```
Key:   GOOGLE_CLIENT_ID
Value: xxx.apps.googleusercontent.com

Key:   OPENROUTER_API_KEY
Value: sk-xxx
```

### 5.2 Verificación

Debería verse algo así:

```
Environment Variables
┌─────────────────────────────────────────────┐
│ DATABASE_URL                 postgresql://... │
│ JWT_SECRET                   ***masked***     │
│ PORT                         8080             │
│ ENV                          production       │
│ LOG_LEVEL                    info             │
│ CORS_ORIGINS                 http://localhost│
│ GOOGLE_CLIENT_ID             xxx...           │
│ OPENROUTER_API_KEY           sk-...           │
└─────────────────────────────────────────────┘
```

---

## 🚀 Paso 6: Deploy

### 6.1 Revisar Todo

Antes de hacer deploy, verifica:

```
✓ Name: flowstate-api
✓ Repository: tu-repo/backend-integrador-sistemas2-main
✓ Branch: main
✓ Environment: Docker
✓ Dockerfile: ./Dockerfile
✓ Region: Configurada
✓ All Environment Variables: Agregadas
```

### 6.2 Hacer Deploy

Click el botón **"Deploy"** (grande, abajo a la derecha)

Vercel comienza a:
1. Clonar tu repositorio
2. Compilar la imagen Docker
3. Desplegar el contenedor
4. Asignar una URL

**Esto toma ~3-5 minutos.**

### 6.3 Esperar el Resultado

Deberías ver:

```
Building...
┌─ Build started
├─ Step 1/8: FROM golang:1.26-alpine AS builder
├─ Step 2/8: WORKDIR /app
│...
├─ Step 8/8: CMD ["/app/server"]
└─ Build completed

✓ Deploying service
✓ Service live at: https://flowstate-api.onrender.com
```

✅ **¡Tu API está viva!**

---

## 🌐 Paso 7: Verificar el Despliegue

### 7.1 Health Check

Abre en tu navegador (o cURL):

```bash
curl https://flowstate-api.onrender.com/health
```

Debería responder algo como:

```json
{
  "status": "ok",
  "uptime": "45s"
}
```

### 7.2 Swagger (Documentación)

Ve a:

```
https://flowstate-api.onrender.com/swagger/index.html
```

Deberías ver la documentación OpenAPI interactiva.

### 7.3 Copiar URL

Tu API está en: **`https://flowstate-api.onrender.com`**

Guarda esta URL, la necesitarás para:
- Actualizar Vercel (frontend)
- Actualizar CORS_ORIGINS
- Testing

---

## 🔄 Paso 8: Conectar con Frontend

Una vez que tengas Vercel desplegado, necesitas conectarlos:

### 8.1 Actualizar CORS en Render

1. Ve a **https://dashboard.render.com**
2. Selecciona tu servicio: `flowstate-api`
3. Click **"Settings"** (en la parte superior)
4. Scroll hasta **"Environment"**
5. Edita `CORS_ORIGINS` y cambia a:
   ```
   https://flowstate-web.vercel.app
   ```
6. Click **"Save Changes"**

Render redeploya automáticamente (~2 minutos).

### 8.2 Actualizar API URL en Vercel

1. Ve a **https://vercel.com/dashboard**
2. Selecciona `flowstate-web`
3. **Settings** → **Environment Variables**
4. Edita `NEXT_PUBLIC_API_URL`:
   ```
   https://flowstate-api.onrender.com
   ```
5. Click **"Save"**

Vercel redeploya automáticamente (~1 minuto).

---

## 🛠️ Solucionar Problemas

### ❌ Error: "Build failed: exit code 1"

**Causa:** Error compilando Go o en el Dockerfile

**Solución:**
1. Ve a **"Logs"** en Render
2. Scroll hasta el error (búscalo en rojo)
3. Errores comunes:
   ```
   error: cannot find package "github.com/xxx"
   → Solución: Asegúrate que go.mod y go.sum están en apps/api/
   
   error: Package 'ca-certificates' not found
   → Solución: Alpine 3.21 debe tener los certificados. Usa nuestra imagen.
   ```

### ❌ Error: "Service failed to start"

**Causa:** Aplicación Go no inicia

**Solución:**
1. Verifica logs completos
2. Errores típicos:
   ```
   DATABASE_URL is required
   → Agregaste la variable en Render?
   
   Failed to connect to database
   → ¿Es correcta la DATABASE_URL?
   → ¿Firewall de InsForge permite Render?
   
   JWT_SECRET is required
   → Falta la variable o está vacía
   ```

### ⚠️ /health devuelve error 404

**Causa:** No hay endpoint /health

**Solución:**
1. Verifica que existe en `apps/api/internal/handler/health.go`
2. Asegúrate que está registrado en el router
3. Re-deploy

### ⚠️ CORS error en frontend

```
Access to XMLHttpRequest at 'https://flowstate-api.onrender.com/...' 
from origin 'https://flowstate-web.vercel.app' has been blocked by CORS policy
```

**Causa:** CORS_ORIGINS no está bien configurado

**Solución:**
1. En Render, edita `CORS_ORIGINS`
2. Debe ser exactamente: `https://flowstate-web.vercel.app`
3. NO agregar `http://` (solo `https://`)
4. NO agregar trailing slash
5. Re-deploy

### ❌ Service goes to sleep (Free tier)

**Comportamiento Normal:** En Free tier, si no hay tráfico en 15 minutos, Render pausa el servicio.

**Síntoma:** Primera petición tarda 20-30 segundos

**Soluciones:**
1. Usar Starter plan ($7/mes) - sin pausas
2. Configurar "Auto-wake" (hay herramientas)
3. Aceptar que MVP tiene latencia al inicio

---

## 📊 Dashboard de Render

Una vez desplegado, tu servicio muestra:

```
flowstate-api

Status: Live ✓
URL: https://flowstate-api.onrender.com

Logs (últimas líneas del servidor)
Metrics (CPU, memoria, requests)

Settings
├─ Environment Variables
├─ Custom Domains
├─ Build & Deploy Settings
└─ Auto-Deploy
```

---

## 🔄 Configurar Auto-Deploy

Por defecto, Render redeploya cuando haces `git push main`.

**Verificar:**
1. En Settings
2. Scroll a "Auto-Deploy"
3. Debería estar en "Yes" para `main`

✅ Cada `git push` hace un nuevo deploy automático.

---

## 🎯 Checklist Final

- [ ] GitHub actualizado (`git push`)
- [ ] Render conectado a GitHub
- [ ] Dockerfile verificado
- [ ] Todas las variables de entorno agregadas en Render
- [ ] Deploy completado sin errores
- [ ] `/health` responde correctamente
- [ ] `/swagger/index.html` muestra documentación
- [ ] URL guardada: `https://flowstate-api.onrender.com`
- [ ] Vercel configurado con `NEXT_PUBLIC_API_URL`
- [ ] CORS_ORIGINS actualizado en Render
- [ ] Frontend y backend conectados sin errores

---

## 🔗 Referencias Rápidas

| Recurso | Enlace |
|---|---|
| Dashboard Render | https://dashboard.render.com |
| Documentación | https://render.com/docs |
| Docker en Render | https://render.com/docs/deploy-docker |
| Troubleshooting | https://render.com/docs/troubleshooting |
| Go en Render | https://render.com/docs/go |

---

## 💡 Consejos Profesionales

### 1. Monitoreo de Logs
En Render, los logs están en tiempo real. Úsalos para debugging:
```
Logs → Tail Logs → Verás líneas conforme suceden
```

### 2. Redeploy Manual
Si necesitas redeploy sin hacer `git push`:
1. Settings → "Auto-Deploy" → "Redeploy latest"
2. O manualmente desde "Deployments"

### 3. Database Backups
InsForge maneja backups automáticos. Pero verifica en su dashboard.

### 4. Escalabilidad
Cuando crezcas:
- Upgrade a Starter plan ($7/mes)
- Luego a Standard ($25/mes)
- Finalmente cloud (AWS, etc.)

### 5. Custom Domain
Si tienes dominio (ej: api.flowstate.com):
1. Settings → "Custom Domains"
2. Agrega tu dominio
3. Actualiza DNS según instrucciones de Render

---

## 🔐 Mejores Prácticas

### Seguridad

✅ Usa `HTTPS` (Render lo proporciona gratis)  
✅ No hardcodees secrets en el código  
✅ Variables de entorno en Render, no en `.env.local` commiteed  
✅ JWT_SECRET debe ser fuerte (32+ caracteres)  
✅ CORS_ORIGINS solo dominios permitidos  

### Performance

✅ Logs en JSON (zap ya lo hace)  
✅ Monitorea métricas (CPU, memoria)  
✅ Usa CDN para archivos estáticos  
✅ Cache en responses si aplica  

---

**¿Necesitas ayuda con algún paso o tienes errores durante el despliegue?** Avísame y te lo resuelvo.
