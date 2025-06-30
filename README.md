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
#### The query :
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
### 1- Count Movies vs. TV Shows
#### The query :
```sql
SELECT COUNT(*) AS "Count of Shows", type
FROM netflix 
GROUP BY type;
```

### output of the query :

| count of shows | type    |
|----------------|---------|
| 2676           | TV Show |
| 6131           | Movie   |


### 2-Most Common Rating for Movies and TV Shows
#### The query :
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

### output of the query :

| type    | rating | count_per_rating |
|---------|--------|------------------|
| Movie   | TV-MA  | 2062             |
| TV Show | TV-MA  | 1145             |

Another solution
using Table valued function
#### The query :
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

### output of the query :

| type    | most_frequent_rating | rating_count |
|---------|----------------------|--------------|
| Movie   | TV-MA                | 2062         |
| TV Show | TV-MA                | 1145         |

### 3- List All Movies Released in a Specific Year (e.g., 2021)
#### The query :
```sql
SELECT show_id, type, title, release_year
FROM netflix 
WHERE release_year = 2021 AND type = 'movie';
```

### output of the query :

| show_id | type  | title                         | release_year |
|---------|-------|-------------------------------|--------------|
| s7      | Movie | My Little Pony: A New Generation | 2021         |
| s10     | Movie | The Starling                  | 2021         |
| s13     | Movie | Je Suis Karl                  | 2021         |
| s14     | Movie | Confessions of an Invisible Girl | 2021         |
| s19     | Movie | Intrusion                     | 2021         |

### 4- Top 5 Countries with the Most Content
#### The query :
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

### output of the query :

| country       | total_content |
|---------------|---------------|
| United States | 3690          |
| India         | 1046          |
| United Kingdom| 806           |
| Canada        | 445           |
| France        | 393           |

### 5-Identify the Longest Movie
#### The query :
```sql
SELECT *
FROM netflix 
WHERE type = 'movie'
ORDER BY CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT) DESC;
```

### output of the query :


| show_id | type  | title                         | director              | casts                                                                                                  | country       | date_added       | release_year | rating | duration | listed_in                                | description                                                                                                                                                                                                                                           |
|---------|-------|-------------------------------|-----------------------|--------------------------------------------------------------------------------------------------------|---------------|------------------|--------------|--------|----------|------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| s4254   | Movie | Black Mirror: Bandersnatch    | NULL                  | Fionn Whitehead, Will Poulter, Craig Parkinson, Alice Lowe, Asim Chaudhry                              | United States | December 28, 2018| 2018         | TV-MA  | 312 min  | Dramas, International Movies, Sci-Fi & Fantasy | In 1984, a young programmer begins to question reality as he adapts a dark fantasy novel into a video game. A mind-bending tale with multiple endings.                                                                                                    |
| s718    | Movie | Headspace: Unwind Your Mind   | NULL                  | Andy Puddicombe, Evelyn Lewis Prieto, Ginger Daniels, Darren Pettie, Simon Prebble, Rhiannon Mcgavin, Kate Seftel | NULL          | June 15, 2021    | 2021         | TV-G   | 273 min  | Documentaries                            | Do you want to relax, meditate or sleep deeply? Personalize the experience according to your mood or mindset with this Headspace interactive special.                                                                                                 |
| s2492   | Movie | The School of Mischief        | Houssam El-Din Mustafa| Suhair El-Babili, Adel Emam, Saeed Saleh, Younes Shalabi, Hadi El-Gayyar, Ahmad Zaki, Hassan Moustafa | Egypt         | May 21, 2020     | 1973         | TV-14  | 253 min  | Comedies, Dramas, International Movies   | A high school teacher volunteers to transform five notorious misfits into model students GÇö and has unintended results.                                                                                                                                |
| s2488   | Movie | No Longer kids                | Samir Al Asfory       | Said Saleh, Hassan Moustafa, Ahmed Zaki, Younes Shalabi, Nadia Shukri, Karima Mokhtar                  | Egypt         | May 21, 2020     | 1979         | TV-14  | 237 min  | Comedies, Dramas, International Movies   | Hoping to prevent their father from skipping town with his mistress, four rowdy siblings resort to absurd measures to stop him.                                                                                                                        |
| s2485   | Movie | Lock Your Girls In            | Fouad El-Mohandes     | Fouad El-Mohandes, Sanaa Younes, Sherihan, Ahmed Rateb, Ijlal Zaki, Zakariya Mowafi                    | NULL          | May 21, 2020     | 1982         | TV-PG  | 233 min  | Comedies, International Movies, Romantic Movies | A widower believes he must marry off his three problematic daughters before he can pursue his real goal of marrying his secret love.                                                                                                                 |


### 6-Content Added in the Last 5 Years
#### The query :
```sql
SELECT * 
FROM netflix 
WHERE release_year >= YEAR(GETDATE()) - 5
ORDER BY release_year;
```

### output of the query :

| show_id | type    | title                                      | director                              | casts                                                                                                                                                                                                            | country       | date_added       | release_year | rating  | duration  | listed_in                                         | description                                                                                                                                                                                                                                                                                          |
|---------|---------|--------------------------------------------|---------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|------------------|--------------|---------|-----------|---------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| s1      | Movie   | Dick Johnson Is Dead                       | Kirsten Johnson                       | NULL                                                                                                                                                                                                             | United States | September 25, 2021 | 2020         | PG-13   | 90 min    | Documentaries                                     | As her father nears the end of his life, filmmaker Kirsten Johnson stages his death in inventive and comical ways to help them both face the inevitable.                                                                                                                                                |
| s17     | Movie   | Europe's Most Dangerous Man: Otto Skorzeny in Spain | Pedro de Echave García, Pablo Azorín Williams | NULL                                                                                                                                                                                                             | NULL          | September 22, 2021 | 2020         | TV-MA   | 67 min    | Documentaries, International Movies               | Declassified documents reveal the post-WWII life of Otto Skorzeny, a close Hitler ally who escaped to Spain and became an adviser to world presidents.                                                                                                                                           |
| s18     | TV Show | Falsa identidad                            | NULL                                  | Luis Ernesto Franco, Camila Sodi, Sergio Goyri, Samadhi Zendejas, Eduardo Yáñez, Sonya Smith, Alejandro Camacho, Azela Robinson, Uriel del Toro, Géraldine Bazán, Gabriela Roel, Marcus Ornellas                  | Mexico        | September 22, 2021 | 2020         | TV-MA   | 2 Seasons   | Crime TV Shows, Spanish-Language TV Shows, TV Dramas | Strangers Diego and Isabel flee their home in Mexico and pretend to be a married couple to escape his drug-dealing enemies and her abusive husband.                                                                                                                                                    |
| s48     | TV Show | The Smart Money Woman                      | Bunmi Ajakaiye                        | Osas Ighodaro, Ini Dima-Okojie, Kemi Lala Akindoju, Toni Tones, Ebenezer Eno, Eso Okolocha DIke, Patrick Diabuah, Karibi Fubara, Temisan Emmanuel, Timini Egbuson                                                 | NULL          | September 16, 2021 | 2020         | TV-MA   | 1 Season  | International TV Shows, Romantic TV Shows, TV Comedies | Five glamorous millennials strive for success as they juggle careers, finances, love and friendships. Based on Arese Ugwu's 2016 best-selling novel.                                                                                                                                                  |
| s35     | TV Show | Tayo and Little Wizards                    | NULL                                  | Dami Lee, Jason Lee, Bommie Catherine Han, Jennifer Waescher, Nancy Kim                                                                                                                                          | NULL          | September 17, 2021 | 2020         | TV-Y7   | 1 Season  | Kids' TV                                          | Tayo speeds into an adventure when his friends get kidnapped by evil magicians invading their city in search of a magical gemstone.                                                                                                                                                                |

### 7-Movies/TV Shows by Director 'Marcus Raboy'
#### The query :
```sql
SELECT * 
FROM netflix 
CROSS APPLY STRING_SPLIT(director, ',') AS director
WHERE director = 'Marcus Raboy';
```

### output of the query :

| show_id | type    | title                               | director    | casts                           | country       | date_added     | release_year | rating | duration | listed_in                                | description                                                                                                                                                                                                               | value       |
|---------|---------|-------------------------------------|-------------|---------------------------------|---------------|----------------|--------------|--------|----------|------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
| s2508   | TV Show | Patton Oswalt: I Love Everything    | Marcus Raboy| Patton Oswalt, Bob Rubin        | United States | May 19, 2020   | 2020         | TV-MA  | 1 Season | Stand-Up Comedy & Talk Shows, TV Comedies| Turning 50. Finding love again. Buying a house. Experiencing existential dread at Denny's. Life comes at Patton Oswalt fast in this stand-up special.                                                                     | Marcus Raboy|
| s2850   | Movie   | Taylor Tomlinson: Quarter-Life Crisis | Marcus Raboy| Taylor Tomlinson                | United States | March 3, 2020  | 2020         | TV-MA  | 61 min   | Stand-Up Comedy                          | She's halfway through her 20s GÇö and she's over it. Too old to party, too young to settle down, comedian Taylor Tomlinson takes aim at her life choices.                                                               | Marcus Raboy|
| s3636   | Movie   | Whitney Cummings: Can I Touch It?   | Marcus Raboy| Whitney Cummings                | NULL          | July 30, 2019  | 2019         | TV-MA  | 59 min   | Stand-Up Comedy                          | In her fourth stand-up special, Whitney Cummings returns to her hometown of Washington, D.C., and riffs on modern feminism, technology and more.                                                                             | Marcus Raboy|
| s3777   | Movie   | Miranda Sings LiveGÇªYour Welcome  | Marcus Raboy| Colleen Ballinger               | United States | June 4, 2019   | 2019         | TV-14  | 62 min   | Stand-Up Comedy                          | Viral video star Miranda Sings and her real-world alter ego Colleen Ballinger share the stage in a special packed with music, comedy and "magichinry."                                                                    | Marcus Raboy|
| s3878   | Movie   | Anthony Jeselnik: Fire in the Maternity Ward | Marcus Raboy| Anthony Jeselnik                | United States | April 30, 2019 | 2019         | TV-MA  | 64 min   | Stand-Up Comedy                          | Forging his own comedic boundaries, Anthony Jeselnik revels in getting away with saying things others can't in this stand-up special shot in New York.                                                                        | Marcus Raboy|

### 8-TV Shows with More Than 5 Seasons
#### The query :
```sql
SELECT *
FROM netflix 
WHERE type = 'TV Show' AND CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT) > 5
ORDER BY CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT);
```

### output of the query :

| show_id | type    | title                     | director | casts                                                                                                                                                                                                                                                         | country       | date_added       | release_year | rating | duration  | listed_in                                | description                                                                                                                                                                                                                                                                                               |
|---------|---------|---------------------------|----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|------------------|--------------|--------|-----------|------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| s56     | TV Show | Nailed It                 | NULL     | Nicole Byer, Jacques Torres                                                                                                                                                                                                                   | United States | September 15, 2021 | 2021         | TV-PG  | 6 Seasons | Reality TV                               | Home bakers with a terrible track record take a crack at re-creating edible masterpieces for a $10,000 prize. It's part reality contest, part hot mess.                                                                                                                                                        |
| s66     | TV Show | Numberblocks              | NULL     | Beth Chalmers, David Holt, Marcel McCalla, Teresa Gallagher                                                                                                                                                                                   | United Kingdom| September 15, 2021 | 2021         | TV-Y   | 6 Seasons | Kids' TV                                 | In a place called Numberland, math adds up to tons of fun when a group of cheerful blocks work, play and sing together.                                                                                                                                                                                      |
| s83     | TV Show | Lucifer                   | NULL     | Tom Ellis, Lauren German, Kevin Alejandro, D.B. Woodside, Lesley-Ann Brandt, Scarlett Estevez, Rachael Harris, Aimee Garcia, Tricia Helfer, Tom Welling, Jeremiah W. Birkett, Pej Vahdat, Michael Gladis                                           | United States | September 10, 2021 | 2021         | TV-14  | 6 Seasons | Crime TV Shows, TV Comedies, TV Dramas   | Bored with being the Lord of Hell, the devil relocates to Los Angeles, where he opens a nightclub and forms a connection with a homicide detective.                                                                                                                                                         |
| s339    | TV Show | Hunter X Hunter (2011)    | NULL     | Megumi Han, Mariya Ise, Keiji Fujiwara, Miyuki Sawashiro, Daisuke Namikawa                                                                                                                                                                     | Japan         | August 1, 2021   | 2014         | TV-14  | 6 Seasons | Anime Series, International TV Shows     | To fulfill his dreams of becoming a legendary Hunter like his dad, a young boy must pass a rigorous examination and find his missing father.                                                                                                                                                               |
| s668    | TV Show | Glee                      | NULL     | Lea Michele, Chris Colfer, Jane Lynch, Matthew Morrison, Cory Monteith, Naya Rivera, Kevin McHale, Jenna Ushkowitz, Amber Riley, Mark Salling, Heather Morris, Harry Shum Jr., Jayma Mays, Dianna Agron | United States | June 19, 2021    | 2015         | TV-14  | 6 Seasons | TV Comedies, TV Dramas, Teen TV Shows    | Amid relationship woes and personal attacks from a wicked cheerleading coach, a teacher fights to turn underdog glee club members into winners.                                                                                                                                                           |

### 9-Count Content Items in Each Genre
#### The query :
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

### output of the query :

| genra                | total_content |
|----------------------|---------------|
| International Movies | 2752          |
| Dramas               | 2427          |
| Comedies             | 1674          |
| International TV Shows | 1351          |
| Documentaries        | 869           |

### 10-Yearly Content Release in the USA and Average Releases per Year
#### The query :
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

### output of the query :

| country       | release_year | total_release | avg_release |
|---------------|--------------|---------------|-------------|
| United States | 2018         | 356           | 52.71       |
| United States | 2017         | 352           | 52.71       |
| United States | 2019         | 351           | 52.71       |
| United States | 2020         | 336           | 52.71       |
| United States | 2016         | 263           | 52.71       |

### 11-List All Movies That Are Documentaries
#### The query :
```sql
SELECT *
FROM netflix 
WHERE type = 'movie' AND listed_in LIKE '%Documentaries%'
ORDER BY release_year DESC;
```

### output of the query :

| show_id | type  | title                               | director                                | casts                       | country       | date_added       | release_year | rating | duration | listed_in                               | description                                                                                                                                                                                                            |
|---------|-------|-------------------------------------|-----------------------------------------|-----------------------------|---------------|------------------|--------------|--------|----------|-----------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| s46     | Movie | My Heroes Were Cowboys              | Tyler Greco                             | NULL                        | NULL          | September 16, 2021 | 2021         | PG     | 23 min   | Documentaries                           | Robin Wiltshire's painful childhood was rescued by Westerns. Now he lives on the frontier of his dreams, training the horses he loves for the big screen.                                                               |
| s69     | Movie | Schumacher                          | Hanns-Bruno Kammertöns, Vanessa Näcker, Michael Wech | Michael Schumacher          | NULL          | September 15, 2021 | 2021         | TV-14  | 113 min  | Documentaries, International Movies, Sports Movies | Through exclusive interviews and archival footage, this documentary traces an intimate portrait of seven-time Formula 1 champion Michael Schumacher.                                                                      |
| s89     | Movie | Blood Brothers: Malcolm X & Muhammad Ali | Marcus Clarke                           | Malcolm X, Muhammad Ali     | NULL          | September 9, 2021  | 2021         | PG-13  | 96 min   | Documentaries, Sports Movies            | From a chance meeting to a tragic fallout, Malcolm X and Muhammad Ali's extraordinary bond cracks under the weight of distrust and shifting ideals.                                                                      |
| s92     | Movie | The Women and the Murderer          | Mona Achache, Patricia Tourancheau      | NULL                        | France        | September 9, 2021  | 2021         | TV-14  | 92 min   | Documentaries, International Movies     | This documentary traces the capture of serial killer Guy Georges through the tireless work of two women: a police chief and a victim's mother.                                                                            |
| s102    | Movie | Untold: Breaking Point              | Chapman Way, Maclain Way                | NULL                        | United States | September 7, 2021  | 2021         | TV-MA  | 80 min   | Documentaries, Sports Movies            | Under pressure to continue a winning tradition in American tennis, Mardy Fish faced mental health challenges that changed his life on and off the court.                                                                  |

### 12-Find Content Without a Director
#### The query :
```sql
SELECT *
FROM netflix 
WHERE director IS NULL;
```


### output of the query :

| show_id | type    | title                         | director | casts                                                                                                                                                                                                                                                                       | country      | date_added       | release_year | rating | duration  | listed_in                                         | description                                                                                                                                                                                                                                                                                                 |
|---------|---------|-------------------------------|----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------|------------------|--------------|--------|-----------|---------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| s2      | TV Show | Blood & Water                 | NULL     | Ama Qamata, Khosi Ngema, Gail Mabalane, Thabang Molaba, Dillon Windvogel, Natasha Thahane, Arno Greeff, Xolile Tshabalala, Getmore Sithole, Cindy Mahlangu, Ryle De Morny, Greteli Fincham, Sello Maake Ka-Ncube, Odwa Gwanya, Mekaila Mathys, Sandi Schultz, Duane Williams, Shamilla Miller, Patrick Mofokeng | South Africa | September 24, 2021 | 2021         | TV-MA  | 2 Seasons | International TV Shows, TV Dramas, TV Mysteries   | After crossing paths at a party, a Cape Town teen sets out to prove whether a private-school swimming star is her sister who was abducted at birth.                                                                                                                                                           |
| s4      | TV Show | Jailbirds New Orleans         | NULL     | NULL                                                                                                                                                                                                                                                                        | NULL         | September 24, 2021 | 2021         | TV-MA  | 1 Season  | Docuseries, Reality TV                            | Feuds, flirtations and toilet talk go down among the incarcerated women at the Orleans Justice Center in New Orleans on this gritty reality series.                                                                                                                                                         |
| s5      | TV Show | Kota Factory                  | NULL     | Mayur More, Jitendra Kumar, Ranjan Raj, Alam Khan, Ahsaas Channa, Revathi Pillai, Urvi Singh, Arun Kumar                                                                                                                                                                  | India        | September 24, 2021 | 2021         | TV-MA  | 2 Seasons | International TV Shows, Romantic TV Shows, TV Comedies | In a city of coaching centers known to train IndiaGÇÖs finest collegiate minds, an earnest but unexceptional student and his friends navigate campus life.                                                                                                                                                    |
| s11     | TV Show | Vendetta: Truth, Lies and The Mafia | NULL     | NULL                                                                                                                                                                                                                                                                        | NULL         | September 24, 2021 | 2021         | TV-MA  | 1 Season  | Crime TV Shows, Docuseries, International TV Shows | Sicily boasts a bold "Anti-Mafia" coalition. But what happens when those trying to bring down organized crime are accused of being criminals themselves?                                                                                                                                                  |
| s15     | TV Show | Crime Stories: India Detectives | NULL     | NULL                                                                                                                                                                                                                                                                        | NULL         | September 22, 2021 | 2021         | TV-MA  | 1 Season  | British TV Shows, Crime TV Shows, Docuseries     | Cameras following Bengaluru police on the job offer a rare glimpse into the complex and challenging inner workings of four major crime investigations.                                                                                                                                                  |

### 13-Movies Actor 'Adam Sandler' Appeared in the Last 10 Years
#### The query :
```sql
SELECT *
FROM netflix
WHERE casts LIKE '%Adam Sandler%'
  AND release_year > YEAR(GETDATE()) - 10;
```

### output of the query :

| show_id | type  | title                         | director                  | casts                                                                                                                                                                                                                                                                 | country       | date_added     | release_year | rating | duration  | listed_in                    | description                                                                                                                                                                                                                                                                                             |
|---------|-------|-------------------------------|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|----------------|--------------|--------|-----------|------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| s1880   | Movie | Hubie Halloween               | Steve Brill               | Adam Sandler, Kevin James, Julie Bowen, Ray Liotta, Steve Buscbuscemi, Maya Rudolph, Rob Schneider, June Squibb, Kenan Thompson, Tim Meadows, Michael Chiklis, Karan Brar, George Wallace, Paris Berelc, Noah Schnapp, China Anne McClain, Colin Quinn, Kym Whitley, Lavell Crawford, Mikey Day, Jackie Sandler, Sadie Sandler, Sunny Sandler | United States | October 7, 2020| 2020         | PG-13  | 104 min   | Comedies, Horror Movies      | Hubie's not the most popular guy in Salem, Mass., but when Halloween turns truly spooky, this good-hearted scaredy-cat sets out to keep his town safe.                                                                                                                                                        |
| s2472   | Movie | Uncut Gems                    | Josh Safdie, Benny Safdie | Adam Sandler, LaKeith Stanfield, Kevin Garnett, Julia Fox, Idina Menzel, Eric Bogosian, Judd Hirsch, Abel Tesfaye                                                                                                                                               | United States | May 25, 2020   | 2019         | R      | 135 min   | Dramas, Thrillers            | With his debts mounting and angry collectors closing in, a fast-talking New York City jeweler risks everything in hopes of staying afloat and alive.                                                                                                                                                             |
| s3754   | Movie | Murder Mystery                | Kyle Newacheck            | Adam Sandler, Jennifer Aniston, Luke Evans, Gemma Arterton, Adeel Akhtar, Luis Gerardo Méndez, Dany Boon, Terence Stamp                                                                                                                                         | United States | June 14, 2019  | 2019         | PG-13  | 98 min    | Comedies                     | On a long-awaited trip to Europe, a New York City cop and his hairdresser wife scramble to solve a baffling murder aboard a billionaire's yacht.                                                                                                                                                            |
| s4483   | Movie | ADAM SANDLER 100% FRESH       | Steve Brill               | Adam Sandler                                                                                                                                                                                                                                                    | United States | October 23, 2018| 2018         | TV-MA  | 74 min    | Stand-Up Comedy              | From "Heroes" to "Ice Cream Ladies" – Adam Sandler's comedy special hits you with new songs and jokes in an unexpected, groundbreaking way.                                                                                                                                                                 |
| s4913   | Movie | The Week Of                   | Robert Smigel             | Adam Sandler, Chris Rock, Steve Buscemi, Rachel Dratch, Allison Strong, Roland Buck III, Katie Hartman, Chloe Himmelman, Jake Lippmann, Jim Barone, June Gable                                                                                              | United States | April 27, 2018 | 2018         | TV-14  | 117 min   | Comedies                     | Two fathers with clashing views about their children's upcoming wedding struggle to keep it together during the chaotic week before the big day.                                                                                                                                                              |

### 14-Top 10 Actors Appearing in Movies Produced in the USA
#### The query :
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

### output of the query :

| type  | actor           | country       | count_of_movie |
|-------|-----------------|---------------|----------------|
| Movie | Adam Sandler    | United States | 20             |
| Movie | Samuel L. Jackson | United States | 18             |
| Movie | Laura Bailey    | United States | 14             |
| Movie | Nicolas Cage    | United States | 13             |
| Movie | James Franco    | United States | 13             |
| Movie | Molly Shannon   | United States | 13             |
| Movie | Erin Fitzgerald | United States | 12             |
| Movie | Fred Tatasciore | United States | 12             |
| Movie | Kate Higgins    | United States | 12             |
| Movie | Dennis Quaid    | United States | 12             |

### 15-Categorize Content Based on 'Kill' and 'Violence' Keywords
#### The query :
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

### output of the query :

| type    | title                       | rating | listed_in                                   | category          | description                                                                                                                                                                                                            |
|---------|-----------------------------|--------|---------------------------------------------|-------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Movie   | Jaws 2                      | PG     | Dramas, Horror Movies, Thrillers            | contain violence  | Four years after the last deadly shark attacks, police chief Martin Brody fights to protect Amity Island from another killer great white.                                                                                |
| Movie   | Je Suis Karl                | TV-MA  | Dramas, International Movies                | contain violence  | After most of her family is murdered in a terrorist bombing, a young woman is unknowingly lured into joining the very group that killed them.                                                                            |
| Movie   | The Women and the Murderer  | TV-14  | Documentaries, International Movies         | contain violence  | This documentary traces the capture of serial killer Guy Georges through the tireless work of two women: a police chief and a victim's mother.                                                                            |
| TV Show | Dive Club                   | TV-G   | Kids' TV, TV Dramas, Teen TV Shows          | contain violence  | On the shores of Cape Mercy, a skillful group of teen divers investigate a series of secrets and signs after one of their own mysteriously goes missing.                                                                 |
| TV Show | Ganglands                   | TV-MA  | Crime TV Shows, International TV Shows, TV Action & Adventure | contain violence  | To protect his family from a powerful drug lord, skilled thief Mehdi and his expert team of robbers are pulled into a violent and deadly turf war.                                                                        |

## Requirements
Microsoft SQL Server
A CSV file containing Netflix data, formatted as netflix_titles.csv
<br></br>

## Conclusion
This project provides a range of SQL queries to analyze Netflix content.
It includes categorizing data by type, duration, director, actor, and genre, as well as identifying trends in release years, countries, and content ratings.
By running these queries, we gain insights into the distribution and characteristics of Netflix’s catalog.
