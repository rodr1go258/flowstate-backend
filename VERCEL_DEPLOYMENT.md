# 🚀 Despliegue en Vercel - Guía Visual Paso a Paso

## 📌 Resumen

Vercel es la plataforma oficial de Next.js. Es **gratuita**, **rápida** y **automática**. En ~5 minutos tendrás tu app en línea.

---

## 🎯 Paso 1: Preparativos (2 min)

### 1.1 Verificar que el código está en GitHub

Tu repositorio debe estar en GitHub (público o privado).

```bash
# Verifica que has hecho push
git remote -v
# Debería mostrar algo como: origin  https://github.com/tuusuario/backend-integrador-sistemas2-main.git
```

### 1.2 Preparar variables de entorno locales

Crea `apps/web/.env.local`:

```bash
# apps/web/.env.local
NEXT_PUBLIC_API_URL=http://localhost:8080
```

> **Nota:** Cambiaremos esto después cuando tengas URL del backend en producción.

### 1.3 Verificar que Next.js compila

```bash
cd apps/web
npm install
npm run build
```

Si ves ✅ sin errores, estás listo.

---

## 🔑 Paso 2: Conectar GitHub a Vercel (1 min)

### 2.1 Crear cuenta en Vercel

1. Ve a **https://vercel.com**
2. Click en **"Sign Up"**
3. Selecciona **"GitHub"**
4. Autoriza Vercel en GitHub (acepta permisos)
5. Confirma tu email

✅ Cuenta creada.

---

## 📁 Paso 3: Importar el Proyecto (1 min)

### 3.1 Desde Dashboard de Vercel

1. Ve a **https://vercel.com/dashboard**
2. Click **"Add New..."** (arriba a la derecha)
3. Selecciona **"Project"**
4. Click **"Import Git Repository"**

### 3.2 Seleccionar el Repositorio

1. En el campo de búsqueda, escribe el nombre de tu repo
2. Debería aparecer: `backend-integrador-sistemas2-main`
3. Click **"Import"**

✅ Vercel inicia el setup automático.

---

## ⚙️ Paso 4: Configurar el Proyecto

Deberías ver la pantalla "Configure Project". Aquí es importante:

### 4.1 Framework Selection
- **Framework Preset:** Next.js (está preseleccionado ✓)

### 4.2 Root Directory

Esta es **CRÍTICA**:

1. Click en el campo de "Root Directory"
2. Borra lo que dice (probablemente está vacío)
3. Escribe: **`apps/web`**

**Verificación:**
```
Root Directory: apps/web
```

### 4.3 Build & Development Settings

Vercel auto-detecta. Debería verse así:

```
Build Command: next build
Output Directory: .next
Install Command: npm ci
Development Command: next dev
```

Si está así, ✅ continúa. Si no, NO cambies nada aún.

### 4.4 Environment Variables

Aquí agregarás las variables que tu Next.js necesita.

Haz click en **"Environment Variables"** y agrega:

**Variable 1: API URL**
```
Name: NEXT_PUBLIC_API_URL
Value: http://localhost:8080
```

> **Nota:** Por ahora es localhost. Lo cambiaremos después.

**Cómo hacerlo:**
1. Click **"Add"** (o el botón de agregar variable)
2. En "Name" escribe: `NEXT_PUBLIC_API_URL`
3. En "Value" escribe: `http://localhost:8080`
4. Click **"Save"**

Debería verse:
```
┌─────────────────────────────────────────┐
│ Environment Variables                   │
├─────────────────────────────────────────┤
│ NEXT_PUBLIC_API_URL    http://localhost │
│ Production             (empty)          │
└─────────────────────────────────────────┘
```

> **Importante:** Si tienes otras variables (Google OAuth, etc.), agrégalas aquí también, pero con el prefijo `NEXT_PUBLIC_` si necesitas que estén disponibles en el navegador.

### 4.5 Revisar Todo

```
✓ Project Name: flowstate-web (o el que quieras)
✓ Framework: Next.js
✓ Root Directory: apps/web
✓ Build Command: next build
✓ Environment Variables: NEXT_PUBLIC_API_URL agregada
```

Si todo es ✓, sigue adelante.

---

## 🚀 Paso 5: Deploy

### 5.1 Hacer Deploy

1. Click en **"Deploy"** (botón grande abajo a la derecha)
2. Vercel comienza a:
   - Clonar tu repositorio
   - Instalar dependencias (`npm install`)
   - Compilar Next.js (`npm run build`)
   - Desplegar a CDN

**Esto toma ~2-3 minutos.**

### 5.2 Esperar el Resultado

Deberías ver una pantalla como:

```
✓ Build completed in 45 seconds
✓ Deployed to: https://flowstate-web.vercel.app
✓ Production: flowstate-web.vercel.app
```

✅ **¡Tu app está viva!**

---

## 🌐 Paso 6: Verificar el Despliegue

### 6.1 Abrir tu sitio

1. Click en el enlace (algo como `https://flowstate-web.vercel.app`)
2. Tu app debería cargar ✓

### 6.2 Revisar Consola de Errores

1. Abre DevTools (F12 en Windows, Cmd+Option+I en Mac)
2. Ve a la pestaña **"Console"**
3. ¿Ves errores en rojo? 
   - Si ✅ no hay errores → perfecto
   - Si ❌ hay errores de CORS → mira la sección "Solucionar CORS" abajo

---

## 🔄 Paso 7: Conectar Backend

Una vez que tengas el backend desplegado (en Render o Railway), necesitas actualizar la URL.

### 7.1 En Render/Railway

Obtendrás una URL así: `https://flowstate-api.onrender.com`

### 7.2 Actualizar en Vercel

1. Ve a **https://vercel.com/dashboard**
2. Selecciona tu proyecto: `flowstate-web`
3. Click en **"Settings"** (arriba a la derecha)
4. Click en **"Environment Variables"** (en el sidebar izquierdo)
5. Busca `NEXT_PUBLIC_API_URL`
6. Cambia el valor a: `https://flowstate-api.onrender.com` (tu URL real)
7. Click **"Save"**

### 7.3 Re-deploy Automático

Vercel automáticamente hace redeploy con la nueva variable.

Espera ~1 minuto y verifica que todo funciona.

---

## 🛠️ Solucionar Problemas

### ❌ Error: "Build failed"

**Cause:** Error en Next.js

**Solución:**
1. Ve a **"Deployments"** en el dashboard de Vercel
2. Click en el deployment fallido
3. Haz scroll down a **"Logs"**
4. Lee el error completo
5. Copia el error y busca en GitHub Issues de Next.js

Errores comunes:
```
Error: Cannot find module 'zustand'
→ Solución: Corre npm install localmente y verifica package.json

Error: TypeScript compilation failed
→ Solución: Revisa tipos en apps/web/src
```

### ❌ Error: "Root directory doesn't exist"

**Causa:** Configuraste el Root Directory mal

**Solución:**
1. Ve a **Settings → General**
2. Verifica que Root Directory sea exactamente: `apps/web`
3. NO `apps/web/` (sin slash final)
4. NO `./apps/web`
5. Haz cambios y Vercel re-deploya automáticamente

### ⚠️ Error: CORS en la consola del navegador

```
Access to XMLHttpRequest at 'https://api.onrender.com/...' 
from origin 'https://flowstate-web.vercel.app' has been blocked by CORS policy
```

**Causa:** El backend no permite tu dominio

**Solución:**
1. Ve a tu backend en Render/Railway
2. Edita variable de entorno: `CORS_ORIGINS`
3. Cambia a: `https://flowstate-web.vercel.app`
4. Redeploy del backend
5. Espera 2 minutos y recarga el navegador

### ⚠️ Sitio carga pero vacío (white screen)

**Causa:** Probablemente error en `_app.tsx` o `layout.tsx`

**Solución:**
1. Abre DevTools → Console
2. ¿Ves errores en rojo? Cópia el error
3. Revisa el archivo mencionado en el error
4. Busca problemas comunes:
   - Variables de entorno mal referenciadas
   - Imports circulares
   - Componentes que necesitan `'use client'`

---

## 📊 Panel de Control de Vercel

Una vez desplegado, tu dashboard muestra:

```
Project: flowstate-web

Deployments (últimos)
├─ Production: https://flowstate-web.vercel.app ✓
├─ Preview: (cada push a rama crea una preview)
└─ Logs & Analytics

Settings
├─ Environment Variables
├─ Domains
├─ Redirects
├─ Caching
└─ Analytics
```

---

## 🎯 Checklist Final

- [ ] Código en GitHub y actualizado (`git push`)
- [ ] Vercel conectado a GitHub
- [ ] Root Directory configurado: `apps/web`
- [ ] Variable de entorno: `NEXT_PUBLIC_API_URL` agregada
- [ ] Deploy completado sin errores
- [ ] Sitio accesible en navegador
- [ ] Consola sin errores críticos
- [ ] Backend desplegado y URL conocida
- [ ] `CORS_ORIGINS` actualizado en backend
- [ ] Variables de producción correctas (si tienes DB, OAuth, etc.)

---

## 🔗 Referencias Rápidas

| Recurso | Enlace |
|---|---|
| Dashboard Vercel | https://vercel.com/dashboard |
| Documentación | https://vercel.com/docs |
| Next.js en Vercel | https://vercel.com/docs/frameworks/nextjs |
| Troubleshooting | https://vercel.com/help |

---

## 💡 Consejos Profesionales

### 1. Preview Deployments
Cada vez que hagas un PR en GitHub, Vercel crea una URL de preview automática. Útil para testing antes de producción.

### 2. Automatic Redeployment
Vercel redeploya automáticamente cada vez que haces `git push` a `main` (o la rama que configures).

### 3. Analytics
Vercel proporciona Web Vitals gratis. Ve a **"Analytics"** en el dashboard para ver performance.

### 4. Custom Domains
Si tienes dominio propio (ej: flowstate.com), en **Settings → Domains** puedes agregarlo en 2 minutos.

### 5. Environment Secrets
Para variables sensibles (API keys), Vercel tiene "Encrypted Environment Variables". Mejor que texto plano.

---

**¿Necesitas ayuda con algún paso específico o tienes errores durante el despliegue?** Avísame y te lo resuelvo.
