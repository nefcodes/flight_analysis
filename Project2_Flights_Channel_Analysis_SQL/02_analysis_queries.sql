-- =====================================================================
-- Flights Performance Marketing: Channel & Market Analysis
-- Database: flights_marketing.db (SIMULATED data, 1 Jul - 30 Aug 2026)
-- Goal: find which channels and markets earn the most per dollar spent,
--       check whether scaling spend in August hurt efficiency, and
--       suggest where to move budget.
-- Key metrics:
--   CTR  = clicks / impressions
--   CVR  = bookings / clicks
--   CPA  = spend / bookings          (cost to win one booking)
--   ROAS = revenue / spend           (revenue per $1 of spend, above 1 = profitable)
-- =====================================================================

-- Q1. Overall performance by channel
SELECT c.channel_name,
       c.channel_type,
       ROUND(SUM(p.spend_usd), 0)                                   AS spend_usd,
       SUM(p.bookings)                                              AS bookings,
       ROUND(SUM(p.revenue_usd), 0)                                 AS revenue_usd,
       ROUND(100.0 * SUM(p.clicks) / SUM(p.impressions), 2)         AS ctr_pct,
       ROUND(100.0 * SUM(p.bookings) / SUM(p.clicks), 2)            AS cvr_pct,
       ROUND(SUM(p.spend_usd) / SUM(p.bookings), 2)                 AS cpa_usd,
       ROUND(SUM(p.revenue_usd) / SUM(p.spend_usd), 2)              AS roas
FROM daily_performance p
JOIN channels c ON c.channel_id = p.channel_id
GROUP BY c.channel_name, c.channel_type
ORDER BY roas DESC;

-- Q2. Share of spend vs share of revenue by channel
--     (a channel taking more spend share than revenue share is a budget drain)
WITH ch AS (
  SELECT channel_id, SUM(spend_usd) AS spend, SUM(revenue_usd) AS revenue
  FROM daily_performance GROUP BY channel_id
)
SELECT c.channel_name,
       ROUND(100.0 * spend   / SUM(spend)   OVER (), 1) AS spend_share_pct,
       ROUND(100.0 * revenue / SUM(revenue) OVER (), 1) AS revenue_share_pct
FROM ch JOIN channels c USING (channel_id)
ORDER BY spend_share_pct DESC;

-- Q3. ROAS for every market x channel, with the best channel ranked 1 in each market
SELECT m.market_name,
       c.channel_name,
       ROUND(SUM(p.revenue_usd) / SUM(p.spend_usd), 2) AS roas,
       RANK() OVER (PARTITION BY m.market_name
                    ORDER BY SUM(p.revenue_usd) / SUM(p.spend_usd) DESC) AS rank_in_market
FROM daily_performance p
JOIN channels c ON c.channel_id  = p.channel_id
JOIN markets  m ON m.market_code = p.market_code
GROUP BY m.market_name, c.channel_name
ORDER BY m.market_name, rank_in_market;

-- Q4. Did scaling up spend in August reduce efficiency? (July vs August)
SELECT c.channel_name,
       ROUND(SUM(CASE WHEN p.perf_date <  '2026-08-01' THEN p.spend_usd END), 0) AS jul_spend,
       ROUND(SUM(CASE WHEN p.perf_date >= '2026-08-01' THEN p.spend_usd END), 0) AS aug_spend,
       ROUND(SUM(CASE WHEN p.perf_date <  '2026-08-01' THEN p.revenue_usd END)
           / SUM(CASE WHEN p.perf_date <  '2026-08-01' THEN p.spend_usd END), 2) AS jul_roas,
       ROUND(SUM(CASE WHEN p.perf_date >= '2026-08-01' THEN p.revenue_usd END)
           / SUM(CASE WHEN p.perf_date >= '2026-08-01' THEN p.spend_usd END), 2) AS aug_roas
FROM daily_performance p
JOIN channels c ON c.channel_id = p.channel_id
GROUP BY c.channel_name
ORDER BY c.channel_name;

-- Q5. Weekly trend of spend, bookings and ROAS (for a dashboard line chart)
SELECT strftime('%Y-W%W', perf_date)                 AS week,
       ROUND(SUM(spend_usd), 0)                      AS spend_usd,
       SUM(bookings)                                 AS bookings,
       ROUND(SUM(revenue_usd) / SUM(spend_usd), 2)   AS roas
FROM daily_performance
GROUP BY week
ORDER BY week;

-- Q6. Budget reallocation candidates
--     Flag market x channel pairs as:
--       'Scale up'   ROAS >= 1.8 (well above break-even)
--       'Cut / fix'  ROAS <  1.0 (losing money)
--       'Hold'       everything in between
SELECT m.market_name,
       c.channel_name,
       ROUND(SUM(p.spend_usd), 0)                       AS spend_usd,
       ROUND(SUM(p.revenue_usd) / SUM(p.spend_usd), 2)  AS roas,
       CASE WHEN SUM(p.revenue_usd) / SUM(p.spend_usd) >= 1.8 THEN 'Scale up'
            WHEN SUM(p.revenue_usd) / SUM(p.spend_usd) <  1.0 THEN 'Cut / fix'
            ELSE 'Hold' END                             AS action
FROM daily_performance p
JOIN channels c ON c.channel_id  = p.channel_id
JOIN markets  m ON m.market_code = p.market_code
GROUP BY m.market_name, c.channel_name
HAVING action <> 'Hold'
ORDER BY action DESC, roas DESC;
