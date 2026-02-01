# 🍎 Publicar Framio en TestFlight - Guía Completa

## TestFlight = Beta Testing de Apple

TestFlight te permite probar tu app antes de publicarla oficialmente en el App Store.

---

## 📋 Requisitos Previos

### 1. Apple Developer Account ($99 USD/año)
**¿Ya tienes cuenta?**
- Sí → Continúa al paso 2
- No → Regístrate aquí:

```
https://developer.apple.com/programs/enroll/
```

**Proceso de registro:**
1. Ir a developer.apple.com
2. Click "Account"
3. "Enroll" en Apple Developer Program
4. Pagar $99 USD (tarjeta de crédito)
5. Esperar aprobación (1-2 días)

---

## 🚀 Paso 1: Preparar el Proyecto

### A. Verifica que Xcode esté configurado

```bash
cd /Users/carlos/App/framio

# Abre el workspace en Xcode
open ios/Runner.xcworkspace
```

### B. Configura el Bundle Identifier

1. En Xcode, selecciona **Runner** en el navegador izquierdo
2. En la pestaña **General**:
   - **Bundle Identifier:** `com.capitanmelao.framio`
   - **Version:** `1.0.0`
   - **Build:** `1`

### C. Configura el Team (Apple Developer)

1. En la misma pantalla **General**
2. Sección **Signing & Capabilities**
3. **Team:** Selecciona tu cuenta de Apple Developer
4. **Automatically manage signing:** ✅ Activado

### D. Actualiza el Display Name

Ya está configurado como "Framio" ✅

---

## 🏗️ Paso 2: Crear el Build

### Desde Terminal:

```bash
cd /Users/carlos/App/framio

# Asegúrate de tener Flutter en el PATH
export PATH="$HOME/flutter/bin:$PATH"

# Limpia el proyecto
flutter clean

# Obtén las dependencias
flutter pub get

# Construye la versión de release para iOS
flutter build ios --release
```

**Esto tomará 2-5 minutos.** ⏱️

---

## 📦 Paso 3: Archivar en Xcode

### A. Abre Xcode

```bash
open ios/Runner.xcworkspace
```

### B. Selecciona el Dispositivo

1. En la barra superior de Xcode
2. Junto al botón Run/Stop
3. Selecciona **"Any iOS Device"** (no simulator)

### C. Archive

1. Menu: **Product → Archive**
2. Espera 3-5 minutos mientras compila
3. Se abrirá la ventana **Organizer** automáticamente

---

## 🚢 Paso 4: Subir a App Store Connect

### En la ventana Organizer:

1. Selecciona tu archivo más reciente
2. Click **"Distribute App"**
3. Selecciona **"App Store Connect"**
4. Click **"Next"**
5. Selecciona **"Upload"**
6. Click **"Next"**
7. **Signing:** Automatically manage signing ✅
8. Click **"Upload"**
9. Espera mientras sube (5-10 minutos)

**Recibirás un email cuando el procesamiento termine** (30-60 min)

---

## 🎯 Paso 5: Configurar en App Store Connect

### A. Ve a App Store Connect

```
https://appstoreconnect.apple.com
```

### B. Crear la App (Primera vez)

1. Click **"My Apps"**
2. Click el botón **"+"** → **"New App"**
3. Completa el formulario:

**Platforms:** ✅ iOS

**Name:** Framio

**Primary Language:** English

**Bundle ID:** com.capitanmelao.framio

**SKU:** framio-001

**User Access:** Full Access

4. Click **"Create"**

---

## 🧪 Paso 6: Configurar TestFlight

### A. Agregar Build a TestFlight

1. En App Store Connect → Tu app "Framio"
2. Click pestaña **"TestFlight"**
3. Espera a que aparezca tu build (puede tardar hasta 1 hora)
4. Cuando aparezca, verás algo como: **"1.0.0 (1)"**

### B. Información de Prueba

1. Click en tu build
2. **Test Information** → Completa:

**What to Test:**
```
Please test the following features:
- Load video and extract frames
- Use batch mode to select multiple frames
- Apply filters (Grayscale, Sepia, Brightness, etc.)
- Frame-by-frame navigation
- Video trimming
- Share frames to other apps

Please report any bugs or issues.
```

**Beta App Description:**
```
Framio - Professional video frame editor.
Extract, edit and share perfect moments from any video.
Features: Batch export, 7 filters, precision controls.
```

3. Click **"Save"**

### C. Agregar Información de Exportación

1. En el build, click **"Provide Export Compliance Information"**
2. **Does your app use encryption?**
   - Si solo usas HTTPS → **No**
   - Click **"Start Internal Testing"**

---

## 👥 Paso 7: Invitar Testers

### Opción A: Internal Testing (Hasta 100 personas)

1. Pestaña **TestFlight** → **Internal Testing**
2. Click **"+"** para crear un grupo
3. Nombre: "Framio Internal Testers"
4. Click **"Create"**
5. **Add Testers:**
   - Escribe emails de las personas
   - Click **"Add"**

### Opción B: External Testing (Beta público)

1. Pestaña **TestFlight** → **External Testing**
2. Click **"+"** para crear un grupo
3. Nombre: "Framio Beta Testers"
4. Selecciona tu build
5. Click **"Next"**
6. Agrega emails o genera link público
7. **Submit for Beta App Review** (espera 1-2 días)

---

## 📧 Los Testers Recibirán:

1. **Email de invitación** con link a TestFlight
2. Instrucciones para descargar TestFlight app
3. Link para instalar Framio beta

### Testers deben:

1. Descargar **TestFlight** del App Store
2. Abrir el link de invitación
3. Aceptar la invitación
4. Instalar Framio
5. ¡Probar la app!

---

## 🔄 Actualizar el Build (Nuevas versiones)

Cuando hagas cambios:

```bash
# 1. Incrementa el build number en pubspec.yaml
version: 1.0.0+2  # Cambia +1 a +2, +3, etc.

# 2. Construye de nuevo
flutter build ios --release

# 3. Archive de nuevo en Xcode
# Product → Archive

# 4. Upload a App Store Connect

# 5. En TestFlight, agrega el nuevo build al grupo
```

---

## ✅ Checklist TestFlight

Antes de subir:

- [ ] Apple Developer Account activa ($99 pagados)
- [ ] Bundle ID configurado (com.capitanmelao.framio)
- [ ] Team seleccionado en Xcode
- [ ] App creada en App Store Connect
- [ ] Build compilado sin errores
- [ ] Archive subido a App Store Connect
- [ ] Export compliance completado
- [ ] Test information agregada
- [ ] Testers invitados

---

## 🐛 Solución de Problemas

### Error: "No valid code signing identity"
**Solución:**
1. Xcode → Settings → Accounts
2. Agrega tu Apple ID
3. Download Manual Profiles

### Error: "Bundle identifier cannot be used"
**Solución:**
1. Cambia el Bundle ID en Xcode
2. Usa: com.tunombre.framio

### Build no aparece en App Store Connect
**Solución:**
- Espera 30-60 minutos
- Revisa tu email por errores
- Verifica en Xcode Organizer que subió correctamente

### TestFlight dice "Missing Compliance"
**Solución:**
1. Click en el build
2. Provide Export Compliance Information
3. Selecciona "No" si solo usas HTTPS

---

## 📊 Después de TestFlight

### Cuando estés listo para lanzamiento oficial:

1. Recopila feedback de testers
2. Corrige bugs encontrados
3. Prepara screenshots (ver APP_STORE_GUIDE.md)
4. Completa la información del App Store
5. Submit for App Review
6. ¡Lanza al App Store! 🚀

---

## 💰 Costos

- **Apple Developer:** $99/año (obligatorio)
- **TestFlight:** Gratis ✅
- **App Store:** Gratis ✅ (Apple toma 30% de ventas)

---

## ⏱️ Tiempos Estimados

- **Registro Apple Developer:** 1-2 días
- **Primer build:** 30-60 minutos
- **Processing en App Store Connect:** 30-60 minutos
- **Internal Testing:** Disponible inmediatamente
- **External Testing Review:** 1-2 días
- **Testers pueden usar:** Indefinidamente (90 días por build)

---

## 🎯 Resumen Rápido

```bash
# 1. Construir
flutter build ios --release

# 2. Archivar en Xcode
Product → Archive

# 3. Upload
Distribute → App Store Connect → Upload

# 4. En App Store Connect
TestFlight → Agregar build → Invitar testers

# 5. Los testers
Reciben email → Instalan TestFlight → Prueban Framio
```

---

## 📞 Ayuda

**Apple Developer Support:**
- https://developer.apple.com/support/

**App Store Connect Guide:**
- https://help.apple.com/app-store-connect/

---

**¡Tu app estará en TestFlight en menos de 1 hora!** ⏱️✨

(Asumiendo que ya tienes Apple Developer Account)
