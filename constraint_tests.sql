-- =====================================================================
-- File:     constraint_tests.sql
-- Project:  CSC312 Practical Assignment 2, Clearpoint Financial Advisors
-- Team:     Power Rangers
-- Members:  Rufaro Ruvarashe Chipoyera (4417552), Ketsia Elengemoke-Mbombo (4397468),
--           Amy Felix (4419804), Harrison Ibeh (4276312),
--           Thiana Moodley (4323023), Nephtali Mwamba (4492340)
--
-- Purpose:  Negative tests for section 8. EVERY statement below must FAIL.
--           Run them ONE AT A TIME in Workbench (cursor on the line, then
--           Ctrl+Enter) and screenshot the red error in the Output panel.
--           Nothing is changed when a statement fails, so your data stays
--           identical to everyone else's.
-- =====================================================================

-- T1 (Amy) Foreign key: claim against a policy that does not exist.
-- Expected: Error 1452, fk_claim_policy
INSERT INTO claim (claim_id, policy_id, claim_number, incident_date,
                   incident_description, date_reported, claim_amount)
VALUES (99, 999, 'CLM-2026-099', '2026-10-01', 'Test', '2026-10-02', 1000.00);

-- T2 (Rufaro) CHECK: closed date earlier than the reported date.
-- Expected: Error 3819, ck_claim_closed
INSERT INTO claim (claim_id, policy_id, claim_number, incident_date,
                   incident_description, date_reported, claim_amount,
                   status, closed_date)
VALUES (99, 3, 'CLM-2026-099', '2026-10-01', 'Test', '2026-10-05', 1000.00,
        'Closed', '2026-10-02');

-- T3 (Harrison) Composite primary key: duplicate licence for adviser 1, seq 1.
-- Expected: Error 1062, PRIMARY
INSERT INTO adviser_licence
VALUES (1, 1, 'Investments', 'LIC-9999', '2026-01-01', '2029-01-01');

-- T4 (Ketsia) UNIQUE: a client with an ID number already in use.
-- Expected: Error 1062, uq_client_id_number
INSERT INTO client (client_id, adviser_id, first_name, last_name, id_number,
                    date_of_birth, email, phone, onboarding_date)
VALUES (99, 1, 'Test', 'Duplicate', '8803150234081', '1990-01-01',
        'test@mail.co.za', '0730000000', '2026-10-12');

-- T5 (Thiana) ON DELETE RESTRICT: delete a client who holds policies.
-- Expected: Error 1451, fk_policy_client
DELETE FROM client WHERE client_id = 1;

-- T6 (Nephtali) CHECK: claim amount of zero.
-- Expected: Error 3819, ck_claim_amount
INSERT INTO claim (claim_id, policy_id, claim_number, incident_date,
                   incident_description, date_reported, claim_amount)
VALUES (99, 3, 'CLM-2026-099', '2026-10-01', 'Test', '2026-10-02', 0);

-- Extra tests, if wanted
-- T7 NOT NULL: client without a phone number.        Expected: Error 1048
INSERT INTO client (client_id, adviser_id, first_name, last_name, id_number,
                    date_of_birth, email, phone, onboarding_date)
VALUES (99, 1, 'Test', 'NoPhone', '9001010000000', '1990-01-01',
        'test@mail.co.za', NULL, '2026-10-12');

-- T8 Composite UNIQUE: same product name twice for one provider. Expected: Error 1062
INSERT INTO product VALUES (99, 2, 'Comprehensive Car Cover', 'Insurance', NULL, 100.00);

-- T9 CHECK: mark an open claim Closed without a closed date. Expected: Error 3819, ck_claim_open
UPDATE claim SET status = 'Closed' WHERE claim_id = 13;
