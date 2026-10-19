# Tech Stack

| Layer | Choice | Why |
|---|---|---|
| Mobile | Flutter 3.x (Dart 3.7+), Material 3 | Course requirement, cross-platform |
| State management | Riverpod (flutter_riverpod) | Testable, async-friendly |
| Navigation | go_router | Role-based redirects |
| HTTP | dio (interceptors for JWT refresh) | Retry, logging |
| Real-time client | stomp_dart_client (WebSocket) | Live request/dashboard updates |
| Push | firebase_core, firebase_messaging, flutter_local_notifications | Matched-request alerts |
| Maps/GPS | google_maps_flutter, geolocator, geocoding | Banks/camps map, donor location |
| Secure storage | flutter_secure_storage | Tokens |
| Models | freezed + json_serializable | Typed API models |
| Backend | Java 21, Spring Boot 3.3+ (Web, Security, Validation, Data JPA, WebSocket, Actuator) | Course stack |
| Auth | Spring Security + JWT (access 15 min, refresh rotation), Argon2/BCrypt; Firebase Phone Auth for OTP (backend verifies Firebase ID token) | Secure, SMS handled by Firebase |
| Database | PostgreSQL 16 + PostGIS | Relational integrity + geospatial matching |
| Migrations | Flyway | Versioned schema (`V1__init.sql`) |
| Real-time server | Spring WebSocket + STOMP | Status/dashboard events |
| Push server | Firebase Admin SDK (FCM) | Notifications |
| AI service | Python 3.12, FastAPI, pandas, scikit-learn, statsmodels | Eligibility, matching rank, forecasting |
| Scheduler | Spring `@Scheduled` or Python APScheduler (daily forecast job) | Forecast generation |
| API docs | springdoc-openapi (Swagger UI) | Contract for frontend/AI |
| Testing | JUnit 5, Testcontainers (Postgres/PostGIS), flutter_test, integration_test, pytest | Real DB tests |
| Infra | Docker + docker-compose (postgres/postgis, backend, ai-service); deploy on Render/Railway/Fly.io or a VPS | Reproducible |
| CI | GitHub Actions (analyze, test, build) | Quality gate |
| VCS | GitHub, feature branches, individual commits | Course requirement |

## Architecture
```
Flutter app  <--HTTPS REST + WSS-->  Spring Boot API  <--SQL-->  PostgreSQL/PostGIS
      ^                                   |  \--HTTP-->  FastAPI AI service (eligibility, rank, forecast)
      |                                   \--FCM-->  Firebase Cloud Messaging --> devices
      \-- Google Maps / GPS
```

## Ports and environment variables (never commit real values)
Backend: `DB_URL, DB_USER, DB_PASSWORD, JWT_SECRET, JWT_ACCESS_MIN, JWT_REFRESH_DAYS, FIREBASE_CREDENTIALS_PATH, AI_SERVICE_URL, CORS_ORIGINS`
AI service: `DB_URL (read-only user), MODEL_DIR`
Flutter: `--dart-define=API_BASE_URL=... --dart-define=WS_URL=...`; Google Maps key in AndroidManifest/AppDelegate via local, git-ignored config.
