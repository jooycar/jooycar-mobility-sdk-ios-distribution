# SDK de Trackeo de Viajes (iOS)

## Descripción

Librería para trackeo de viajes en vehículo en aplicaciones iOS. Provee tres métodos principales: `initialize`, `login` y `start`. Maneja permisos del dispositivo y devuelve estados claros de éxito o error. Incluye un flujo de UI completo para solicitar permisos al usuario.

## Instalación

El SDK se distribuye vía **Swift Package Manager** contra registries privados de Jooycar y DriveKit. Para integrarlo, seguí estos pasos.

### 1. Configurar credenciales locales

El SDK y sus dependencias se sirven desde registries privados que requieren autenticación. Agregá las siguientes entradas a `~/.netrc` (este archivo nunca debe versionarse):

```
machine octotelematics.jfrog.io
  login mobility-sdk@jooycar.cl
  password TU_PASSWORD

machine github.com
  login jooycar-mobility-sdk
  password TU_PERSONAL_ACCESS_TOKEN
```

Las credenciales las provee el equipo de Jooycar.

### 2. Registrar los scopes de SPM

Swift Package Manager necesita saber a qué registry privado pedir cada scope. Registralos globalmente una sola vez por máquina y autenticate contra JFrog:

```bash
REGISTRY="https://octotelematics.jfrog.io/artifactory/api/swift"

# Scopes principales del SDK y de DriveKit
swift package-registry set --global --scope drivekit     "$REGISTRY/drivekit-spm-ios"
swift package-registry set --global --scope octokit      "$REGISTRY/octokit-spm-ios"
swift package-registry set --global --scope httpclient   "$REGISTRY/httpclient-spm-ios"
swift package-registry set --global --scope rorschach    "$REGISTRY/rorschach-spm-ios"
swift package-registry set --global --scope octosmaaskit "$REGISTRY/octosmaaskit-spm-ios"

# Scopes auxiliares (mismo repo de dependencias)
for scope in factory grdb kscrash nordicdfu zipfoundation; do
    swift package-registry set --global --scope "$scope" "$REGISTRY/drivekit-dependencies-spm-ios"
done

# Autenticar (toma las credenciales del .netrc)
swift package-registry login "$REGISTRY/drivekit-spm-ios"
```

Si SPM falla con errores de autenticación o de fingerprint, limpiá las cachés locales y reintentá:

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/org.swift.swiftpm/security/fingerprints
```

### 3. Agregar la dependencia

En el `Package.swift` de tu app:

```swift
dependencies: [
    .package(url: "https://github.com/jooycar/jooycar-mobility-sdk-ios-distribution.git", from: "1.2.2")
],
targets: [
    .target(
        name: "MiApp",
        dependencies: [
            .product(name: "JooycarMobilitySDK", package: "jooycar-mobility-sdk-ios-distribution"),
            // Proveedor de telemática.
            .product(name: "OctoProvider", package: "jooycar-mobility-sdk-ios-distribution")
        ]
    )
]
```

O desde Xcode: **File → Add Package Dependencies…**, ingresar la URL del repo de distribución y marcar `JooycarMobilitySDK` y `OctoProvider`. Consultá los [tags del repo](https://github.com/jooycar/jooycar-mobility-sdk-ios-distribution/tags) para fijar una versión específica.

Plataforma mínima: **iOS 15**, con **Xcode 27 (Swift 6.4)**. SwiftPM los aplica a todo el paquete de distribución.

#### Verificar el artefacto (opcional)

El XCFramework se publica firmado con el certificado de distribución de Jooycar, y cada versión trae además un manifiesto de integridad firmado y un inventario de componentes (SBOM, CycloneDX). Si tu proceso de seguridad exige comprobar la procedencia del binario antes de incorporarlo:

```bash
codesign -dv --verbose=4 JooycarMobilitySDK.xcframework
# -> Authority=Apple Distribution: Jooycar Spa (4EA35D7A4S)
#    TeamIdentifier=4EA35D7A4S
```

El procedimiento completo —firma, manifiesto, SBOM y sus limitaciones— está en [docs/verificacion-de-artefactos.md](https://github.com/jooycar/jooycar-mobility-sdk-ios/blob/release-1.2.2/docs/verificacion-de-artefactos.md). Nada de esto es necesario para integrar el SDK: SwiftPM ya valida el checksum en cada resolución.

### 4. Configurar `Info.plist`

Claves obligatorias:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación para detectar automáticamente tus viajes.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Necesitamos tu ubicación en segundo plano para registrar tus viajes automáticamente.</string>

<key>NSMotionUsageDescription</key>
<string>Necesitamos acceso a la actividad física para reconocer cuándo conduces.</string>
```

Background Modes requeridos:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>bluetooth-central</string>
</array>
```

## Uso rápido (iOS — Swift)

### Inicializar

```swift
import JooycarMobilitySDK

let config = InitConfig(
    env: .QA,
    channel: "client-1",
    theme: JooycarMobilityThemeData( // opcional
        fontFamily: "PlusJakartaSans" // PostScript base name
    ),
    program: .TBYB // opcional, default .TBYB (ver sección Programas SDK)
)
let result = await JooycarMobility.initialize(config: config).value
// result: MobilityResult.success | MobilityResult.failure(code, message)
```

### Login

```swift
let person = Person(
    areaCode: "52",
    birthDate: "1979-04-18",
    email: "jjrojas@correo.com",
    firstName: "Juan",
    gender: "M",
    idType: "rut",
    idValue: "1111111-1",
    landline: "",
    lastName1: "Rojas",
    lastName2: "Ortiz",
    midName: "Jose",
    mobile: "9999999",
    mobileCode: "9",
    nationality: ""
)

let vehicle = Vehicle(
    brandCode: "5",
    chassisNumber: "",
    color: "Blanco",
    displayBrand: "CHEVROLET",
    displayModel: "AVEO",
    displaySubModel: "",
    engineNumber: "",
    isNew: "2",
    modelCode: "1535",
    plate: "JLKK47",
    subModelCode: "",
    usage: "particular",
    vehicleType: "1",
    year: "2018"
)

let address = Address(
    block: "13",
    city: "1",
    country: "CL",
    level: "201",
    municipality: "DOWNTOWN",
    reference: "",
    state: "CENTRAL STATE",
    street: "Av. de las Flores",
    streetNumber: "50",
    type: "",
    unitNumber: "13024",
    zipCode: ""
)

let credentials = LoginData(
    token: "token",
    campaignCode: nil, // opcional. En .WINGS_LITE el SDK lo fija a "WINGS:SDK" automáticamente
    person: person,
    vehicle: vehicle,
    address: address
)

let loginResult = await JooycarMobility.login(credentials: credentials)
// loginResult: MobilityResult.success | MobilityResult.failure(code: ErrorCode...)
```

### Start

```swift
let startResult = await JooycarMobility.start()
// startResult: MobilityResult.success | MobilityResult.failure
```

### Proveedor de telemática

El SDK captura viajes con Octo (DriveKit). El proveedor es un producto aparte, `OctoProvider`, que la app host enlaza junto a `JooycarMobilitySDK`.

No hay que llamar nada extra: `initialize(config:)` detecta el producto enlazado y lo configura. `JooycarMobility.telematicsProvider` devuelve cuál quedó activo (`nil` si no hay ninguno).

- Sin `OctoProvider`, `initialize`, `start()` y el resto de las operaciones de telemática devuelven `TELEMATICS_NOT_CONFIGURED`.
- Llamar a `initialize(config:)` en `application(_:didFinishLaunchingWithOptions:)`, sin envolverlo en un `Task`. El resultado se espera después con `.value` del `Task` que devuelve.

## API — Métodos principales

### `initialize(config:)`

- **Descripción:** Inicializa la librería a través de un canal y un ambiente.
- **Parámetros:**
  - `InitConfig`: `env: Env` (`.QA` o `.PROD`), `channel: String` (client channel), `theme: JooycarMobilityThemeData` (opcional, ver sección **Theming**). El proveedor de telemática no se pasa acá: lo define el producto enlazado (ver **Proveedor de telemática**).
- **Llamada:** síncrona, desde `didFinishLaunchingWithOptions` (ver **Proveedor de telemática**).
- **Retorno:** `Task<MobilityResult, Never>` (descartable); su `value` es el `MobilityResult`:
  - `success`: inicialización correcta.
  - `failure`: motivo (p. ej. `INITIALIZATION_FAILED`, o `TELEMATICS_NOT_CONFIGURED` si no hay producto de proveedor enlazado).

### `login(credentials:)`

- **Descripción:** Autentica al usuario.
- **Parámetros:**
  - `credentials: LoginData` con `token`, `person`, `vehicle`, `address`.
  - `person`, `vehicle` y `address` son opcionales (default `nil`).
- **Retorno:** `MobilityResult`:
  - `success`: autenticación OK.
  - `failure` específico: `INVALID_CREDENTIALS`.

### `start()`

- **Descripción:** Valida permisos del dispositivo e inicializa el servicio de monitoreo.
- **Parámetros:** N/A.
- **Validaciones internas:**
  - Permiso de ubicación siempre (`locationAlways`)
  - Permiso de actividad física (`activityRecognition`)
- **Retorno:** `MobilityResult`:
  - `success`: Permisos concedidos y dispositivo asociado correctamente.
  - `failure` específico: `PERMISSION_DENIED_LOCATION`, `PERMISSION_DENIED_ACTIVITY`, `NETWORK_ERROR`, etc.
- **Comportamiento:** si faltan permisos críticos, retorna error específico y sugiere acción (p. ej. lanzar el flow de permisos desde la app host).

### `areAllPermissionsGranted()`

- **Descripción:** Retorna `true` si todos los permisos requeridos por el SDK están otorgados (ubicación en uso, ubicación siempre, actividad física).
- **Retorno:** `Bool`.
- **Uso típico:** en el routing de la app host, decidir si mostrar el flow de permisos o ir directo al Home.

### `getUserState()`

- **Descripción:** Devuelve el estado del usuario respecto al onboarding del SDK para que la app host enrute la pantalla inicial sin reimplementar la lógica de routing.
- **Retorno:** `JooycarUserState`:
  - `.home`: usuario logueado y con todos los permisos requeridos otorgados.
  - `.permissions`: usuario logueado pero faltan permisos por otorgar.
  - `.idle`: usuario aún no ha iniciado sesión.
  - `.logged`: reservado para iteraciones futuras (hoy nunca es retornado).
- **Uso típico:** al arranque de la app, decidir entre login, permission flow o home.

```swift
switch await JooycarMobility.getUserState() {
case .home:        // ir al home
case .permissions: // lanzar PermissionFlowViewController
case .idle, .logged: // ir al login
}
```

### `configureAnalytics(_:)`

- **Descripción:** Configura las preferencias de analítica del SDK.
- **Parámetro:** `AnalyticsConfig`
  - `analyticsEnabled` (por defecto `false`): interruptor general de **toda** la analítica del SDK. **Viene apagado**: mientras el host no lo encienda, no se inicializa Amplitude ni se emite ningún evento, ni a Amplitude ni al backend de Jooycar (`POST /v1/logs`).
  - `sessionReplayEnabled` (por defecto `false`): habilita la grabación de sesiones.
- **Retorno:** `Void` (síncrono, no lanza).
- **Cuándo llamarlo:** antes de `initialize` (las preferencias quedan guardadas y se aplican al inicializar) o en cualquier momento posterior, en cuyo caso el cambio toma efecto de inmediato.

```swift
// Encender la analítica del SDK (viene apagada; p. ej. tras el consentimiento del usuario)
JooycarMobility.configureAnalytics(
    AnalyticsConfig(analyticsEnabled: true)
)

// Encender también la grabación de sesiones (apagada por defecto)
JooycarMobility.configureAnalytics(
    AnalyticsConfig(analyticsEnabled: true, sessionReplayEnabled: true)
)

// Volver a apagar toda la analítica en runtime (equivale a `AnalyticsConfig()`)
JooycarMobility.configureAnalytics(
    AnalyticsConfig(analyticsEnabled: false)
)
```

**Consideraciones:**

- La analítica está **apagada por defecto**: si la app host no llama a `configureAnalytics(AnalyticsConfig(analyticsEnabled: true))`, el SDK no emite nada.
- Las preferencias viven **en memoria**: no se persisten entre arranques. Si la app host necesita recordar la elección del usuario, debe guardarla y volver a llamar a `configureAnalytics` en cada arranque, antes de `initialize`.
- Mientras `analyticsEnabled` sea `false` (el valor inicial), Amplitude **nunca se instancia** (sin red, sin autocapture). Si se habilita después, la instancia se crea en ese momento.
- Con `sessionReplayEnabled: true`, el porcentaje real de sesiones grabadas lo define el Sampling Rate del dashboard de Amplitude (*Settings → Projects → [proyecto] → Session Replay*). El flag local es un interruptor por encima de eso: en `false` no se graba ninguna sesión, sin importar el dashboard.
- El interruptor cubre los dos destinos de analítica del SDK: los eventos de Amplitude (`ONB_REG_*`, `SDK_WEBVIEW_*`, autocapture) y los logs de onboarding que van al backend de Jooycar (`POST /v1/logs`, los `ONB_*` del flujo de permisos).

## Formato de resultados

```swift
/// Resultado de una operación del Jooycar Mobility SDK.
public enum MobilityResult: Sendable {

    /// Operación exitosa.
    case success

    /// Operación fallida con código específico y mensaje opcional.
    case failure(code: ErrorCode, message: String?)
}
```

Helpers recomendados (extension en la app host):

```swift
extension MobilityResult {
    var isSuccess: Bool {
        if case .success = self { return true } else { return false }
    }
    var errorCode: ErrorCode? {
        if case .failure(let code, _) = self { return code } else { return nil }
    }
}
```

Códigos de error disponibles:

```swift
public enum ErrorCode: Sendable {

    /// Credenciales provistas (token) inválidas o malformadas.
    case INVALID_CREDENTIALS

    /// Código de campaña inexistente, vencido o ausente.
    case INVALID_CAMPAIGN_CODE

    /// Permiso de ubicación (en uso o siempre) denegado por el usuario.
    case PERMISSION_DENIED_LOCATION

    /// Permiso de ubicación en segundo plano denegado (requerido para tracking en background).
    case PERMISSION_DENIED_BACKGROUND_LOCATION

    /// Permiso de actividad física denegado.
    case PERMISSION_DENIED_ACTIVITY

    /// Servicios de ubicación globales de iOS desactivados (master toggle off).
    case SERVICE_LOCATION_DISABLE

    /// La operación requiere sesión activa pero el usuario no está logueado.
    case NOT_AUTHENTICATED

    /// Servicio interno del SDK falló al inicializar o ejecutar.
    case SERVICE_FAILED

    /// Error de red (sin conexión, timeout, etc.).
    case NETWORK_ERROR

    /// Falla genérica durante la inicialización del SDK.
    case INITIALIZATION_FAILED

    /// El voucher fue deshabilitado en el backend (Octo). El tracking se detuvo.
    case VOUCHER_DISABLED

    /// La app host no enlazó el producto de proveedor de telemática (`OctoProvider`).
    case TELEMATICS_NOT_CONFIGURED
}
```

### Copy listo para mostrar

`ErrorCode` expone `title` y `message` ya traducidos. La app host **no necesita
mapear códigos del backend ni redactar copy propio**: muestra lo que trae el
resultado.

```swift
let result = await JooycarMobility.login(credentials: credentials)

if case .failure(let code, let message) = result {
    showAlert(title: code.title, message: message ?? code.message)
}
```

| `ErrorCode` | `title` | `message` |
|---|---|---|
| `INVALID_CAMPAIGN_CODE` | Código inválido | Tu código de campaña no es válido o ya no está vigente. |
| `INVALID_CREDENTIALS` | Revisa tus datos | Los datos ingresados son incorrectos. Por favor, verifícalos y vuelve a intentarlo. |
| resto | Ocurrió un inconveniente | Algo salió mal. Inténtalo de nuevo en unos minutos. |

### Mapeo de errores del login

`login` traduce el `errorCode` que devuelve el backend en `POST /v1/auth/external`.
El mapeo es por código y no por status HTTP: E0032 y E0043 comparten el 422 pero
son situaciones distintas para el usuario.

| Backend | HTTP | `ErrorCode` |
|---|---|---|
| `E0043` | 422 | `INVALID_CAMPAIGN_CODE` |
| `E0032`, `E0033` | 422, 401 | `INVALID_CREDENTIALS` |
| `E0031`, `E0034`, `E0035` | 503, 400 | `SERVICE_FAILED` |
| sin código conocido | 401, 403 | `INVALID_CREDENTIALS` |
| sin código conocido | 500 y resto | `SERVICE_FAILED` |
| sin respuesta (timeout / offline) | — | `NETWORK_ERROR` |

El detalle técnico del backend (`srcMessage`) no se muestra al usuario: viaja a
Amplitude en la propiedad `error_reason` del evento de error de registro.

## Permisos requeridos

| Permiso | Info.plist Key | Descripción |
|---|---|---|
| Ubicación en uso | `NSLocationWhenInUseUsageDescription` | Foreground location |
| Ubicación siempre | `NSLocationAlwaysAndWhenInUseUsageDescription` | Background location |
| Actividad física | `NSMotionUsageDescription` | CoreMotion |

**Background Modes** requeridos en Info.plist: `location`, `bluetooth-central`.

**Servicio de ubicación global:** el master toggle de iOS (Ajustes → Privacidad y seguridad → Ubicación) debe estar activado. El SDK detecta cuando está apagado y muestra un step especial que redirige a Ajustes.

## Manejo de permisos

La librería:

- Detecta permisos faltantes en `start`.
- Devuelve errores específicos para cada permiso faltante.
- Provee un flujo de UI completo (`PermissionFlowView` / `PermissionFlowViewController`) para solicitarlos paso a paso.

## Buenas prácticas

- Llamar a `initialize` en `AppDelegate.application(_:didFinishLaunchingWithOptions:)` y esperar su `.value` donde se necesite el resultado.
- Presentar el flow de permisos **antes** de llamar a `start`.
- Suscribirse a cambios de permisos desde la app host (observer de `UIApplication.didBecomeActiveNotification` + `JooycarMobility.areAllPermissionsGranted()`) para relanzar el flow si el usuario revoca algún permiso desde Ajustes.

## Ejemplo de flujo recomendado

```swift
// 1. Inicializar SDK
let initResult = await JooycarMobility.initialize(
    config: InitConfig(env: .PROD, channel: "client-1")
).value
guard case .success = initResult else { return }

// 2. Login
let loginResult = await JooycarMobility.login(credentials: credentials)
guard case .success = loginResult else { return }

// 3. Flow de permisos (UI)
PermissionFlowViewController.launch(from: self, onResult: { result in
    guard case .completed = result else { return }

    // 4. Iniciar tracking
    Task {
        let startResult = await JooycarMobility.start()
    }
}) {
    DefaultPermissionFlowConfig.build(
        illustrations: DefaultPermissionFlowConfig.Illustrations(
            locationServicesDisabled: "il_location_services_disabled",
            locationWhenInUse: "il_location_service",
            locationAlways: "il_location_always",
            activityRecognition: "il_activity",
            completion: "il_check_ok",
            locationWhenInUseDenied: "il_location_denied",
            locationAlwaysDenied: "il_location_always_denied",
            activityDenied: "il_activity_denied"
        ),
        showCloseButton: true
    )
}
```

## Errores comunes y resolución

- **`PERMISSION_DENIED_LOCATION` / `PERMISSION_DENIED_BACKGROUND_LOCATION`** → Pedir desde el flow o redirigir a Ajustes. La denied screen del flow ya lo hace.
- **`PERMISSION_DENIED_ACTIVITY`** → Igual al anterior, usando la denied screen de actividad.
- **`SERVICE_LOCATION_DISABLE`** → El master toggle de Location Services está apagado; el step `locationServicesDisabled` del flow redirige al usuario a Ajustes.
- **`INVALID_CREDENTIALS`** → Mostrar `code.title` / `message` y reintentar el login.
- **`INVALID_CAMPAIGN_CODE`** → El código de campaña no existe o venció; pedir al usuario que lo revise.
- **`SERVICE_FAILED`** → Revisar logs y reportar al backend.
- **`NETWORK_ERROR`** → Reintentar con backoff; verificar conectividad.
- **`VOUCHER_DISABLED`** → El voucher de Octo fue dado de baja en el backend; `start()` lo revalida en cada llamada.
- **`TELEMATICS_NOT_CONFIGURED`** → Agregar al target de la app el producto `OctoProvider` junto a `JooycarMobilitySDK`.

## Notas de integración

- Declarar las claves de `Info.plist` correctamente; iOS rechaza apps que llaman a APIs de permisos sin la descripción correspondiente.
- Indicar claramente en la UI por qué se solicita cada permiso antes de disparar el diálogo nativo (el flow del SDK ya lo hace).
- En producción, la primera vez que el SDK llama a `CLLocationManager.requestAlwaysAuthorization()` iOS muestra el diálogo de upgrade a Always. Si el usuario elige "Keep Only While Using", iOS no volverá a mostrar ese diálogo; el flow redirige entonces a Ajustes.

---

## 🎨 Theming

El SDK expone una configuración mínima de tema vía `JooycarMobilityThemeData`, pasada en `InitConfig.theme`. Hoy permite sobrescribir la tipografía aplicada en todas las superficies de UI del SDK (WebView, Permission Flow, bottom sheets, pantallas de denegación, etc.).

### 📐 Modelo

```swift
public struct JooycarMobilityThemeData: Sendable, Codable {
    public let fontFamily: String?
    public init(fontFamily: String? = nil)
}
```

| Campo | Tipo | Default | Descripción |
|-------|------|---------|-------------|
| `fontFamily` | `String?` | `nil` | Nombre PostScript base de la fuente (ej. `"PlusJakartaSans"`). Las variantes se resuelven como `"<fontFamily>-Regular"`, `"<fontFamily>-Bold"`, etc. Si es `nil`, el SDK conserva su default (Plus Jakarta Sans). |

### 📦 Uso

La tipografía se setea una sola vez dentro de `initialize`, antes de mostrar cualquier UI del SDK. La fuente debe estar **registrada en el proceso** previamente; en iOS hay dos caminos:

1. **Fuente declarada en el `Info.plist` del host** bajo la clave `UIAppFonts` (Xcode "Fonts provided by application"). Los `.ttf`/`.otf` deben estar incluidos como recursos del bundle del host.
2. **Registro programático** vía `CTFontManagerRegisterFontsForURL` antes de llamar a `JooycarMobility.initialize`.

```swift
import JooycarMobilitySDK

let config = InitConfig(
    env: .QA,
    channel: "client-1",
    theme: JooycarMobilityThemeData(
        fontFamily: "PlusJakartaSans"
    )
)

let result = await JooycarMobility.initialize(config: config).value
```

Internamente, una sola asignación a `JooycarTypography.fontFamily` alinea ambas escalas tipográficas:

- `JooycarTypography` — estilos del WebView y superficies generales del SDK.
- `PermissionFlowTypography` — estilos del flujo de permisos (lee de `JooycarTypography.fontFamily`).

### ⚠️ Consideraciones

- El override se aplica una sola vez durante `initialize`. Si no se pasa `theme`, el SDK queda con Plus Jakarta Sans por default.
- Los `WebViewColors` y `PermissionFlowColors` siguen configurándose por separado en sus call sites (`JooycarWebViewController.init(..., colors:)`, `DefaultPermissionFlowConfig.build(..., colors:)`). `JooycarMobilityThemeData` no los reemplaza.
- El `fontFamily` debe coincidir con el **PostScript name base** de la fuente (no el nombre del archivo). Si una variante no se encuentra (`"<fontFamily>-Bold"`, etc.), iOS cae silenciosamente a la fuente del sistema.
- La fuente tiene que estar registrada antes de llamar a `initialize`; si se registra después, las primeras pantallas usarán la fuente del sistema.

---

## 📍 JooycarPermissionManager

`JooycarPermissionManager` es una utilidad que centraliza la validación y solicitud de los permisos requeridos por el SDK en iOS. Permite verificar el estado de los permisos críticos y solicitarlos de forma simplificada desde la app host.

### 🚀 Características

- Verificación de estado de permisos:
  - Ubicación en uso
  - Ubicación en segundo plano
  - Actividad física
- Solicitud unificada de permisos (async)
- Integración directa con el proveedor de telemática enlazado

### 📦 Uso básico

```swift
import JooycarMobilitySDK

// Verificar
let hasLocation = await JooycarPermissionManager.isLocationPermissionGranted()

// Solicitar
await JooycarPermissionManager.requestLocationPermission()
```

### ✅ Métodos de verificación

Todos retornan `Bool` indicando si el permiso está concedido.

#### 📍 Ubicación

```swift
public static func isLocationPermissionGranted() async -> Bool
```

Indica si el permiso de ubicación (en uso o siempre) está concedido.

```swift
public static func isLocationAlwaysPermissionGranted() async -> Bool
```

Indica si el permiso de ubicación en segundo plano (`authorizedAlways`) está concedido.

#### 🏃 Actividad física

```swift
public static func isActivityPermissionGranted() async -> Bool
```

Indica si el permiso de actividad/movimiento está concedido.

### ✅ Verificación global

```swift
public static func areAllPermissionsGranted() async -> Bool
```

Verifica de forma combinada si todos los permisos y servicios requeridos por el SDK están habilitados (ubicación en uso, ubicación siempre y actividad física). Retorna `true` solo si todos están concedidos.

```swift
if await JooycarMobility.areAllPermissionsGranted() {
    // Todos los permisos están OK, se puede arrancar el SDK
} else {
    // Falta al menos uno, lanzar el flow de permisos
}
```

### 🔐 Métodos de solicitud de permisos

⚠️ Los métodos son `async` y deben invocarse desde una `Task` o contexto concurrente.

#### 📍 Ubicación

```swift
public static func requestLocationPermission() async
```

Solicita el permiso de ubicación en uso (`requestWhenInUseAuthorization`).

```swift
public static func requestLocationAlwaysPermission() async
```

Solicita el permiso de ubicación siempre (`requestAlwaysAuthorization`). iOS solo muestra el diálogo de upgrade una vez por instalación.

#### 🏃 Actividad física

```swift
public static func requestActivityPermission() async
```

Solicita el permiso de actividad física (vía el proveedor de telemática; sin proveedor, CoreMotion).

### ⚠️ Consideraciones importantes

- Los métodos son `async` y deben ejecutarse dentro de una `Task` o contexto concurrente.
- La gestión real de los permisos está delegada al proveedor de telemática y a los frameworks del sistema (`CoreLocation`, `CoreMotion`).
- Las claves de `Info.plist` correspondientes deben estar presentes (ver sección Permisos requeridos).
- El master toggle global de Location Services de iOS es ortogonal al permiso específico de la app; se detecta vía `CLLocationManager.locationServicesEnabled()`.

### 🧠 Buenas prácticas

- Verificá el estado del permiso antes de solicitarlo.
- Explicá al usuario por qué necesitás cada permiso (usando los textos de `Info.plist` y el flow de UI).
- Manejá correctamente el caso de rechazo: mostrá la denied screen con acción a Ajustes.
- Evitá solicitar todos los permisos al mismo tiempo; usá el flow paso a paso.

### 📄 Ejemplo completo

```swift
if !(await JooycarPermissionManager.isLocationPermissionGranted()) {
    await JooycarPermissionManager.requestLocationPermission()
}
```

---

## 🔄 Permission Flow (Onboarding de Permisos)

El SDK ofrece dos APIs equivalentes para presentar el flow visual de permisos:

- **`PermissionFlowView`** — SwiftUI (`UIViewControllerRepresentable`).
- **`PermissionFlowViewController`** — UIKit.

Ambos guían al usuario paso a paso por todos los permisos requeridos por el SDK. Usa SwiftUI internamente.

### 🚀 Características

- Flow paso a paso con barra de progreso animada.
- Pantallas de permiso denegado con redirección a Ajustes del sistema.
- Bottom sheet de confirmación cuando el usuario intenta omitir un paso.
- Pantalla de completación opcional con checkbox de términos y condiciones.
- Detección del master toggle de Location Services de iOS (step especial que aparece solo cuando está off).
- Colores, ilustraciones y flag del botón de cerrar totalmente configurables.
- Manejo de race conditions: el flow es idempotente frente a `didBecomeActive` durante transiciones de step.

### 📦 Lanzamiento rápido (SwiftUI)

```swift
import JooycarMobilitySDK
import SwiftUI

struct PermissionsScreen: View {
    let onCompleted: () -> Void
    let onCancelled: () -> Void

    var body: some View {
        PermissionFlowView(
            illustrations: DefaultPermissionFlowConfig.Illustrations(
                locationServicesDisabled: "il_location_services_disabled",
                locationWhenInUse: "il_location_service",
                locationAlways: "il_location_always",
                activityRecognition: "il_activity",
                completion: "il_check_ok",
                locationWhenInUseDenied: "il_location_denied",
                locationAlwaysDenied: "il_location_always_denied",
                activityDenied: "il_activity_denied"
            ),
            showCloseButton: true, // opcional, default false
            onCompleted: onCompleted,
            onCancelled: onCancelled
        )
    }
}
```

### 📦 Lanzamiento rápido (UIKit)

```swift
import JooycarMobilitySDK

PermissionFlowViewController.launch(
    from: self,
    closeIcon: "ic_close", // opcional
    onResult: { result in
        switch result {
        case .completed:
            // Todos los permisos otorgados, iniciar tracking
            Task { _ = await JooycarMobility.start() }
        case .cancelled:
            // Usuario cerró el flow sin completar
            break
        }
    },
    provider: {
        DefaultPermissionFlowConfig.build(
            illustrations: DefaultPermissionFlowConfig.Illustrations(
                locationServicesDisabled: "il_location_services_disabled",
                locationWhenInUse: "il_location_service",
                locationAlways: "il_location_always",
                activityRecognition: "il_activity",
                completion: "il_check_ok",
                locationWhenInUseDenied: "il_location_denied",
                locationAlwaysDenied: "il_location_always_denied",
                activityDenied: "il_activity_denied"
            ),
            showCloseButton: true
        )
    }
)
```

### 🎨 Personalización de colores

```swift
import SwiftUI
import JooycarMobilitySDK

let colors = PermissionFlowColors(
    primary: Color(red: 0, green: 1.0/3.0, blue: 1.0),
    tertiary: Color(red: 0.16, green: 0.61, blue: 1.0),
    title: Color(red: 0.165, green: 0.169, blue: 0.318),
    body: Color(red: 0.165, green: 0.169, blue: 0.318),
    primaryButtonText: .white,
    secondaryButtonText: Color(red: 0, green: 1.0/3.0, blue: 1.0),
    secondaryButtonBorder: Color(red: 0, green: 1.0/3.0, blue: 1.0)
)

let config = DefaultPermissionFlowConfig.build(
    illustrations: illustrations,
    colors: colors,
    showCloseButton: true
)
```

### 🔧 Configuración avanzada

#### Botón de cerrar (X)

Default `false`. Si se activa, se pinta en step, denied screens y bottom sheet. El callback es el mismo en todas las vistas (dispara `onCancelled`).

```swift
DefaultPermissionFlowConfig.build(
    illustrations: illustrations,
    showCloseButton: true
)
```

### 📋 Tipos de paso (`PermissionStepType`)

| Tipo | Descripción |
|---|---|
| `locationServicesDisabled` | Aparece **solo** cuando el switch global de Location Services de iOS está apagado. Comparte numeral de progreso con `locationWhenInUse`. |
| `locationWhenInUse` | Solicita permiso de ubicación en uso (foreground). |
| `locationAlways` | Solicita permiso de ubicación siempre (background). Intenta el diálogo nativo de upgrade cuando viene del flujo secuencial. |
| `activityRecognition` | Solicita permiso de actividad física / movimiento. |
| `completion` | Pantalla final de confirmación con T&C opcionales. |

### 🖼️ Assets requeridos

El flow requiere 8 ilustraciones en el Asset Catalog de la app host:

| Asset (campo en `Illustrations`) | Pantalla |
|---|---|
| `locationServicesDisabled` | Step especial cuando Location Services global está off |
| `locationWhenInUse` | Step de ubicación en uso |
| `locationAlways` | Step de ubicación siempre |
| `activityRecognition` | Step de actividad física |
| `completion` | Pantalla final "¡Todo listo!" |
| `locationWhenInUseDenied` | Denied screen del step de ubicación en uso |
| `locationAlwaysDenied` | Denied screen del step de ubicación siempre (icono 24H) |
| `activityDenied` | Denied screen del step de actividad |

### 🔁 Resultado del flow

El callback `onResult` (UIKit) / `onCompleted`+`onCancelled` (SwiftUI) retorna:

- `.completed`: el usuario otorgó todos los permisos y cerró el flow en la pantalla final.
- `.cancelled`: el usuario cerró el flow sin completar (solo posible si `showCloseButton: true`).

### 🏗️ Arquitectura de denied screens

Las pantallas de permiso denegado siguen un patrón **híbrido** (un layout compartido + una view por permiso), para permitir que cada pantalla diverja sin duplicar código:

- `DeniedScreenLayout` (interno) — componente SwiftUI compartido con el layout base: botón cerrar opcional, ilustración, título, descripción, highlight opcional, botón primario y progress bar.
- `LocationWhenInUseDeniedView` / `LocationAlwaysDeniedView` / `ActivityDeniedView` — views por permiso con sus textos e ilustración propios; delegan el layout a `DeniedScreenLayout`.
- `PermissionFlowScreen` rutea al view correcto según `PermissionStepType`.

Agregar un nuevo permiso denegado = crear una `{Nombre}DeniedView` nueva + un `case` en el router. No se tocan los otros views.

### ⚠️ Consideraciones importantes

- `PermissionFlowView` se presenta como un `UIViewControllerRepresentable`; internamente agrega un child VC al container.
- El `configProvider` se configura antes de lanzar el flow; si es `nil`, el flow se cierra inmediatamente con `.cancelled`.
- Los permisos ya otorgados se saltan automáticamente al iniciar el flow.
- Al volver de Ajustes del sistema, el flow re-evalúa el estado del permiso actual y avanza si fue concedido (respetando idempotencia para evitar flickers visuales).
- Para el caso específico de `authorizedWhenInUse` en el step `locationAlways`:
  - **Re-entrada fresca (downgrade):** el flow salta directo a la denied screen, ya que iOS no volverá a mostrar el diálogo de upgrade.
  - **Flujo secuencial (step anterior → step 2):** preserva el step screen para permitir que el diálogo nativo de upgrade aparezca al tocar "Continuar".

### 📝 Nota sobre el diálogo nativo de "Ubicación siempre"

iOS controla cuándo mostrar el diálogo de upgrade a `Always` — no existe API pública para forzarlo. El diálogo se muestra solo si se cumplen todas:

1. El status actual es `.authorizedWhenInUse` **persistente** (usuario eligió "Allow While Using App", no "Allow Once").
2. La app nunca antes llamó a `requestAlwaysAuthorization` (one-shot por instalación).
3. La app está activa en foreground.
4. El master toggle de Location Services del dispositivo está encendido.

Si cualquiera falla, iOS ignora la llamada silenciosamente (sin callback, sin error). El SDK lo detecta con una espera corta al `willResignActive`; si iOS no muestra el diálogo en ese intervalo, el flow pasa a la denied screen con el CTA "Ir a ajustes".

**Caso común donde esto ocurre:** el usuario elige "Allow Once" en el diálogo del step anterior. iOS no permite upgrade desde un permiso temporal. El usuario verá la step screen normal y, al tocar "Confirmar", será llevado a la denied screen tras una espera breve. Este comportamiento es correcto y **no es un bug** — es la política de privacidad de iOS.

## 🌐 JooycarWebViewController

ViewController público para abrir vistas embebidas del SDK como pantalla full-screen, con toolbar y colores configurables.

Tiene **dos modos de launch**:

1. **`launch(view:...)`** — recomendado para el flow de **onboarding TBYB**. El integrador solo pasa los callbacks; el SDK resuelve todo internamente.
2. **`launch(from:url:...)`** — para abrir cualquier URL arbitraria (Wings, ayuda, T&C, etc.).

---

### `launch(view:...)` — Onboarding TBYB

```swift
import JooycarMobilitySDK

JooycarWebViewController.launch(
    view: .onboarding,
    onComplete: {
        // Usuario completó el flow (ej. aceptó el CTA principal "quiero mi
        // descuento"). Acción típica: avanzar al flujo de permisos.
    },
    onFailure: {
        // Error en la carga o estado del flow. Acción típica: mostrar
        // fallback de error o volver al home del integrador.
    },
    onClose: {
        // Usuario cerró el flow sin completarlo: tap en la X de la
        // toolbar, "No estoy interesado", o "Más tarde". Acción típica:
        // volver al home del integrador.
    }
)
```

#### Cuándo se dispara cada callback

| Acción del usuario en el WebView | Callback |
|---|---|
| Acepta el CTA principal (ej. "Quiero mi descuento", "Quiero probar"). | `onComplete` |
| Tap en el botón cerrar (X) de la toolbar. | `onClose` |
| Decline explícito ("No estoy interesado"). | `onClose` |
| Postpone ("Más tarde"). | `onClose` |
| Error interno del flow o falla la carga. | `onFailure` |

#### Vistas disponibles (`WebviewHubView`)

```swift
public enum WebviewHubView: String, Sendable {
    case onboarding   // Flow inicial: registro y CTA principal.
    case tbyb         // Home con progreso del programa.
    case `default`    // Usado por WINGS_LITE; la URL no requiere el query `view`.
}
```

#### Pre-requisitos

Antes de invocar `launch(view:...)`, el integrador debe haber completado en este orden:

1. `JooycarMobility.initialize(config:)`
2. `JooycarMobility.login(credentials:)`

Si falta alguno → el launch dispara `onFailure` sin presentar el WebView.

#### Personalización visual

```swift
JooycarWebViewController.launch(
    view: .onboarding,
    sourceScreen: "home",                    // opcional; se propaga como `source_screen` en Amplitude
    title: "TBYB",                           // default "TBYB"
    colors: WebViewColors(
        toolbarBackground: .black,
        toolbarContent: .white,
        loadingIndicator: .white,
        loadingTrack: .gray
    ),
    closeIcon: UIImage(named: "ic_close"),   // si es nil usa SF Symbol "xmark"
    transition: .slideHorizontal,            // ver "Transiciones del WebView"; default .slideHorizontal
    hideAppBar: false,                       // true oculta la toolbar superior del WebView
    onComplete: { /* ... */ },
    onFailure: { /* ... */ },
    onClose: { /* ... */ }
)
```

Parámetros opcionales adicionales (disponibles en ambos `launch(...)`):

- `transition` — estilo de transición de entrada/salida. Ver [Transiciones del WebView](#transiciones-del-webview). Default `.slideHorizontal`.
- `hideAppBar` — si es `true`, oculta la toolbar superior (título + botón cerrar). Default `false`.
- `sourceScreen` *(solo `launch(view:...)`)* — identificador opcional de la pantalla del host desde la que se lanza; se incluye como propiedad `source_screen` en los eventos Amplitude del WebView.

#### Integración desde SwiftUI

Como `launch(view:...)` no requiere `presenter`, se puede invocar desde un `View.onAppear`. Para evitar doble-presentación si SwiftUI dispara `onAppear` más de una vez en una transición, recomendamos un guard `@State`:

```swift
struct OnboardingWebviewLauncher: View {
    let onComplete: () -> Void
    let onFailure: () -> Void
    let onClose: () -> Void

    @State private var didLaunch = false

    var body: some View {
        Color.black
            .ignoresSafeArea()
            .onAppear {
                guard !didLaunch else { return }
                didLaunch = true
                JooycarWebViewController.launch(
                    view: .onboarding,
                    onComplete: onComplete,
                    onFailure: onFailure,
                    onClose: onClose
                )
            }
    }
}
```

---

### `launch(from:url:...)` — URL arbitraria

Para abrir cualquier URL Jooycar como pantalla embebida.

```swift
JooycarWebViewController.launch(
    from: self,
    url: URL(string: "https://www.jooycar.com/wings/")!,
    title: "Jooycar Wings",
    onResult: { result in
        switch result {
        case .completed: // flow finalizado correctamente
        case .dismissed: // tap en cerrar
        case .failed:    // error de navegación del main frame
        }
    }
)
```

`launch(...)` se encarga de instanciar el VC, configurar la transición según el estilo elegido (ver [Transiciones del WebView](#transiciones-del-webview)) — `modalTransitionStyle` para los estilos modales (`slideVertical`/`fade`), push nativo para `slideHorizontal` —, presentarlo (o pushearlo en una nav stack) y, al recibir el resultado, invocar `onResult` antes de cerrarlo.

#### Resultados (`JooycarWebViewResult`)

| Caso         | Cuándo se dispara                                              |
| ------------ | -------------------------------------------------------------- |
| `.completed` | El flow señalizó completion.                                   |
| `.dismissed` | Usuario tap en el botón cerrar de la toolbar, o swipe-back en modo `slideHorizontal`. |
| `.failed`    | El `WKWebView` reporta un error de navegación del main frame.  |

### Transiciones del WebView

Ambos `launch(...)` aceptan el parámetro `transition: JooycarWebViewTransitionStyle` para controlar cómo entra y sale la pantalla del WebView. Permite alinear el WebView con la navegación del host (push horizontal) o usar el modal vertical clásico.

| Estilo            | Apariencia                                       | Cuándo usarlo                                                                                       |
| ----------------- | ------------------------------------------------ | --------------------------------------------------------------------------------------------------- |
| `slideHorizontal` | Push lateral nativo de iOS (estilo `UINavigationController`). | **Default.** Continuidad visual tipo push con la navegación del host. Funciona en cualquier carrier, con o sin `UINavigationController`. |
| `slideVertical`   | Modal full-screen entrando desde abajo.          | Cuando preferís el modal vertical clásico en lugar del push horizontal.                              |
| `fade`            | Cross-dissolve sin sensación de dirección.       | Cuando el contexto previo no debe sugerir una dirección de navegación (por ejemplo, deeplinks).      |

**Requisitos y comportamientos:**

- `slideHorizontal` siempre da push horizontal nativo de iOS. Si el `presenter` (o el VC resuelto por `topMostViewController`) tiene un `UINavigationController` accesible, lo usa para integrar con el back stack del host. Si no, el SDK levanta un `UINavigationController` interno transparente para garantizar la misma animación nativa sin pantalla negra.
- En `slideHorizontal`, el swipe-back izquierdo del sistema dispara `onResult(.dismissed)` (o el callback equivalente en `launch(view:...)`) automáticamente, tanto si el push fue sobre el `UINavigationController` del host como sobre el nav interno del SDK. El callback se entrega antes de que termine el pop.
- Al cerrar en `slideHorizontal` (botón X o swipe-back) cuando el SDK usó su nav interno, el cierre hace el pop horizontal —invirtiendo el slide de entrada— y recién al terminar descarta el contenedor, evitando el slide vertical por defecto.
- `fade` usa `overFullScreen`, por lo que durante la transición el carrier puede ver brevemente la pantalla previa. Es el trade-off por evitar el cut-to-black de `fullScreen`.
- El estilo elegido se propaga como propiedad `transition_style` en los eventos Amplitude `SDK_WEBVIEW_OPENED` y `SDK_WEBVIEW_RETURNED_*` para correlacionar bugs por modo.

```swift
JooycarWebViewController.launch(
    from: self,
    url: someURL,
    transition: .slideHorizontal,
    onResult: { result in /* ... */ }
)
```

> El default es `.slideHorizontal` para alinear la transición con el push nativo del SO. Funciona en todos los carriers sin requisitos sobre la estructura del host (el SDK levanta un nav interno transparente cuando hace falta). Si querés forzar el modal vertical, pasá `transition: .slideVertical` explícito.

### Tipografía

`JooycarTypography` provee 14 estilos basados en Plus Jakarta Sans (`displayLarge`, `headingH1..H4`, `bodyLarge/Medium/Small`, `labelButton/Nav/Input`, `overlineSection/Small`, `caption`, `captionLink`). Cada estilo es un `JooycarTextStyle` con `font + fontSize + lineHeight + letterSpacing + underline`. Aplicar a un `Text` SwiftUI con el helper `style(_:)`:

```swift
Text("Mi título").style(JooycarTypography.headingH2)
```

Las fuentes se registran automáticamente en el proceso al inicializar el SDK (`JooycarMobility.initialize(...)`) y al construir `JooycarWebViewController`. Si la registración falla (recursos no disponibles, etc.) los estilos caen a la fuente del sistema sin crashear.

---

## 📚 Ejemplo: flujo TBYB end-to-end

Patrón de referencia para integrar el flujo completo (login → onboarding → permisos → tbyb → home). El SDK provee los building blocks; **el integrador define la navegación** entre ellos.

```swift
// 1. Init al arrancar la app
let config = InitConfig(env: .QA, channel: "wings2")
JooycarMobility.initialize(config: config)

// 2. Login con las credenciales del partner
let loginResult = await JooycarMobility.login(credentials: data)
guard case .success = loginResult else { /* manejar error */ return }

// 3. Onboarding del programa TBYB
JooycarWebViewController.launch(
    view: .onboarding,
    colors: brandColors,
    onComplete: {
        // Usuario aceptó el CTA principal → continuar al flujo de permisos.
    },
    onFailure: { /* error de carga o falta de data */ },
    onClose:    { /* user dismissó: volver al home cascarón */ }
)

// 4. Flujo nativo de permisos (post onComplete del onboarding)
PermissionFlowViewController.launch(
    from: presenter,
    onResult: { result in
        guard case .completed = result else { return }
        Task {
            _ = await JooycarMobility.start()
            // 5. Home con progreso del programa
            JooycarWebViewController.launch(
                view: .tbyb,
                colors: brandColors,
                onComplete: { /* completion → home cascarón */ },
                onFailure: { /* error → home */ },
                onClose:    { /* user cerró → home */ }
            )
        }
    },
    provider: { permissionFlowConfig }
)
```

### Responsabilidades del integrador

El SDK provee los building blocks (init, login, WebView del hub, flujo de permisos, start del trackeo); la app host es responsable de:

- Persistir si el onboarding ya fue completado (e.g. flag en `UserDefaults`) y decidir si volver a presentarlo en arranques siguientes.
- Re-evaluar `areAllPermissionsGranted()` al volver a foreground en caso de que el usuario haya modificado permisos desde Settings.
- Mantener una paleta de colores compartida entre `WebViewColors` y `PermissionFlowColors` para que la transición entre pantallas del SDK sea visualmente continua.
