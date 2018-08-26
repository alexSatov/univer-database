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

CREATE TABLE Tariff
(
    ID INT IDENTITY(1, 1) PRIMARY KEY,
    Title NVARCHAR(50),
    SubMinutes DECIMAL(10, 2),
    SubCost DECIMAL(10, 2),
    ExtraMinuteCost DECIMAL(10, 2)
)
GO

INSERT INTO Tariff VALUES
    ('Без абонентской платы', 0, 0, 0.5),
    ('Смарт', 6, 2, 1),
    ('Безлимит', 44640, 5, 0)
GO

CREATE FUNCTION GetCost(@minutes DECIMAL(10, 2), @subMinutes DECIMAL(10, 2), @subCost DECIMAL(10, 2), @extraMinuteCost DECIMAL(10, 2))
RETURNS DECIMAL(10, 2) AS
BEGIN
    IF (@subMinutes >= @minutes)
        RETURN @subCost
    RETURN @subCost + (@minutes - @subMinutes) * @extraMinuteCost
END
GO

CREATE FUNCTION GetBestTariff(@minutes DECIMAL(10, 2))
RETURNS NVARCHAR(50) AS
BEGIN
    IF (@minutes > 44640)
        RETURN 'None'
    
    DECLARE @tariffs TABLE(Title NVARCHAR(50), Cost DECIMAL(10, 2))
    INSERT @tariffs
        SELECT t.Title, dbo.GetCost(@minutes, t.SubMinutes, t.SubCost, t.ExtraMinuteCost)
        FROM Tariff as t

    DECLARE @bestTariff NVARCHAR(50)
    SET @bestTariff = (
        SELECT TOP 1 t.Title
        FROM @tariffs AS t
        ORDER BY t.Cost)

    RETURN @bestTariff
END
GO

CREATE FUNCTION GetIntersectionPoints(@x1 DECIMAL(10, 2), @y1 DECIMAL(10, 2), @k1 DECIMAL(10, 2), 
									  @x2 DECIMAL(10, 2), @y2 DECIMAL(10, 2), @k2 DECIMAL(10, 2))
RETURNS @points TABLE(X DECIMAL(10, 2)) AS
BEGIN
    IF (@x1 = 0 and @x2 = 0 or @k1 = 0 and @k2 = 0)
        RETURN
    
    DECLARE @b1 DECIMAL(10, 2)
    DECLARE @b2 DECIMAL(10, 2)
    DECLARE @pointX DECIMAL(10, 2)
    DECLARE @pointY DECIMAL(10, 2)

    IF (@x1 != 0 and @k2 != 0)
    BEGIN
        SET @b2 = @k2 * @x2 - @y2
        SET @pointX = (@y1 + @b2) / @k2
        IF (@y1 > @y2)
            INSERT INTO @points VALUES (@pointX)
    END

    IF (@x2 != 0 and @k1 != 0)
    BEGIN
        SET @b1 = @k1 * @x1 - @y1
        SET @pointX = (@y2 + @b1) / @k1
        IF (@y1 < @y2)
            INSERT INTO @points VALUES (@pointX)
    END

    IF (@k1 != 0 and @k2 != 0 and @k1 != @k2)
    BEGIN
        SET @b1 = @k1 * @x1 - @y1
        SET @b2 = @k2 * @x2 - @y2
        SET @pointX = (@b1 - @b2) / (@k1 - @k2)
        SET @pointY = @k1 * @pointX - @b1
        IF (@y1 <= @y2 and @pointY >= @y1 or @y2 <= @y1 and @pointY >= @y2)
            INSERT INTO @points VALUES (@pointX)
    END

    RETURN
END
GO

CREATE FUNCTION GetAllIntersectionPoints()
RETURNS @allPoints TABLE(X DECIMAL(10, 2)) AS
BEGIN
    DECLARE tariffCursor1 CURSOR FOR
        SELECT t.ID, t.SubMinutes, t.SubCost, t.ExtraMinuteCost
        FROM Tariff as t
    DECLARE @id1 INT
    DECLARE @subMinutes1 DECIMAL(10, 2)
    DECLARE @subCost1 DECIMAL(10, 2)
    DECLARE @extraMinuteCost1 DECIMAL(10, 2)
    OPEN tariffCursor1
    FETCH NEXT FROM tariffCursor1 INTO @id1, @subMinutes1, @subCost1, @extraMinuteCost1
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE tariffCursor2 CURSOR FOR
            SELECT t.ID, t.SubMinutes, t.SubCost, t.ExtraMinuteCost
            FROM Tariff as t
        DECLARE @id2 INT
        DECLARE @subMinutes2 DECIMAL(10, 2)
        DECLARE @subCost2 DECIMAL(10, 2)
        DECLARE @extraMinuteCost2 DECIMAL(10, 2)
        OPEN tariffCursor2
        FETCH NEXT FROM tariffCursor2 INTO @id2, @subMinutes2, @subCost2, @extraMinuteCost2
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF (@id1 < @id2)
            BEGIN
                INSERT @allPoints SELECT * FROM dbo.GetIntersectionPoints(@subMinutes1, @subCost1, @extraMinuteCost1, @subMinutes2, @subCost2, @extraMinuteCost2)
            END
            FETCH NEXT FROM tariffCursor2 INTO @id2, @subMinutes2, @subCost2, @extraMinuteCost2
        END
        CLOSE tariffCursor2
        DEALLOCATE tariffCursor2

        FETCH NEXT FROM tariffCursor1 INTO @id1, @subMinutes1, @subCost1, @extraMinuteCost1
    END
    CLOSE tariffCursor1
    DEALLOCATE tariffCursor1

    RETURN
END
GO

CREATE FUNCTION GetBestTariffByInterval()
RETURNS @intervals TABLE(A DECIMAL(10, 2), B DECIMAL(10, 2), TariffName NVARCHAR(50)) AS
BEGIN
    DECLARE @a DECIMAL(10, 2) = 0
    DECLARE pointCursor CURSOR FOR
        SELECT DISTINCT p.X
        FROM dbo.GetAllIntersectionPoints() as p
        ORDER BY p.X
    DECLARE @x DECIMAL(10, 2)
    OPEN pointCursor
    FETCH NEXT FROM pointCursor INTO @x
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO @intervals VALUES
            (@a, @x, dbo.GetBestTariff(@a + (@x - @a) / 2))

        SET @a = @x

        FETCH NEXT FROM pointCursor INTO @x
    END
    CLOSE pointCursor
    DEALLOCATE pointCursor

    INSERT INTO @intervals VALUES
        (@a, 44640, dbo.GetBestTariff(@a + 1))

    RETURN
END
GO

DECLARE @uniqueIntervals TABLE(A DECIMAL(10, 2), B DECIMAL(10, 2), TariffName NVARCHAR(50))

DECLARE intervalCursor CURSOR FOR
    SELECT i.A, i.B, i.TariffName
    FROM dbo.GetBestTariffByInterval() i
DECLARE @a DECIMAL(10, 2)
DECLARE @b DECIMAL(10, 2)
DECLARE @tariffName NVARCHAR(50)
OPEN intervalCursor
FETCH NEXT FROM intervalCursor INTO @a, @b, @tariffName
WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @lastTariffName NVARCHAR(50) = (
        SELECT TOP 1 TariffName
        FROM @uniqueIntervals
        ORDER BY A DESC
    )

    IF (@lastTariffName = @tariffName)
        UPDATE @uniqueIntervals
        SET B = @b
        WHERE TariffName = @lastTariffName
    ELSE
        INSERT INTO @uniqueIntervals VALUES
            (@a, @b, @tariffName)

    FETCH NEXT FROM intervalCursor INTO @a, @b, @tariffName
END
CLOSE intervalCursor
DEALLOCATE intervalCursor

SELECT * FROM @uniqueIntervals
