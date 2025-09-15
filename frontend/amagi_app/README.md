# Amagi App - Aplicación Móvil

![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-Flutter-green.svg)
![License](https://img.shields.io/badge/license-Private-red.svg)

## 📱 Descripción

**Amagi App** es una aplicación móvil Flutter para la gestión integral de tickets y solicitudes con integración a servicios GLPI. Permite autenticación segura, creación y seguimiento de tickets, adjuntar archivos, gestionar históricos, aplicar filtros y recibir notificaciones locales. Disponible para Android e iOS.

## ✨ Características Principales

### 🎫 Gestión de Tickets
- Creación de tickets con campos y adjuntos
- Listado, detalle y seguimiento por estado
- Filtros avanzados y búsqueda
- Historial y valoración de satisfacción

### 📎 Adjuntos y Documentos
- Selección de archivos desde el dispositivo
- Descargas en segundo plano con reintentos
- Apertura de archivos compatibles y visualización de PDF

### 🔔 Notificaciones y Tareas en Segundo Plano
- Notificaciones locales configurables
- Trabajos en background para descargas y recordatorios

### 👤 Perfil y Sesión
- Inicio de sesión y almacenamiento seguro de credenciales
- Persistencia de sesión y cierre de sesión

### 🌐 Conectividad y Offline Básico
- Detección de conectividad
- Almacenamiento local para preferencias y caché ligera

## 🛠️ Tecnologías Utilizadas

### Frontend
- **Flutter** 3.35.1

### Desarrollo
- Flutter CLI, Gradle (Android), CocoaPods (iOS)

## 📦 Instalación

### Prerrequisitos
```bash
# Verificar Flutter
flutter --version

# Java (requerido por Android/Gradle)
java -version

# CocoaPods (iOS)
sudo gem install cocoapods
```

### Instalación Local
```bash
# Clonar el repositorio
git clone <https://github.com/tu-usuario/amagi_app.git>
cd amagi_app

# Instalar dependencias
flutter pub get

# iOS (primera vez)
cd ios && pod install && cd ..
```

### Configuración de Variables de Entorno
- Editar `lib/config/environment.dart` y configurar:
  - URLs base del backend/GLPI
  - Rutas/IDs de servicios y timeouts
  - Flags de entorno (dev/stage/prod)

## 🚀 Uso

### Desarrollo
```bash
# Ejecutar en Android
flutter run -d android

# Ejecutar en iOS (simulador)
flutter run -d ios

# Formato y análisis
flutter format .
flutter analyze
```

### Construcción para Producción
```bash
# Android - APK
flutter build apk --release

# Android - App Bundle
flutter build appbundle --release

# iOS - IPA (requiere Xcode firmado)
flutter build ipa
# o
flutter build ios --release
```

## 🏗️ Arquitectura

### Estructura de Carpetas
```
amagi_app/
├── lib/
│   ├── main.dart                  # Arranque de la app
│   ├── config/                    # Configuración y entornos
│   ├── controllers/               # Lógica de presentación/control
│   ├── models/                    # Entidades y conversiones
│   ├── repositories/              # Acceso a datos/abstracciones
│   ├── services/                  # Integraciones (auth, GLPI, tickets)
│   ├── theme/                     # Theming
│   ├── views/                     # Pantallas de la app
│   └── widgets/                   # Componentes reutilizables
├── android/                       # Proyecto Android (Gradle)
└── ios/                           # Proyecto iOS (Xcode/CocoaPods)
```

### Patrón de Estado
- Controladores por vista/flujo (carpeta `controllers/`)
- Repositorios/servicios para acceso a API y datos
- Modelos tipados para entidades de dominio

## 📱 Funcionalidades Detalladas

### Autenticación
- Login y persistencia de sesión
- Almacenamiento seguro de tokens

### Tickets
- Listados paginados y filtrables
- Detalle con histórico
- Creación con adjuntos y MIME correcto

### Notificaciones
- Locales para cambios y recordatorios
- Canales configurables (Android)

### Descargas y Archivos
- Descargas en background con progreso
- Visualización de PDF y apertura de archivos

## 🔐 Seguridad
- Almacenamiento seguro de secretos/tokens
- Sanitización y reducción de logs sensibles

## 📊 Rendimiento
- Caché ligera en preferencias/base local
- Manejo eficiente de adjuntos y descargas

## 🔧 Permisos de Plataforma

### Android
- Internet, notificaciones, lectura de medios/almacenamiento
- Configuración de `flutter_downloader` (servicio y provider)
- Canales de notificación y compatibilidad SDK 33+

### iOS
- Descripciones en `Info.plist` (cámara/fotos/archivos/notificaciones según uso)
- Background Modes si hay descargas en segundo plano

## 🐛 Depuración

### Logs Comunes
- Deshabilitar logs verbosos en release
- Útiles: `print`/`logger` en desarrollo (no dejar secretos)

### Herramientas de Desarrollo
- Flutter DevTools
- Android Studio/Logcat
- Xcode Instruments/Console

## 📱 Plataformas Soportadas
- **Android** 6.0+ (API 23+)
- **iOS** 12.0+

## 📋 Requisitos del Sistema
- **RAM**: 2 GB mínimo
- **Almacenamiento**: 200 MB libres
- **Internet**: conexión estable

## 🔄 Actualizaciones

### Versión Actual: 1.3.0
- Release funcional (tickets, adjuntos, notificaciones)
- Integración GLPI básica
- Mejoras de estabilidad y rendimiento

### Próximas Funcionalidades
- Internacionalización (i18n)
- Mejoras de accesibilidad
- Sincronización offline avanzada
- Notificaciones push remotas

## 📞 Soporte
- Email: soporte@amagigroup.net
- Web: https://www.amagigroup.net/

## 📄 Licencia

Este proyecto es propiedad privada de la organización. Todos los derechos reservados.
