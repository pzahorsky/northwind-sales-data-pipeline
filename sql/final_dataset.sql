WITH revenues_per_order AS
(
    SELECT o.order_id, o.customer_id, 
           EXTRACT(YEAR FROM o.order_date) :: INT AS year,
           SUM(od.unit_price * od.quantity * (1 - od.discount)) AS order_revenue
      FROM order_details od
      JOIN orders o
        ON od.order_id = o.order_id
     GROUP BY o.order_id,
              year,
              o.customer_id
),
     customer_year AS
(
    SELECT c.customer_id, c.company_name, rpo.year,
           SUM(rpo.order_revenue) AS total_revenue,
           COUNT(rpo.order_id) AS order_count
      FROM revenues_per_order rpo
      JOIN customers c
        ON rpo.customer_id = c.customer_id
     GROUP BY rpo.year, 
              c.customer_id,
              c.company_name
),
     customer_year_features_base AS
(
    SELECT *,cy.total_revenue / NULLIF(cy.order_count, 0) AS avg_order_value,
           DENSE_RANK() OVER (PARTITION BY year
                              ORDER BY cy.total_revenue DESC) AS customer_rank_year,
           SUM(cy.total_revenue) 
                        OVER (PARTITION BY year) AS year_total_revenue,
           cy.total_revenue / NULLIF(SUM(cy.total_revenue) 
                        OVER (PARTITION by year),0) AS revenue_share_year
      FROM customer_year cy
),
     customer_year_features AS
(
    SELECT *, SUM(cyfb.revenue_share_year) 
                        OVER (PARTITION BY year 
                        ORDER BY cyfb.total_revenue 
                        DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
                        AS cum_revenue_share_year
      FROM customer_year_features_base cyfb 
)

/* Check: Revenue share year should be ~1 for each year*/

/*
SELECT year, SUM(revenue_share_year) AS share_sum
FROM customer_year_features
GROUP BY year
ORDER BY year;
*/

/* Check: Cumulative revenue share should be ~1 for each year*/
/*
SELECT year, MAX(cum_revenue_share_year) AS cum_max
FROM customer_year_features
GROUP BY year
ORDER BY year;
*/

SELECT *
  FROM customer_year_features
 ORDER BY year, customer_rank_year
