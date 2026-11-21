# Flights Performance Marketing: Channel & Market Analysis (SQL)

**Data:** simulated practice data, not real company data. 1 Jul – 30 Aug 2026, 5 channels × 6 markets × 61 days (1,830 rows).

## Files
- `flights_marketing.db`: SQLite database, ready to open
- `01_schema_and_data.sql`: creates the 3 tables and loads all data (works in any SQL tool)
- `02_analysis_queries.sql`: the 6 analysis queries, with comments

**How to run:** open `flights_marketing.db` in [DB Browser for SQLite](https://sqlitebrowser.org) (free), go to *Execute SQL*, paste a query and run it.

## Tables
| Table | What it holds |
|---|---|
| `channels` | 2 metasearch sites, search ads, social ads, affiliate network |
| `markets` | India, Thailand, Indonesia, Philippines, Vietnam, Australia |
| `daily_performance` | daily impressions, clicks, spend, bookings and net revenue per channel × market |

## Key findings
1. **Metasearch A earns 36% of revenue on 29% of spend.** Affiliate is the most efficient channel (ROAS 2.02, CPA $4.88).
2. **Search Ads takes the largest share of spend (35%) but returns only 29% of revenue** (ROAS 1.14). It loses money in every market except Australia.
3. **Social Ads loses money (ROAS 0.59, CPA $16).** It may still help with awareness, but it shouldn't be judged on last-click bookings alone.
4. **Scaling hurt efficiency.** When August spend went up ~40% on Metasearch A and Search Ads, their ROAS fell (1.83 → 1.58 and 1.23 → 1.07). That's diminishing returns. Weekly ROAS overall slid from 1.42 to 1.29.
5. **Australia is the strongest market.** Every channel there except Social is well above break-even, because revenue per booking is much higher.

## Recommendation
- Move budget out of Search Ads in India, Indonesia and Vietnam, and out of Social Ads in all Asian markets.
- Put it into Australia (metasearch and affiliate) and Thailand affiliate.
- Roll back August's Metasearch A increase until ROAS recovers. Then test spend levels step by step to find where returns start dropping.

## Interview notes (how to explain it)
- **ROAS** = revenue ÷ spend. Above 1 means the channel pays for itself.
- **CPA** = spend ÷ bookings, the cost to win one booking.
- **Q2** uses a *window function* (`SUM() OVER ()`) to get each channel's share of the total without a second query.
- **Q3** uses `RANK() OVER (PARTITION BY market …)` to rank channels within each market.
- **Q4** uses `CASE WHEN` inside `SUM()` to compare July and August side by side.
- **Limitation:** last-click data undervalues upper-funnel channels like social. In a real job I'd check attribution or run an incrementality test before cutting social.
