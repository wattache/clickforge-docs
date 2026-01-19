SELECT
  product_id,
  product_title,
  product_category,
  star_rating,
  helpful_votes,
  total_votes,
  review_date
FROM clickforge.amazon_reviews
WHERE product_category = {product_category: String}
  AND star_rating > 4
ORDER BY helpful_votes DESC
LIMIT 100