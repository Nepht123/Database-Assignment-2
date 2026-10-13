-- =====================================================================
-- This script executes business rule 8. Reminders are not stored; they are produced
--           by this query from dates already held on POLICY, ADVISER_LICENCE
--           and CLIENT. Lists every reminder due in the 30 days after the
--           reference date 2026-10-12, plus anything already overdue.
-- =====================================================================
SELECT 'Policy renewal' AS reminder_type,
       CONCAT(a.first_name, ' ', a.last_name) AS adviser,
       CONCAT(c.first_name, ' ', c.last_name, ' - ', p.policy_number) AS regarding,
       DATE_ADD(p.start_date, INTERVAL p.term_months MONTH) AS due_date
FROM policy p
JOIN client  c ON c.client_id  = p.client_id
JOIN adviser a ON a.adviser_id = c.adviser_id
WHERE p.status = 'Active'
  AND DATE_ADD(p.start_date, INTERVAL p.term_months MONTH)
      <= DATE_ADD(DATE '2026-10-12', INTERVAL 30 DAY)
UNION ALL
SELECT 'Licence expiry',
       CONCAT(a.first_name, ' ', a.last_name),
       CONCAT(l.licence_type, ' - ', l.licence_ref),
       l.expiry_date
FROM adviser_licence l
JOIN adviser a ON a.adviser_id = l.adviser_id
WHERE l.expiry_date BETWEEN DATE '2026-10-12'
                        AND DATE_ADD(DATE '2026-10-12', INTERVAL 30 DAY)
UNION ALL
SELECT 'Annual review',
       CONCAT(a.first_name, ' ', a.last_name),
       CONCAT(c.first_name, ' ', c.last_name),
       DATE_ADD(COALESCE(c.last_review_date, c.onboarding_date), INTERVAL 1 YEAR)
FROM client c
JOIN adviser a ON a.adviser_id = c.adviser_id
WHERE DATE_ADD(COALESCE(c.last_review_date, c.onboarding_date), INTERVAL 1 YEAR)
      <= DATE_ADD(DATE '2026-10-12', INTERVAL 30 DAY)
ORDER BY due_date;
