# Netflix Movies and Shows Data Analysis Using SQL

![netflix](https://github.com/TanmoyDutta017/netflix_sql_project/blob/main/files/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives
- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset
 
 The data for this project is sourced from the Kaggle dataset:

- Dataset Link: [Netflix Dataset](https://github.com/TanmoyDutta017/netflix_sql_project/blob/main/files/netflix.csv)

## Table Creation

```sql
DROP TABLE IF EXISTS nfd.netflix
CREATE TABLE nfd.netflix(
show_id VARCHAR(10),
type VARCHAR(15),
title VARCHAR(255),
director VARCHAR(255),
cast VARCHAR(1050),
country VARCHAR(200),
date_added	VARCHAR (100),
release_year INT,
rating VARCHAR(20),
duration VARCHAR(50),
listed_in VARCHAR(200),
description VARCHAR(500))
```

## Data Loading

```sql
TRUNCATE TABLE nfd.netflix
BULK INSERT nfd.netflix
  -- Here, the file location will be different for you. Select the file > right click > properties > security > copy the whole object name.
FROM 'C:\Users\iamta\Downloads\netflix.csv'
WITH(
FORMAT = 'CSV',
FIRSTROW = 2,
FIELDQUOTE = '"',
FIELDTERMINATOR = ',',
ROWTERMINATOR = '0x0a',
TABLOCK
);
```

## Data Analysis (Business Questions and Solutions)

**1.Count the number of Movies vs TV Shows**

```sql
		SELECT
		type,
		count(type) No_of_shows
		FROM nfd.netflix
		GROUP BY type
		Order by 2 DESC
```
### Objective: Determine the distribution of content types on Netflix.

**2.Find the most common rating for movies and TV shows**

```sql
    WITH CTE_Rating AS(
    SELECT
    type,
    rating,
    count(rating) AS cm_rating,
    RANK() OVER(Partition by type order by count(rating)    DESC) AS Rnfx
    FROM nfd.netflix
    WHERE rating IS NOT NULL
    GROUP BY type,
    rating)

    SELECT
    type,
    rating
    FROM CTE_Rating
    WHERE Rnfx  = 1
```
### Objective: Identify the most frequently occurring rating for each type of content.

**3.List all movies released in a specific year (e.g., 2020)**

```sql
    SELECT 
    type,
    title,
    release_year
    FROM nfd.netflix
    WHERE  release_year = '2020' AND type = 'Movie'
```
### Objective: List all movies released in a specific year (e.g., 2020).

**4.Find the top 5 countries with the most content on Netflix**

```sql
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
```
### Objective: Find the top 5 countries with the most content on Netflix.

**5.Identify the longest movie**

```sql
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

```
### Objective: Identify the longest movie.

**6.Find content added in the last 5 years**

```sql
    SELECT 
    *,
    FORMAT(CAST(date_added AS DATE),'dd-MMM-yyyy') dateadded2-- Not required
    FROM nfd.netflix
    WHERE DATEDIFF(Year,date_added,GETDATE()) <= 5
```
### Objective: Find content added in the last 5 years.

**7. Find all the movies/TV shows by director 'Rajiv Chilaka'!**
```sql
    SELECT 
    *
    FROM nfd.netflix
    WHERE director LIKE '%Rajiv Chilaka%'
```    
### Objective: Find all the movies/TV shows by director 'Rajiv Chilaka'.

**8. List all TV shows with more than 5 seasons**
```sql
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
 ```   
### Objective: List all TV shows with more than 5 seasons.

**9. Count the number of content items in each genre**
```sql
    SELECT
    TRIM(VALUE) as genre,
    count(*) AS cnt
    FROM nfd.netflix
    CROSS APPLY string_split(listed_in,',')
    GROUP BY TRIM(value)
    Order by 2 DESC
 ```   
### Objective: Count the number of content items in each genre.

**10.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!**
```sql		
    -- Option 1
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
 ```       
### Objective: Top 5 year with highest avg content release in India.

**11. List all movies that are documentaries**
```sql		
    SELECT
    *
    FROM nfd.netflix
    WHERE listed_in like '%Documentaries%'
```
### Objective: List all movies that are documentaries.

**12. Find all content without a director**
```sql
    SELECT
    *
    FROM nfd.netflix
    WHERE director IS NULL
```        
### Objective: Find all content without a director.

**13. Find how many movies actor 'Salman Khan' appeared in last 10 years!**
```sql		
    SELECT
    *
    FROM nfd.netflix
    WHERE cast LIKE '%Salman Khan%'
    AND YEAR(GETDATE())-release_year <=10
```        
### Objective: Find how many movies actor 'Salman Khan' appeared in last 10 years!

**14. Find the top 10 actors who have appeared in the highest number of movies produced in India.**
```sql		
    SELECT TOP 10
    TRIM(Value) as cast,
    count(*) cnt
    FROM nfd.netflix
    CROSS APPLY string_split(cast,',')
    WHERE country like '%India%'
    GROUP BY TRIM(Value)
    Order by cnt DESC
```       
### Objective: Find the top 10 actors who have appeared in the highest number of movies produced in India.

**15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.**
```sql		
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
```        
### Objective: Count how many content fall into each category based on specific keywords.

## Findings and Conclusions

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.

## Tools Used

- **SQL Server Management Studio (SSMS)**: Used for database management and query execution.
- **SQL Server**: The database management system used for storing and managing the dataset.

## 🛡️License
This project is licensed under the MIT License. You are free to use, modify, and share this project with proper attribution.

## ⭐About Me

Tanmoy Dutta    
Regional Coordinator/MIS Executive  
📧Email: iamtanmoydutta@gmail.com
🔗 [LinkedIn](https://www.linkedin.com/in/tanmoy-dutta-53996820b/)
