-- this script verifies if the database has been created
SELECT 'adviser'             AS table_name, COUNT(*) AS row_count,  5 AS expected FROM adviser
UNION ALL SELECT 'adviser_licence',     COUNT(*),  9 FROM adviser_licence
UNION ALL SELECT 'client',              COUNT(*), 15 FROM client
UNION ALL SELECT 'compliance_document', COUNT(*), 58 FROM compliance_document
UNION ALL SELECT 'goal',                COUNT(*), 14 FROM goal
UNION ALL SELECT 'provider',            COUNT(*), 12 FROM provider
UNION ALL SELECT 'product',             COUNT(*), 20 FROM product
UNION ALL SELECT 'policy',              COUNT(*), 34 FROM policy
UNION ALL SELECT 'claim',               COUNT(*), 16 FROM claim;

-- Fingerprint: catches edited values, not just missing rows.
-- Expected: total_premium = 40418.00, total_claimed = 548000.00, open_claims = 8
SELECT (SELECT SUM(premium_amount) FROM policy)          AS total_premium,
       (SELECT SUM(claim_amount)   FROM claim)           AS total_claimed,
       (SELECT COUNT(*) FROM claim WHERE closed_date IS NULL) AS open_claims;
