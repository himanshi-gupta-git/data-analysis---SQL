WITH avg_monthly_rating AS(
    SELECT movie_id, 
           DATE_TRUNC('month', rating_date) AS month, 
           AVG(rating) AS monthly_avg_rating
    FROM ratings
    GROUP BY movie_id, DATE_TRUNC('month', rating_date)
),
rating_difference AS(
    SELECT movie_id,
           month,
           LAG(monthly_avg_rating) OVER (PARTITION BY movie_id ORDER BY month) AS previous_month_avg,
           (monthly_avg_rating - LAG(monthly_avg_rating) OVER (PARTITION BY movie_id ORDER BY month)) AS monthly_diff
    FROM avg_monthly_rating
),
count_improvement AS(
    SELECT movie_id,
           COUNT(monthly_diff) AS improvement_count
    FROM rating_difference
    WHERE monthly_diff > 0
    GROUP by movie_id
),
final AS (
    SELECT m.title AS movie_name,
           DENSE_RANK() OVER (ORDER BY ci.improvement_count DESC) AS ranked
    FROM movies m 
    LEFT JOIN count_improvement ci 
       ON m.movie_id = ci.movie_id 
)
SELECT movie_name
FROM final 
WHERE ranked <= 3;

