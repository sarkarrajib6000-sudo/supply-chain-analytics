# Key Findings — Full Query Results

Source: `sql/02_business_queries.sql` run against `data/supply_chain.db`
(10,000-row DataCo sample, Jan 2015 – Jan 2018).

## Q1. Late-delivery risk by shipping mode

| Shipping Mode | Shipments | Late Risk % | Avg Delay (days) |
|---|---|---|---|
| First Class | 1,155 | 99.7% | 1.00 |
| Second Class | 2,074 | 79.9% | 2.01 |
| Same Day | 143 | 56.6% | 0.59 |
| Standard Class | 6,628 | 37.5% | -0.02 |

**Takeaway**: Standard Class is the most reliable mode. First and Second
Class — the paid upgrades — are markedly less reliable, which is
counter-intuitive and worth flagging to whoever owns the carrier contract.

## Q2. Top 10 regions by late-delivery risk

| Region | Shipments | Late Risk % |
|---|---|---|
| Northern Europe | 518 | 66.2% |
| East Africa | 83 | 65.1% |
| Southern Africa | 51 | 60.8% |
| Southern Europe | 523 | 59.5% |
| Western Europe | 1,423 | 58.7% |
| Central Asia | 43 | 58.1% |
| Eastern Europe | 236 | 56.8% |
| Central Africa | 84 | 56.0% |
| East of USA | 336 | 55.7% |
| South of USA | 236 | 55.5% |

Note: several of these regions have small sample sizes (<100 shipments) in
this 10K-row sample — treat the percentages for those as directional, not
statistically robust; re-running on the full 180K-row dataset would
tighten these estimates.

## Q3. Monthly sales & profit trend

36 months of data (Jan 2015 – Jan 2018). Sales are broadly stable in the
$40–85K/month range for this sample, with a slight decline through 2016–2017
before an uptick at the end of the series. Full table in the workbook's
"Sales & Profit" sheet.

## Q4. Top 10 categories by profit

| Category | Total Profit | Total Sales | Margin % |
|---|---|---|---|
| Cleats | 31,753 | 357,421 | 8.9% |
| Women's Apparel | 30,112 | 256,550 | 11.7% |
| Camping & Hiking | 28,162 | 238,484 | 11.8% |
| Cardio Equipment | 27,637 | 292,681 | 9.4% |
| Men's Footwear | 17,297 | 172,627 | 10.0% |
| Fishing | 15,265 | 150,792 | 10.1% |
| Sporting Goods | 12,519 | 117,007 | 10.7% |
| Shop By Sport | 11,681 | 105,454 | 11.1% |
| Hockey | 5,397 | 48,361 | 11.2% |
| Electronics | 3,405 | 28,782 | 11.8% |

## Q5. Bottom 10 categories by profit

Books, CDs, Pet Supplies, DVDs, and Baby are the lowest-profit categories in
this sample, several close to break-even. These are candidates for a
range/assortment review rather than immediate delisting, given small volume.

## Q6. Delay & risk by market

| Market | Shipments | Avg Delay (days) | Late Risk % |
|---|---|---|---|
| Europe | 2,700 | 0.67 | 60.1% |
| Africa | 499 | 0.53 | 56.1% |
| LATAM | 2,511 | 0.51 | 51.5% |
| USCA | 1,336 | 0.47 | 50.9% |
| Pacific Asia | 2,954 | 0.44 | 50.6% |

## Q7. Order status breakdown

| Status | Order Items | % of Total |
|---|---|---|
| COMPLETE | 3,738 | 37.4% |
| PENDING_PAYMENT | 1,811 | 18.1% |
| CLOSED | 1,677 | 16.8% |
| PROCESSING | 940 | 9.4% |
| PENDING | 810 | 8.1% |
| ON_HOLD | 602 | 6.0% |
| SUSPECTED_FRAUD | 194 | 1.9% |
| CANCELED | 150 | 1.5% |
| PAYMENT_REVIEW | 78 | 0.8% |

## Q8. Customer segment performance

| Segment | Customers | Total Sales | Total Profit | Avg Sales/Customer |
|---|---|---|---|---|
| Consumer | 2,852 | 1,037,151 | 110,597 | 364 |
| Corporate | 2,055 | 665,873 | 73,695 | 324 |
| Home Office | 669 | 286,962 | 27,658 | 429 |

**Takeaway**: Home Office has the fewest customers but the highest average
sales per customer — a smaller, higher-value segment worth targeted
retention effort.

## Q9. Discount rate vs. profit ratio

| Discount Band | Line Items | Avg Profit Ratio % |
|---|---|---|
| 0% (no discount) | 534 | 9.6% |
| 1–10% | 4,373 | 12.5% |
| 11–20% | 3,943 | 12.0% |
| 21%+ | 1,150 | 10.9% |

**Takeaway**: light discounting (1–10%) outperforms both no discount and
heavy discounting on margin — the relationship isn't linear, so a blanket
"discount more to move volume" policy isn't supported by this data.

## Q10. Top 10 regions by sales

| Region | Total Sales | Total Profit | Orders |
|---|---|---|---|
| Western Europe | 307,454 | 34,987 | 979 |
| Central America | 259,576 | 22,333 | 952 |
| Southeast Asia | 154,828 | 18,482 | 546 |
| Oceania | 154,306 | 11,453 | 560 |
| South America | 147,683 | 21,600 | 551 |
| Eastern Asia | 126,142 | 12,221 | 400 |
| South Asia | 125,505 | 15,144 | 430 |
| Northern Europe | 112,305 | 12,229 | 342 |
| Southern Europe | 109,992 | 13,916 | 354 |
| Caribbean | 73,382 | 7,864 | 272 |

---

## Optional: building a Power BI dashboard on this data

This repo ships an Excel dashboard so it's viewable without any extra
software. To build an interactive Power BI version instead:

1. Open Power BI Desktop → **Get Data** → **Text/CSV** → select
   `data/cleaned_supply_chain.csv`.
2. In Power Query, confirm `order_date` and `shipping_date` are typed as
   Date, and `late_delivery_risk` as Whole Number.
3. Build measures for the metrics above, e.g.:
   ```
   Late Delivery Risk % = AVERAGE(orders[late_delivery_risk])
   Total Profit = SUM(orders[order_profit_per_order])
   ```
4. Suggested visuals: a matrix of `shipping_mode` × `Late Delivery Risk %`;
   a map or bar chart of `order_region` × `Total Sales`; a line chart of
   `order_month` × `Total Sales`/`Total Profit`; a table of `category_name`
   sorted by `Total Profit`.
5. Publish to the Power BI service if you want a shareable link for your
   portfolio.
