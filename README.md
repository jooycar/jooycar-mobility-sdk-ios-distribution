//
//  README.me
//  JooycarMobilitySDKPackage
//
//  Created by Kimberlly Florez on 15/3/2026.
//

# SDK para trackeo y monitoreo de viajes en vehículo dentro de aplicaciones iOS.

El SDK permite inicializar el servicio, autenticar al usuario y comenzar el monitoreo de conducción, gestionando internamente validaciones y permisos del dispositivo.

## Funcionalidades principales

El SDK expone tres métodos principales:

initialize → Inicializa el SDK y configura el entorno.

login → Autentica al usuario junto con los datos del vehículo.

start → Inicia el monitoreo del viaje validando permisos del dispositivo.Instalación

## Instalación

El SDK se distribuye mediante Swift Package Manager.

1. Agregar el SDK en Xcode

2. Abrir el proyecto en Xcode

Ir a:

``` swift
  File → Add Package Dependency
```
3. Ingresa a la URL del repositorio

 https://github.com/jooycar/jooycar-mobility-sdk-ios-distribution
 
4. Escoger la version deseada 

## Flujo uso recomendado

###1. Inicializar SDK
###2. Autenticar usuario
###3. Iniciar monitoreo de viajes

###1. Inicializar SDK

``` swift

initialize(config:)

```
Inicializa el SDK y configura el entorno donde se ejecutará.

Debe ejecutarse una vez al iniciar la aplicación.

###Parametros

* Env: Ambiente donde operará el SDK

```swift

let config = InitConfig(
    env: .QA
)
En donde Env:

```swift 

enum Env {
    case PROD
    case QA
}
```

let result = await JooycarMobility.shared.initialize(config: config)

switch result {
case .success:
    print("SDK initialized successfully")
case .failure(let error):
    print("Initialization error: \(error)")
}
```

### Resultado 

El metodo retorna:

```swift

    SDKResult
```

SDKResult puede ser success o failure, en caso de ser failure se indicara el motivo.

###2. Autenticar usuario

login(credentials:)
    
Autentica al usuario junto con la información asociada al vehículo y dirección.


###Parametros

* token de autenticación
* información de la persona
* información del vehículo
* información de dirección

```Swift

let credentials = LoginData(
    token: "token",
    person: person,
    vehicle: vehicle,
    address: address
)

let loginResult = await JooycarMobility.shared.login(credentials: credentials)
```

En donde 
#### Token: String

#### Person:
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
```
#### Person:
```swift
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
```
#### Address:
```swift
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
```


### Resultado 

El metodo retorna:

```swift

    SDKResult
```

SDKResult puede ser success o failure, en caso de ser failure se indicara el motivo. Ej failure(INVALID_CREDENTIALS)


###3. Iniciar monitoreo de viajes

Inicia el servicio de monitoreo de viajes y comportamiento de conducción.

Antes de iniciar, el SDK valida los permisos requeridos del dispositivo.

```swift
let result = await JooycarMobility.shared.start()

switch result {
case .success:
    print("Monitoring started")
case .failure(let error):
    print("Error starting monitoring: \(error)")
}
```
## Validación de permisos

Durante la ejecución de start(), el SDK valida los permisos necesarios.

Permisos utilizados:

Permiso    Descripción
Location When In Use    Ubicación mientras la app está en uso
Location Always    Ubicación en segundo plano
Motion & Fitness    Detección de actividad física

### Los métodos principales retornan un objeto SDKResult.

```swift
public enum SDKResult {
    case success
    case failure(code: ErrorCode, message: String?)
}
```
### Códigos de error

```swift
enum ErrorCode {
  INVALID_CONTEXT
  MISSING_NOTIFICATION_ICON
  INVALID_CREDENTIALS
  PERMISSION_DENIED_LOCATION
  PERMISSION_DENIED_BACKGROUND_LOCATION
  PERMISSION_DENIED_ACTIVITY
  NOT_AUTHENTICATED
  SERVICE_FAILED
  NETWORK_ERROR
}
```
### Permisos requeridos en Info.plist

Debes agregar los siguientes permisos en el archivo Info.plist de tu aplicación:

```
NSLocationWhenInUseUsageDescription
NSLocationAlwaysAndWhenInUseUsageDescription
NSMotionUsageDescription
Ejemplo
<key>NSLocationWhenInUseUsageDescription</key>
<string>We use your location to detect driving activity</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Location is required to monitor trips even in background</string>

<key>NSMotionUsageDescription</key>
<string>Motion activity is used to detect driving behavior</string>
Manejo de permisos
```

El SDK:

Detecta permisos faltantes durante start()

Devuelve errores específicos según el permiso faltante

Permite que la aplicación host gestione la solicitud de permisos desde su interfaz

## Buenas prácticas

Se recomienda:

Llamar a initialize al iniciar la aplicación

Solicitar permisos desde la UI de la aplicación antes de iniciar el monitoreo

Ejecutar login después de la autenticación del usuario

Ejecutar start una vez que el usuario esté autenticado
