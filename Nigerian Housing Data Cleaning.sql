SELECT * 
	FROM nigeria_houses_data
	ORDER BY 8;

SELECT title, town, state, price
	FROM nigeria_houses_data
    ORDER BY title;
    
SELECT DISTINCT title
	FROM nigeria_houses_data;
    
SELECT * 
	FROM nigeria_houses_data
	WHERE state = "lagos" AND town = "Ibeju Lekki";
    
SELECT * 
	FROM nigeria_houses_data
	WHERE (bathrooms = 3 AND toilets = 3 AND parking_space= 3) AND title = "block of flats";
    
-- No of Rsidences per State and average prices
    
SELECT state, AVG(price), COUNT(state)
	FROM nigeria_houses_data
    GROUP BY state
    ORDER BY 3 DESC;
    
SELECT state, AVG(price), AVG(bedrooms), AVG(bathrooms),AVG(toilets)
	FROM nigeria_houses_data
    GROUP BY state
    HAVING AVG(bedrooms) > 3 AND AVG(toilets) > 5;
    
SELECT * 
	FROM nigeria_houses_data
    ORDER BY 'price'
	LIMIT 100;
    
SELECT title, count(title)
	FROM nigeria_houses_data
    GROUP BY title;
    
SELECT price, COUNT(price)
	FROM nigeria_houses_data
    GROUP BY price
    ORDER BY 2 DESC;

SELECT title, state, price,
	CASE
		WHEN price >= 50000000 THEN 'Very Expensive'
        WHEN price <= 10000000 THEN 'Affordable'
        WHEN price BETWEEN 10000000 AND 50000000 THEN 'Expensive' 
        WHEN price < 1000000 THEN 'Cheap'
	END AS Affordability
    FROM nigeria_houses_data
    WHERE state = 'lagos';
    
    -- CTE QUERY 1

WITH Affordability_Table AS
(
SELECT title, state, price,
	CASE
		WHEN price >= 50000000 THEN 'Very Expensive'
        WHEN price BETWEEN 1000000 and 10000000 THEN 'Affordable'
        WHEN price BETWEEN 10000000 AND 50000000 THEN 'Expensive' 
        WHEN price < 1000000 THEN 'Cheap'
	END AS Affordability
    FROM nigeria_houses_data
    )
SELECT * 
FROM Affordability_table
WHERE affordability = 'cheap';

-- CTE QUERY 2

WITH Affordability_Table AS
(
SELECT title, state, price,
	CASE
		WHEN price > 100000000 THEN 'Exremely Expensive'
		WHEN price BETWEEN 50000000 AND 100000000 THEN 'Very Expensive'
        WHEN price BETWEEN 1000000 and 10000000 THEN 'Affordable'
        WHEN price BETWEEN 10000000 AND 50000000 THEN 'Expensive' 
        WHEN price < 1000000 THEN 'Cheap'
	END AS Affordability
    FROM nigeria_houses_data
    )
SELECT affordability, COUNT(affordability)
	FROM Affordability_table
	GROUP BY Affordability;
    

CREATE PROCEDURE Housing_affordability()
	WITH Affordability_Table AS
(
SELECT title, state, price,
	CASE
		WHEN price >= 50000000 THEN 'Very Expensive'
        WHEN price BETWEEN 1000000 and 10000000 THEN 'Affordable'
        WHEN price BETWEEN 10000000 AND 50000000 THEN 'Expensive' 
        WHEN price < 1000000 THEN 'Cheap'
	END AS Affordability
    FROM nigeria_houses_data
    )
SELECT * 
FROM Affordability_table;

CALL Housing_affordability;

SELECT *
	FROM nigeria_houses_data
    WHERE state = 'lagos';
SELECT *
	FROM nigeria_houses_data
    WHERE bedrooms > 3;
SELECT *
	FROM nigeria_houses_data
    WHERE bathrooms > 2;
    
CALL new_procedure

-- ADD TRIGGER

DELIMITER $$
CREATE TRIGGER new_property
	AFTER INSERT ON nigeria_houses_data
    FOR EACH ROW 
BEGIN
	INSERT INTO nigeria_houses_data (bedrooms, bathrooms, toilets, state, price, town, parking_space, title)
	VALUES (NEW.bedrooms, NEW.bathrooms, NEW.toilets, NEW.state, NEW.price, NEW.town, NEW.parking_space, NEW.title);
END $$
DELIMITER ;

 INSERT INTO nigeria_houses_data (bedrooms, bathrooms, toilets, state, price, town, parking_space, title)
 VALUES ( 5, 4, 6, 'Edo', 5000000, 'Ugbowo', 2, 'Detatched Duples');
 
 CREATE TABLE nigeria_houses_data_staging
	Like nigeria_houses_data;
    
INSERT INTO nigeria_houses_data_staging
SELECT *
FROM nigeria_houses_data;  

-- Cleaning Data
 
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY bedrooms, bathrooms, toilets, state, price, town, parking_space, title) AS row_num
FROM nigeria_houses_data_staging; 

WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY bedrooms, bathrooms, toilets, state, price, town, parking_space, title) AS row_num
FROM nigeria_houses_data_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `nigeria_houses_data_staging2` (
  `bedrooms` double DEFAULT NULL,
  `bathrooms` double DEFAULT NULL,
  `toilets` double DEFAULT NULL,
  `parking_space` double DEFAULT NULL,
  `title` text,
  `town` text,
  `state` text,
  `price` double DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO nigeria_houses_data_staging2
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY bedrooms, bathrooms, toilets, state, price, town, parking_space, title) AS row_num
FROM nigeria_houses_data_staging;

SELECT *
FROM nigeria_houses_data_staging2
WHERE row_num > 1;

DELETE 
FROM nigeria_houses_data_staging2
WHERE row_num > 1;

SELECT *
FROM nigeria_houses_data_staging2;

SELECT DISTINCT state
FROM nigeria_houses_data_staging2;

ALTER TABLE nigeria_houses_data_staging2
DROP row_num;

SELECT *
FROM nigeria_houses_data_staging2;
