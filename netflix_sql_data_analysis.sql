CREATE TABLE netflix_1
(
    show_id VARCHAR(6),
    type VARCHAR(10),
    title VARCHAR(150),
    director VARCHAR(500),
    casts VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(15),
    listed_in VARCHAR(255),
    description VARCHAR(250)
)

DROP TABLE IF EXISTS
public.netflix_1;

SELECT *
FROM netflix_1;

SELECT COUNT(*)
FROM netflix_1;

-- 1. Count the number of Movies vs TV Shows
SELECT type, COUNT(*)
FROM netflix_1
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows
SELECT type, rating, rating_count, rank -- using outer subquery we display type, rating, total count of ratings and the rank assigned to rating based on partition by type
FROM (  
SELECT type, rating, COUNT(*) AS rating_count,
RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rank -- inner subquery used to partiton by type(movie and tv show) and order by total count in DESC as rank
FROM netflix_1  
GROUP BY type, rating  
) AS rated_counts -- this used to name the inner subquery if we want to reuse the inner subquery we can name it or we can skip it
WHERE rank = 1; -- subquery is filterd where rank = 1 will be returned

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT type, title, release_year
FROM netflix_1
WHERE release_year = 2020 and type = 'Movie';

-- 4. Find the top 5 countries with the most content on Netflix
SELECT country, COUNT(*) AS count
FROM netflix_1
GROUP BY country
ORDER BY count DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT title, duration
FROM netflix_1
WHERE type = 'Movie' and duration IS NOT NULL
ORDER BY duration DESC
LIMIT 1;

or 

SELECT title, duration
FROM netflix_1
WHERE type = 'Movie' and duration = (SELECT MAX(duration) FROM netflix_1)
LIMIT 1;

-- 6. Find content added in the last 5 years
SELECT *
FROM netflix_1
WHERE TO_DATE(date_added, 'Month DD YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM netflix_1
WHERE director = 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix_1
WHERE type = 'TV Show' AND SPLIT_PART(duration, ' ', 1):: numeric > 5; -- extracting the first part of the string and after extracting it will be in string format so tyoecat to numeric using ::numeric to compare

-- 9. Count the number of content items in each genre
SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS content_items, COUNT(*)
FROM netflix_1
GROUP BY 1
ORDER BY 2 DESC;

-- 10.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!
SELECT SPLIT_PART(date_added, ' ', 3), country, COUNT(*),
ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix_1 WHERE country = 'India')::numeric * 100, 2) AS average_content
FROM netflix_1
WHERE country = 'India'
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 5;

-- 11. List all movies that are documentaries
SELECT type, listed_in
FROM netflix_1
WHERE type ILIKE '%Movie%' AND listed_in ILIKE '%Documentaries%'

-- 12. Find all content without a director
SELECT *
FROM netflix_1
WHERE director IS NULL

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT *
FROM netflix_1
WHERE casts ILIKE '%Salman Khan%' AND type = 'Movie' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10 -- used to compare the relase year greater than current date by sybtracting 10 from current year 2025-10=2015(e.g. 2018>2015)

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor, COUNT(*)
FROM netflix_1
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' 
in the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
SELECT COUNT(*),
CASE
	WHEN 
	description ILIKE '%Kill%' OR  
	description ILIKE '%Violence%' 
	THEN 'Bad' 
	ELSE 'Good' 
	END AS Category
FROM netflix_1
GROUP BY 2
ORDER BY 1