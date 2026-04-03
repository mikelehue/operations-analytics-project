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
SELECT 
    p.master_category,
    SUM(x.total_amount)::NUMERIC AS revenue
FROM (
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
) x
INNER JOIN product p
    ON p.id = x.product_id::INT
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

-- Sessions that include HOMEPAGE
SELECT COUNT(DISTINCT session_id) AS session_count
FROM clickstream c
WHERE EXISTS (
    SELECT 1
    FROM clickstream c1
    WHERE c1.event_name = 'HOMEPAGE'
      AND c.session_id = c1.session_id
);

-- Sessions that include HOMEPAGE and SEARCH
SELECT COUNT(DISTINCT session_id) AS session_count
FROM clickstream c
WHERE EXISTS (
    SELECT 1
    FROM clickstream c1
    WHERE c1.event_name = 'HOMEPAGE'
      AND c.session_id = c1.session_id
)
AND EXISTS (
    SELECT 1
    FROM clickstream c2
    WHERE c2.event_name = 'SEARCH'
      AND c.session_id = c2.session_id
);

-- Sessions that include HOMEPAGE, SEARCH and ITEM_DETAIL
SELECT COUNT(DISTINCT session_id) AS session_count
FROM clickstream c
WHERE EXISTS (
    SELECT 1
    FROM clickstream c1
    WHERE c1.event_name = 'HOMEPAGE'
      AND c.session_id = c1.session_id
)
AND EXISTS (
    SELECT 1
    FROM clickstream c2
    WHERE c2.event_name = 'SEARCH'
      AND c.session_id = c2.session_id
)
AND EXISTS (
    SELECT 1
    FROM clickstream c3
    WHERE c3.event_name = 'ITEM_DETAIL'
      AND c.session_id = c3.session_id
);

-- Sessions that include HOMEPAGE, SEARCH, ITEM_DETAIL and ADD_TO_CART
SELECT COUNT(DISTINCT session_id) AS session_count
FROM clickstream c
WHERE EXISTS (
    SELECT 1
    FROM clickstream c1
    WHERE c1.event_name = 'HOMEPAGE'
      AND c.session_id = c1.session_id
)
AND EXISTS (
    SELECT 1
    FROM clickstream c2
    WHERE c2.event_name = 'SEARCH'
      AND c.session_id = c2.session_id
)
AND EXISTS (
    SELECT 1
    FROM clickstream c3
    WHERE c3.event_name = 'ITEM_DETAIL'
      AND c.session_id = c3.session_id
)
AND EXISTS (
    SELECT 1
    FROM clickstream c4
    WHERE c4.event_name = 'ADD_TO_CART'
      AND c.session_id = c4.session_id
);

-- Sessions that include HOMEPAGE, SEARCH, ITEM_DETAIL, ADD_TO_CART and BOOKING
SELECT COUNT(DISTINCT session_id) AS session_count
FROM clickstream c
WHERE EXISTS (
    SELECT 1
    FROM clickstream c1
    WHERE c1.event_name = 'HOMEPAGE'
      AND c.session_id = c1.session_id
)
AND EXISTS (
    SELECT 1
    FROM clickstream c2
    WHERE c2.event_name = 'SEARCH'
      AND c.session_id = c2.session_id
)
AND EXISTS (
    SELECT 1
    FROM clickstream c3
    WHERE c3.event_name = 'ITEM_DETAIL'
      AND c.session_id = c3.session_id
)
AND EXISTS (
    SELECT 1
    FROM clickstream c4
    WHERE c4.event_name = 'ADD_TO_CART'
      AND c.session_id = c4.session_id
)
AND EXISTS (
    SELECT 1
    FROM clickstream c5
    WHERE c5.event_name = 'BOOKING'
      AND c.session_id = c5.session_id
);