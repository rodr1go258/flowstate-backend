# ⚡ Quick Start: Despliegue en 15 minutos

## Paso 1: Organizar Variables (3 min)

### 1.1 Copiar plantilla
```bash
cp .env.example .env.local
```

### 1.2 Rellenar valores críticos en `.env.local`:
```bash
# Base de datos (de tu proyecto InsForge)
DATABASE_URL=postgresql://user:pass@host.insforge.app:5432/flowstate

# JWT (genera con: openssl rand -base64 32)
JWT_SECRET=TU_CLAVE_SECRETA_DE_32_CARACTERES_AQUI

# Servidor
PORT=8080
ENV=production
CORS_ORIGINS=https://flowstate-web.vercel.app

# Resto (completa si tienes)
GOOGLE_CLIENT_ID=tu_client_id.apps.googleusercontent.com
OPENROUTER_API_KEY=sk-tu_clave
```

### 1.3 Para el frontend
```bash
# Crear apps/web/.env.local
echo "NEXT_PUBLIC_API_URL=https://tu-backend-url.onrender.com" > apps/web/.env.local
```

---

## Paso 2: Desplegar Backend (5 min)

### Opción A: Render.com (más fácil)

1. Ve a https://render.com y crea cuenta
2. Conecta tu GitHub
3. Click "New +" → "Web Service"
4. Selecciona este repositorio
5. **Configuración:**
   - Root Directory: `apps/api`
   - Runtime: Docker
   - Name: `flowstate-api`
6. **Environment:** Copia cada variable de `.env.local`
7. Haz click "Deploy" y espera ~5 minutos
8. Tu URL será: `https://flowstate-api.onrender.com`

### Opción B: Railway.app

1. Ve a https://railway.app
2. Conecta GitHub
3. Selecciona el repo
4. Railway detecta automáticamente
5. Agrega variables de entorno
6. Deploy automático

---

## Paso 3: Desplegar Frontend (5 min)

### Vercel (recomendado para Next.js)

1. Ve a https://vercel.com
2. Conecta GitHub
3. Click "Add New Project"
4. Importa el repo
5. **Configuración:**
   - Framework: Next.js (auto-detectado)
   - Root Directory: `apps/web`
6. **Environment Variables:**
   - Name: `NEXT_PUBLIC_API_URL`
   - Value: `https://flowstate-api.onrender.com` (tu URL del backend)
7. Click "Deploy"
8. Tu URL será: `https://flowstate-web.vercel.app`

---

## Paso 4: Actualizar Configuraciones (2 min)

### Backend CORS
Vuelve a Render/Railway y actualiza:
```
CORS_ORIGINS=https://flowstate-web.vercel.app
```

### Frontend API URL
Si cambió la URL del backend, actualiza en Vercel:
```
NEXT_PUBLIC_API_URL=https://tu-url-real.onrender.com
```

---

## ✅ Verificación Final

```bash
# 1. Backend está vivo
curl https://flowstate-api.onrender.com/health

# 2. Frontend se cargó
curl https://flowstate-web.vercel.app

# 3. Prueba en navegador
# Abre: https://flowstate-web.vercel.app
# Abre DevTools (F12) y verifica que NO hay errores de CORS
```

---

## 🆘 Errores Comunes

| Error | Causa | Solución |
|---|---|---|
| `DATABASE_URL is required` | Variable vacía o mal formada | Verifica en Render/Railway que `DATABASE_URL` esté completa |
| `CORS error` en navegador | Dominio no está en `CORS_ORIGINS` | Actualiza en backend: `CORS_ORIGINS=https://tu-frontend.vercel.app` |
| `Cannot connect to API` | `NEXT_PUBLIC_API_URL` mal | Revisa en `.env.local` que tenga la URL correcta |
| Migraciones SQL fallan | Base de datos vacía | Ejecuta `/migrations/20260623172511_flowstate-init.sql` manualmente en InsForge |

---

## 📋 Checklist Rápido

- [ ] `.env.local` completado
- [ ] `apps/web/.env.local` completado
- [ ] Backend desplegado en Render/Railway → obtuviste URL
- [ ] Frontend desplegado en Vercel → obtuviste URL
- [ ] Migraciones SQL ejecutadas en InsForge
- [ ] CORS actualizado con dominio de frontend
- [ ] Prueba de salud (curl /health) funciona
- [ ] Frontend carga sin errores de CORS

---

## 🎯 URLs de Referencia

| Servicio | Enlace |
|---|---|
| **Dashboard Render** | https://dashboard.render.com |
| **Vercel Dashboard** | https://vercel.com/dashboard |
| **InsForge Dashboard** | https://dashboard.insforge.app |
| **Documentación Deployment** | Ver `DEPLOYMENT.md` en la raíz |

---

¡Listo! Tu proyecto debe estar en línea.
