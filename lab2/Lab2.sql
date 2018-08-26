use master
go

if exists (select name
    from sys.databases
    where name = 'Satov')
alter database Satov set single_user with rollback immediate
go

if exists (select name
    from sys.databases
    where name = 'Satov')
drop database Satov
go

create database Satov
go

use Satov
go

if OBJECT_ID('CarNumber', 'U') is not null
    drop trigger CarNumber
go

create function dbo.checkPassageType (@passageType bit, @carNumber nvarchar(6), @passageTime time)
returns bit
as
begin
    declare @lastPassageType bit

    if exists (select *
        from NumberRegistration as nr
        where nr.CarNumber = @carNumber and nr.PassageTime < @passageTime)
    begin
        select top 1 @lastPassageType = PassageType
        from NumberRegistration as nr
        where nr.CarNumber = @carNumber and nr.PassageTime < @passageTime
        order by nr.PassageTime desc

        if (@lastPassageType = @passageType)
            return 0

        return 1
    end

    return 1
end
go

create function dbo.GetCarType (@carNumber nvarchar(6))
returns nvarchar(12)
as
begin
    declare @localRegionCodes table (Code varchar(3))
    insert into @localRegionCodes select Code
        from RegionCode as rc
        where rc.RegionID = 77

    if exists (select *
        from NumberRegistration as nr1
        where nr1.RegionCode not in (select * from @localRegionCodes)
            and nr1.CarNumber = @carNumber
            and exists(select * from NumberRegistration as nr2
                where nr2.CarNumber = @carNumber
                    and nr1.PostID != nr2.PostID
                    and nr1.PassageTime < nr2.PassageTime
                    and nr1.PassageType = 1
                    and nr2.PassageType = 0))
        return 'Транзитный'

    if exists (select *
        from NumberRegistration as nr1
        where nr1.CarNumber = @carNumber and exists(select *
                from NumberRegistration as nr2
                where nr2.CarNumber = @carNumber
                    and nr1.PostID = nr2.PostID
                    and nr1.PassageTime < nr2.PassageTime
                    and nr1.PassageType = 1
                    and nr2.PassageType = 0))
        return 'Иногородний'

    if exists (select *
        from NumberRegistration as nr1
        where nr1.RegionCode in (select * from @localRegionCodes)
            and nr1.CarNumber = @carNumber
            and exists(select * from NumberRegistration as nr2
                where nr2.CarNumber = @carNumber
                    and nr1.PostID != nr2.PostID
                    and nr1.PassageTime > nr2.PassageTime
                    and nr1.PassageType = 1
                    and nr2.PassageType = 0))
        return 'Местный'

    return 'Другой'
end
go

create table Region
(
    ID int primary key,
    Name nvarchar(40)
)
go

create table RegionCode
(
    Code nvarchar(3) primary key,
    RegionID int,
    constraint FK_RegionID foreign key (RegionID) references Region(ID),
    constraint CHK_Code check (Code like '[127][0-9][0-9]' or Code like '[0-9][0-9]')
)
go

create table PassageType
(
    ID int primary key,
    Type nvarchar(5)
)
go

create table Post
(
    ID int primary key,
    Name nvarchar(20)
)
go

create table NumberRegistration
(
    PostID int,
    CarNumber nvarchar(6),
    RegionCode nvarchar(3),
    PassageTime time,
    PassageType bit,
    constraint FK_PostID foreign key (PostID) references Post(ID),
    constraint FK_RegionCode foreign key (RegionCode) references RegionCode(Code),
    constraint CHK_PassageType check (dbo.checkPassageType(PassageType, CarNumber, PassageTime) = 1)
)
go

create trigger CarNumber on NumberRegistration
after insert, update
as
begin
    if exists (select CarNumber from NumberRegistration
        where CarNumber not like '[ABEKMHOPCTX][0-9][0-9][0-9][ABEKMHOPCTX][ABEKMHOPCTX]'
            or CarNumber like '[ABEKMHOPCTX]000[ABEKMHOPCTX][ABEKMHOPCTX]')
    begin
        print 'Некорректный номер'
        rollback
    end
end
go

enable trigger CarNumber on NumberRegistration
go

insert into PassageType values
    (0, 'Выезд'),
    (1, 'Въезд')
go

insert into Region values
    (66, 'Свердловская обл.'),
    (77, 'г. Москва'),
    (50, 'Московская обл.'),
    (74, 'Челябинская обл.')
go

insert into Post values
    (0, 'Северный'),
    (1, 'Восточный'),
    (2, 'Южный'),
    (3, 'Западный')
go

insert into RegionCode values
    ('66',  66),
    ('96',  66),
    ('196', 66),
    ('77',  77),
    ('97',  77),
    ('99',  77),
    ('177', 77),
    ('197', 77),
    ('199', 77),
    ('777', 77),
    ('799', 77),
    ('50',  50),
    ('90',  50),
    ('150', 50),
    ('190', 50),
    ('750', 50),
    ('74',  74),
    ('174', 74)
go

insert into RegionCode values
    ('333', 66)
go

insert into NumberRegistration values
    (1, 'A505BT', '174', '12:00', 1),
    (3, 'A505BT', '174', '13:56', 0),
    (0, 'T666MH', '77',  '09:23', 0),
    (3, 'T666MH', '77',  '11:23', 1),
    (1, 'C245AM', '196', '06:00', 1),
    (1, 'C245AM', '196', '07:00', 0),
    (2, 'B123OM', '197', '14:00', 1),
    (2, 'B123OM', '197', '19:00', 0)
go

insert into NumberRegistration values
    (2, 'A505BT', 174, '14:43', 0)
go

insert into NumberRegistration values
    (2, 'A505BT', 174, '13:00', 1)
go

insert into NumberRegistration values
    (2, 'А505ЫГ', 174, '14:43', 1)
go

select * from NumberRegistration

select
    convert(nvarchar, nr.PassageTime, 108) as 'Время проезда',
    concat(nr.CarNumber, nr.RegionCode) as 'Номер автомобиля',
    pt.Type as 'Тип проезда',
    p.Name as 'Пост',
    dbo.GetCarType(nr.CarNumber) as 'Тип автомобиля',
	r.Name as 'Регион'
from NumberRegistration as nr
join PassageType pt on pt.ID = nr.PassageType
join Post p on p.ID = nr.PostID
join RegionCode rc on rc.Code = nr.RegionCode
join Region r on r.ID = rc.RegionID
go
