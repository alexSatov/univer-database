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

CREATE TABLE Club
(
    ID INT IDENTITY(1, 1) PRIMARY KEY,
    Name NVARCHAR(20)
)
GO

INSERT INTO Club VALUES
    ('Спартак'),
    ('Урал'),
    ('Рубин')
GO

CREATE TABLE Player
(
    ID INT IDENTITY(1, 1) PRIMARY KEY,
    Surname NVARCHAR(20),
    Name NVARCHAR(20),
    ClubID INT FOREIGN KEY REFERENCES Club(ID)
)
GO

INSERT INTO Player VALUES
    ('Ребров', 'Артем', 1),
    ('Селихов', 'Александр', 1),
    ('Луиш', 'Зе', 1),
    ('Адриано', 'Луис', 1),
    ('Арапов', 'Дмитрий', 2),
    ('Тимофеев', 'Андрей', 2),
    ('Ильин', 'Владимир', 2),
    ('Портнягин', 'Игорь', 2),
    ('Фильцов', 'Александр', 3),
    ('Рыжиков', 'Сергей', 3),
    ('Сердар', 'Азмун', 3),
    ('Максим', 'Канунников', 3)
GO

CREATE TABLE Goalkeeper
(
    ID INT IDENTITY(1, 1) PRIMARY KEY,
    PlayerID INT FOREIGN KEY REFERENCES Player(ID)
)
GO

INSERT INTO Goalkeeper VALUES
    (1),
    (2),
    (5),
    (6),
    (9),
    (10)
GO

CREATE TABLE Game
(
    ID INT IDENTITY(1, 1) PRIMARY KEY,
    HostTeam INT FOREIGN KEY REFERENCES Club(ID),
    GuestTeam INT FOREIGN KEY REFERENCES Club(ID),
    GameDate DATE,
    HostScore INT,
    GuestScore INT,
    CONSTRAINT CHK_DifTeams CHECK (HostTeam != GuestTeam)
)
GO

INSERT INTO Game VALUES
    (2, 3, '01.12.2017', 2, 1),
    (2, 1, '02.12.2017', 1, 1),
    (3, 1, '03.12.2017', 1, 3)
GO

CREATE TABLE Bombardier
(
    ID INT IDENTITY(1, 1) PRIMARY KEY,
    PlayerID INT FOREIGN KEY REFERENCES Player(ID),
    GameID INT FOREIGN KEY REFERENCES Game(ID),
    Score INT,
    CONSTRAINT CHK_Score CHECK (Score > 0)
)
GO

INSERT INTO Bombardier VALUES
    (7, 1, 2),
    (12, 1, 1),
    (7, 2, 1),
    (3, 2, 1),
    (4, 3, 2),
    (3, 3, 1),
    (12, 3, 1)
GO

CREATE FUNCTION dbo.getPoints(@clubID INT, @date DATE)
RETURNS INT
AS
BEGIN
    DECLARE @points INT = 
    (
        SELECT SUM(
            CASE
                WHEN g.HostTeam = @clubID and g.HostScore > g.GuestScore THEN 3
                WHEN g.GuestTeam = @clubID and g.GuestScore > g.HostScore THEN 3
                WHEN (g.HostTeam = @clubID OR g.GuestTeam = @clubID) AND g.HostScore = g.GuestScore THEN 1
                ELSE 0 END
        )
        FROM Game AS g
        WHERE g.GameDate <= @date
    )
    RETURN @points
END
GO

CREATE FUNCTION dbo.getScore(@clubID INT, @date DATE)
RETURNS INT
AS
BEGIN
    DECLARE @score INT =
    (
        SELECT SUM(
            CASE
                WHEN g.HostTeam = @clubID THEN g.HostScore
                WHEN g.GuestTeam = @clubID THEN g.GuestScore
                ELSE 0 END
        )
        FROM Game AS g
        WHERE g.GameDate <= @date
    )
    RETURN @score
END
GO

CREATE FUNCTION dbo.getScoreOnRivalField(@clubID INT, @date DATE)
RETURNS INT
AS
BEGIN
    DECLARE @score INT =
    (
        SELECT SUM(g.GuestTeam)
        FROM Game AS g
        WHERE g.GuestTeam = @clubID and g.GameDate <= @date
    )
    RETURN @score
END
GO

CREATE FUNCTION dbo.getMissed(@clubID INT, @date DATE)
RETURNS INT
AS
BEGIN
    DECLARE @score INT =
    (
        SELECT SUM(
            CASE
                WHEN g.HostTeam = @clubID THEN g.GuestScore
                WHEN g.GuestTeam = @clubID THEN g.HostScore
                ELSE 0 END
        )
        FROM Game AS g
        WHERE g.GameDate <= @date
    )
    RETURN @score
END
GO

CREATE FUNCTION dbo.getChampionshipTable(@date DATE)
RETURNS @championshipTable TABLE
(
    ClubID INT,
    ClubName NVARCHAR(20),
    Points INT,
    Score INT,
    Missed INT
) AS
BEGIN
    INSERT INTO @championshipTable
        SELECT c.ID,
            c.Name,
            dbo.getPoints(c.ID, @date),
            dbo.getScore(c.ID, @date),
            dbo.getMissed(c.ID, @date)
        FROM Club as c
    return
END
GO

CREATE PROCEDURE showChampionshipTable @date DATE
AS
BEGIN
    SELECT t.ClubName AS ' ', t.Points AS 'Очки', t.Score AS 'Забито', t.Missed AS 'Пропущено'
    FROM dbo.getChampionshipTable(@date) AS t
    ORDER BY t.Points DESC,
        dbo.getScoreOnRivalField(t.ClubID, @date) DESC,
        t.Score - t.Missed DESC
END
GO

EXEC showChampionshipTable '03.12.2017'
GO

CREATE PROCEDURE showScoreTable @date DATE
AS
BEGIN
    DECLARE @scoreTable TABLE
    (
        Host NVARCHAR(20),
        Guest NVARCHAR(20),
        Score NVARCHAR(5),
        Points INT
    )

    INSERT INTO @scoreTable
    SELECT h.Name as 'Хозяин',
        gt.Name as 'Гость', 
        CONCAT(g.HostScore, '-', g.GuestScore) as 'Счет',
        dbo.getPoints(h.ID, @date)
    FROM Game AS g
    JOIN Club AS h ON g.HostTeam = h.ID
    JOIN Club AS gt ON g.GuestTeam = gt.ID
    WHERE g.GameDate <= @date

    INSERT INTO @scoreTable
    SELECT gt.Name as 'Хозяин',
        h.Name as 'Гость', 
        CONCAT(g.GuestScore, '-', g.HostScore) as 'Счет',
        dbo.getPoints(gt.ID, @date)
    FROM Game AS g
    JOIN Club AS h ON g.HostTeam = h.ID
    JOIN Club AS gt ON g.GuestTeam = gt.ID
    WHERE g.GameDate <= @date

    SELECT Host,
        ISNULL([Урал], ' ') as [Урал],
        ISNULL([Рубин], ' ') as [Рубин],
        ISNULL([Спартак], ' ') as [Спартак],
        Points as 'Очки'
    FROM @scoreTable
    PIVOT
    (
        MAX(Score)
        FOR Guest IN ([Урал], [Рубин], [Спартак])
    )
    AS pv
END
GO

EXEC showScoreTable '03.12.2017'
GO

CREATE FUNCTION dbo.getPlayerScore(@playerID INT)
RETURNS INT
AS
BEGIN
	DECLARE @score INT = (SELECT SUM(b.Score)
		FROM Bombardier as b
		WHERE b.PlayerID = @playerID)
	RETURN @score
END
GO

drop view Bombardiers
go

CREATE VIEW Bombardiers
AS
    SELECT distinct CONCAT(p.Surname, ' ', p.Name) as 'Имя', dbo.getPlayerScore(p.ID) as 'Забил', c.Name as 'Клуб'
    FROM Bombardier as b
    JOIN Player as p on p.ID = b.PlayerID
    JOIN Club as c on c.ID = p.ClubID
GO

SELECT * FROM Bombardiers
ORDER BY 'Клуб', 'Забил' desc
GO

CREATE VIEW Goalkeepers
AS
    SELECT CONCAT(p.Surname, ' ', p.Name) as 'Имя', c.Name as 'Клуб'
    FROM Goalkeeper as g
    JOIN Player as p on p.ID = g.PlayerID
    JOIN Club as c on c.ID = p.ClubID
GO

SELECT * FROM Goalkeepers
ORDER BY 'Клуб'
GO
