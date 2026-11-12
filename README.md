# PharmaSoft Backend — Sesión 14

Backend Spring Boot basado en la versión de la sesión 13; incluye los pasos 1–4 de la guía práctica de la sesión 14.

## Desarrollo local

Configura `DB_PASSWORD` para Oracle y `JWT_SECRET` como clave segura de al menos 256 bits codificada en Base64 antes de iniciar el perfil `dev`. No hay credenciales reales en la configuración publicada.

En Windows ejecuta `mvnw.cmd spring-boot:run` (o `./mvnw spring-boot:run`). Oracle debe estar disponible con el esquema esperado.

`docs/sql/volumen_pruebas.sql` genera datos de carga para desarrollo; ejecútalo solo en una base de pruebas.
