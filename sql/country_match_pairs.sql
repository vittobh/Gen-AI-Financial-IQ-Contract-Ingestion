CREATE TABLE teams (
    id INTEGER,
    name VARCHAR(100)
);

INSERT INTO teams(id, name) VALUES (1, 'India');
INSERT INTO teams(id, name) VALUES (2, 'Russia');
INSERT INTO teams(id, name) VALUES (3, 'New Zealand');
INSERT INTO teams(id, name) VALUES (4, 'Australia');

-- Option 1: self join.
SELECT
    t1.name AS team1,
    t2.name AS team2
FROM teams t1
JOIN teams t2
    ON t1.id < t2.id
ORDER BY t1.id, t2.id;

-- Option 2: older WHERE syntax.
SELECT
    t1.name AS team1,
    t2.name AS team2
FROM teams t1, teams t2
WHERE t1.id < t2.id
ORDER BY t1.name;

-- Option 3: best approach with match number and readable title.
SELECT
    ROW_NUMBER() OVER (ORDER BY t1.id, t2.id) AS match_no,
    t1.name AS team1,
    t2.name AS team2,
    CONCAT(t1.name, ' vs ', t2.name) AS match_title
FROM teams t1
JOIN teams t2
    ON t1.id < t2.id
ORDER BY t1.id, t2.id;
