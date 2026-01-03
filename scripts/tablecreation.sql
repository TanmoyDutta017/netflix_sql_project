/*
====================================================================
Step 1: Drop the table if it already exists.
Step2: Cerate requierd colulmns
*/

DROP TABLE IF EXISTS nfd.netflix
CREATE TABLE nfd.netflix(
show_id VARCHAR(10),
type VARCHAR(15),
title VARCHAR(255),
director VARCHAR(255),
cast VARCHAR(1050),
country VARCHAR(200),
date_added	VARCHAR (100),
release_year INT,
rating VARCHAR(20),
duration VARCHAR(50),
listed_in VARCHAR(200),
description VARCHAR(500))
