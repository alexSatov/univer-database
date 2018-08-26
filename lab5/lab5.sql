USE master
GO

IF EXISTS (SELECT name
    FROM sys.databases
    WHERE name = 'Satov')
BEGIN
    ALTER DATABASE Satov SET single_user WITH ROLLBACK IMMEDIATE
    DROP DATABASE Satov
END
GO

CREATE DATABASE Satov
GO

USE Satov
GO

-- if OBJECT_ID('[Name]', 'U') is not null
--     drop [object] [Name]
-- go

CREATE TABLE Company
(
    ID INT IDENTITY(1, 1) PRIMARY KEY,
    Name NVARCHAR(20)
)
GO

INSERT INTO Company VALUES
    ('Аэрофлот'),
    ('Победа'),
    ('Россия')
GO

CREATE TABLE Plane
(
    ID INT IDENTITY(1, 1) PRIMARY KEY,
    Name NVARCHAR(20)
)
GO

INSERT INTO Plane VALUES
    ('Boeng')
GO

CREATE TABLE City
(
    ID INT IDENTITY(1, 1) PRIMARY KEY,
    Name NVARCHAR(20)
)
GO

INSERT INTO City VALUES
    ('Москва'),
    ('Санкт-Петерсбург'),
    ('Екатеринбург')
GO

CREATE TABLE Flight
(
    ID INT IDENTITY(1, 1) PRIMARY KEY,
    CompanyID INT FOREIGN KEY REFERENCES Company(ID),
    PlaneID INT FOREIGN KEY REFERENCES Plane(ID),
    DepartureCityID INT FOREIGN KEY REFERENCES City(ID),
    ArrivalCityID INT FOREIGN KEY REFERENCES City(ID),
    DepartureTime TIME,
    ArrivalTime TIME
)
GO

INSERT INTO Flight VALUES
    (1, 1, 1, 2, '00:00', '00:30'),
    (1, 1, 1, 3, '00:00', '00:40'),
    (1, 1, 2, 3, '00:00', '00:20'),
    (2, 1, 2, 1, '00:00', '00:10'),
    (2, 1, 2, 3, '00:00', '00:25'),
    (3, 1, 3, 1, '00:00', '00:15')
GO

CREATE TABLE Ticket
(
    ID INT IDENTITY(1, 1) PRIMARY KEY,
    FlightID INT FOREIGN KEY REFERENCES Flight(ID),
    DepartureDate DATE,
    Passenger NVARCHAR(50),
    Place NVARCHAR(10),
    CONSTRAINT CHK_Place CHECK (Place LIKE '[1-9][a-d]' OR Place LIKE '[1-9][0-9][a-d]')
)
GO

CREATE TRIGGER FreePlace ON Ticket
AFTER INSERT, UPDATE AS
BEGIN
    DECLARE placeCursor CURSOR FOR
        SELECT FlightID, DepartureDate, Place
        FROM Ticket
    DECLARE @id INT
    DECLARE @day DATE
    DECLARE @place NVARCHAR(10)
    OPEN placeCursor
    FETCH NEXT FROM placeCursor INTO @id, @day, @place
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @placeCount INT = (
            SELECT TOP 1 COUNT(*)
            FROM Ticket
            WHERE FlightID = @id and DepartureDate = @day and Place = @place
        )

        IF (@placeCount > 1)
        BEGIN
            PRINT 'Место занято'
            ROLLBACK
        END

        FETCH NEXT FROM placeCursor INTO @id, @day, @place
    END
    CLOSE placeCursor
    DEALLOCATE placeCursor
END
GO

INSERT INTO Ticket VALUES
    (1, '01.01.2000', 'Satov', '1a'),
    (1, '01.01.2000', 'Rive', '11a'),
    (1, '01.01.2000', 'Petrov', '11b'),
    (1, '02.01.2000', 'Satov', '1a'),
    (1, '02.01.2000', 'Rive', '2a'),
    (2, '01.01.2000', 'Satov', '1a'),
    (2, '01.01.2000', 'Rive', '2a'),
    (2, '03.01.2000', 'Petrov', '1a'),
    (2, '03.01.2000', 'Satov', '2a'),
    (2, '03.01.2000', 'Rive', '3a'),
    (2, '03.01.2000', 'Ivanov', '4a'),
    (3, '01.01.2000', 'Satov', '1a'),
    (3, '01.01.2000', 'Rive', '2a'),
    (3, '02.01.2000', 'Satov', '1a'),
    (3, '03.01.2000', 'Satov', '1a'),
    (4, '01.01.2000', 'Satov', '1a'),
    (4, '01.01.2000', 'Rive', '2a'),
    (4, '02.01.2000', 'Satov', '1a'),
    (4, '03.01.2000', 'Satov', '1a'),
    (5, '01.01.2000', 'Satov', '1a'),
    (5, '01.01.2000', 'Rive', '2a'),
    (5, '02.01.2000', 'Satov', '1a')
GO

INSERT INTO Ticket VALUES
    (1, '01.01.2000', 'Ivanov', '1a') --занято
GO

--1
SELECT c.Name AS 'Компания', COUNT(f.ID) AS 'Количество рейсов'
FROM Flight f
JOIN Company c ON c.ID = f.CompanyID
GROUP BY c.Name
GO

--2
DECLARE @passengersOnFlight TABLE(FlightID INT, PassengersCount INT)
INSERT @passengersOnFlight
    SELECT FlightID, COUNT(FlightID)
    FROM Ticket
	GROUP BY FlightID

DECLARE @maxPassengersCountFlightID INT = (
    SELECT TOP 1 FlightID
    FROM @passengersOnFlight
    ORDER BY PassengersCount DESC)

SELECT
    f.ID            AS 'Номер рейса',
    c.Name          AS 'Компания',
    p.Name          AS 'Тип самолета',
    dc.Name         AS 'Город отправления',
    ac.Name         AS 'Город прибытия',
    f.DepartureTime AS 'Время отправления',
    f.ArrivalTime   AS 'Время прибытия'
FROM Flight f
JOIN Company c  ON c.ID  = f.CompanyID
JOIN Plane   p  ON p.ID  = f.PlaneID
JOIN City    dc ON dc.ID = f.DepartureCityID
JOIN City    ac ON ac.ID = f.ArrivalCityID
WHERE f.ID = @maxPassengersCountFlightID
GO

--3
DECLARE @flightCountByDay TABLE(Day DATE, FlightCount INT)
INSERT @flightCountByDay
    SELECT t.DepartureDate, COUNT(DISTINCT t.FlightID)
    FROM Ticket t
    JOIN Flight f on f.ID = t.FlightID
    WHERE f.DepartureCityID = 2
    GROUP BY t.DepartureDate

DECLARE @maxFlightCount INT = (SELECT TOP 1 MAX(FlightCount) FROM @flightCountByDay)

SELECT *
FROM @flightCountByDay
WHERE FlightCount = @maxFlightCount
GO

--4
CREATE FUNCTION GetMinutesSum(@companyID INT)
RETURNS INT AS
BEGIN
    DECLARE @minutesByFlight TABLE (FlightID INT, Minutes INT)
	INSERT @minutesByFlight
		SELECT t.FlightID, COUNT(DISTINCT t.DepartureDate) * DATEDIFF(mi, MAX(f.DepartureTime), MAX(f.ArrivalTime))
		FROM Ticket t
		JOIN Flight f ON f.ID = t.FlightID
		WHERE f.CompanyID = @companyID
		GROUP BY t.FlightID

    DECLARE @sum INT = (SELECT TOP 1 SUM(Minutes) FROM @minutesByFlight)

    RETURN @sum
END
GO

SELECT Name AS 'Компания', dbo.GetMinutesSum(ID) AS 'Минуты'
FROM Company
GO

--5
SELECT c.Name, COUNT(t.ID)
FROM Ticket t
JOIN Flight f on f.ID = t.FlightID
JOIN Company c on c.ID = f.CompanyID
WHERE t.DepartureDate = '01.01.2000'
GROUP BY c.Name
GO
