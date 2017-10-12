Use Kevin
CREATE TABLE celebs (id INTEGER, name TEXT, age INTEGER);
INSERT INTO celebs (id, name, age) VALUES (1, 'Justin Bieber', 21);
SELECT * FROM celebs;
INSERT INTO celebs (id, name, age) VALUES (2, 'Beyonce Knowles', 33); 
INSERT INTO celebs (id, name, age) VALUES (3, 'Jeremy Lin', 26); 
INSERT INTO celebs (id, name, age) VALUES (4, 'Taylor Swift', 26);

UPDATE celebs 
SET age = 22 
WHERE id = 1; 

SELECT * FROM celebs;

ALTER TABLE celebs
ADD twitter_handle TEXT;

SELECT * FROM celebs;

UPDATE celebs 
SET twitter_handle = '@taylorswift13' 
WHERE id = 4; 

DELETE FROM celebs WHERE twitter_handle IS NULL;

SELECT * FROM celebs;