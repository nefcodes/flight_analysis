# Flight Pricing Experiment Analysis (Excel)

**Data:** simulated practice data, not real company data.

**Question:** should we lower the flight service fee from 4.5% to 3.5%? A lower fee raises conversion but earns less per booking.

## Sheets
- **README:** the question and setup
- **Dashboard:** KPIs, 2 charts and the recommendation
- **Assumptions:** fee levels and significance level (blue cells, change them and everything updates)
- **Raw_Data:** 168 rows (14 days × 6 markets × 2 variants)
- **Analysis:** overall and per-market results, built with SUMIFS, a z-test (NORMSDIST) and IF decision rules

## Key findings
- The lower fee raised conversion by **27%** overall, which is statistically significant (p < 0.0001).
- But fee revenue per visitor fell **3.8%** overall. The break-even lift is 28.6% (4.5 ÷ 3.5 − 1), and 27% falls just short.
- Results differ by market:
  - **India (+6%), Indonesia (+10%) and Vietnam (+4%) gain.** These are price-sensitive markets.
  - **Australia (−14%) and Thailand (−9%) lose.**
  - **The Philippines (−2%) is near break-even.**

## Recommendation
- Roll out the 3.5% fee only in India, Indonesia and Vietnam.
- Keep 4.5% in Australia and Thailand.
- Re-test the Philippines at 4.0%.

## Interview notes
- **Why fee revenue per visitor, not conversion?** Conversion alone ignores that each booking now earns less. Revenue per visitor captures both effects.
- **Z-test:** compares two conversion rates and asks whether the gap is bigger than random noise.
- **Segmenting matters:** the overall result says "don't do it," but 3 markets gain. A blanket decision would leave money on the table.
