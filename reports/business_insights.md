# Business Insights

**Project:** E-Commerce Sales & Customer Analytics
**Data window:** January 2022 - December 2023 · **41,262** cleaned order lines · **3,923** unique customers

All figures below come directly from `notebooks/02_eda.ipynb` and
`notebooks/03_customer_segmentation.ipynb`, run on the cleaned dataset. Currency is in Rupees (Rs).

---

### 1. Electronics drives revenue, but not proportional profit

- **Observation:** Electronics is the top revenue category by a wide margin.
- **Evidence:** Electronics generated **Rs 329.9M** in sales (46% of total Rs 715.8M revenue) but only **Rs 17.5M** in profit at a **5.29%** margin - almost identical to the company-wide average margin of 5.30%.
- **Business implication:** Electronics is a volume driver, not a margin driver. The business is heavily dependent on a single, thin-margin category.
- **Recommendation:** Protect Electronics volume (it funds overall revenue) while actively growing higher-margin categories (see Insight 2) to diversify profit sources.

### 2. Clothing and Office Supplies are small but efficient

- **Observation:** The two smallest-revenue categories are the two most profitable per rupee of sales.
- **Evidence:** Clothing converts sales to profit at **13.46%** margin and Office Supplies at **9.47%**, both well above the 5.30% company average, despite contributing only 3.3% and 2.2% of total revenue respectively.
- **Business implication:** There is untapped margin upside if these categories were grown, not just maintained.
- **Recommendation:** Increase marketing spend and product range in Clothing and Office Supplies; they scale profit faster than Electronics per rupee invested.

### 3. Furniture is the weakest category on profitability

- **Observation:** Furniture is the #2 category by revenue but the worst by margin.
- **Evidence:** Furniture generated **Rs 196.0M** in sales (27% of revenue) but only **Rs 2.65M** in profit - a **1.35%** margin, the lowest of all six categories. Both of the only 2 net loss-making products in the entire catalog ("Chairs Political Max", "Tables Professor Max") belong to Furniture.
- **Business implication:** A large share of capital and operational effort is tied up in a category that barely breaks even.
- **Recommendation:** Review Furniture pricing and discount policy specifically (see Insight 4); consider reducing SKU count or renegotiating supplier costs.

### 4. Discounting above ~20% turns orders unprofitable on average

- **Observation:** Profit margin declines steadily as discount level rises, and flips negative on average once discounts pass roughly 20%.
- **Evidence:** Average profit margin by discount tier: **0% discount -> 16.69%**, **1-10% -> 9.73%**, **11-20% -> 1.10%**, **21-30% -> -9.40%**, **30%+ -> -19.86%**. Discounts above 20% (4,204 order lines, ~10% of all orders) are, on average, sold at a loss.
- **Business implication:** Discounting is actively eroding profit once it crosses the ~20% threshold, not just "reducing margin" - many of those orders lose money outright.
- **Recommendation:** Cap standard promotional discounts at 15-20% except for clearly justified clearance/inventory situations, and require margin sign-off for anything above that.

### 5. A small share of customers (Champions) generates the majority of revenue

- **Observation:** The RFM segmentation shows revenue is highly concentrated in the top segment.
- **Evidence:** **Champions** are 22.9% of customers (899 of 3,923) but generate **64.6%** of total historical revenue (Rs 462.7M of Rs 715.8M). The single largest customer alone contributed over Rs 8.9M in sales.
- **Business implication:** The business is significantly dependent on a relatively small, high-value customer base - both an asset (loyalty potential) and a risk (concentration).
- **Recommendation:** Build a formal VIP/loyalty program for Champions with retention as the #1 priority; losing even a handful of these customers would materially impact revenue.

### 6. A meaningful share of the customer base is At Risk or Lost

- **Observation:** Combined, the At Risk, Needs Attention, and Lost segments make up nearly half the customer base but a small share of revenue.
- **Evidence:** **At Risk** (345 customers, 7.7% of revenue), **Needs Attention** (717 customers, 5.4% of revenue) and **Lost Customers** (886 customers, 2.1% of revenue) together represent **49.7%** of all customers but only **15.2%** of total revenue.
- **Business implication:** Nearly half the customer base is disengaged, representing both a retention opportunity and evidence of leaky top-of-funnel-to-loyalty conversion.
- **Recommendation:** Launch targeted win-back campaigns for the At Risk segment specifically (highest revenue-per-customer among the three at-risk groups) before they fully churn to Lost status.

### 7. Repeat purchase rate is strong, but a real one-time-buyer segment exists

- **Observation:** Most customers do return, but roughly 1 in 9 never makes a second purchase.
- **Evidence:** **3,471** customers (88.5%) are repeat buyers (2+ orders) versus **452** (11.5%) one-time buyers.
- **Business implication:** The core retention engine works well overall, so the one-time-buyer segment is likely a specific onboarding/first-purchase-experience gap rather than a systemic problem.
- **Recommendation:** Introduce a structured post-first-purchase follow-up (email/offer sequence) targeted specifically at the 452 one-time buyers to convert them before they age into "Lost."

### 8. Sales peak sharply in the October-November festive season

- **Observation:** Monthly sales show a clear, repeatable seasonal spike in Q4.
- **Evidence:** November had the highest monthly sales at **Rs 78.1M**, followed by October at **Rs 72.6M** - both roughly 40-45% above the lowest month (April, Rs 51.6M). January also shows a secondary spike (Rs 68.5M).
- **Business implication:** Festive-season promotions are working to drive volume, but (per Insight 4) the associated deeper discounts also compress margin during exactly these peak months.
- **Recommendation:** Plan inventory and staffing around the confirmed Oct-Nov-Jan peaks, but model festive discount depth carefully against the margin data in Insight 4 rather than defaulting to the deepest discount tier.

### 9. Region-level performance is balanced - no single weak region

- **Observation:** Unlike category performance, regional performance is fairly even.
- **Evidence:** Sales range narrowly from **Rs 169.5M (West)** to **Rs 185.1M (South)**, and profit margin ranges from **5.12% (North)** to **5.48% (East)** - a spread of only 0.36 percentage points.
- **Business implication:** Regional strategy is not currently a major lever for improving overall profitability; the bigger opportunities lie in category mix and discount policy.
- **Recommendation:** Maintain current regional resource allocation; prioritize the category- and segment-level recommendations above over regional restructuring.

### 10. UPI is the leading payment method

- **Observation:** Digital wallet-style payments dominate over cards and cash.
- **Evidence:** **UPI** accounts for **12,220** order lines (~30% of transactions with a known payment mode), ahead of Credit Card (8,230) and Cash on Delivery (6,090).
- **Business implication:** The customer base is digitally native; checkout and post-purchase experience should be optimized primarily for UPI flows.
- **Recommendation:** Prioritize UPI-specific payment UX (QR/one-tap flows) and monitor UPI-specific transaction failure rates, since it is the single largest payment channel.

---

## Summary table

| Metric | Value |
|---|---|
| Total Revenue | Rs 715,833,822 |
| Total Profit | Rs 37,911,637 |
| Overall Profit Margin | 5.30% |
| Total Orders | 41,262 |
| Total Customers | 3,923 |
| Average Order Value | Rs 17,349 |
| Repeat Customer Rate | 88.5% |
| Revenue from Champions segment | 64.6% |
| Top category by revenue | Electronics (Rs 329.9M) |
| Top category by margin | Clothing (13.46%) |
| Weakest category by margin | Furniture (1.35%) |
