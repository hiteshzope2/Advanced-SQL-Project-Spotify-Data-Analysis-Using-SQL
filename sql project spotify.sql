--- Advanced Sql Project---Spotify Datasets

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

---EDA---

Select count(*) from spotify;

Select count(distinct artist) from spotify;

Select count(distinct album) from spotify;

Select distinct album_type from spotify;

Select MAX(duration_min) from spotify;

Select MIN(duration_min) from spotify;

Select * from spotify
where duration_min=0;

Delete from spotify
where duration_min=0;

Select distinct channel from spotify;

Select distinct most_played_on from spotify;



-------------------------------------------------
----DATA ANALYSIS----
-------------------------------------------------

---Q.1:Retrieve the names of all tracks that have more than 1 billion streams.

Select * from spotify
where stream > 1000000000;

---Q.2:List all albums along with their respective artists.

Select 
	distinct album,artist
from spotify
order by 1;--there could be more than one or two artist work in a single album.

Select 
	distinct album
from spotify
order by 1;

---Q.3:Get the total number of comments for tracks where licensed = TRUE.

Select 
	SUM(comments) AS Total_Comments 
	from spotify
where licensed = 'true';

---Q.4:Find all tracks that belong to the album type single.

Select * from spotify
where album_type = 'single';

---Q.5:Count the total number of tracks by each artist.

Select 	
	artist,
	count(*) as total_no_songs
from spotify
group by artist
order by 2;

---Q.6:Calculate the average danceability of tracks in each album.

Select
	album,
	avg(danceability) as Avg_danceability
from spotify
Group by album
order by 2 desc;

---Q.7:Find the top 5 tracks with the highest energy values.

Select
	track,
	MAX(energy) as Top_5_tracks_with_highest_enery_values
from spotify
Group by 1
order by 2 desc
limit 5;

---Q.8:List all tracks along with their views and likes where official_video = TRUE.

Select 
	track,
	sum(views) as Total_views,
	SUM(likes) as Total_likes
from spotify
where official_video = 'true'
Group by 1
order by 2 desc
limit 5;

---Q.9:For each album, calculate the total views of all associated tracks.

Select 
	album,
	track,
	sum(views) as Total_views
from spotify
Group by 1,2
order by 3 desc
limit 5;

---Q.10:Retrieve the track names that have been streamed on Spotify more than YouTube.

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

---Q.11:Find the top 3 most-viewed tracks for each artist using window functions.

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

---Q.12:Write a query to find tracks where the liveness score is above the average.

Select 
	track,
	artist,
	liveness
from spotify
where liveness >(Select avg(liveness) from spotify);

---Q.13:Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

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

---Q.14:Find tracks where the energy-to-liveness ratio is greater than 1.2.

SELECT 
	track,
	energy_liveness AS energy_to_liveness_ratio
FROM Spotify 
	WHERE energy_liveness > 1.2 ;

---Q.15:Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT 
	track,
	SUM(likes) OVER (ORDER BY views) AS cumulative_sum
FROM Spotify
ORDER BY 3 DESC ;
