# BloodLink AI - Product Requirements Document (PRD)

Version 1.0 | Course: SE303.3 Mobile Application Development, NSBM Green University | Deadline: 30 Nov 2026

## 1. Purpose
BloodLink AI is a real-time mobile platform that connects blood donors, requesters (patients, families, hospital staff) and blood banks in Sri Lanka. It reduces the time between an urgent blood request and a suitable donor being found, helps donors check eligibility, and gives blood banks demand forecasts.

## 2. Problem
- Matching blood requests to donors is manual (phone calls, social media) and slow.
- Donors do not know when their blood type is urgently needed nearby, or whether they are eligible.
- Blood banks lack visibility on upcoming shortages.

## 3. Goals and success metrics
| Goal | Metric |
|---|---|
| Fast matching | Median time from request creation to first donor notification < 60 s |
| Real-time visibility | Request status updates reach the requester app < 3 s |
| Eligibility clarity | 100% of donors see an eligibility result with reasons before donating |
| Bank planning | Forecast generated daily for every verified bank |
| Reliability | Backend availability >= 99% during demo period |

## 4. Users and roles
| Role | Description |
|---|---|
| Donor | Registers blood type, location, availability; receives matched alerts; tracks history |
| Requester | Creates blood requests, sees ranked matched donors, tracks status |
| Blood Bank / Hospital | Manages inventory, verifies donations, runs camps, sees forecasts |
| Admin | Verifies accounts, monitors fraud/no-shows, sends awareness alerts, sees analytics |

## 5. Functional requirements
Priority: P0 = must for submission, P1 = should, P2 = nice.

### 5.1 Authentication and accounts
- FR-1 (P0) Sign up/sign in for Donor, Requester, Blood Bank with email+password; phone OTP verification (6-digit).
- FR-2 (P0) JWT access + refresh tokens; role-based access control on every endpoint.
- FR-3 (P0) Blood bank accounts start PENDING; admin approves/rejects with reason; bank sees status screen.
- FR-4 (P1) Forgot password via email link. FR-5 (P0) Admin login (separate screen).
- FR-6 (P0) Terms & Privacy consent captured with timestamp; health-data consent stored.

### 5.2 Donor
- FR-7 (P0) Profile: blood type, DOB, weight, district/city, GPS location, availability toggle.
- FR-8 (P0) AI eligibility check (questionnaire + donation history) returns eligible/not, readiness score, reasons, next eligible date. Result stored.
- FR-9 (P0) Receive push + in-app alert for matched requests; accept/decline within the response window.
- FR-10 (P0) Donation history, next eligible date, reminders.
- FR-11 (P1) Urgent appeals list near me; camp registration (RSVP). FR-12 (P2) Streak/milestone badges.

### 5.3 Requester
- FR-13 (P0) Create request: patient, hospital/ward, blood type, component, units, urgency, needed-by, contact, hospital location.
- FR-14 (P0) AI-ranked matched donors list (score = compatibility, distance, reliability).
- FR-15 (P0) Real-time tracking: Created, Notified, Accepted, Arrived, Fulfilled; donor ETA; contact donor.
- FR-16 (P1) Cancel/extend request; history of requests.

### 5.4 Blood bank
- FR-17 (P0) Dashboard: stock per blood type, low-stock flags, incoming donors.
- FR-18 (P0) Inventory management with movement ledger (donation, transfusion, expiry, adjustment).
- FR-19 (P0) Verify donation (marks donor reliability, updates stock, closes match).
- FR-20 (P0) AI demand forecast (next 7 days per blood type). FR-21 (P1) Create/manage donation camps.

### 5.5 Admin
- FR-22 (P0) Review pending bank applications. FR-23 (P1) Fraud/no-show monitoring, suspend users.
- FR-24 (P1) Regional analytics. FR-25 (P1) Send awareness alerts (nationwide/district/blood type).

### 5.6 Maps and location
- FR-26 (P0) Map of nearby blood banks and camps (Google Maps, GPS, directions).

## 6. AI components (real, not mocked)
1. **Eligibility predictor:** rule engine from NBTS donation criteria (configurable thresholds in DB/config) plus risk flags; returns reasons and `model_version`.
2. **Matching engine:** candidate set from PostGIS (compatible, available, past cooldown, within radius), ranked by `0.5*compatibility + 0.3*proximity + 0.2*reliability`. Weights configurable. Escalates radius if no candidates.
3. **Demand forecasting:** daily job reads `demand_history`, fits a time-series model per district/blood type (seasonal-naive baseline, then Holt-Winters/ARIMA when >= 8 weeks of data), writes `demand_forecasts`. Shows "insufficient data" instead of fake numbers when history is too short.

## 7. Non-functional requirements
- **Real-time:** WebSocket (STOMP) for request status and bank dashboard; FCM push for alerts.
- **Performance:** API p95 < 500 ms; matching query < 1 s for 100k donors (GIST index).
- **Security:** HTTPS only; passwords hashed (Argon2/BCrypt); JWT short-lived (15 min) + refresh rotation; rate limiting; input validation; no secrets in code; audit logs.
- **Privacy:** Sri Lanka Personal Data Protection Act (No. 9 of 2022) principles: consent, minimal collection, donors' exact location never shown to requesters (only approximate distance until the donor accepts), data export/delete on request.
- **Compatibility:** Android 8+ and iOS 13+. **Accessibility:** min touch target 48 px, contrast AA, Sinhala/Tamil-ready strings (i18n structure).
- **Offline/edge:** clear empty, loading and error states on every screen; retry on network failure.

## 8. Core flow (end to end)
1. Requester creates request, backend saves it (status CREATED).
2. Backend calls AI service/matching, stores `request_matches`, sends FCM + WebSocket events to the top-N donors (status NOTIFIED).
3. A donor accepts; requester sees live update with ETA; other notifications expire.
4. Donor arrives; bank verifies donation; inventory ledger updated; request status FULFILLED; donor history and reliability updated.
5. If no donor accepts within the window, the radius widens and the next batch is notified; the bank is alerted.

## 9. Out of scope
Payments, online selling of blood, medical diagnosis, integrations with national hospital systems (documented as future work).

## 10. Assumptions and risks
| Risk | Mitigation |
|---|---|
| Fake requests/abuse | Phone OTP, rate limits, admin flags, audit log |
| Eligibility rules vary by centre | Rules are configurable; screen shows "final decision made by medical staff" |
| Low donor density | Radius escalation; fall back to bank/camp suggestions |
| No history for forecasts | Show "insufficient data"; baseline model |
| Privacy of health data | Consent, encryption at rest, role-based access |

## 11. Acceptance criteria (submission)
- All P0 requirements work against the real backend and database, with zero mock data in the code.
- A new install can complete the full core flow with three real accounts (donor, requester, bank).
- `flutter analyze` has no errors; backend tests pass; schema applies cleanly via Flyway.

## 12. Milestones
Backend + DB + auth (week 1-2), Flutter modules (2-4), AI + forecasting (3-5), maps + push (4-5), testing + docs (5-6), demo + submit (by 30 Nov 2026).
