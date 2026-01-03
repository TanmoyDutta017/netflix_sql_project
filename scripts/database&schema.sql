/*=========================================================================================*/
-- Create Database and Schemas
/*=========================================================================================*/
 
USE master
GO
-- NOTE: Only use this code if you are sure to drop the database.

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'netflixdb')
BEGIN
ALTER DATABASE netflixdb SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE netflixdb;
END
GO

CREATE DATABASE netflixdb
GO 

USE netflixdb
GO

CREATE SCHEMA nfd
