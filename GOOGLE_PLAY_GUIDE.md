# 🤖 Publicar Framio en Google Play Store - Guía Completa

## Google Play = Tienda Oficial de Android

---

## 📋 Requisitos Previos

### 1. Cuenta de Google Play Console ($25 USD una sola vez)

**¿Ya tienes cuenta?**
- Sí → Continúa al paso 2
- No → Regístrate aquí:

```
https://play.google.com/console/signup
```

**Proceso de registro:**
1. Ir a play.google.com/console
2. Click "Create account"
3. Pagar $25 USD (una sola vez, para siempre!)
4. Completar información de desarrollador
5. Aceptar términos
6. ¡Listo! (inmediato)

**Ventaja:** Solo $25 vs $99/año de Apple 💰

---

## 🚀 Paso 1: Preparar el Proyecto

### A. Configurar el App Bundle ID

El archivo ya está configurado con el nombre "Framio" ✅

### B. Crear Keystore (Firma de App)

**Importante:** Guarda este archivo para siempre. Lo necesitarás para todas las actualizaciones.

```bash
cd /Users/carlos/App/video_screenshot_app/android

# Crear keystore
keytool -genkey -v -keystore ~/framio-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias framio

# Te preguntará:
# Password: [Crea una contraseña segura y GUÁRDALA]
# First and Last Name: Carlos Zamalloa
# Organizational Unit: Framio
# Organization: Framio
# City: [Tu ciudad]
# State: [Tu estado]
# Country Code: [US/MX/etc]
```

**IMPORTANTE:** Guarda este archivo y contraseña en un lugar seguro!

### C. Configurar el key.properties

```bash
# Crear archivo de propiedades
cat > android/key.properties <<EOF
storePassword=[TU_PASSWORD]
keyPassword=[TU_PASSWORD]
keyAlias=framio
storeFile=/Users/carlos/framio-release-key.jks
EOF
```

### D. Actualizar build.gradle

El archivo ya está configurado, pero vamos a verificar:

```bash
# Abrir el archivo
open android/app/build.gradle.kts
```

Busca y verifica que tenga algo similar a esto (si no, agrégalo):

```kotlin
// Cerca del inicio del archivo
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

// En android { ... }
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
    }
}
```

---

## 🏗️ Paso 2: Construir el App Bundle

### Opción A: App Bundle (Recomendado - más pequeño)

```bash
cd /Users/carlos/App/video_screenshot_app

# Asegúrate de tener Flutter en el PATH
export PATH="$HOME/flutter/bin:$PATH"

# Limpia el proyecto
flutter clean

# Obtén las dependencias
flutter pub get

# Construye el App Bundle
flutter build appbundle --release
```

**Resultado:**
```
build/app/outputs/bundle/release/app-release.aab
```

### Opción B: APK (Para pruebas o distribución directa)

```bash
flutter build apk --release
```

**Resultado:**
```
build/app/outputs/flutter-apk/app-release.apk
```

**Usa App Bundle (.aab) para Google Play.** Es más eficiente.

---

## 📦 Paso 3: Crear la App en Google Play Console

### A. Ir a Play Console

```
https://play.google.com/console
```

### B. Crear Nueva App

1. Click **"Create app"**
2. Completa el formulario:

**App name:** Framio

**Default language:** English (United States)

**App or game:** App

**Free or paid:** Paid ($4.99)

**Declarations:**
- ✅ Acepta términos de US export laws
- ✅ Acepta términos de Google Play

3. Click **"Create app"**

---

## 📝 Paso 4: Completar la Información de la App

### A. Store Presence → Main Store Listing

**App name:** Framio - Video Frame Editor

**Short description:** (80 caracteres máx)
```
Extract, edit & share video frames with 7 filters and batch export
```

**Full description:** (4000 caracteres máx)
```
Transform your videos into stunning still images with Framio!

🎬 PROFESSIONAL FRAME CAPTURE
• Extract perfect moments from any video
• Frame-by-frame navigation for precision
• High-quality output up to 100%

✨ POWERFUL FEATURES
• Batch Export - Save multiple frames at once
• 7 Professional Filters - Grayscale, Sepia, Blur & more
• Video Trimming - Focus on specific segments
• Quality Control - Adjust file size & quality
• Share Anywhere - Cloud, social media, messaging

🎨 CREATIVE TOOLS
• Apply artistic filters to your captures
• Adjust brightness, contrast, and blur
• Choose quality from 30% to 100%
• Perfect for social media, presentations, or memories

📤 EASY SHARING
• Share to any app on your device
• Export to cloud storage
• Save to photo gallery
• Send via Messages, Email, WhatsApp & more

💎 PREMIUM EXPERIENCE
• No ads, ever
• No subscriptions
• One-time purchase
• Regular updates

Perfect for:
• Content creators & influencers
• Video editors & filmmakers
• Teachers & presenters
• Sports enthusiasts
• Anyone who wants to capture perfect video moments

Download Framio and start capturing amazing frames!
```

**App icon:** (512x512 PNG)
- Sube tu logo: `assets/icon/framio_icon.png`

**Feature graphic:** (1024x500 PNG)
- Crea un banner horizontal con tu logo y texto "Framio"
- Usa Canva: https://www.canva.com/

**Phone screenshots:** (Mínimo 2, máximo 8)
- Toma screenshots del simulador Android
- Tamaño: 1080x1920 o superior

**Category:** Tools

**Tags:** video, screenshot, frame, capture, editor

**Email:** leinso@gmail.com

**Privacy Policy URL:** [Crea una, ver abajo]

---

### B. Store Presence → Store Settings

**App category:**
- Primary: Tools
- Tags: video editor, screenshot, photo & video

---

### C. Policy → App Content

#### 1. Privacy Policy
**Necesitas crear una.** Opciones:

**Opción Rápida - Generador:**
```
https://app-privacy-policy-generator.firebaseapp.com/
```

Completa el formulario:
- App name: Framio
- Type: Video editing app
- Data collected: None
- Genera y copia la URL

**Opción Manual - Template:**
```
Privacy Policy for Framio

We do not collect any personal information.
This app operates entirely on your device.
Videos and screenshots are stored locally.
We do not transmit any data to external servers.

Contact: leinso@gmail.com
Last updated: February 2026
```

Súbelo a:
- GitHub Pages (gratis)
- Tu propio sitio web
- Google Sites (gratis)

#### 2. Data Safety

**Does your app collect or share user data?**
- No ✅

**Does your app handle financial transactions?**
- No ✅

#### 3. App Access

**Does your app restrict access?**
- No ✅

#### 4. Content Ratings

1. Click **"Start questionnaire"**
2. Responde las preguntas:
   - Violence: None
   - Sexual content: None
   - Drugs: None
   - Bad language: None
3. Recibirás rating: Everyone

#### 5. Target Audience

**Age groups:** 13+ (o Everyone si no hay restricciones)

#### 6. News App

**Is this a news app?** No

---

## 🚀 Paso 5: Preparar el Release

### A. Production → Countries/Regions

1. Click **"Add countries/regions"**
2. Selecciona:
   - ✅ United States
   - ✅ Mexico
   - ✅ (Todos los países que quieras)
3. Click **"Add"**

### B. Production → Create Release

1. Click **"Create new release"**
2. **Upload app bundle:**
   - Arrastra `app-release.aab`
   - O click "Upload" y selecciona el archivo

3. **Release name:** 1.0.0

4. **Release notes:** (En inglés y español)

**English:**
```
Initial release of Framio!

Features:
• Extract high-quality frames from any video
• Batch export multiple frames at once
• 7 professional filters (Grayscale, Sepia, Blur, etc.)
• Frame-by-frame navigation
• Video trimming
• Quality control (30-100%)
• Share to any app

Thank you for downloading Framio!
```

**Spanish:**
```
¡Lanzamiento inicial de Framio!

Características:
• Extrae frames de alta calidad de cualquier video
• Exporta múltiples frames a la vez
• 7 filtros profesionales
• Navegación frame por frame
• Recorte de video
• Control de calidad (30-100%)
• Comparte a cualquier app

¡Gracias por descargar Framio!
```

5. Click **"Save"**

---

## 💰 Paso 6: Configurar Precio

### A. Set Up Pricing

1. **Pricing → Set up pricing**
2. **Paid app:** $4.99 USD
3. Google convertirá automáticamente a otras monedas:
   - Mexico: ~$99 MXN
   - Europe: ~€4.99
   - etc.

4. **Tax settings:** Completa según tu país

---

## ✅ Paso 7: Revisar y Publicar

### A. Review Summary

1. Ve a **Dashboard**
2. Verifica que todo esté completo (checkmarks verdes)

### B. Submit for Review

1. Click **"Send for review"**
2. Confirma
3. **Espera 1-7 días** para revisión

### C. Estado de Revisión

**Under review:** 1-7 días (promedio 2-3 días)
**Published:** ¡Tu app está viva! 🎉

---

## 🧪 Paso 8: Beta Testing (Opcional - antes del launch)

### Internal Testing (Hasta 100 testers)

1. **Testing → Internal testing**
2. **Create new release**
3. Upload el .aab
4. **Testers:** Agrega emails
5. **Save**

Los testers recibirán un link para descargar la beta.

### Closed Testing (Beta privado)

1. **Testing → Closed testing**
2. Similar a Internal testing
3. Hasta 10,000 testers

### Open Testing (Beta público)

1. **Testing → Open testing**
2. Cualquiera puede unirse
3. Aparece en Play Store como "Early Access"

---

## 🔄 Actualizar la App (Nuevas versiones)

```bash
# 1. Incrementa la versión en pubspec.yaml
version: 1.0.1+2  # 1.0.1 = version name, +2 = version code

# 2. Haz tus cambios al código

# 3. Construye el nuevo bundle
flutter build appbundle --release

# 4. En Play Console
# Production → Create new release
# Upload nuevo app-release.aab
# Agrega release notes
# Submit
```

---

## 📊 Screenshots para Play Store

### Tamaños Necesarios:

**Phone screenshots:** (Mínimo 2)
- 1080 x 1920 (o superior)
- PNG o JPG

**7-inch tablet:** (Opcional pero recomendado)
- 1080 x 1920

**10-inch tablet:** (Opcional)
- 1200 x 1920

### Cómo Tomar Screenshots:

```bash
# 1. Ejecuta la app en emulador Android
flutter run

# 2. En el emulador, usa:
# - Cmd + S (Mac)
# - Ctrl + S (Windows)

# O usa el botón de screenshot del emulador
```

### Edita en Canva (Opcional):
- Agrega texto descriptivo
- Muestra las features
- Haz que se vea profesional

---

## ✅ Checklist Google Play

Antes de enviar a revisión:

- [ ] Cuenta de Google Play Console ($25 pagados)
- [ ] Keystore creado y guardado (framio-release-key.jks)
- [ ] App Bundle compilado (.aab)
- [ ] App creada en Play Console
- [ ] Store listing completado
- [ ] App icon subido (512x512)
- [ ] Feature graphic creado (1024x500)
- [ ] Screenshots tomados (mínimo 2)
- [ ] Privacy policy creada y URL agregada
- [ ] Content ratings completado
- [ ] Países seleccionados
- [ ] Precio configurado ($4.99)
- [ ] App bundle subido
- [ ] Release notes escritos
- [ ] Enviado para revisión

---

## 🐛 Solución de Problemas

### Error: "Upload failed"
**Solución:**
- Verifica que sea .aab (no .apk)
- Recompila: `flutter build appbundle --release`

### Error: "Version code X has already been used"
**Solución:**
- Incrementa el version code en pubspec.yaml
- version: 1.0.0+2 (cambia el número después del +)

### Error: "Missing required fields"
**Solución:**
- Revisa Dashboard para ver qué falta
- Completa todos los campos con checkmark rojo

### Keystore perdido
**¡PROBLEMA GRANDE!** No podrás actualizar la app.
**Prevención:**
- Guarda framio-release-key.jks en 3 lugares:
  1. Tu computadora
  2. Cloud (Dropbox/Google Drive)
  3. USB externo

---

## 💰 Costos

- **Google Play Console:** $25 una sola vez ✅
- **Publicación:** Gratis ✅
- **Google toma:** 15% de los primeros $1M/año
- **Google toma:** 30% después de $1M/año

**Mucho mejor que Apple (30% siempre)** 💰

---

## ⏱️ Tiempos Estimados

- **Registro Play Console:** Inmediato
- **Crear keystore:** 2 minutos
- **Build app bundle:** 3-5 minutos
- **Completar formularios:** 30-60 minutos
- **Revisión de Google:** 1-7 días (promedio 2-3)
- **App publicada:** Inmediatamente después de aprobación

---

## 📊 Después de Publicar

### Monitorea tu App:

1. **Dashboard:** Instalaciones, calificaciones
2. **Reviews:** Responde a usuarios
3. **Vitals:** Performance, crashes
4. **Statistics:** Países, dispositivos

### Marketing:

1. **URL de tu app:**
   ```
   https://play.google.com/store/apps/details?id=com.capitanmelao.framio
   ```

2. Compártela en:
   - Redes sociales
   - Tu sitio web
   - Email signature

---

## 🎯 Resumen Rápido

```bash
# 1. Crear keystore
keytool -genkey -v -keystore ~/framio-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias framio

# 2. Configurar key.properties
# (Ver paso 1C)

# 3. Build app bundle
flutter build appbundle --release

# 4. Ir a Play Console
https://play.google.com/console

# 5. Create app → Complete forms → Upload .aab → Submit
```

---

## 📞 Ayuda

**Google Play Console Help:**
- https://support.google.com/googleplay/android-developer/

**Developer Policy Center:**
- https://play.google.com/console/about/developer-policy/

---

**¡Tu app estará en Google Play en menos de 1 semana!** 🚀🤖

(Después de la revisión de Google)
