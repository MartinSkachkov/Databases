```sql
-- Добавете Брус Уилис в базата.
-- Направете така, че при добавяне на филм, чието заглавие съдържа “save” или “world”,
-- Брус Уилис автоматично да бъде добавен като актьор, играл в съответния филм.
use mods

begin transaction

insert into MOVIESTAR -- Добавете Брус Уилис в базата.
values ('Bruce Willis', 'Hollywood', 'M', '1955-03-19');

create trigger BruceWillis on MOVIE
after insert, update 
as
begin
	insert into STARSIN(MOVIETITLE, MOVIEYEAR, STARNAME) -- Брус Уилис автоматично да бъде добавен като актьор, играл в съответния филм.
	select TITLE, YEAR, 'Bruce Willis' -- Направете така, че при добавяне на филм, чието заглавие съдържа “save” или “world”,
	from inserted
	where TITLE like '%save%' or TITLE like '%world%'
end
go

insert into MOVIE(TITLE, YEAR)
values ('Say my name', 1999),
	   ('Save the world', 2000),
	   ('Only save', 2001)

select * from MOVIE
select * from STARSIN

rollback

-- Да се направи така, че да не е възможно средната стойност на networth
-- да е по- малка от 500'000 (ако при промени в таблицата MovieExec тази стойност
-- стане по- малка от 500'000, промените да бъдат отхвърлени).
begin transaction

create trigger MinimumNetworth on MOVIEEXEC
after update, delete
as
begin
	if (select AVG(NETWORTH) from MOVIEEXEC) < 500000
		throw 50001, 'Data Integrity Violation', 1 -- това ще върне старите стойности и няма да има обновяване
end
go

update MOVIEEXEC
set NETWORTH = 0

select * from MOVIEEXEC

rollback

-- MSSQL не поддържа SET NULL ON DELETE. Да се реализира с тригер за външния
-- ключ Movie.producerc#.
begin transaction

create trigger SetNullOnDel on MOVIEEXEC
instead of delete
as
begin
	-- трием продуцент на филм, тогава Movie.producerc# = null
	update MOVIE
	set PRODUCERC# = null
	where PRODUCERC# in (select CERT# from deleted)

	-- вече правим същинското триене на продуцента понеже имаме instead of
	delete from MOVIEEXEC
	where CERT# in (select CERT# from deleted)
end
go

delete from MOVIEEXEC
where CERT# = 123

select * from MOVIEEXEC
select * from MOVIE

rollback

-- Никой производител на компютри не може да произвежда и принтери.
begin transaction

create trigger MakerEnforce on product
after insert, update
as
begin
	if EXISTS(select *
			  from inserted join product p2 on inserted.maker = p2.maker
			  where inserted.type = 'Printer' and p2.type = 'PC')
		throw 50001, 'Data Integrity Violation', 1
end
go

insert product
values ('C', '1111', 'Printer')

select * from product

rollback

-- Ако някой лаптоп има повече памет от някой компютър, трябва да бъде и по-скъп от него.
begin transaction

create trigger Price on pc
after insert, update
as
begin
	if EXISTS(select *
			  from inserted join laptop on laptop.ram > inserted.ram
			  where laptop.price > inserted.price)
		throw 50001, 'Data Integrity Violation', 1
end
go

rollback

-- Кораб с повече от 9 оръдия не може да участва в битка с кораб, който е с по-малко от 9 
-- оръдия. Напишете тригер за Outcomes.

-- ако приемеме, че след създаване на клас в таблицата CLASSES може да се модифицират
-- атрибутите на класовете (в нашия случай - броя оръдия), то тогава би следвало и за там
-- да се направи тригер за UPDATE
-- в случая приемаме, че за класове имаме само INSERT/DELETE операции (в практическия 
-- случай - при нови параметри - имаме нов клас кораби)

-- за битките, за които имаме добавени/обновени кораби, проверяваме дали има двойки, 
-- нарушаващи условието
begin transaction

create trigger OutcomesEnforce on OUTCOMES
after insert, delete
as
begin
if exists(
	select *
	from OUTCOMES o1 join OUTCOMES o2 on o1.BATTLE = o2.BATTLE and o1.SHIP != o2.SHIP
					 join SHIPS s1 on s1.NAME = o1.SHIP
					 join SHIPS s2 on s2.NAME = o2.SHIP
					 join CLASSES c1 on c1.CLASS = s1.CLASS
					 join CLASSES c2 on c2.CLASS = s2.CLASS
	where c1.NUMGUNS > 9 and c2.NUMGUNS < 9 and o1.BATTLE in (select BATTLE from inserted))
	throw 50001, 'Data Integrity Violation', 1;
end
go

rollback

-- Никой клас не може да има повече от два кораба.
begin transaction

create trigger ShipsPerClass on SHIPS
after insert, update
as
begin
	if exists(select CLASS from SHIPS group by CLASS having COUNT(*) > 2)
		throw 50001, 'Data Integrity Violation', 1;
end
go

select * from SHIPS

insert into SHIPS(NAME, CLASS)
values ('MARTO', 'Kongo')

rollback

-- Създайте изглед, който показва за всеки клас името му и броя кораби (евентуално 0). 
-- Направете така, че при изтриване на ред да се изтрие класът и всички негови кораби.
begin transaction

create view ClassShips as
	select CLASSES.CLASS, count(distinct NAME) as SHIPS
	from SHIPS right join CLASSES on SHIPS.CLASS = CLASSES.CLASS
	group by CLASSES.CLASS
go

create trigger Deletion on ClassShips
instead of delete
as
begin
	-- трябва да изтрием всички кораби, които са от класа, който искаме да изтрием
	delete from SHIPS
	where CLASS in (select CLASS from deleted)

	-- трябва да изтрием и самият клас от таблицата CLASSES
	delete from CLASSES
	where CLASS in (select CLASS from deleted)
end
go
	
rollback

-- Ако бъде добавен нов клас с водоизместимост по-голяма от 35000, класът да бъде добавен 
-- в таблицата, но да му се зададе водоизместимост 35000.
begin transaction

create trigger Displ on CLASSES
after insert
as
begin
	insert into CLASSES
	select CLASS, 
           TYPE, 
           COUNTRY, 
           NUMGUNS, 
           BORE, 
           case
				when DISPLACEMENT > 35000 then 35000
                else DISPLACEMENT
           end as DISPLACEMENT
	from inserted
end
go

-- Да приемем, че цветните матрични принтери (type = 'Matrix') са забранени за продажба. 
-- При добавяне на принтери да се игнорират цветните матрични. Ако с една заявка се добавят 
-- няколко принтера, да се добавят само тези, които не са забранени, а другите да се игнорират.

create trigger InsertMatrix on printer
instead of insert
as
begin
	insert into printer
	select *
	from inserted
	where type != 'Matrix' or color != 'y'
end
go

-- Да се направи така, че при изтриване на лаптоп на производител D автоматично 
-- да се добавя PC със същите параметри в таблицата с компютри. Моделът на новите 
-- компютри да бъде ‘1121’, CD устройството да бъде ‘52x’, а кодът - със 100 
-- по-голям от кода на лаптопа.

create trigger DeleteD on laptop
after delete
as
begin
	insert into pc
	select code + 100, '1121', speed, ram, hd, '52x', price
	from deleted join product on deleted.model = product.model
	where maker = 'D'
end
go
```