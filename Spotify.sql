

-- SQL Advanced Project: Spotify Data Analysis


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










-- Exploratory Data Analysis (EDA)

-- Total number of rows
SELECT COUNT(*) FROM Spotify;
-- Result: 20,594 tracks

-- Number of distinct artists
SELECT COUNT(DISTINCT Artist) FROM Spotify;
-- Result: 2,074 distinct artists

-- Number of distinct albums
SELECT COUNT(DISTINCT Album) FROM Spotify;
-- Result: 11,854 distinct albums

-- Different types of albums
SELECT DISTINCT Album_type FROM Spotify;
-- Result: album, compilation, single

-- Maximum duration
SELECT MAX(Duration_min) FROM Spotify;
-- Result: ~77 minutes

-- Minimum duration
SELECT MIN(Duration_min) FROM Spotify;
-- Result: 0 (indicates data inconsistency)

-- Check for tracks with zero duration
SELECT * FROM Spotify WHERE Duration_min  = 0;
-- Result: 2 tracks with zero duration

-- Delete tracks with zero duration
DELETE FROM Spotify WHERE Duration_min = 0;

-- Verify deletion
SELECT COUNT(*) FROM Spotify;
-- Result: 20,592 tracks (2 tracks deleted)

-- Distinct channels
SELECT COUNT(DISTINCT Channel) FROM Spotify;
-- Result: 6,723 channels

-- Distinct most_played_on values
SELECT DISTINCT most_played_on FROM Spotify;
-- Result: Spotify, YouTube

-- Easy Level Questions

-- Q1: Retrieve the names of all tracks that have more than 1 billion streams
SELECT * FROM Spotify WHERE Stream > 1000000000;
-- Result: 385 tracks

-- Q2: List all albums along with their respective artists
SELECT Album, Artist FROM Spotify;


-- Verify distinct albums
SELECT COUNT(DISTINCT Album) FROM Spotify;
-- Result: 11,854 distinct albums

-- Q3: Get the total number of comments for tracks where Licensed is true
SELECT SUM(Comments) AS total_comments FROM Spotify WHERE Licensed = true;
-- Result: Total comments (less than 1 billion)

-- Q4: Find all tracks that belong to the album type 'single'
SELECT * FROM Spotify WHERE Album_type = 'single';


-- Q5: Count the total number of tracks by each artist
SELECT Artist, COUNT(*) AS total_number_of_songs
FROM Spotify
GROUP BY Artist
ORDER BY total_number_of_songs DESC;
-- Result: Lists artists with their track counts, e.g., top artists have 10 songs

-- Medium Level Questions

-- Q6: Calculate the average danceability of tracks in each album
SELECT Album, AVG(Danceability) AS average_danceability
FROM Spotify
GROUP BY Album
ORDER BY average_danceability DESC;
-- Result: Albums with highest average danceability (e.g., Simp Funky Friday: 0.975)

-- Q7: Find the top 5 tracks with the highest energy values
SELECT Track, MAX(Energy) AS max_energy
FROM Spotify
GROUP BY Track
ORDER BY max_energy DESC
LIMIT 5;
-- Result: Top 5 tracks with highest energy values (some have energy = 1)

-- Q8: List all tracks along with their views and likes where the official video is true
SELECT Track, SUM(Views) AS total_views, SUM(Likes) AS total_likes
FROM Spotify
WHERE official_video = true
GROUP BY Track;
-- Result: 13,000 tracks with their total views and likes

-- Q9: For each album, calculate the total views of all associated tracks
SELECT Album, Track, SUM(Views) AS total_views
FROM Spotify
GROUP BY Album, Track
ORDER BY total_views DESC;
-- Result: 18,680 records, highest view album/track has 1.6 billion views

-- Q10: Retrieve track names that have been streamed on Spotify more than YouTube
WITH st1 AS (
    SELECT 
        Track,
        SUM(CASE WHEN most_played_on = 'YouTube' THEN Stream ELSE 0 END) AS stream_on_youtube,
        SUM(CASE WHEN most_played_on = 'Spotify' THEN Stream ELSE 0 END) AS stream_on_spotify
    FROM Spotify
    GROUP BY Track
)
SELECT *
FROM st1
WHERE stream_on_spotify > stream_on_youtube
AND stream_on_youtube > 0;


-- Advanced Level Questions

-- Q11: Find the top 3 most viewed tracks for each artist using window functions
WITH ranking_artist AS (
    SELECT 
        Artist,
        Track,
        SUM(Views) AS total_views,
        DENSE_RANK() OVER (PARTITION BY Artist ORDER BY SUM(Views) DESC) AS rank
    FROM Spotify
    GROUP BY Artist, Track
)
SELECT *
FROM ranking_artist
WHERE rank <= 3;
-- Result: 689 records, top 3 tracks per artist based on views

-- Q12: Write a query to find tracks where the liveness score is above the average
SELECT Track, Artist, Liveness
FROM Spotify
WHERE Liveness > (SELECT AVG(Liveness) FROM Spotify);
-- Result: 6,478 tracks with liveness above average (0.19)

-- Q13: Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album
WITH cte AS (
    SELECT 
        Album,
        MAX(Energy) AS highest_energy,
        MIN(Energy) AS lowest_energy
    FROM Spotify
    GROUP BY Album
)
SELECT Album, (highest_energy - lowest_energy) AS energy_difference
FROM cte
ORDER BY energy_difference DESC;
-- Result: Albums with their energy differences, highest difference is 0.9

-- Query Optimization Example

-- Query without index
EXPLAIN ANALYZE
SELECT Artist, Track, Views
FROM Spotify
WHERE Artist = 'Gorillaz'
AND most_played_on = 'YouTube'
ORDER BY Views DESC
LIMIT 25;
-- Result: Execution Time: ~7.8 ms, Planning Time: ~0.112 ms (sequence scan)

-- Create index on Artist column
CREATE INDEX artist_index ON Spotify (Artist);

-- Query with index
EXPLAIN ANALYZE
SELECT Artist, Track, Views
FROM Spotify
WHERE Artist = 'Gorillaz'
AND most_played_on = 'YouTube'
ORDER BY Views DESC
LIMIT 25;
-- Result: Execution Time: ~1 ms (index scan, ~700% faster)

-- Drop index (for demonstration)
DROP INDEX artist_index;

-- Note: Avoid over-indexing as it can slow down DML operations (INSERT, UPDATE, DELETE).