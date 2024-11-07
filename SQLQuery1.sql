--creating tables for data 
create table netflix
(

	show_id	varchar(6),
	type	varchar(10),
	title	varchar(150),
	director varchar(208),	
	casts	varchar(1000),
	country	varchar(150),
	date_added	varchar(50),
	release_year	int,
	rating	varchar(10),
	duration	varchar(15),
	listed_in	varchar(200),
	description varchar(250),
);
--insert data from the csv file to the MS SQL Server (dbo.netflix ) database .
Bulk insert dbo.netflix
from 'C:\Users\Home\Desktop\sql project\netflix_titles.csv'
with (format = 'csv',
       firstrow = 2 ,
	   fieldterminator = ',',
	   rowterminator = '0x0a' );
	
------------------------------------------------------------------------------------------------------------
------------------------------------data exploration Queries------------------------------------------------
-- 1- count the number of movies vs TV Show  
	   select  count(*) as "count of shows" ,type
	   from netflix 
	   group by type ;

	   select * from netflix
-------------------------------------------------------------------------------------------------------------

-- 2- find the most common rating for movies and tv shows
	                 
					                         -- ( first solution )


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
	   where type = 'movie' and count_per_rating = (select max(count_per_rating) from @common_rating)
	 
	 union 
	  
	  select  top 1 *
	   from @common_rating
	   where type = 'TV Show' and count_per_rating = (select max(count_per_rating) from @common_rating where type = 'TV Show');
	   
	                                       --( 2nd solution )
	   

	   WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
		
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating 
	
FROM RankedRatings
WHERE rank = 1;
---------------------------------------------------------------------------------------------------------------                                      
-- 3-  List All Movies Released in a Specific Year (e.g., 2021)

select show_id, type, title, release_year from netflix 
where release_year = 2021 and type = 'movie' ;

----------------------------------------------------------------------------------------------------------------

-- 4- Find the Top 5 Countries with the Most Content on Netflix

SELECT TOP 5 country, COUNT(*) AS total_content
FROM (
    SELECT 
        TRIM(value) AS country  -- 'value' is the column from STRING_SPLIT
    FROM netflix
    CROSS APPLY STRING_SPLIT(country, ',')
) AS t1
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC;
--------------------------------------------------------------------------------------------------------------
-- 5- Identify the Longest Movie
select *
from netflix 
where type ='movie'
order by cast(substring(duration,1,charindex(' ' ,duration)-1) As int)desc;

--------------------------------------------------------------------------------------------------------------
-- 6-  Find Content Added in the Last 5 Years
select * from netflix 
where release_year >= year(getdate())-5
order by release_year; 
---------------------------------------------------------------------------------------------------------------
-- 7- Find All Movies/TV Shows by Director 'Marcus Raboy'
select * 
from netflix 
 cross apply string_split(director,',') as director
 where director = 'Marcus Raboy';
----------------------------------------------------------------------------------------------------------------
-- 8- List All TV Shows with More Than 5 Seasons
select * from netflix 
where type = 'TV Show' and cast(substring(duration,1,charindex(' ' ,duration)-1)As int)>5
order by cast(substring(duration,1,charindex(' ' ,duration)-1)As int);
----------------------------------------------------------------------------------------------------------------
-- 9- Count the Number of Content Items in Each Genre
SELECT genra , count(*) as total_content
FROM (
    SELECT 
        TRIM(value) AS genra  -- 'value' is the column from STRING_SPLIT
    FROM netflix
    CROSS APPLY STRING_SPLIT(listed_in, ',')
) AS t1
WHERE genra IS NOT NULL
GROUP BY genra
ORDER BY total_content DESC;
--------------------------------------------------------------------------------------------------------------
-- 10- Find each year and the number of content per year and the average numbers of content per year release in usa on netflix
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        (SELECT CAST(COUNT(show_id) AS FLOAT) FROM netflix WHERE country like '%United States%') / (select cast(count(distinct release_year)as float) from netflix where country like '%United States%') , 2
    ) AS avg_release
FROM netflix
WHERE country like '%United States%'
GROUP BY release_year , country
ORDER BY total_release DESC;
--------------------------------------------------------------------------------------------------------------
-- 11- List All Movies that are Documentaries
select * from netflix 
where type = 'movie' and listed_in like '%Documentaries%'
order by release_year desc;
--------------------------------------------------------------------------------------------------------------
-- 12- Find All Content Without a Director
select * from netflix 
where director is null
--------------------------------------------------------------------------------------------------------------
-- 13- Find How Many Movies Actor 'Adam sandler' Appeared in the Last 10 Years
SELECT * 
FROM netflix
WHERE casts LIKE '%Adam Sandler%'
 AND release_year > year(getdate()) - 10;
--------------------------------------------------------------------------------------------------------------
-- 14- Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in united states

select top 10 type,actor,country, count(*) as count_of_movie 
from (SELECT country,type,
        TRIM(value) AS actor  -- 'value' is the column from STRING_SPLIT
    FROM netflix
    CROSS APPLY STRING_SPLIT(casts, ',')
) AS t1
where country like '%united state%' and type = 'movie'
group by actor,country,type
order by count_of_movie desc;
-------------------------------------------------------------------------------------------------------------
--15- Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT type , title,rating,listed_in,
    category, description
    
FROM (
    SELECT type , title,rating,listed_in,description,
        CASE 
            WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'contain violence'
            ELSE 'doesnot contain violence'
        END AS category
    FROM netflix
) AS categorized_content
order by category


