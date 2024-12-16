# Spotify Advanced SQL Project and Query Optimization 
Project Category: Advanced

![Spotify Logo](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_logo.jpg)

## Overview
This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.

```sql
-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
```
## Project Steps

### 1. Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

### 2. Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into **easy**, **medium**, and **advanced** levels to help progressively develop SQL proficiency.

#### Easy Queries
- Simple data retrieval, filtering, and basic aggregations.
  
#### Medium Queries
- More complex queries involving grouping, aggregation functions, and joins.
  
#### Advanced Queries
- Nested subqueries, window functions, CTEs, and performance optimization.

### 3. Query Optimization
In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:
- **Indexing**: Adding indexes on frequently queried columns.
- **Query Execution Plan**: Using `EXPLAIN ANALYZE` to review and refine query performance.
  
---

## 15 Practice Questions

### Easy Level
1. Retrieve the names of all tracks that have more than 1 billion streams.
```sql
Select * from spotify
where stream > 1000000000;
```
2. List all albums along with their respective artists.
```sql
Select 
	distinct album,artist
from spotify
order by 1;--there could be more than one or two artist work in a single album.

Select 
	distinct album
from spotify
order by 1;
```
3. Get the total number of comments for tracks where `licensed = TRUE`.
```sql
Select 
	SUM(comments) AS Total_Comments 
	from spotify
where licensed = 'true';
```
4. Find all tracks that belong to the album type `single`.
```sql
Select * from spotify
where album_type = 'single';
```
5. Count the total number of tracks by each artist.
```sql

Select 	
	artist,
	count(*) as total_no_songs
from spotify
group by artist
order by 2;
```

### Medium Level
1. Calculate the average danceability of tracks in each album.
```sql
Select
	album,
	avg(danceability) as Avg_danceability
from spotify
Group by album
order by 2 desc;
```
2. Find the top 5 tracks with the highest energy values.
```sql
Select
	track,
	MAX(energy) as Top_5_tracks_with_highest_enery_values
from spotify
Group by 1
order by 2 desc
limit 5;
```
3. List all tracks along with their views and likes where `official_video = TRUE`.
```sql
Select 
	track,
	sum(views) as Total_views,
	SUM(likes) as Total_likes
from spotify
where official_video = 'true'
Group by 1
order by 2 desc
limit 5;
```
4. For each album, calculate the total views of all associated tracks.
```sql
Select 
	album,
	track,
	sum(views) as Total_views
from spotify
Group by 1,2
order by 3 desc
limit 5;
```
5. Retrieve the track names that have been streamed on Spotify more than YouTube.
```sql
Select * from
(Select 
	track,
	---most_played_on,
	COALESCE(SUM(CASE WHEN most_played_on = 'Youtube' Then stream END),0) as streamed_on_Youtube,
	COALESCE(SUM(CASE WHEN most_played_on = 'Spotify' Then stream END),0) as streamed_on_spotify
From spotify 
Group by 1
) as t1
Where
	streamed_on_spotify > streamed_on_Youtube
	AND
	streamed_on_Youtube <> 0;
```

### Advanced Level
1. Find the top 3 most-viewed tracks for each artist using window functions.
```sql
with ranking_artist
as
(Select 
	artist,
	track,
	sum(views) as total_views,
	DENSE_RANK() OVER(PARTITION BY ARTIST ORDER BY SUM(VIEWS) DESC) AS RANK
FROM spotify
Group by 1,2
order by 1,3 desc
)
select * from ranking_artist
where rank <=3;
```
2. Write a query to find tracks where the liveness score is above the average.
```sql
Select 
	track,
	artist,
	liveness
from spotify
where liveness >(Select avg(liveness) from spotify);
```
3. **Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**
```sql
WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC
```
4. Find tracks where the energy-to-liveness ratio is greater than 1.2.
```sql
SELECT 
	track,
	energy_liveness AS energy_to_liveness_ratio
FROM Spotify 
	WHERE energy_liveness > 1.2 ;
```
5. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
```sql
SELECT 
	track,
	SUM(likes) OVER (ORDER BY views) AS cumulative_sum
FROM Spotify
ORDER BY 3 DESC ;
```

---

## Query Optimization Technique 

To improve query performance, we carried out the following optimization process:

- **Initial Query Performance Analysis Using `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **7 ms**
        - Planning time (P.T.): **0.17 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
      ![EXPLAIN Before Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_before_index.png)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX idx_artist ON spotify_tracks(artist);
      ```

- **Performance Analysis After Index Creation**
    - After creating the index, we ran the same query again and observed significant improvements in performance:
        - Execution time (E.T.): **0.153 ms**
        - Planning time (P.T.): **0.152 ms**
    - Below is the **screenshot** of the `EXPLAIN` result after index creation:
      ![EXPLAIN After Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_after_index.png)

- **Graphical Performance Comparison**
    - A graph illustrating the comparison between the initial query execution time and the optimized query execution time after index creation.
    - **Graph view** shows the significant drop in both execution and planning times:
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%203.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%202.png)
      ![Performance Graph](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_graphical%20view%201.png)

This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.
---

## Technology Stack
- **Database**: PostgreSQL
- **SQL Queries**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions.
- **Tools**: pgAdmin 4 (or any SQL editor), PostgreSQL.






