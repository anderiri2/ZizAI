# Configuración de Google Sign-In y Google Drive Backup (`appDataFolder`)

**Perretxikotan** utiliza la API oficial de **Google Drive v3** con el permiso privado `https://www.googleapis.com/auth/drive.appdata` (`appDataFolder`), exactamente igual que WhatsApp para guardar copias de seguridad ocultas en la cuenta personal de Google del usuario sin pasar por servidores externos.

Mientras desarrollas o cuando estás en el monte sin cobertura, puedes pulsar **"Continuar en modo local (Offline)"** y usar también las **Instantáneas Locales (ZIP)**. Para activar el inicio de sesión con Google en dispositivos Android e iOS, sigue estos pasos:

---

## 1. Crear proyecto y habilitar Google Drive API
1. Entra en [Google Cloud Console](https://console.cloud.google.com/).
2. Crea un proyecto nuevo llamado **Perretxikotan**.
3. Ve a **APIs y servicios > Biblioteca**, busca **Google Drive API** y pulsa **Habilitar**.

## 2. Configurar la Pantalla de Consentimiento OAuth
1. Ve a **APIs y servicios > Pantalla de consentimiento de OAuth**.
2. Selecciona **Externo** y completa el nombre de la aplicación (`Perretxikotan`) y tu correo de soporte.
3. En **Permisos (Scopes)**, añade el scope:
   * `https://www.googleapis.com/auth/drive.appdata` (*Ver, crear y eliminar sus propios datos de configuración en tu Google Drive*).
4. Añade tu cuenta de Google en la lista de **Usuarios de prueba (Test users)**.

## 3. Credenciales para Android (Valores de este equipo listos para copiar)
1. En **APIs y servicios > Credenciales > Crear credenciales > ID de cliente de OAuth**:
   * **Tipo de aplicación**: `Android`
   * **Nombre del paquete (`Package name`)**: `com.perretxikotan.perretxikotan`
   * **Huella digital del certificado SHA-1**: `6E:E0:DE:E9:DB:FD:33:63:96:C3:84:9B:7D:5F:F9:4C:93:AF:44:C1`
   * *(Opcional en Firebase)* **SHA-256**: `64:B7:9F:00:F1:C0:78:06:42:E6:17:B5:43:CE:FC:02:1F:51:6F:2D:FE:3C:C2:3A:8F:54:B6:5F:68:A8:C3:AB`
2. *(Referencia)* Comando con el que se extrajo del keystore de desarrollo (`~/.android/debug.keystore`):
   ```bash
   /usr/bin/keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

## 4. Credenciales para iOS
1. En **APIs y servicios > Credenciales > Crear credenciales > ID de cliente de OAuth**:
   * **Tipo de aplicación**: `iOS`
   * **ID del paquete (Bundle ID)**: `com.perretxikotan.perretxikotan`
2. Copia el `CLIENT_ID` y el `REVERSED_CLIENT_ID` generados y añádelos en `ios/Runner/Info.plist`:
   ```xml
   <key>GIDClientID</key>
   <string>TU_IOS_CLIENT_ID.apps.googleusercontent.com</string>
   <key>CFBundleURLTypes</key>
   <array>
     <dict>
       <key>CFBundleTypeRole</key>
       <string>Editor</string>
       <key>CFBundleURLSchemes</key>
       <array>
         <string>com.googleusercontent.apps.TU_IOS_CLIENT_ID</string>
       </array>
     </dict>
   </array>
   ```
