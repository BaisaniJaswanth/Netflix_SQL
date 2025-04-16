# Movies and TV Shows Data Analysis in Netflix using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

  ## 📌 Project Overview

This project presents an in-depth analysis of Netflix’s catalog of movies and TV shows using SQL. The primary aim is to uncover meaningful insights and address key business-related queries derived from the dataset. This README outlines the project’s goals, business challenges, strategic solutions, and the key insights drawn from the data exploration.

## 🎯 Project Goals

- Examine the distribution between different content types (e.g., Movies vs. TV Shows).
- Determine the most frequently assigned content ratings to understand viewer segmentation.
- Analyze trends across release years, countries of origin, and content durations.
- Categorize and filter content using specific attributes and thematic keywords to reveal deeper insights.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix_1;
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
);
```
```sql
SELECT *
FROM netflix_1;
```

```sql
SELECT COUNT(*)
FROM netflix_1;
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT type, COUNT(*)
FROM netflix_1
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT type, rating, rating_count, rank -- using outer subquery we display type, rating, total count of ratings and the rank assigned to rating based on partition by type
FROM (  
SELECT type, rating, COUNT(*) AS rating_count,
RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rank -- inner subquery used to partiton by type(movie and tv show) and order by total count in DESC as rank
FROM netflix_1  
GROUP BY type, rating  
) AS rated_counts -- this used to name the inner subquery if we want to reuse the inner subquery we can name it or we can skip it
WHERE rank = 1; -- subquery is filterd where rank = 1 will be returned
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT type, title, release_year
FROM netflix_1
WHERE release_year = 2020 and type = 'Movie';
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT country, COUNT(*) AS count
FROM netflix_1
GROUP BY country
ORDER BY count DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
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
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix_1
WHERE TO_DATE(date_added, 'Month DD YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM netflix_1
WHERE director = 'Rajiv Chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix_1
WHERE type = 'TV Show' AND SPLIT_PART(duration, ' ', 1):: numeric > 5; -- extracting the first part of the string and after extracting it will be in string format so tyoecat to numeric using ::numeric to compare
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS content_items, COUNT(*)
FROM netflix_1
GROUP BY 1
ORDER BY 2 DESC;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT SPLIT_PART(date_added, ' ', 3), country, COUNT(*),
ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix_1 WHERE country = 'India')::numeric * 100, 2) AS average_content
FROM netflix_1
WHERE country = 'India'
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 5;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT type, listed_in
FROM netflix_1
WHERE type ILIKE '%Movie%' AND listed_in ILIKE '%Documentaries%'
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT *
FROM netflix_1
WHERE director IS NULL
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT *
FROM netflix_1
WHERE casts ILIKE '%Salman Khan%' AND type = 'Movie' AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10 -- used to compare the relase year greater than current date by sybtracting 10 from current year 2025-10=2015(e.g. 2018>2015)
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor, COUNT(*)
FROM netflix_1
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## 📊 Key Insights and Final Interpretation

- **🎬 Diverse Content Portfolio:**  
  The dataset showcases a broad spectrum of movies and series, encompassing various genres and content ratings, reflecting Netflix’s global content strategy.

- **👥 Audience Targeting Through Ratings:**  
  The analysis of frequently occurring ratings reveals the platform’s approach to targeting different audience age groups, helping in identifying trends in viewer demographics.

- **🌍 Regional Trends and Country Focus:**  
  A notable share of titles originates from specific countries, with India being a significant contributor. This emphasizes Netflix’s focus on region-specific content production and distribution.

- **🏷️ Genre and Theme Classification:**  
  By analyzing recurring keywords and content descriptions, we gain valuable insights into the thematic structure and genre preferences within the Netflix library.

