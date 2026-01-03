-- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows
		SELECT
		type,
		count(type) No_of_shows
		FROM nfd.netflix
		GROUP BY type
		Order by 2 DESC

--2. Find the most common rating for movies and TV shows
		WITH CTE_Rating AS(
		SELECT
		type,
		rating,
		count(rating) AS cm_rating,
		RANK() OVER(Partition by type order by count(rating) DESC) AS Rnfx
		FROM nfd.netflix
		WHERE rating IS NOT NULL
		GROUP BY type,
		rating)

		SELECT
		type,
		rating
		FROM CTE_Rating
		WHERE Rnfx  = 1
--3. List all movies released in a specific year (e.g., 2020)
		SELECT 
		type,
		title,
		release_year
		FROM nfd.netflix
		WHERE  release_year = '2020' AND type = 'Movie'
--4. Find the top 5 countries with the most content on Netflix
	
		SELECT TOP 5
		Country,
		cnt_cntry AS content
		FROM(
		SELECT
		TRIM(value) as Country,
		count(*) AS cnt_cntry
		FROM nfd.netflix
		CROSS APPLY string_split(country,',')
		WHERE TRIM(value) <> ''
		GROUP BY TRIM(VALUE)
		)t
		Order by cnt_cntry DESC
	
--5. Identify the longest movie
		SELECT TOP 1
		type,
		title,
		duration
		FROM(
		SELECT 
		type,
		title,
		duration,
		CAST(TRIM(REPLACE(duration,'min','')) AS INT) AS duration_min	
		FROM nfd.netflix
		WHERE type = 'Movie')t
		ORDER BY duration_min DESC
--6. Find content added in the last 5 years
		SELECT 
		*,
		FORMAT(CAST(date_added AS DATE),'dd-MMM-yyyy') dateadded2-- Not required
		FROM nfd.netflix
		WHERE DATEDIFF(Year,date_added,GETDATE()) <= 5
--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
		SELECT 
		*
		FROM nfd.netflix
		WHERE director LIKE '%Rajiv Chilaka%'
--8. List all TV shows with more than 5 seasons
		SELECT
		*
		FROM(
		SELECT
		*,
		CAST(LEFT(duration,CHARINDEX(' ',duration)-1) AS INT) dura
		FROM nfd.netflix
		WHERE type = 'TV Show'
		)t WHERE dura >=5
		Order by dura DESC
--9. Count the number of content items in each genre
		SELECT
		TRIM(VALUE) as genre,
		count(*) AS cnt
		FROM nfd.netflix
		CROSS APPLY string_split(listed_in,',')
		GROUP BY TRIM(value)
		Order by 2 DESC
/*10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release! */
		-- Option 1:
		SELECT TOP 5
		Year(date_added) AS year,
		count(TRIM(VALUE)) cnt
		FROM nfd.netflix
		CROSS APPLY string_split(country,',')
		WHERE TRIM(VALUE)  = 'India'
		GROUP BY Year(date_added)
		Order by 2 DESC
		-- option 2:
		SELECT TOP 5
		year(date_added) as year,
		count(*) cnt
		FROM nfd.netflix
		WHERE country LIKE '%India%'
		GROUP BY year(date_added)
		Order by 2 DESC
--11. List all movies that are documentaries
		SELECT
		*
		FROM nfd.netflix
		WHERE listed_in like '%Documentaries%'
--12. Find all content without a director
		SELECT
		*
		FROM nfd.netflix
		WHERE director IS NULL
--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
		SELECT
		*
		FROM nfd.netflix
		WHERE cast LIKE '%Salman Khan%'
		AND YEAR(GETDATE())-release_year <=10
--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
		SELECT TOP 10
		TRIM(Value) as cast,
		count(*) cnt
		FROM nfd.netflix
		CROSS APPLY string_split(cast,',')
		WHERE country like '%India%'
		GROUP BY TRIM(Value)
		Order by cnt DESC
/*15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/
		SELECT
		category,
		count(*) cnt
		FROM (
		SELECT
		*,
		CASE WHEN lower(description) like '%kill%' OR lower(description) like '%violence%' THEN 'BAD'
		ELSE 'Good' END category
		FROM nfd.netflix)t
		GROUP BY category
