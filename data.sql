-- =====================================================================
-- File:     data.sql
-- Project:  CSC312 Practical Assignment 2
--           Clearpoint Financial Advisors: client, policy and claims database
-- Team:     Power Rangers
-- Members:  Rufaro Ruvarashe Chipoyera (4417552)
--           Ketsia Elengemoke-Mbombo   (4397468)
--           Amy Felix                  (4419804)
--           Harrison Ibeh              (4276312)
--           Thiana Moodley             (4323023)
--           Nephtali Mwamba            (4492340)
--
-- Loads the fixed sample data. 
--
-- Rules so all six databases stay identical:
--   * Every primary key value and every date is fixed. Do not edit rows
--     by hand; send changes to Amy, who updates this file for everyone.
--   * REFERENCE DATE for "today" in all queries: 2026-10-12.
--     Use DATE '2026-10-12' instead of CURDATE() so everyone gets the
--     same results and the report screenshots stay correct.
--   * All companies and people are fictional.
--
-- Planted edge cases (useful for LEFT JOIN, subquery and HAVING queries):
--   * Client 15 has no policies; clients 3, 14 and 15 have no goals.
--   * Products 19 and 20 (providers 11 and 12) have never been sold.
--   * Client 7 holds product 3 twice (policies 19 and 34): this is why
--     POLICY uses a surrogate key.
--   * Open claims (status not Closed, so no closed_date): 4, 7, 9, 10,
--     11, 13, 15, 16. Claims 11 and 15 were Rejected.
--   * Policy 3 has two claims; most policies have none.
--   * Licences LIC-1002 and LIC-3002 expire within 30 days of the
--     reference date; LIC-4002 has already expired.
--   * Policies 3, 7, 27 and 30 renew within 30 days of the reference date.
--   * Clients 2 and 7 are overdue for their annual review; clients
--     3, 6, 13, 14 and 15 have never been reviewed (last_review_date NULL).
--   * Clients 3 and 11 have no address (optional attribute).
-- =====================================================================


-- ADVISER: 5 rows. Parent table.
INSERT INTO adviser (adviser_id, first_name, last_name, email, phone, hire_date) VALUES
    (1, 'Thandiwe', 'Nkosi', 'thandiwe.nkosi@clearpoint.co.za', '0821234501', '2015-03-02'),
    (2, 'Pieter', 'van der Merwe', 'pieter.vandermerwe@clearpoint.co.za', '0821234502', '2017-08-14'),
    (3, 'Ayesha', 'Patel', 'ayesha.patel@clearpoint.co.za', '0821234503', '2019-01-07'),
    (4, 'Sipho', 'Dlamini', 'sipho.dlamini@clearpoint.co.za', '0821234504', '2021-06-01'),
    (5, 'Megan', 'Daniels', 'megan.daniels@clearpoint.co.za', '0821234505', '2023-02-13');

-- ADVISER_LICENCE: 9 rows. Weak entity; every adviser has at least one.
INSERT INTO adviser_licence (adviser_id, licence_seq, licence_type, licence_ref, issue_date, expiry_date) VALUES
    (1, 1, 'Long-term Insurance', 'LIC-1001', '2024-03-01', '2027-02-28'),
    (1, 2, 'Investments', 'LIC-1002', '2023-11-01', '2026-10-31'),
    (2, 1, 'Short-term Insurance', 'LIC-2001', '2025-01-15', '2028-01-14'),
    (2, 2, 'Long-term Insurance', 'LIC-2002', '2024-07-01', '2027-06-30'),
    (3, 1, 'Investments', 'LIC-3001', '2025-05-01', '2028-04-30'),
    (3, 2, 'Long-term Insurance', 'LIC-3002', '2023-10-20', '2026-10-19'),
    (4, 1, 'Long-term Insurance', 'LIC-4001', '2024-06-01', '2027-05-31'),
    (4, 2, 'Short-term Insurance', 'LIC-4002', '2022-06-01', '2025-05-31'),
    (5, 1, 'Short-term Insurance', 'LIC-5001', '2025-02-13', '2028-02-12');

-- CLIENT: 15 rows. Each client has exactly one adviser.
INSERT INTO client (client_id, adviser_id, first_name, last_name, id_number, date_of_birth, email, phone, address_street, address_city, address_postal_code, onboarding_date, last_review_date) VALUES
    (1, 1, 'Lerato', 'Mokoena', '8803150234081', '1988-03-15', 'lerato.mokoena@mail.co.za', '0731100001', '14 Kloof Street, Gardens', 'Cape Town', '8001', '2019-04-10', '2025-11-05'),
    (2, 1, 'Johan', 'Botha', '7509225123085', '1975-09-22', 'johan.botha@mail.co.za', '0731100002', '3 Vine Road', 'Durbanville', '7550', '2018-02-01', '2025-08-20'),
    (3, 1, 'Nomvula', 'Zulu', '9201110456082', '1992-01-11', 'nomvula.zulu@mail.co.za', '0731100003', NULL, NULL, NULL, '2024-09-03', NULL),
    (4, 2, 'David', 'Naidoo', '8106305678089', '1981-06-30', 'david.naidoo@mail.co.za', '0731100004', '27 Musgrave Road, Berea', 'Durban', '4001', '2017-05-22', '2026-05-10'),
    (5, 2, 'Fatima', 'Hendricks', '8512240789083', '1985-12-24', 'fatima.hendricks@mail.co.za', '0731100005', '9 Bree Street', 'Cape Town', '8001', '2020-01-15', '2026-01-20'),
    (6, 2, 'Kagiso', 'Molefe', '9907085234087', '1999-07-08', 'kagiso.molefe@mail.co.za', '0731100006', '45 Jan Smuts Avenue, Rosebank', 'Johannesburg', '2196', '2025-03-03', NULL),
    (7, 3, 'Chloe', 'Smith', '9004020345088', '1990-04-02', 'chloe.smith@mail.co.za', '0731100007', '6 Main Road, Rondebosch', 'Cape Town', '7700', '2016-11-11', '2025-10-01'),
    (8, 3, 'Themba', 'Khumalo', '7802145789081', '1978-02-14', 'themba.khumalo@mail.co.za', '0731100008', '120 Oxford Road, Illovo', 'Johannesburg', '2196', '2018-07-30', '2026-07-15'),
    (9, 3, 'Priya', 'Govender', '8709290123084', '1987-09-29', 'priya.govender@mail.co.za', '0731100009', '33 Florida Road, Morningside', 'Durban', '4001', '2021-08-16', '2026-03-02'),
    (10, 4, 'Michael', 'Jacobs', '6911055678082', '1969-11-05', 'michael.jacobs@mail.co.za', '0731100010', '18 Church Street', 'Stellenbosch', '7600', '2015-06-01', '2026-02-18'),
    (11, 4, 'Zanele', 'Mthembu', '9403300456086', '1994-03-30', 'zanele.mthembu@mail.co.za', '0731100011', NULL, NULL, NULL, '2023-01-09', '2025-12-12'),
    (12, 4, 'Ruan', 'Pretorius', '8308185123089', '1983-08-18', 'ruan.pretorius@mail.co.za', '0731100012', '5 Lynnwood Road', 'Pretoria', '0081', '2019-10-28', '2026-09-30'),
    (13, 5, 'Aisha', 'Abrahams', '0105120234080', '2001-05-12', 'aisha.abrahams@mail.co.za', '0731100013', '71 Long Street', 'Cape Town', '8001', '2026-06-15', NULL),
    (14, 5, 'Brandon', 'Williams', '9612015789085', '1996-12-01', 'brandon.williams@mail.co.za', '0731100014', '2 Beach Road, Sea Point', 'Cape Town', '8005', '2025-11-20', NULL),
    (15, 5, 'Naledi', 'Sithole', '9808240456083', '1998-08-24', 'naledi.sithole@mail.co.za', '0731100015', '88 Voortrekker Road', 'Bellville', '7530', '2026-09-01', NULL);

-- COMPLIANCE_DOCUMENT: 58 rows. Weak entity; every client has at least one.
INSERT INTO compliance_document (client_id, document_no, document_type, signed_date, file_reference) VALUES
    (1, 1, 'FICA ID Verification', '2019-04-10', 'DOCS/C001/01.pdf'),
    (1, 2, 'POPIA Consent', '2019-04-10', 'DOCS/C001/02.pdf'),
    (1, 3, 'Proof of Address', '2019-04-10', 'DOCS/C001/03.pdf'),
    (1, 4, 'FAIS Disclosure', '2019-04-10', 'DOCS/C001/04.pdf'),
    (2, 1, 'FICA ID Verification', '2018-02-01', 'DOCS/C002/01.pdf'),
    (2, 2, 'POPIA Consent', '2018-02-01', 'DOCS/C002/02.pdf'),
    (2, 3, 'Proof of Address', '2018-02-01', 'DOCS/C002/03.pdf'),
    (2, 4, 'FAIS Disclosure', '2018-02-01', 'DOCS/C002/04.pdf'),
    (3, 1, 'FICA ID Verification', '2024-09-03', 'DOCS/C003/01.pdf'),
    (3, 2, 'POPIA Consent', '2024-09-03', 'DOCS/C003/02.pdf'),
    (3, 3, 'FAIS Disclosure', '2024-09-03', 'DOCS/C003/03.pdf'),
    (4, 1, 'FICA ID Verification', '2017-05-22', 'DOCS/C004/01.pdf'),
    (4, 2, 'POPIA Consent', '2017-05-22', 'DOCS/C004/02.pdf'),
    (4, 3, 'Proof of Address', '2017-05-22', 'DOCS/C004/03.pdf'),
    (4, 4, 'FAIS Disclosure', '2017-05-22', 'DOCS/C004/04.pdf'),
    (5, 1, 'FICA ID Verification', '2020-01-15', 'DOCS/C005/01.pdf'),
    (5, 2, 'POPIA Consent', '2020-01-15', 'DOCS/C005/02.pdf'),
    (5, 3, 'Proof of Address', '2020-01-15', 'DOCS/C005/03.pdf'),
    (5, 4, 'FAIS Disclosure', '2020-01-15', 'DOCS/C005/04.pdf'),
    (6, 1, 'FICA ID Verification', '2025-03-03', 'DOCS/C006/01.pdf'),
    (6, 2, 'POPIA Consent', '2025-03-03', 'DOCS/C006/02.pdf'),
    (6, 3, 'Proof of Address', '2025-03-03', 'DOCS/C006/03.pdf'),
    (6, 4, 'FAIS Disclosure', '2025-03-03', 'DOCS/C006/04.pdf'),
    (7, 1, 'FICA ID Verification', '2016-11-11', 'DOCS/C007/01.pdf'),
    (7, 2, 'POPIA Consent', '2016-11-11', 'DOCS/C007/02.pdf'),
    (7, 3, 'Proof of Address', '2016-11-11', 'DOCS/C007/03.pdf'),
    (7, 4, 'FAIS Disclosure', '2016-11-11', 'DOCS/C007/04.pdf'),
    (8, 1, 'FICA ID Verification', '2018-07-30', 'DOCS/C008/01.pdf'),
    (8, 2, 'POPIA Consent', '2018-07-30', 'DOCS/C008/02.pdf'),
    (8, 3, 'Proof of Address', '2018-07-30', 'DOCS/C008/03.pdf'),
    (8, 4, 'FAIS Disclosure', '2018-07-30', 'DOCS/C008/04.pdf'),
    (9, 1, 'FICA ID Verification', '2021-08-16', 'DOCS/C009/01.pdf'),
    (9, 2, 'POPIA Consent', '2021-08-16', 'DOCS/C009/02.pdf'),
    (9, 3, 'Proof of Address', '2021-08-16', 'DOCS/C009/03.pdf'),
    (9, 4, 'FAIS Disclosure', '2021-08-16', 'DOCS/C009/04.pdf'),
    (10, 1, 'FICA ID Verification', '2015-06-01', 'DOCS/C010/01.pdf'),
    (10, 2, 'POPIA Consent', '2015-06-01', 'DOCS/C010/02.pdf'),
    (10, 3, 'Proof of Address', '2015-06-01', 'DOCS/C010/03.pdf'),
    (10, 4, 'FAIS Disclosure', '2015-06-01', 'DOCS/C010/04.pdf'),
    (11, 1, 'FICA ID Verification', '2023-01-09', 'DOCS/C011/01.pdf'),
    (11, 2, 'POPIA Consent', '2023-01-09', 'DOCS/C011/02.pdf'),
    (11, 3, 'FAIS Disclosure', '2023-01-09', 'DOCS/C011/03.pdf'),
    (12, 1, 'FICA ID Verification', '2019-10-28', 'DOCS/C012/01.pdf'),
    (12, 2, 'POPIA Consent', '2019-10-28', 'DOCS/C012/02.pdf'),
    (12, 3, 'Proof of Address', '2019-10-28', 'DOCS/C012/03.pdf'),
    (12, 4, 'FAIS Disclosure', '2019-10-28', 'DOCS/C012/04.pdf'),
    (13, 1, 'FICA ID Verification', '2026-06-15', 'DOCS/C013/01.pdf'),
    (13, 2, 'POPIA Consent', '2026-06-15', 'DOCS/C013/02.pdf'),
    (13, 3, 'Proof of Address', '2026-06-15', 'DOCS/C013/03.pdf'),
    (13, 4, 'FAIS Disclosure', '2026-06-15', 'DOCS/C013/04.pdf'),
    (14, 1, 'FICA ID Verification', '2025-11-20', 'DOCS/C014/01.pdf'),
    (14, 2, 'POPIA Consent', '2025-11-20', 'DOCS/C014/02.pdf'),
    (14, 3, 'Proof of Address', '2025-11-20', 'DOCS/C014/03.pdf'),
    (14, 4, 'FAIS Disclosure', '2025-11-20', 'DOCS/C014/04.pdf'),
    (15, 1, 'FICA ID Verification', '2026-09-01', 'DOCS/C015/01.pdf'),
    (15, 2, 'POPIA Consent', '2026-09-01', 'DOCS/C015/02.pdf'),
    (15, 3, 'Proof of Address', '2026-09-01', 'DOCS/C015/03.pdf'),
    (15, 4, 'FAIS Disclosure', '2026-09-01', 'DOCS/C015/04.pdf');

-- GOAL: 14 rows. Zero or more per client.
INSERT INTO goal (goal_id, client_id, goal_type, description, target_amount, target_date, status) VALUES
    (1, 1, 'Retirement', 'Retire at 60 with R6 million capital', 6000000.00, '2048-03-15', 'Active'),
    (2, 1, 'Education', 'Fund daughter''s university fees', 450000.00, '2032-01-31', 'Active'),
    (3, 2, 'Retirement', 'Supplement pension income', 2500000.00, '2035-09-30', 'Active'),
    (4, 4, 'Property', 'Deposit for a holiday home', 400000.00, '2027-12-31', 'Active'),
    (5, 5, 'Wealth', 'Emergency fund of six months'' expenses', 120000.00, '2025-12-31', 'Achieved'),
    (6, 6, 'Wealth', 'Start investing monthly', NULL, '2027-06-30', 'Active'),
    (7, 7, 'Protection', 'Keep the family covered if income stops', NULL, '2026-12-31', 'Active'),
    (8, 8, 'Retirement', 'Retire early at 55', 8000000.00, '2033-02-14', 'Active'),
    (9, 9, 'Education', 'Postgraduate study fund', 200000.00, '2028-01-15', 'Active'),
    (10, 10, 'Retirement', 'Preserve capital in retirement', NULL, '2034-11-05', 'Active'),
    (11, 11, 'Property', 'Buy a first home', 350000.00, '2028-06-30', 'Active'),
    (12, 12, 'Wealth', 'Grow an offshore portfolio', 1000000.00, '2031-08-18', 'Active'),
    (13, 13, 'Wealth', 'Save for a car', 80000.00, '2027-03-31', 'Active'),
    (14, 4, 'Education', 'Son''s private schooling', 600000.00, '2030-01-15', 'Abandoned');

-- PROVIDER: 12 rows. About a dozen providers, as in the scenario.
INSERT INTO provider (provider_id, provider_name, fsp_number, contact_email, contact_phone) VALUES
    (1, 'Harbourline Life', '40211', 'info@harbourlinelife.co.za', '0215550101'),
    (2, 'Protea Assurance', '40387', 'claims@proteaassurance.co.za', '0115550102'),
    (3, 'Table Bay Investments', '40452', 'invest@tablebayinv.co.za', '0215550103'),
    (4, 'Karoo Mutual', '40519', 'service@karoomutual.co.za', '0515550104'),
    (5, 'Summit Short-Term Insurance', '40633', 'help@summitsti.co.za', '0315550105'),
    (6, 'Baobab Wealth Managers', '40778', 'clients@baobabwealth.co.za', NULL),
    (7, 'Kestrel Health Cover', '40815', 'members@kestrelhealth.co.za', '0115550107'),
    (8, 'Meridian Life & Savings', '40962', 'info@meridianlife.co.za', '0125550108'),
    (9, 'Fynbos Insure', '41027', 'claims@fynbosinsure.co.za', '0215550109'),
    (10, 'Highveld Asset Management', '41144', 'invest@highveldam.co.za', NULL),
    (11, 'Cape Point Assurance', '41290', 'info@capepointassure.co.za', '0215550111'),
    (12, 'Amber Retirement Funds', '41365', 'funds@amberretire.co.za', '0115550112');

-- PRODUCT: 20 rows. Each provider offers at least one product.
INSERT INTO product (product_id, provider_id, product_name, category, description, base_premium) VALUES
    (1, 1, 'Premium Life Cover', 'Insurance', 'Whole-life cover with level premiums', 650.00),
    (2, 1, 'Funeral Plan Plus', 'Insurance', 'Family funeral cover up to R50 000', 189.00),
    (3, 2, 'Comprehensive Car Cover', 'Insurance', 'Accident, theft and third-party cover for one vehicle', 1250.00),
    (4, 2, 'Home Contents Cover', 'Insurance', 'Cover for household contents against theft and damage', 420.00),
    (5, 3, 'Balanced Unit Trust', 'Investment', 'Monthly debit order into a balanced fund', 1000.00),
    (6, 3, 'Tax-Free Savings Account', 'Investment', 'Tax-free investment within annual limits', 3000.00),
    (7, 4, 'Disability Income Protector', 'Insurance', 'Monthly income if unable to work', 540.00),
    (8, 4, 'Critical Illness Cover', 'Insurance', 'Lump sum on diagnosis of a listed illness', 380.00),
    (9, 5, 'Household Buildings Cover', 'Insurance', 'Cover for the structure of the home', 610.00),
    (10, 5, 'Business Liability Cover', 'Insurance', 'Public liability cover for small businesses', 980.00),
    (11, 6, 'Retirement Annuity', 'Investment', 'Tax-deductible retirement savings', 2500.00),
    (12, 6, 'Endowment Plan', 'Investment', 'Fixed-term savings with a lump-sum payout', 1500.00),
    (13, 7, 'Hospital Plan', 'Insurance', 'In-hospital medical cover', 1450.00),
    (14, 7, 'Gap Cover', 'Insurance', 'Covers specialist shortfalls not paid by medical aid', 310.00),
    (15, 8, 'Education Savings Plan', 'Investment', 'Savings plan for tertiary education costs', 800.00),
    (16, 8, 'Term Life Cover', 'Insurance', 'Life cover for a fixed term', 290.00),
    (17, 9, 'Vehicle Tracking & Theft Cover', 'Insurance', 'Tracking device with theft-only cover', 230.00),
    (18, 10, 'Global Equity Fund', 'Investment', 'Offshore equity unit trust', 2000.00),
    (19, 11, 'Travel Insurance Annual', 'Insurance', 'Annual multi-trip travel cover', 150.00),
    (20, 12, 'Preservation Fund', 'Investment', 'Preserves retirement savings when changing jobs', 5000.00);

-- POLICY: 34 rows. Bridge between CLIENT and PRODUCT.
INSERT INTO policy (policy_id, client_id, product_id, policy_number, start_date, term_months, premium_amount, status) VALUES
    (1, 1, 1, 'CP-100001', '2019-05-01', 240, 680.00, 'Active'),
    (2, 1, 5, 'CP-100002', '2019-05-01', 120, 1000.00, 'Active'),
    (3, 1, 3, 'CP-100003', '2025-11-01', 12, 1310.00, 'Active'),
    (4, 2, 16, 'CP-100004', '2018-03-01', 240, 310.00, 'Active'),
    (5, 2, 11, 'CP-100005', '2018-03-01', 300, 3000.00, 'Active'),
    (6, 2, 9, 'CP-100006', '2026-01-01', 12, 640.00, 'Active'),
    (7, 3, 2, 'CP-100007', '2024-10-25', 24, 189.00, 'Active'),
    (8, 4, 3, 'CP-100008', '2026-03-01', 12, 1420.00, 'Active'),
    (9, 4, 4, 'CP-100009', '2026-03-01', 12, 450.00, 'Active'),
    (10, 4, 12, 'CP-100010', '2017-06-01', 120, 1500.00, 'Active'),
    (11, 4, 15, 'CP-100011', '2017-06-01', 180, 900.00, 'Active'),
    (12, 5, 13, 'CP-100012', '2026-01-01', 12, 1520.00, 'Active'),
    (13, 5, 14, 'CP-100013', '2026-01-01', 12, 330.00, 'Active'),
    (14, 5, 6, 'CP-100014', '2020-02-01', 120, 3000.00, 'Active'),
    (15, 6, 17, 'CP-100015', '2025-11-15', 12, 230.00, 'Active'),
    (16, 6, 18, 'CP-100016', '2025-04-01', 60, 2000.00, 'Active'),
    (17, 7, 1, 'CP-100017', '2017-01-01', 240, 720.00, 'Active'),
    (18, 7, 7, 'CP-100018', '2024-01-01', 36, 560.00, 'Active'),
    (19, 7, 3, 'CP-100019', '2023-06-01', 12, 1180.00, 'Cancelled'),
    (20, 8, 8, 'CP-100020', '2019-08-01', 120, 395.00, 'Active'),
    (21, 8, 11, 'CP-100021', '2018-08-01', 240, 4000.00, 'Active'),
    (22, 8, 10, 'CP-100022', '2026-04-01', 12, 1020.00, 'Active'),
    (23, 9, 13, 'CP-100023', '2026-02-01', 12, 1480.00, 'Active'),
    (24, 9, 16, 'CP-100024', '2021-09-01', 120, 275.00, 'Active'),
    (25, 10, 1, 'CP-100025', '2015-07-01', 240, 640.00, 'Active'),
    (26, 10, 11, 'CP-100026', '2015-07-01', 120, 2500.00, 'Expired'),
    (27, 10, 9, 'CP-100027', '2025-10-20', 12, 600.00, 'Active'),
    (28, 11, 2, 'CP-100028', '2023-02-01', 36, 199.00, 'Lapsed'),
    (29, 12, 18, 'CP-100029', '2020-01-01', 120, 2200.00, 'Active'),
    (30, 12, 7, 'CP-100030', '2024-11-01', 24, 520.00, 'Active'),
    (31, 13, 6, 'CP-100031', '2026-07-01', 60, 3000.00, 'Active'),
    (32, 13, 3, 'CP-100032', '2026-07-01', 12, 1150.00, 'Active'),
    (33, 14, 17, 'CP-100033', '2025-12-01', 12, 240.00, 'Active'),
    (34, 7, 3, 'CP-100034', '2025-12-01', 12, 1260.00, 'Active');

-- CLAIM: 16 rows. Zero or more per policy.
INSERT INTO claim (claim_id, policy_id, claim_number, incident_date, incident_description, date_reported, claim_amount, status, closed_date) VALUES
    (1, 3, 'CLM-2025-001', '2025-12-14', 'Rear-end collision on the N1; bumper and boot damaged', '2025-12-15', 18500.00, 'Closed', '2026-01-20'),
    (2, 6, 'CLM-2026-002', '2026-03-02', 'Burst geyser flooded the ceiling', '2026-03-02', 24300.00, 'Closed', '2026-03-30'),
    (3, 8, 'CLM-2026-003', '2026-04-18', 'Windscreen cracked by a stone', '2026-04-19', 4200.00, 'Closed', '2026-04-25'),
    (4, 9, 'CLM-2026-004', '2026-05-07', 'Laptop and television stolen in a burglary', '2026-05-08', 31000.00, 'Approved', NULL),
    (5, 12, 'CLM-2026-005', '2026-02-10', 'Emergency appendectomy', '2026-02-12', 68000.00, 'Closed', '2026-03-15'),
    (6, 13, 'CLM-2026-006', '2026-02-10', 'Specialist shortfall for appendectomy', '2026-02-20', 9400.00, 'Closed', '2026-03-25'),
    (7, 18, 'CLM-2026-007', '2026-06-01', 'Back injury; unable to work for three months', '2026-06-05', 45000.00, 'Under Review', NULL),
    (8, 19, 'CLM-2023-008', '2023-09-10', 'Side-swiped in a parking lot', '2023-09-11', 7800.00, 'Closed', '2023-10-02'),
    (9, 22, 'CLM-2026-009', '2026-07-14', 'Customer slipped on a wet floor at the shop', '2026-07-15', 52000.00, 'Lodged', NULL),
    (10, 23, 'CLM-2026-010', '2026-08-03', 'Knee arthroscopy', '2026-08-05', 41000.00, 'Approved', NULL),
    (11, 27, 'CLM-2025-011', '2025-11-30', 'Storm damage to the roof', '2025-12-01', 37500.00, 'Rejected', NULL),
    (12, 15, 'CLM-2026-012', '2026-01-25', 'Vehicle stolen from a shopping centre', '2026-01-25', 165000.00, 'Closed', '2026-04-10'),
    (13, 34, 'CLM-2026-013', '2026-09-20', 'Hail damage to bonnet and roof', '2026-09-21', 12600.00, 'Lodged', NULL),
    (14, 33, 'CLM-2026-014', '2026-03-03', 'Attempted theft; ignition damaged', '2026-03-04', 6800.00, 'Closed', '2026-03-20'),
    (15, 30, 'CLM-2025-015', '2025-12-10', 'Recovery after hand surgery', '2025-12-15', 22000.00, 'Rejected', NULL),
    (16, 3, 'CLM-2026-016', '2026-08-08', 'Side mirror broken', '2026-08-09', 2900.00, 'Under Review', NULL);
