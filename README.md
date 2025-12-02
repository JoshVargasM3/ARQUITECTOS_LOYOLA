# Arquitectos Loyola

Aplicación móvil Flutter + Firebase para que clientes y arquitectos de Loyola gestionen y consulten el avance de proyectos en tiempo real.

## Tecnologías
- Flutter 3 (UI)
- Firebase (Auth, Firestore, Storage)
- Provider para estado
- YouTube Player embebido para avances en video

## Estructura destacada
- `lib/core`: tema y constantes
- `lib/models`: modelos para usuario, proyecto, comentarios, inventario y videos
- `lib/services`: integración con Firebase Auth y Firestore
- `lib/screens/auth`: Splash y Login
- `lib/screens/client`: Home de cliente con accesos rápidos y resumen
- `lib/screens/architect`: Home de arquitecto con listado de proyectos
- `lib/screens/project`: Detalle con pestañas (resumen, presupuesto, fotos/planos placeholder, videos, comentarios)

## Configuración local
1. Instala Flutter y configura un dispositivo/emulador.
2. Ejecuta `flutter pub get` para instalar dependencias.
3. Configura Firebase con `flutterfire configure` y reemplaza `lib/firebase_options.dart` por el archivo generado.
4. Crea las colecciones de Firestore según el modelo descrito en el prompt (users, projects y subcolecciones).
5. Ejecuta la app:
   ```bash
   flutter run
   ```

## Roles
- **Cliente**: solo puede ver sus proyectos activos y el historial cuando se marcan como finalizados.
- **Arquitecto/Admin**: puede ver todos los proyectos y usar flujos de gestión (inventario, costos, cargas de archivos) ampliando las pantallas existentes.
