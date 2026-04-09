-- ==================================================
-- BASIC KPIs
-- ==================================================

-- Total revenue
SELECT SUM(total_amount) AS total_revenue
FROM transactions;

-- Number of transactions
SELECT COUNT(*) AS total_transactions
FROM transactions;

-- Average order value (AOV)
SELECT AVG(total_amount) AS avg_order_value
FROM transactions;

-- Net revenue
SELECT SUM(total_amount - promo_amount) AS net_revenue
FROM transactions;


-- ==================================================
-- REVENUE OVER TIME
-- ==================================================

-- Revenue by month
SELECT 
    DATE_TRUNC('month', created_at) AS month,
    SUM(total_amount) AS revenue
FROM transactions
GROUP BY month
ORDER BY month;


-- ==================================================
-- REVENUE BY CATEGORY
-- ==================================================

-- Revenue by product category
WITH transactions_with_product_id  AS (
    SELECT 
        t.*,
        REPLACE(
            REPLACE(
                REPLACE(product_metadata, '''product_id''', '"product_id"'),
                '''quantity''', '"quantity"'
            ),
            '''item_price''', '"item_price"'
        )::json->0->>'product_id' AS product_id
    FROM transactions t
)
SELECT
	p.master_category,
    SUM(transactions_with_product_id .total_amount)::NUMERIC AS revenue
FROM transactions_with_product_id 
INNER JOIN product p
ON p.id = transactions_with_product_id .product_id::INT
GROUP BY p.master_category
ORDER BY revenue DESC;


-- ==================================================
-- PURCHASE FUNNEL
-- ==================================================

-- Event-based counts
SELECT 
    event_name,
    COUNT(DISTINCT session_id) AS session_count
FROM clickstream
WHERE event_name IN ('HOMEPAGE','SEARCH','ITEM_DETAIL','ADD_TO_CART','BOOKING')
GROUP BY event_name;


-- --------------------------------------------------
-- Journey-based counts
-- --------------------------------------------------

WITH session_event_flags AS (
  SELECT 
      session_id,
      MAX(CASE WHEN event_name = 'HOMEPAGE' THEN 1 ELSE 0 END) AS has_homepage,
      MAX(CASE WHEN event_name = 'SEARCH' THEN 1 ELSE 0 END) AS has_search,
      MAX(CASE WHEN event_name = 'ITEM_DETAIL' THEN 1 ELSE 0 END) AS has_item_detail,
      MAX(CASE WHEN event_name = 'ADD_TO_CART' THEN 1 ELSE 0 END) AS has_add_to_cart,
      MAX(CASE WHEN event_name = 'BOOKING' THEN 1 ELSE 0 END) AS has_booking
  FROM clickstream
  GROUP BY session_id
)

SELECT
    'HOMEPAGE' AS funnel_step,
    SUM(CASE WHEN has_homepage = 1 THEN 1 ELSE 0 END) AS session_count
FROM session_event_flags

UNION ALL

SELECT
    'HOMEPAGE + SEARCH' AS funnel_step,
    SUM(CASE WHEN has_homepage = 1 AND has_search = 1 THEN 1 ELSE 0 END) AS session_count
FROM session_event_flags

UNION ALL

SELECT
    'HOMEPAGE + SEARCH + ITEM_DETAIL' AS funnel_step,
    SUM(CASE WHEN has_homepage = 1 AND has_search = 1 AND has_item_detail = 1 THEN 1 ELSE 0 END) AS session_count
FROM session_event_flags

UNION ALL

SELECT
    'HOMEPAGE + SEARCH + ITEM_DETAIL + ADD_TO_CART' AS funnel_step,
    SUM(CASE WHEN has_homepage = 1 AND has_search = 1 AND has_item_detail = 1 AND has_add_to_cart = 1 THEN 1 ELSE 0 END) AS session_count
FROM session_event_flags

UNION ALL

SELECT
    'HOMEPAGE + SEARCH + ITEM_DETAIL + ADD_TO_CART + BOOKING' AS funnel_step,
    SUM(CASE WHEN has_homepage = 1 AND has_search = 1 AND has_item_detail = 1 AND has_add_to_cart = 1 AND has_booking = 1 THEN 1 ELSE 0 END) AS session_count
FROM session_event_flags;
