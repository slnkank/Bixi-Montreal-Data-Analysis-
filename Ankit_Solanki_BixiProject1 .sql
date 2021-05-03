-- Bixi Project Part One
# Question 1
	# 1.1 Total trips in the year 2016
	SELECT COUNT(YEAR(start_date)) AS total_trips2016
	FROM trips
	WHERE YEAR(start_date) = 2016;
    
    # 1.2 Total trips in th year 2017
    SELECT COUNT(YEAR(start_date)) AS total_trips2016
	FROM trips
	WHERE YEAR(start_date) = 2017;
    
    #1.3 Total trips in the year 2016 broken down by month
    SELECT MONTH(start_date) AS months_2016, COUNT(MONTH(start_date)) AS total_trips_month
    FROM trips
    WHERE YEAR(start_date) = 2016
    GROUP BY MONTH(start_date)
    ORDER BY MONTH(start_date);
    
    #1.4 Total trips in the year 2017 broken down by month
	SELECT MONTH(start_date) AS months_2017, COUNT(MONTH(start_date)) AS total_trips_month
    FROM trips
    WHERE YEAR(start_date) = 2017
    GROUP BY MONTH(start_date)
    ORDER BY MONTH(start_date);
    
    #1.5 Average number of trips a day by year, month
    SELECT year,month,AVG(total_trips) AS avg_trips_day
	FROM
		(
		SELECT YEAR(start_date) AS year,MONTH(start_date) AS month,DAY(start_date) AS day,COUNT(*) AS total_trips
		FROM trips
		GROUP BY YEAR(start_date),MONTH(start_date),DAY(start_date)
		) As total_trips_summary
	GROUP BY year,month
	ORDER BY year,month;
    
    #1.6 Create table of Question1.5
    CREATE TABLE working_table1
    SELECT year,month,AVG(total_trips) AS avg_trips_day
	FROM
		(
		SELECT YEAR(start_date) As year,MONTH(start_date) as month,DAY(start_date) As day,COUNT(*) AS total_trips
		FROM trips
		GROUP BY YEAR(start_date),MONTH(start_date),DAY(start_date)
		) As total_trips_summary
	GROUP BY year,month
	ORDER BY year,month;

# Question 2
	# 2.1 Total trips by membership status in the year 2017
	SELECT is_member, 
	CASE
		WHEN is_member = 0 THEN 'non-member'
		ELSE 'member'
		END AS membership, total_trips_2017
	FROM 
		(
		SELECT is_member,COUNT(*) as total_trips_2017
		FROM trips
		WHERE YEAR(start_date) = 2017
		GROUP BY is_member
		ORDER by is_member 
		) AS t_2017;
        
	# 2.2 Fraction of total trips that were done by members in year 2017 broken down by month
         -- fractions are in percentage for better representation
	SELECT monthly_trip.is_member, monthly_trip.month, ROUND(monthly_trip.total_by_member * 100 / total_trip.total_by_month,1) AS fract_percent
	FROM
		(
		SELECT is_member,MONTH(start_date) AS month, COUNT(*) AS total_by_member
		FROM trips
		WHERE YEAR(start_date) = 2017
		GROUP BY is_member,month
		ORDER BY month
		) AS monthly_trip
	JOIN
		(
		SELECT MONTH(start_date) AS month, COUNT(*) AS total_by_month
		FROM trips
		WHERE YEAR(start_date) = 2017
		GROUP BY MONTH(start_date)
		) AS total_trip
	ON  monthly_trip.month = total_trip.month
	WHERE monthly_trip.is_member = 1
	GROUP BY monthly_trip.month
	ORDER BY monthly_trip.month;   

# Question 3 answers are in the PDF

# Question 4
	# 4.1 Five most popular starting stations without subquery(4.75 sec)
    SELECT stations.name, COUNT(*) AS total_trips 
	FROM trips
	JOIN stations
	ON trips.start_station_code = stations.code
	GROUP BY stations.name  
	ORDER BY COUNT(*)  DESC
	LIMIT 5;
    
    # 4.2 Five most popular starting stations using subquery (1.44 sec)
    SELECT stations.name,total_trips
	FROM
		(
		SELECT start_station_code, COUNT(*) AS total_trips
		FROM trips
		GROUP BY start_station_code
		ORDER BY COUNT(*)  DESC
		LIMIT 5
		) AS pop_station_code
	JOIN stations
	ON pop_station_code.start_station_code = stations.code;

# Question 5
	# 5.1 number of start and end distribution throughout the day at Mackay / de Maisonneuve
	SELECT start.time_of_day, start.start_total_trips, end.end_total_trips
	FROM	
		(
		SELECT
		CASE
			   WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning"
			   WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon"
			   WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening"
			   ELSE "night"
			   END AS "time_of_day", COUNT(*) AS start_total_trips
		FROM trips
		WHERE start_station_code = 6100 
		GROUP BY time_of_day
		) AS start
	JOIN    
		(
		SELECT
		CASE
			   WHEN HOUR(end_date) BETWEEN 7 AND 11 THEN "morning"
			   WHEN HOUR(end_date) BETWEEN 12 AND 16 THEN "afternoon"
			   WHEN HOUR(end_date) BETWEEN 17 AND 21 THEN "evening"
			   ELSE "night"
			   END AS "time_of_day", COUNT(*) AS end_total_trips
		FROM trips
		WHERE end_station_code = 6100 
		GROUP BY time_of_day
		) AS end
	ON start.time_of_day = end.time_of_day;

# Question 6
	#6.1 Number of Starting trips per station
    SELECT start_station_code, COUNT(*) AS total_per_station
    FROM trips
    GROUP BY start_station_code
    ORDER BY total_per_station DESC;
    
    #6.2 Number of roudtrips for each station
    SELECT start_station_code, total_trips AS total_roundtrips
	FROM
		(
		SELECT start_station_code, end_station_code,COUNT(*) AS total_trips
		FROM trips
		GROUP BY start_station_code,end_station_code
		ORDER BY total_trips DESC
		) AS t
	WHERE start_station_code = end_station_code
	ORDER BY total_roundtrips DESC; 
    
    #6.3 Fraction of round trips to the total number of starting trips for each station
    --   Creating a view table to further filter down the results in the next query
    CREATE VIEW fract_roundtrip AS
    SELECT s.start_station_code, total_roundtrips * 100 / total_per_station AS fract_percent
		FROM
			(
			SELECT start_station_code, COUNT(*) AS total_per_station
			FROM trips
			GROUP BY start_station_code
			ORDER BY total_per_station DESC
			) AS s 
		JOIN
			(
			SELECT start_station_code, total_trips AS total_roundtrips
			FROM
				(
				SELECT start_station_code, end_station_code,COUNT(*) AS total_trips
				FROM trips
				GROUP BY start_station_code,end_station_code
				ORDER BY total_trips DESC
				) AS t
			WHERE start_station_code = end_station_code
			ORDER BY total_roundtrips DESC
			) AS r
		ON s.start_station_code = r.start_station_code
		GROUP BY s.start_station_code
		ORDER BY fract_percent DESC;
        
        #6.4 Stations with at least 500 trips originating from them and at least 10% of their trips as round trips
        SELECT s.start_station_code, s.total_per_station, fract_roundtrip.fract_percent
	    FROM
		    (
		    SELECT start_station_code, COUNT(*) AS total_per_station
		    FROM trips
		    GROUP BY start_station_code
		    ORDER BY total_per_station DESC
		    ) AS s
	   JOIN fract_roundtrip # view table from 6.3
	   ON s.start_station_code = fract_roundtrip.start_station_code
	   WHERE s.total_per_station >= 500 AND fract_roundtrip.fract_percent >= 10
	   ORDER BY fract_roundtrip.fract_percent DESC;
    