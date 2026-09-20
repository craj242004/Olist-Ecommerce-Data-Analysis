# 🛒 Olist E-commerce — Business Insights

## 1. Business Scale

The Olist dataset contains:

- 99,441 orders
- 96,096 unique customers
- 112,650 order-item records
- 32,951 products
- 3,095 sellers
- 99,224 reviews
- 103,886 payment records

The analysis therefore covers a large multi-table e-commerce marketplace.

---

## 2. Sales Performance

Revenue calculated using product price plus freight value was approximately:

**15.84M**

The analysis also calculated:

**Average Order Value: 160.58**

Order activity increased significantly over the analyzed years.

### Orders by year

- 2016: 312
- 2017: 44,579
- 2018: 53,775

2018 had the highest order volume among the three years represented in the dataset.

---

## 3. Product & Category Performance

The category analysis identified several major revenue-generating categories.

### Highest-revenue categories

1. Health & Beauty — 1.44M
2. Watches & Gifts — 1.31M
3. Bed/Bath/Table — 1.24M
4. Sports & Leisure — 1.16M
5. Computers & Accessories — 1.06M

Health & Beauty generated the highest revenue among the analyzed categories.

---

## 4. Customer Behavior

The dataset contains:

**96,096 unique customers**

Customer-level analysis showed:

- One-time customers: 93,099
- Repeat customers: 2,997
- Repeat customer percentage: 3.12%

This indicates that most customers in the analyzed marketplace placed only one order.

The project also created customer-level metrics including:

- Total orders
- Total spending
- Average order value
- Customer type
- Spending segment

---

## 5. Seller Performance

Seller analysis examined:

- Total revenue
- Items sold
- Orders handled
- Average order value

This allowed sellers to be compared using both volume-based and value-based metrics.

---

## 6. Payment Behavior

Credit card was the most frequently used payment method.

### Credit card

- Approximately 73.9% of payment records
- Approximately 78.3% of total payment value

Boleto was the second-largest payment method by payment count.

Payment analysis also examined installment usage across customers.

---

## 7. Delivery Performance

Delivery performance was classified into four categories:

- Early
- On Time
- Late
- Not Delivered

### Delivery status

| Status | Orders |
|---|---:|
| Early | 88,649 |
| Late | 6,535 |
| Not Delivered | 2,965 |
| On Time | 1,292 |

The categories cover all 99,441 orders.

The Python analysis also calculated delivery duration and delivery delay metrics.

---

## 8. Customer Satisfaction

The overall average review score was:

**4.09 / 5**

### Review distribution

- 1 star: 11,424
- 2 stars: 3,151
- 3 stars: 8,179
- 4 stars: 19,142
- 5 stars: 57,328

Five-star reviews represented the largest group.

---

## 9. Delivery & Customer Satisfaction

The SQL analysis compared average review scores across delivery-status groups.

This analysis was used to examine whether delivery performance and customer satisfaction varied together.

The results should be interpreted as an observed relationship in the dataset rather than proof that delivery status directly causes a particular review score.

---

## 10. Data Quality Insights

The Python data-quality analysis identified:

### Missing values

Important missing values existed in:

- Order approval dates
- Carrier delivery dates
- Customer delivery dates
- Review comments
- Product category attributes
- Product dimensions

### Duplicate records

The Geolocation dataset contained:

**261,831 duplicate rows**

Other major business datasets did not contain complete duplicate rows during the duplicate check.

---

## 11. Order Relationship Validation

The Orders table contained:

**99,441 unique orders**

The Order Items table contained:

**98,666 unique orders**

Therefore:

**775 orders did not have corresponding order-item records.**

This was identified during relationship validation and is an important data-quality consideration when calculating item-level revenue.

---

## 12. Overall Takeaways

The analysis provides a structured view of the Olist marketplace across:

- Sales
- Orders
- Products
- Customers
- Sellers
- Payments
- Delivery
- Reviews
- Data quality

The project demonstrates an end-to-end analytical workflow:

```text
Raw Data
↓
Python Data Cleaning
↓
Data Validation
↓
Transformation
↓
PostgreSQL
↓
SQL Business Questions
↓
Business Insights