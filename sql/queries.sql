-- =====================================================================
-- File:     queries.sql
-- Project:  CSC312 Practical Assignment 2
--           Clearpoint Financial Advisors: client, policy and claims database
-- Team:     Power Rangers
-- Members:  Rufaro Ruvarashe Chipoyera (4417552), Ketsia Elengemoke-Mbombo (4397468),
--           Amy Felix (4419804), Harrison Ibeh (4276312),
--           Thiana Moodley (4323023), Nephtali Mwamba (4492340)
--
-- Purpose:  The 10 queries from report section 6 (2 simple, 4 medium,
--           4 complex). Run after schema.sql and data.sql.
--           Every query uses the fixed reference date 2026-10-12 instead of
--           CURDATE(), so all members and the markers get identical results.
--           Each query ends with a semicolon so the script can split them.
-- =====================================================================

-- Q1 (Simple, Amy Felix): WHERE, ORDER BY
-- Which clients live in Cape Town? Listed by surname for a client
-- information evening at the Cape Town office.
SELECT client_id, first_name, last_name, phone,
       address_street, onboarding_date
FROM client
WHERE address_city = 'Cape Town'
ORDER BY last_name, first_name;

-- Q2 (Simple, Rufaro Chipoyera): WHERE with IN, ORDER BY
-- Which claims are still in progress, oldest first? The claims desk works
-- through them in this order so no client waits too long.
SELECT claim_number, policy_id, date_reported, claim_amount, status
FROM claim
WHERE status IN ('Lodged', 'Under Review', 'Approved')
ORDER BY date_reported;

-- Q3 (Medium, Thiana Moodley): INNER JOIN, CONCAT, LIKE
-- Contact list of every client in the Western Cape (postal codes 7xxx and
-- 8xxx) with the adviser responsible for them.
SELECT CONCAT(c.first_name, ' ', c.last_name)  AS client_name,
       c.phone                                  AS client_phone,
       c.address_city                           AS city,
       CONCAT(a.first_name, ' ', a.last_name)  AS adviser_name,
       a.email                                  AS adviser_email
FROM client c
INNER JOIN adviser a ON a.adviser_id = c.adviser_id
WHERE c.address_postal_code LIKE '7%'
   OR c.address_postal_code LIKE '8%'
ORDER BY adviser_name, client_name;

-- Q4 (Medium, Harrison Ibeh): INNER JOIN, COUNT, SUM, AVG, GROUP BY
-- How do insurance and investment products compare in number of active
-- policies, total monthly premium and average premium?
SELECT pr.category,
       COUNT(*)                       AS active_policies,
       SUM(po.premium_amount)         AS total_monthly_premium,
       ROUND(AVG(po.premium_amount), 2) AS avg_premium
FROM policy po
INNER JOIN product pr ON pr.product_id = po.product_id
WHERE po.status = 'Active'
GROUP BY pr.category
ORDER BY total_monthly_premium DESC;

-- Q5 (Medium, Ketsia Elengemoke-Mbombo): subquery in WHERE
-- Which active policies pay more than the average active premium? These are
-- the highest-value policies, which advisers should prioritise at renewal.
SELECT policy_number, client_id, product_id, premium_amount
FROM policy
WHERE status = 'Active'
  AND premium_amount > (SELECT AVG(premium_amount)
                        FROM policy
                        WHERE status = 'Active')
ORDER BY premium_amount DESC, policy_number;

-- Q6 (Medium, Rufaro Chipoyera): LEFT JOIN, IS NULL, DATEDIFF, CONCAT
-- Which clients have not taken out any policy yet, and how many days have
-- passed since they were onboarded? These are sales opportunities.
SELECT CONCAT(c.first_name, ' ', c.last_name) AS client_name,
       c.onboarding_date,
       DATEDIFF(DATE '2026-10-12', c.onboarding_date)
                                              AS days_since_onboarding
FROM client c
LEFT JOIN policy p ON p.client_id = c.client_id
WHERE p.policy_id IS NULL;

-- Q7 (Complex, Amy Felix): 3-table join, SUM, COUNT DISTINCT, HAVING with OR
-- Which providers bring Clearpoint the most active insurance premium,
-- counting only providers with more than R1 500 a month or at least
-- three clients? Used when negotiating commission with providers.
SELECT pv.provider_name,
       COUNT(DISTINCT po.client_id)  AS clients,
       COUNT(po.policy_id)           AS active_policies,
       SUM(po.premium_amount)        AS monthly_premium
FROM provider pv
JOIN product pr ON pr.provider_id = pv.provider_id
JOIN policy  po ON po.product_id  = pr.product_id
WHERE po.status = 'Active'
  AND pr.category = 'Insurance'
GROUP BY pv.provider_id, pv.provider_name
HAVING SUM(po.premium_amount) > 1500
    OR COUNT(DISTINCT po.client_id) >= 3
ORDER BY monthly_premium DESC;

-- Q8 (Complex, Rufaro Chipoyera): 4-table join, DATEDIFF, AVG, MAX, HAVING
-- How quickly does each provider settle claims? Average and longest
-- turnaround in days for closed claims, for providers with at least two
-- closed claims. Slow providers can be raised with them, and advisers can
-- set client expectations.
SELECT pv.provider_name,
       COUNT(*)                         AS closed_claims,
       ROUND(AVG(DATEDIFF(cl.closed_date, cl.date_reported)), 1)
                                        AS avg_days_to_close,
       MAX(DATEDIFF(cl.closed_date, cl.date_reported))
                                        AS longest_days,
       SUM(cl.claim_amount)             AS total_paid_out
FROM claim cl
JOIN policy   po ON po.policy_id   = cl.policy_id
JOIN product  pr ON pr.product_id  = po.product_id
JOIN provider pv ON pv.provider_id = pr.provider_id
WHERE cl.status = 'Closed'
  AND cl.closed_date IS NOT NULL
GROUP BY pv.provider_id, pv.provider_name
HAVING COUNT(*) >= 2
ORDER BY avg_days_to_close DESC;

-- Q9 (Complex, Nephtali Mwamba): 4-table join, nested subquery in HAVING
-- Which advisers' clients have claimed more in total than the average
-- adviser's clients? A high claim book can point to clients being sold
-- the wrong cover, so these advisers' advice is reviewed first.
SELECT
    CONCAT(adviser.first_name, ' ', adviser.last_name) AS adviser_name,
    COUNT(claim.claim_id) AS claims,
    SUM(claim.claim_amount) AS total_claimed

FROM adviser 

  JOIN client ON adviser.adviser_id = client.adviser_id

  JOIN policy ON client.client_id = policy.client_id

  JOIN claim ON policy.policy_id = claim.policy_id

GROUP BY adviser.adviser_id, adviser.first_name, adviser.last_name

HAVING SUM(claim.claim_amount) > (SELECT AVG(adviser_total)
    FROM (
        SELECT SUM(claim.claim_amount) AS adviser_total

        FROM client

        JOIN policy ON client.client_id = policy.client_id

        JOIN claim ON policy.policy_id = claim.policy_id

        GROUP BY client.adviser_id

    ) AS adviser_totals
)
ORDER BY total_claimed DESC;



-- Q10 (Complex, Nephtali Mwamba): 4-table join, IN subquery, AND/OR, HAVING
-- Compliance check: which advisers have a licence that has expired or
-- expires within 60 days, while still managing clients with active
-- policies? FAIS requires advisers to be licensed, so these renewals are
-- urgent.

SELECT
    CONCAT(adviser.first_name, ' ', adviser.last_name) AS adviser_name,

    COUNT(DISTINCT client.client_id) AS clients_with_active_policies,

    COUNT(policy.policy_id) AS active_policies,

    (
        SELECT MIN(adviser_licence.expiry_date)
        FROM adviser_licence
        WHERE adviser_licence.adviser_id = adviser.adviser_id
          AND adviser_licence.expiry_date <=
              DATE_ADD(DATE '2026-10-12', INTERVAL 60 DAY)
    ) AS earliest_problem_licence

FROM adviser

JOIN client
    ON adviser.adviser_id = client.adviser_id

JOIN policy
    ON client.client_id = policy.client_id

WHERE policy.status = 'Active'

    AND adviser.adviser_id IN (
        SELECT adviser_licence.adviser_id
        FROM adviser_licence
        WHERE adviser_licence.expiry_date < DATE '2026-10-12'

           OR (
                adviser_licence.expiry_date >= DATE '2026-10-12'
                AND adviser_licence.expiry_date <=
                    DATE_ADD(DATE '2026-10-12', INTERVAL 60 DAY)
           )
    )

GROUP BY
    adviser.adviser_id,
    adviser.first_name,
    adviser.last_name

HAVING COUNT(policy.policy_id) >= 1

ORDER BY earliest_problem_licence;
