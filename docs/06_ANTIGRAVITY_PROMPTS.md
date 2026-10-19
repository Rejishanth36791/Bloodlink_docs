# Antigravity Prompts - BloodLink AI

## How to use
1. Create the repo folder `bloodlink/` with `docs/` containing: `01_PRD.md`, `02_TECH_STACK.md`, `03_README.md`, `04_USER_MANUAL.md`, and put `05_schema.sql` at `backend/src/main/resources/db/migration/V1__init.sql`.
2. Copy the existing Flutter prototype into `mobile/`.
3. Open `bloodlink/` in Antigravity. Save **Section A** as the workspace rules (Customizations / Rules, or `AGENTS.md` at the repo root) so every agent follows it.
4. Paste **Phase prompts (Section B)** one at a time, in order. Do not start the next phase until the current one's checks pass. Review each plan/artifact before approving.
5. If an error appears, paste the exact error text into **Section C**.

---
## Section A - Master rules (save as workspace rules / AGENTS.md)

```
You are building BloodLink AI, a REAL production-style, real-time blood donation platform.
Source of truth: docs/01_PRD.md, docs/02_TECH_STACK.md, backend/src/main/resources/db/migration/V1__init.sql. Read them fully before any work.

ABSOLUTE RULES
1. NO mock, fake, sample, dummy or hardcoded data anywhere (no mock.dart, no "Nimal", no fixed donor lists, no fake forecast numbers, no Future.delayed pretending to be a server). Every screen reads from the real API; every API reads from the real PostgreSQL database.
2. Empty/loading/error states are required for every list and screen (e.g. "No active requests yet"). Never fill emptiness with sample content.
3. No secrets in code. Read all config from environment variables / dart-define / git-ignored files. Provide .env.example with variable names only. If a required variable is missing, fail fast with a clear message.
4. Use only the stack in docs/02_TECH_STACK.md. Do not swap technologies. Pin dependency versions that exist; verify each package on pub.dev / Maven Central before adding it.
5. The database schema is fixed by V1__init.sql. Do not edit it; add new Flyway migrations (V2__...) for any change. Use JPA entities that match it exactly (validate with spring.jpa.hibernate.ddl-auto=validate).
6. Security: Spring Security with JWT (access 15 min + rotating refresh), role-based authorization on every endpoint (DONOR, REQUESTER, BLOOD_BANK, ADMIN), bean validation on every request DTO, BCrypt/Argon2 password hashing, rate limiting on auth endpoints, audit log writes for sensitive actions. Never return password hashes or exact donor coordinates to requesters before the donor accepts.
7. Real-time: WebSocket/STOMP for request status and bank dashboard; FCM for push. Do not poll except as a documented fallback.
8. Code quality: layered backend (controller -> service -> repository), DTOs separate from entities, global exception handler returning a consistent JSON error {timestamp,status,code,message,path}. Flutter: Riverpod, go_router, feature-first folders, freezed models, no business logic in widgets.
9. Preserve the existing UI design (colors/typography/components in mobile/lib/theme.dart and widgets.dart, matching the provided design pages). Keep matching Material 3.
10. After EVERY phase you must run the verification commands listed in the phase, show the real output, and fix all errors and warnings before saying done. Never claim something works without running it. If you cannot run something (e.g. no Firebase key), say exactly what is missing instead of faking it.
11. Work in small commits with clear messages (feat:, fix:, test:, docs:). Do not commit secrets or build output.
12. Ask me only when blocked by a missing credential/decision; otherwise decide, document the decision in docs/DECISIONS.md, and continue.
```

---
## Section B - Phase prompts (paste one at a time)

### Phase 0 - Project scaffold
```
Read AGENTS.md/rules and all files in docs/. Create the monorepo structure: backend/ (Spring Boot 3.3+, Java 21, Maven), ai-service/ (FastAPI), mobile/ (existing Flutter app), docker-compose.yml (postgis/postgis:16 with a named volume, healthcheck), .env.example, .gitignore (env files, keystores, google-services.json, build dirs), and a root README.md from docs/03_README.md.
Backend dependencies: web, security, validation, data-jpa, websocket, actuator, flyway-core + flyway-database-postgresql, postgresql driver, hibernate-spatial, jjwt, firebase-admin, springdoc-openapi, lombok or records, testcontainers (postgresql). 
Verify: `docker compose up -d postgres` is healthy; `cd backend && ./mvnw -q clean verify` passes; app starts, Flyway applies V1__init.sql with zero errors; GET /actuator/health returns UP. Show the outputs.
```

### Phase 1 - Backend auth and accounts
```
Implement in backend/: entities and repositories for users, refresh_tokens, device_tokens, donors, requester_profiles, blood_banks (matching V1__init.sql exactly). Implement endpoints with DTOs and validation:
POST /api/auth/register/donor, /register/requester, /register/bank (bank = PENDING until admin approval), POST /api/auth/login, /refresh, /logout, POST /api/auth/verify-phone (accepts a Firebase ID token, verifies with Firebase Admin SDK, marks phone_verified), POST /api/auth/forgot-password and /reset-password, GET/PUT /api/me, PUT /api/donors/me/availability, PUT /api/donors/me/location, POST /api/devices (register FCM token).
Admin: GET /api/admin/banks?status=PENDING, POST /api/admin/banks/{id}/approve|reject, POST /api/admin/users/{id}/suspend. First-admin bootstrap via a CLI argument reading ADMIN_EMAIL/ADMIN_PASSWORD from env.
Include JwtAuthFilter, role-based @PreAuthorize, global exception handler, login rate limiting, audit logging.
Verify: integration tests with Testcontainers (PostGIS) covering register, login, refresh rotation, role denial (403), pending bank cannot access bank endpoints. `./mvnw verify` must pass. Show test output.
```

### Phase 2 - Requests, matching, real-time, notifications
```
Implement blood_requests, request_matches, notifications, donations. Endpoints:
POST /api/requests (REQUESTER), GET /api/requests/mine, GET /api/requests/{id}, POST /api/requests/{id}/cancel, GET /api/requests/{id}/matches (ranked list; hide exact donor location until ACCEPTED),
GET /api/donors/me/alerts, POST /api/matches/{id}/accept (with eta_minutes) and /decline (DONOR),
GET /api/appeals/nearby?lat&lng&radiusKm (open requests compatible with the donor),
POST /api/bank/donations/{id}/verify (BLOOD_BANK).
Matching service: on request creation call the DB function find_candidate_donors, score each candidate = 0.5*compat + 0.3*proximity + 0.2*reliability (weights from config), store top N in request_matches, send FCM + STOMP event. A scheduled job expires unanswered matches after the response window (config, default 10 min), widens the radius (40 -> 80 -> 150 km) and notifies the next batch.
STOMP: endpoint /ws (JWT auth on CONNECT), topics /user/queue/requests (status changes) and /user/queue/alerts. On donation verify: update donations, donor.last_donation_date, total_donations, reliability_score, inventory ledger, request.units_fulfilled and status. No-show updates reliability.
Verify: Testcontainers integration test for the full flow requester -> matches -> donor accepts -> bank verifies -> request FULFILLED, plus a test that incompatible blood types are never matched. `./mvnw verify` passes.
```

### Phase 3 - Inventory, camps, eligibility, AI service
```
Backend: inventory + inventory_movements (ledger-only changes inside one transaction, never negative stock), GET /api/bank/dashboard (stock, low flags, incoming donors, forecasts), donation_camps + camp_registrations endpoints, GET /api/banks/nearby and /api/camps/nearby (PostGIS ST_DWithin), admin endpoints for fraud_flags, awareness_alerts (FCM broadcast by district/blood type), analytics.
AI service (ai-service/, FastAPI): 
- POST /eligibility: rules from config file ai-service/config/eligibility_rules.yaml (age 18-60, weight >= 50 kg, cooldown days, illness, tattoo/piercing months, antibiotics, pregnancy/nursing, etc.), returns {isEligible, readinessScore, reasons[], nextEligibleDate, modelVersion}. 
- POST /rank: re-ranks candidates (same formula, weights from config).
- POST /forecast/run: reads demand_history (read-only DB user), fits per district+blood type: seasonal-naive baseline, Holt-Winters when >= 8 weeks of data, writes demand_forecasts; if history is too short return status INSUFFICIENT_DATA and write nothing.
Backend persists eligibility_assessments and calls the AI service with timeouts + a clear error when it is down (no silent fake results). A nightly job aggregates requests into demand_history and triggers forecasting.
Verify: pytest for the AI service (rules, ranking, forecast with synthetic data INSIDE TESTS ONLY), backend integration tests, Swagger shows every endpoint. All pass.
```

### Phase 4 - Flutter: remove mocks and connect to real API
```
In mobile/: delete lib/data/mock.dart and lib/services/matching.dart (logic now lives in backend/AI service). Restructure feature-first: lib/core (config from --dart-define, dio client with auth + refresh interceptor, secure token storage, error mapping, router with role redirect, theme.dart + widgets.dart kept), lib/features/{auth,donor,requester,bank,admin,map,notifications}/(data,domain,presentation). Use Riverpod, go_router, freezed/json_serializable models generated from the real Swagger contract.
Wire EVERY existing screen to real endpoints with loading/empty/error states: sign in/up + phone OTP (firebase_auth), donor home/appeals/eligibility/history/profile, requester home/new request/matched donors/tracking, bank dashboard, map (google_maps_flutter + geolocator), push (firebase_messaging + local notifications), STOMP live updates for tracking and bank dashboard.
Then build the missing screens from the design pages: Blood Bank Sign Up, Account Status (Pending/Rejected), Admin Login + admin review list, Terms & Privacy, Donation Camps, Inventory Management, Incoming Donors.
Verify: `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze` (zero issues), `flutter test`, then run on an emulator against the local backend and perform the full flow with three real accounts (donor, requester, bank). Show the analyze/test output and describe each step observed. Search the codebase and confirm no mock data remains (grep for "mock", "dummy", "Nimal", "Future.delayed").
```

### Phase 5 - Hardening, tests, docs
```
Add: backend global rate limits, CORS from env, request logging without personal data, Actuator health, Dockerfiles for backend and ai-service, full docker-compose (postgres, backend, ai-service), GitHub Actions workflow (backend verify, flutter analyze+test, ai-service pytest). Flutter integration_test for login and create-request flows. Update README/USER_MANUAL to match actual behaviour, add docs/API.md exported from Swagger, docs/TEST_CASES.md (id, steps, expected, result) for the testing lead, and docs/DECISIONS.md.
Verify: `docker compose up --build` brings the whole system up from scratch; CI workflow passes locally via `act` or equivalent commands; final checklist against PRD section 11. List any PRD item not completed.
```

---
## Section C - Fix prompts (use when something fails)

**Build/compile error**
```
Here is the exact error output: <paste>. Find the root cause, fix it in the code (no workarounds that remove features or add mock data), re-run the same command, and show that it now passes. Then run the full verification for the current phase again.
```

**Runtime/API error**
```
The app shows: <what you see>. The backend log says: <paste>. Reproduce it with curl against the running backend, find whether the bug is in Flutter, Spring Boot, SQL or the AI service, fix it at the source, add a test that fails before the fix and passes after, and show both runs.
```

**Before submission audit**
```
Audit the whole repo against docs/01_PRD.md section 5 and 11. For each FR-x give: implemented? where (file)? tested? Run all tests and analyzers. Grep for mock/dummy/hardcoded data and secrets. Output a table and fix every gap.
```
