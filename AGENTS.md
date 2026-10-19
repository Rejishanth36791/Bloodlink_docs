# BloodLink AI - Master Rules (AGENTS.md)

You are building BloodLink AI, a REAL production-style, real-time blood donation platform.
Source of truth: docs/01_PRD.md, docs/02_TECH_STACK.md, backend/src/main/resources/db/migration/V1__init.sql. Read them fully before any work.

## ABSOLUTE RULES
1. NO mock, fake, sample, dummy or hardcoded data anywhere (no mock.dart, no "Nimal", no fixed donor lists, no fake forecast numbers, no Future.delayed pretending to be a server). Every screen reads from the real API; every API reads from the real PostgreSQL database.
2. Empty/loading/error states are required for every list and screen (e.g. "No active requests yet"). Never fill emptiness with sample content.
3. No secrets in code. Read all config from environment variables / dart-define / git-ignored files. Provide .env.example with variable names only. If a required variable is missing, fail fast with a clear message.
4. Use only the stack in docs/02_TECH_STACK.md. Do not swap technologies. Pin dependency versions that exist; verify each package on pub.dev / Maven Central before adding it.
5. The database schema is fixed by V1__init.sql. Do not edit it; add new Flyway migrations (V2__...) for any change. Use JPA entities that match it exactly (validate with spring.jpa.hibernate.ddl-auto=validate).
6. Security: Spring Security with JWT (access 15 min + rotating refresh), role-based authorization on every endpoint (DONOR, REQUESTER, BLOOD_BANK, ADMIN), bean validation on every request DTO, BCrypt/Argon2 password hashing, rate limiting on auth endpoints, audit log writes for sensitive actions. Never return password hashes or exact donor coordinates to requesters before the donor accepts.
7. Real-time: WebSocket/STOMP for request status and bank dashboard; FCM for push. Do not poll except as a documented fallback.
8. Code quality: layered backend (controller -> service -> repository), DTOs separate from entities, global exception handler returning a consistent JSON error {timestamp,status,code,message,path}. Flutter: Riverpod, go_router, feature-first folders, freezed/json_serializable models, no business logic in widgets.
9. Preserve the existing UI design (colors/typography/components matching Pages/Design System & Components Reference.png). Keep matching Material 3.
10. After EVERY phase you must run the verification commands listed in the phase, show the real output, and fix all errors and warnings before saying done. Never claim something works without running it. If you cannot run something (e.g. no Firebase key), say exactly what is missing instead of faking it.
11. Work in small commits with clear messages (feat:, fix:, test:, docs:). Do not commit secrets or build output.
12. Ask me only when blocked by a missing credential/decision; otherwise decide, document the decision in docs/DECISIONS.md, and continue.
