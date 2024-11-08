# Netflix Data Analysis Project using MS SQL Server
![Netflix Analysis](https://github.com/adham-labeb/NETFLIX-Dataset-analysis-using-MS-SQL-Server/blob/main/logo.png)

This project involves importing and analyzing Netflix data from a CSV file using SQL on Microsoft SQL Server. 
The database allows for exploration of various aspects of Netflix content, including categorization by type, ratings, release years, and more.

## Project Setup

### 1. Database Creation
Create a table in the SQL Server database to store Netflix data with the following structure:
```sql
CREATE TABLE netflix (
    show_id VARCHAR(6),
    type VARCHAR(10),
    title VARCHAR(150),
    director VARCHAR(208), 
    casts VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(15),
    listed_in VARCHAR(200),
    description VARCHAR(250)
);
```
## 2. Importing Data
Use the BULK INSERT command to load data from the CSV file into the SQL Server table.
```sql
BULK INSERT dbo.netflix
FROM 'C:\Users\Home\Desktop\sql project\netflix_titles.csv'
WITH (
    FORMAT = 'csv',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a'
);
```
## 3. Data Exploration Queries
#### 1- Count Movies vs. TV Shows
```sql
SELECT COUNT(*) AS "Count of Shows", type
FROM netflix 
GROUP BY type;
```
#### 2-Most Common Rating for Movies and TV Shows
```sql
WITH RatingCounts AS (
    SELECT type, rating, COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT type, rating, rating_count,
           RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT type, rating AS most_frequent_rating 
FROM RankedRatings
WHERE rank = 1;
```
Another solution
using Table valued function
```sql
declare @common_rating table  
( 
 type varchar (10),  
 rating varchar (10), 
 count_per_rating int 
); 
 
insert into @common_rating 
select  type , rating ,count(*) from netflix 
group by rating,type;  
    
   select  * 
    from @common_rating 
    where type = 'movie' and count_per_rating = (select max(count_per_rating) from 
@common_rating) 
   
  union  
    
   select  top 1 * 
    from @common_rating 
    where type = 'TV Show' and count_per_rating = (select max(count_per_rating) 
from @common_rating where type = 'TV Show'); 
```
#### 3- List All Movies Released in a Specific Year (e.g., 2021)
```sql
SELECT show_id, type, title, release_year
FROM netflix 
WHERE release_year = 2021 AND type = 'movie';
```
#### 4-Top 5 Countries with the Most Content
```sql
SELECT TOP 5 country, COUNT(*) AS total_content
FROM (
    SELECT TRIM(value) AS country
    FROM netflix
    CROSS APPLY STRING_SPLIT(country, ',')
) AS t1
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC;
```
#### 5-Identify the Longest Movie
```sql
SELECT *
FROM netflix 
WHERE type = 'movie'
ORDER BY CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT) DESC;
```
#### 6-Content Added in the Last 5 Years
```sql
SELECT * 
FROM netflix 
WHERE release_year >= YEAR(GETDATE()) - 5
ORDER BY release_year;
```
#### 7-Movies/TV Shows by Director 'Marcus Raboy'
```sql
SELECT * 
FROM netflix 
CROSS APPLY STRING_SPLIT(director, ',') AS director
WHERE director = 'Marcus Raboy';
```
#### 8-TV Shows with More Than 5 Seasons
```sql
SELECT *
FROM netflix 
WHERE type = 'TV Show' AND CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT) > 5
ORDER BY CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT);
```
#### 9-Count Content Items in Each Genre
```sql
SELECT genre, COUNT(*) AS total_content
FROM (
    SELECT TRIM(value) AS genre
    FROM netflix
    CROSS APPLY STRING_SPLIT(listed_in, ',')
) AS t1
WHERE genre IS NOT NULL
GROUP BY genre
ORDER BY total_content DESC;
```
#### 10-Yearly Content Release in the USA and Average Releases per Year
```sql
SELECT 
    country, release_year, COUNT(show_id) AS total_release,
    ROUND(
        (SELECT CAST(COUNT(show_id) AS FLOAT) FROM netflix WHERE country LIKE '%United States%') / 
        (SELECT CAST(COUNT(DISTINCT release_year) AS FLOAT) FROM netflix WHERE country LIKE '%United States%'), 
        2
    ) AS avg_release
FROM netflix
WHERE country LIKE '%United States%'
GROUP BY release_year, country
ORDER BY total_release DESC;
```
#### 11-List All Movies That Are Documentaries
```sql
SELECT *
FROM netflix 
WHERE type = 'movie' AND listed_in LIKE '%Documentaries%'
ORDER BY release_year DESC;
```
#### 12-Find Content Without a Director
```sql
SELECT *
FROM netflix 
WHERE director IS NULL;
```
#### 13-Movies Actor 'Adam Sandler' Appeared in the Last 10 Years
```sql
SELECT *
FROM netflix
WHERE casts LIKE '%Adam Sandler%'
  AND release_year > YEAR(GETDATE()) - 10;
```
#### 14-Top 10 Actors Appearing in Movies Produced in the USA
```sql
SELECT TOP 10 type, actor, country, COUNT(*) AS count_of_movie 
FROM (
    SELECT country, type, TRIM(value) AS actor
    FROM netflix
    CROSS APPLY STRING_SPLIT(casts, ',')
) AS t1
WHERE country LIKE '%United States%' AND type = 'movie'
GROUP BY actor, country, type
ORDER BY count_of_movie DESC;
```
#### 15-Categorize Content Based on 'Kill' and 'Violence' Keywords
```sql
SELECT type, title, rating, listed_in, category, description
FROM (
    SELECT type, title, rating, listed_in, description,
        CASE 
            WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'contain violence'
            ELSE 'does not contain violence'
        END AS category
    FROM netflix
) AS categorized_content
ORDER BY category;
```
## Requirements
Microsoft SQL Server
A CSV file containing Netflix data, formatted as netflix_titles.csv
<br></br>

## Conclusion
This project provides a range of SQL queries to analyze Netflix content.
It includes categorizing data by type, duration, director, actor, and genre, as well as identifying trends in release years, countries, and content ratings.
By running these queries, we gain insights into the distribution and characteristics of Netflix’s catalog.
