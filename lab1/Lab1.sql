use master
go

if exists
(
    select name
    from sys.databases
    where name = N'Satov'
)

alter database [Satov] set single_user with rollback immediate
go

if exists
(
    select name
    from sys.databases
    where name = N'Satov'
)
drop database [Satov]
go

create database [Satov]
go

use [Satov]
go

if exists
(
    select *
    from sys.schemas
    where name = N'Lab'
)
drop schema Lab
go

create schema Lab
go

if OBJECT_ID('[Satov].Lab.MeasurementTypes', 'U') is not null
    drop table [Satov].Lab.MeasurementTypes
go

create table [Satov].Lab.MeasurementTypes
(
    ID1 int,
    Name nvarchar(40),
    Unit nvarchar(40),
    Symbol nvarchar(40),
    constraint PK_ID1 primary key (ID1)
)
go

if OBJECT_ID('[Satov].Lab.Stations', 'U') is not null
    drop table [Satov].Lab.Stations
go

create table [Satov].Lab.Stations
(
    ID2 int,
    Name nvarchar(40),
    Location nvarchar(40),
    constraint PK_ID2 primary key (ID2)
)
go

if OBJECT_ID('[Satov].Lab.Measurements', 'U') is not null
    drop table [Satov].Lab.Measurements
go

create table [Satov].Lab.Measurements
(
    MeasurementDate date,
    StationID int,
    MeasurementID int,
    Value decimal,
    constraint FK_FK1 foreign key (MeasurementID) references [Satov].Lab.MeasurementTypes(ID1),
    constraint FK_FK2 foreign key (StationID) references [Satov].Lab.Stations(ID2)
)
go

insert into [Satov].Lab.MeasurementTypes values
    (1, 'Температура', 'гр. Цельсия', '°C'),
    (2, 'Влажность', '%', 'ф'),
    (3, 'Давление', 'мм рт. ст.', 'mm Hg');
go

insert into [Satov].Lab.Stations values
    (1, 'Уральская станция', 'Россия, г. Екатеринбург'),
    (2, 'Дальневосточная станция', 'Россия, г. Магадан'),
    (3, 'Южная станция', 'Россия, г. Краснодар'),
    (4, 'Центральная станция', 'Россия, г. Москва');
go

insert into [Satov].Lab.Measurements values
    ('2001-06-11 12:00:00', 1, 1, 30),
    ('2001-06-11 12:00:00', 2, 1, 24),
    ('2001-06-11 12:00:00', 3, 1, 20),
    ('2001-06-11 12:00:00', 4, 1, 26),
    ('2001-06-11 20:00:00', 1, 1, 25),
    ('2001-06-11 20:00:00', 2, 1, 16),
    ('2001-06-11 20:00:00', 3, 1, 10),
    ('2001-06-11 20:00:00', 4, 1, 13),
	('2002-07-12 12:00:00', 1, 2, 70),
    ('2002-07-12 12:00:00', 2, 2, 66),
    ('2002-07-12 12:00:00', 3, 2, 81),
    ('2002-07-12 12:00:00', 4, 2, 77),
    ('2002-07-12 20:00:00', 1, 2, 60),
    ('2002-07-12 20:00:00', 2, 2, 60),
    ('2002-07-12 20:00:00', 3, 2, 79),
    ('2002-07-12 20:00:00', 4, 2, 50),
	('2003-06-11 12:00:00', 1, 1, 30),
    ('2003-06-11 12:00:00', 2, 1, 24),
    ('2003-06-11 12:00:00', 3, 1, 20),
    ('2003-06-11 12:00:00', 4, 1, 26),
    ('2003-06-11 20:00:00', 1, 1, 25),
    ('2003-06-11 20:00:00', 2, 1, 16),
    ('2003-06-11 20:00:00', 3, 1, 10),
    ('2003-06-11 20:00:00', 4, 1, 13),
	('2004-07-12 12:00:00', 1, 2, 70),
    ('2004-07-12 12:00:00', 2, 2, 66),
    ('2004-07-12 12:00:00', 3, 2, 81),
    ('2004-07-12 12:00:00', 4, 2, 77),
    ('2004-07-12 20:00:00', 1, 2, 60),
    ('2004-07-12 20:00:00', 2, 2, 60),
    ('2004-07-12 20:00:00', 3, 2, 79),
    ('2004-07-12 20:00:00', 4, 2, 50);
go

select 
	s.Name as 'Название станции',
    mt.Name as 'Измерение',
    convert(decimal(10, 1), avg(m.Value)) as 'Среднее значение'
from [Satov].Lab.Measurements m
join [Satov].Lab.MeasurementTypes mt on m.MeasurementID = mt.ID1
join [Satov].Lab.Stations s on m.StationID = s.ID2
group by s.Name, mt.Name;

select 
    mt.Name as 'Измерение',
    convert(decimal(10, 1), avg(m.Value)) as 'Среднее значение'
from [Satov].Lab.Measurements m
join [Satov].Lab.MeasurementTypes mt on m.MeasurementID = mt.ID1
group by mt.Name;
