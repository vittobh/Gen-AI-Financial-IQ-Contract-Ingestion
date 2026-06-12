# SQL Assignment: Country Match Pairs

## Problem

Given a `teams` table, write a query that selects country pairs for matches.

Rules:

- Each country plays every other country.
- Each pair appears only once.
- Reverse duplicates are not allowed.
- A country does not play itself.

## Table Setup

```sql
CREATE TABLE teams (
    id INTEGER,
    name VARCHAR(100)
);

INSERT INTO teams(id, name) VALUES (1, 'India');
INSERT INTO teams(id, name) VALUES (2, 'Russia');
INSERT INTO teams(id, name) VALUES (3, 'New Zealand');
INSERT INTO teams(id, name) VALUES (4, 'Australia');
```

## Option 1: Self Join

```sql
SELECT
    t1.name AS team1,
    t2.name AS team2
FROM teams t1
JOIN teams t2
    ON t1.id < t2.id
ORDER BY t1.id, t2.id;
```

Why this works:

- `t1.id < t2.id` prevents self-pairs.
- It also removes reverse duplicates.
- Lower ID always appears on the left side of the pair.

## Option 2: Older WHERE Syntax

```sql
SELECT
    t1.name AS team1,
    t2.name AS team2
FROM teams t1, teams t2
WHERE t1.id < t2.id
ORDER BY t1.name;
```

This uses the same pairing logic, written using older SQL join style.

## Option 3: Best Approach

```sql
SELECT
    ROW_NUMBER() OVER (ORDER BY t1.id, t2.id) AS match_no,
    t1.name AS team1,
    t2.name AS team2,
    CONCAT(t1.name, ' vs ', t2.name) AS match_title
FROM teams t1
JOIN teams t2
    ON t1.id < t2.id
ORDER BY t1.id, t2.id;
```

## Expected Output

| match_no | team1 | team2 | match_title |
| --- | --- | --- | --- |
| 1 | India | Russia | India vs Russia |
| 2 | India | New Zealand | India vs New Zealand |
| 3 | India | Australia | India vs Australia |
| 4 | Russia | New Zealand | Russia vs New Zealand |
| 5 | Russia | Australia | Russia vs Australia |
| 6 | New Zealand | Australia | New Zealand vs Australia |

## Product Thinking Note

The query solves the immediate assignment and also models a reusable scheduling pattern. The same principle can be applied to tournament scheduling, pairwise validation checks, entity matching, deduplication review, and relationship graph generation.
