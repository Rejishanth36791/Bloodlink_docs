-- BloodLink AI - PostgreSQL 16 + PostGIS schema (Flyway: V1__init.sql)
-- No sample/mock rows. Only constant reference data (blood compatibility).

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

-- ---------- ENUMS ----------
CREATE TYPE user_role        AS ENUM ('DONOR','REQUESTER','BLOOD_BANK','ADMIN');
CREATE TYPE account_status   AS ENUM ('PENDING','ACTIVE','REJECTED','SUSPENDED');
CREATE TYPE blood_type       AS ENUM ('A+','A-','B+','B-','AB+','AB-','O+','O-');
CREATE TYPE blood_component  AS ENUM ('WHOLE_BLOOD','PLATELETS','PLASMA','RED_CELLS');
CREATE TYPE urgency_level    AS ENUM ('CRITICAL','URGENT','PLANNED');
CREATE TYPE request_status   AS ENUM ('CREATED','MATCHING','DONOR_ACCEPTED','DONOR_ARRIVED','FULFILLED','CANCELLED','EXPIRED');
CREATE TYPE match_status     AS ENUM ('NOTIFIED','ACCEPTED','DECLINED','EXPIRED','ARRIVED','DONATED','NO_SHOW');
CREATE TYPE donation_status  AS ENUM ('SCHEDULED','COMPLETED','REJECTED','NO_SHOW');
CREATE TYPE camp_status      AS ENUM ('UPCOMING','ONGOING','COMPLETED','CANCELLED');
CREATE TYPE movement_reason  AS ENUM ('DONATION','TRANSFUSION','EXPIRY','TRANSFER_IN','TRANSFER_OUT','ADJUSTMENT');
CREATE TYPE flag_status      AS ENUM ('OPEN','REVIEWING','RESOLVED','DISMISSED');

-- ---------- COMMON ----------
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS trigger AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END; $$ LANGUAGE plpgsql;

-- ---------- USERS & AUTH ----------
CREATE TABLE users (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  role           user_role      NOT NULL,
  email          citext         UNIQUE,
  phone          text           UNIQUE,
  password_hash  text,                       -- bcrypt/argon2; NULL if phone-only
  firebase_uid   text           UNIQUE,
  full_name      text           NOT NULL,
  status         account_status NOT NULL DEFAULT 'ACTIVE',
  email_verified boolean        NOT NULL DEFAULT false,
  phone_verified boolean        NOT NULL DEFAULT false,
  last_login_at  timestamptz,
  created_at     timestamptz    NOT NULL DEFAULT now(),
  updated_at     timestamptz    NOT NULL DEFAULT now(),
  CHECK (email IS NOT NULL OR phone IS NOT NULL)
);
CREATE TRIGGER trg_users_upd BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE refresh_tokens (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash  text NOT NULL UNIQUE,
  expires_at  timestamptz NOT NULL,
  revoked_at  timestamptz,
  created_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_refresh_user ON refresh_tokens(user_id);

CREATE TABLE device_tokens (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  fcm_token  text NOT NULL UNIQUE,
  platform   text NOT NULL CHECK (platform IN ('android','ios')),
  last_seen  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_device_user ON device_tokens(user_id);

-- ---------- PROFILES ----------
CREATE TABLE donors (
  user_id            uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  blood_type         blood_type NOT NULL,
  date_of_birth      date NOT NULL,
  gender             text CHECK (gender IN ('MALE','FEMALE','OTHER')),
  weight_kg          numeric(5,2) CHECK (weight_kg BETWEEN 30 AND 250),
  district           text NOT NULL,
  city               text NOT NULL,
  location           geography(Point,4326),
  is_available       boolean NOT NULL DEFAULT true,
  last_donation_date date,
  reliability_score  numeric(4,3) NOT NULL DEFAULT 0.500 CHECK (reliability_score BETWEEN 0 AND 1),
  total_donations    integer NOT NULL DEFAULT 0,
  total_no_shows     integer NOT NULL DEFAULT 0,
  consent_health_data boolean NOT NULL DEFAULT false,
  consent_at         timestamptz,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_donors_loc   ON donors USING GIST (location);
CREATE INDEX idx_donors_match ON donors (blood_type, is_available);
CREATE TRIGGER trg_donors_upd BEFORE UPDATE ON donors FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE requester_profiles (
  user_id        uuid PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  requester_type text NOT NULL CHECK (requester_type IN ('PATIENT_FAMILY','HOSPITAL_STAFF')),
  district       text,
  city           text
);

CREATE TABLE blood_banks (
  id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id            uuid NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  institution_name   text NOT NULL,
  nbts_license_no    text NOT NULL UNIQUE,
  hotline            text NOT NULL,
  address            text NOT NULL,
  district           text NOT NULL,
  location           geography(Point,4326) NOT NULL,
  director_name      text,
  official_email     citext,
  is_24h             boolean NOT NULL DEFAULT false,
  verification_status account_status NOT NULL DEFAULT 'PENDING',
  rejection_reason   text,
  verified_by        uuid REFERENCES users(id),
  verified_at        timestamptz,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_banks_loc ON blood_banks USING GIST (location);
CREATE TRIGGER trg_banks_upd BEFORE UPDATE ON blood_banks FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ---------- REFERENCE: BLOOD COMPATIBILITY (constant medical data) ----------
CREATE TABLE blood_compatibility (
  donor_type     blood_type NOT NULL,
  recipient_type blood_type NOT NULL,
  PRIMARY KEY (donor_type, recipient_type)
);
INSERT INTO blood_compatibility (donor_type, recipient_type) VALUES
 ('O-','O-'),('O-','O+'),('O-','A-'),('O-','A+'),('O-','B-'),('O-','B+'),('O-','AB-'),('O-','AB+'),
 ('O+','O+'),('O+','A+'),('O+','B+'),('O+','AB+'),
 ('A-','A-'),('A-','A+'),('A-','AB-'),('A-','AB+'),
 ('A+','A+'),('A+','AB+'),
 ('B-','B-'),('B-','B+'),('B-','AB-'),('B-','AB+'),
 ('B+','B+'),('B+','AB+'),
 ('AB-','AB-'),('AB-','AB+'),
 ('AB+','AB+');

-- ---------- REQUESTS & MATCHING ----------
CREATE TABLE blood_requests (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  requester_id    uuid NOT NULL REFERENCES users(id),
  patient_name    text NOT NULL,
  relationship    text,
  hospital_name   text NOT NULL,
  ward            text,
  hospital_location geography(Point,4326) NOT NULL,
  blood_type      blood_type NOT NULL,
  component       blood_component NOT NULL DEFAULT 'WHOLE_BLOOD',
  units_required  integer NOT NULL CHECK (units_required BETWEEN 1 AND 20),
  units_fulfilled integer NOT NULL DEFAULT 0 CHECK (units_fulfilled >= 0),
  urgency         urgency_level NOT NULL,
  status          request_status NOT NULL DEFAULT 'CREATED',
  needed_by       timestamptz NOT NULL,
  contact_phone   text NOT NULL,
  notes           text,
  assigned_bank_id uuid REFERENCES blood_banks(id),
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now(),
  fulfilled_at    timestamptz
);
CREATE INDEX idx_req_status  ON blood_requests (status, urgency, created_at DESC);
CREATE INDEX idx_req_owner   ON blood_requests (requester_id, created_at DESC);
CREATE INDEX idx_req_loc     ON blood_requests USING GIST (hospital_location);
CREATE TRIGGER trg_req_upd BEFORE UPDATE ON blood_requests FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE request_matches (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id       uuid NOT NULL REFERENCES blood_requests(id) ON DELETE CASCADE,
  donor_id         uuid NOT NULL REFERENCES donors(user_id),
  score            numeric(5,4) NOT NULL,
  compat_score     numeric(5,4) NOT NULL,
  distance_km      numeric(7,2) NOT NULL,
  reliability_score numeric(4,3) NOT NULL,
  status           match_status NOT NULL DEFAULT 'NOTIFIED',
  eta_minutes      integer,
  notified_at      timestamptz NOT NULL DEFAULT now(),
  responded_at     timestamptz,
  UNIQUE (request_id, donor_id)
);
CREATE INDEX idx_match_donor ON request_matches (donor_id, status);
CREATE INDEX idx_match_req   ON request_matches (request_id, score DESC);

-- ---------- DONATIONS ----------
CREATE TABLE donation_camps (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bank_id       uuid NOT NULL REFERENCES blood_banks(id),
  title         text NOT NULL,
  venue         text NOT NULL,
  district      text NOT NULL,
  location      geography(Point,4326) NOT NULL,
  starts_at     timestamptz NOT NULL,
  ends_at       timestamptz NOT NULL CHECK (ends_at > starts_at),
  target_units  integer CHECK (target_units > 0),
  status        camp_status NOT NULL DEFAULT 'UPCOMING',
  created_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_camps_loc  ON donation_camps USING GIST (location);
CREATE INDEX idx_camps_time ON donation_camps (starts_at);

CREATE TABLE camp_registrations (
  camp_id       uuid NOT NULL REFERENCES donation_camps(id) ON DELETE CASCADE,
  donor_id      uuid NOT NULL REFERENCES donors(user_id) ON DELETE CASCADE,
  registered_at timestamptz NOT NULL DEFAULT now(),
  attended      boolean,
  PRIMARY KEY (camp_id, donor_id)
);

CREATE TABLE donations (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  donor_id     uuid NOT NULL REFERENCES donors(user_id),
  request_id   uuid REFERENCES blood_requests(id),
  bank_id      uuid REFERENCES blood_banks(id),
  camp_id      uuid REFERENCES donation_camps(id),
  component    blood_component NOT NULL DEFAULT 'WHOLE_BLOOD',
  volume_ml    integer CHECK (volume_ml BETWEEN 100 AND 600),
  status       donation_status NOT NULL DEFAULT 'SCHEDULED',
  donated_at   timestamptz,
  verified_by  uuid REFERENCES users(id),
  notes        text,
  created_at   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_don_donor ON donations (donor_id, donated_at DESC);

-- ---------- INVENTORY ----------
CREATE TABLE inventory (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bank_id           uuid NOT NULL REFERENCES blood_banks(id) ON DELETE CASCADE,
  blood_type        blood_type NOT NULL,
  component         blood_component NOT NULL DEFAULT 'WHOLE_BLOOD',
  units_available   integer NOT NULL DEFAULT 0 CHECK (units_available >= 0),
  reorder_threshold integer NOT NULL DEFAULT 10 CHECK (reorder_threshold >= 0),
  updated_at        timestamptz NOT NULL DEFAULT now(),
  UNIQUE (bank_id, blood_type, component)
);
CREATE TRIGGER trg_inv_upd BEFORE UPDATE ON inventory FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE inventory_movements (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  bank_id     uuid NOT NULL REFERENCES blood_banks(id),
  blood_type  blood_type NOT NULL,
  component   blood_component NOT NULL,
  delta       integer NOT NULL CHECK (delta <> 0),
  reason      movement_reason NOT NULL,
  donation_id uuid REFERENCES donations(id),
  request_id  uuid REFERENCES blood_requests(id),
  created_by  uuid REFERENCES users(id),
  created_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_mov_bank ON inventory_movements (bank_id, created_at DESC);

-- ---------- AI ----------
CREATE TABLE eligibility_assessments (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  donor_id         uuid NOT NULL REFERENCES donors(user_id) ON DELETE CASCADE,
  answers          jsonb NOT NULL,
  is_eligible      boolean NOT NULL,
  readiness_score  smallint NOT NULL CHECK (readiness_score BETWEEN 0 AND 100),
  reasons          jsonb NOT NULL DEFAULT '[]',
  next_eligible_date date,
  model_version    text NOT NULL,
  assessed_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_elig_donor ON eligibility_assessments (donor_id, assessed_at DESC);

CREATE TABLE demand_history (
  id               bigserial PRIMARY KEY,
  district         text NOT NULL,
  blood_type       blood_type NOT NULL,
  day              date NOT NULL,
  units_requested  integer NOT NULL DEFAULT 0,
  units_fulfilled  integer NOT NULL DEFAULT 0,
  UNIQUE (district, blood_type, day)
);

CREATE TABLE demand_forecasts (
  id              bigserial PRIMARY KEY,
  bank_id         uuid REFERENCES blood_banks(id) ON DELETE CASCADE,
  district        text NOT NULL,
  blood_type      blood_type NOT NULL,
  forecast_date   date NOT NULL,
  predicted_units numeric(8,2) NOT NULL,
  lower_bound     numeric(8,2),
  upper_bound     numeric(8,2),
  model_version   text NOT NULL,
  generated_at    timestamptz NOT NULL DEFAULT now(),
  UNIQUE (bank_id, district, blood_type, forecast_date, model_version)
);

-- ---------- NOTIFICATIONS / ADMIN ----------
CREATE TABLE notifications (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type       text NOT NULL,
  title      text NOT NULL,
  body       text NOT NULL,
  data       jsonb NOT NULL DEFAULT '{}',
  is_read    boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_notif_user ON notifications (user_id, is_read, created_at DESC);

CREATE TABLE awareness_alerts (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id   uuid NOT NULL REFERENCES users(id),
  title      text NOT NULL,
  body       text NOT NULL,
  district   text,                          -- NULL = nationwide
  blood_type blood_type,                    -- NULL = all
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE fraud_flags (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid NOT NULL REFERENCES users(id),
  reported_by uuid REFERENCES users(id),
  reason      text NOT NULL,
  status      flag_status NOT NULL DEFAULT 'OPEN',
  resolved_by uuid REFERENCES users(id),
  created_at  timestamptz NOT NULL DEFAULT now(),
  resolved_at timestamptz
);

CREATE TABLE audit_logs (
  id            bigserial PRIMARY KEY,
  actor_user_id uuid REFERENCES users(id),
  action        text NOT NULL,
  entity_type   text NOT NULL,
  entity_id     text,
  ip            inet,
  meta          jsonb NOT NULL DEFAULT '{}',
  created_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_audit_actor ON audit_logs (actor_user_id, created_at DESC);

-- ---------- FUNCTIONS / VIEWS ----------
-- Candidate donors for a request: compatible, available, past cooldown, within radius.
CREATE OR REPLACE FUNCTION find_candidate_donors(p_request_id uuid, p_radius_km integer DEFAULT 40, p_cooldown_days integer DEFAULT 112)
RETURNS TABLE (donor_id uuid, blood_type blood_type, distance_km numeric, reliability_score numeric, exact_match boolean)
LANGUAGE sql STABLE AS $$
  SELECT d.user_id, d.blood_type,
         round((ST_Distance(d.location, r.hospital_location) / 1000.0)::numeric, 2),
         d.reliability_score,
         (d.blood_type = r.blood_type)
  FROM blood_requests r
  JOIN blood_compatibility bc ON bc.recipient_type = r.blood_type
  JOIN donors d ON d.blood_type = bc.donor_type
  JOIN users u ON u.id = d.user_id AND u.status = 'ACTIVE'
  WHERE r.id = p_request_id
    AND d.is_available
    AND d.location IS NOT NULL
    AND (d.last_donation_date IS NULL OR d.last_donation_date <= current_date - p_cooldown_days)
    AND ST_DWithin(d.location, r.hospital_location, p_radius_km * 1000)
    AND NOT EXISTS (SELECT 1 FROM request_matches m WHERE m.request_id = r.id AND m.donor_id = d.user_id);
$$;

CREATE OR REPLACE VIEW v_bank_stock AS
SELECT bank_id, blood_type, sum(units_available) AS units, bool_or(units_available < reorder_threshold) AS is_low
FROM inventory GROUP BY bank_id, blood_type;
