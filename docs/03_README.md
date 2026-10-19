# BloodLink AI

AI-powered, real-time blood donation platform for Sri Lanka (SE303.3 MAD coursework, NSBM Green University).
Donors, requesters and blood banks are connected by AI matching, eligibility checks and demand forecasting.

## Repository layout
```
bloodlink/
  mobile/        Flutter app
  backend/       Spring Boot REST + WebSocket API (Flyway migrations in src/main/resources/db/migration)
  ai-service/    FastAPI service (eligibility, ranking, forecasting)
  docs/          PRD, tech stack, user manual, prompts
  docker-compose.yml
```

## Prerequisites
Flutter 3.x, JDK 21, Maven or Gradle, Docker, Python 3.12, a Firebase project (Auth phone + FCM), a Google Maps API key.

## Setup
1. **Database + services**
   ```
   cp .env.example .env        # fill real values; .env is git-ignored
   docker compose up -d postgres
   ```
2. **Backend**
   ```
   cd backend
   ./mvnw spring-boot:run      # Flyway applies V1__init.sql automatically
   ```
   Swagger UI: http://localhost:8080/swagger-ui.html
3. **AI service**
   ```
   cd ai-service && pip install -r requirements.txt
   uvicorn app.main:app --port 8000
   ```
4. **Mobile**
   ```
   cd mobile
   flutter pub get
   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080 --dart-define=WS_URL=ws://10.0.2.2:8080/ws
   ```
   (10.0.2.2 = host machine from the Android emulator; use your LAN IP on a real phone.)

## First admin account
No default accounts exist. Create the first admin with the one-time bootstrap command:
`ADMIN_EMAIL=you@example.com ADMIN_PASSWORD=... ./mvnw spring-boot:run -Dspring-boot.run.arguments=--bootstrap-admin`

## Testing
`cd backend && ./mvnw test` | `cd mobile && flutter analyze && flutter test` | `cd ai-service && pytest`

## Team
Backend & Database: SVC Karunadasa | UI/UX & Frontend: P Rejishanth | Testing & Documentation: Muhammed AT | AI/ML & Integration: P Kukarakshan
Module leader: Mr. Diluka Wijesinghe

## Medical disclaimer
Eligibility results are guidance only. Final donor screening is done by qualified medical staff.
