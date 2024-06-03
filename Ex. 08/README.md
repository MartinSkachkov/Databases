use ships
go

-- 1. Дефинирайте изглед наречен BritishShips, който дава за всеки британски кораб неговият клас, 
--    тип, брой оръдия, калибър, водоизместимост и годината, в която е пуснат на вода
create view BritishShips as
	select NAME ,SHIPS.CLASS, TYPE, NUMGUNS, BORE, DISPLACEMENT, LAUNCHED
	from SHIPS join CLASSES on SHIPS.CLASS = CLASSES.CLASS
	where COUNTRY = 'Gt.Britain'
go

select * from BritishShips

-- 2. Напишете заявка, която използва изгледа от предната задача, за да покаже броят оръдия и 
--    водоизместимост на британските бойни кораби, пуснати на вода преди 1917
select NAME, NUMGUNS, DISPLACEMENT
from BritishShips
where LAUNCHED = 1917

-- 3. Напищете съответната SQL заявка, реализираща задача 2, но без да използвате изглед
select SHIPS.NAME, NUMGUNS, DISPLACEMENT
from CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS
where COUNTRY = 'Gt.Britain' and LAUNCHED = 1917

-- 4. Средната стойност на най-тежките класове кораби от всяка страна
--    Резюмираме, че може да има повече от един клас с максималната изместимост за страна
create view AverageDisplacement as
	select AVG(DISPLACEMENT) as AVG_DISPLACEMENT
	from CLASSES join (select COUNTRY, MAX(DISPLACEMENT) as MAX_DISPLACEMENT
						from CLASSES
						group by COUNTRY) t on CLASSES.COUNTRY = t.COUNTRY and CLASSES.DISPLACEMENT = t.MAX_DISPLACEMENT
go	

select * from AverageDisplacement

-- 5. Създайте изглед за всички потънали кораби по битки
create view SunkShips as
	select SHIP, BATTLE
	from OUTCOMES
	where RESULT = 'sunk'
go

select * from SunkShips

-- 6. Въведете кораба California като потънал в битката при Guadalcanal чрез изгледа от задача 5.
--    За целта задайте подходяща стойност по подразбиране на колоната result от таблицата Outcomes
alter table OUTCOMES
add constraint DF_Result default 'sunk' for result
go

insert into SunkShips
values ('California', 'Guadalcanal')
go

alter table OUTCOMES
drop constraint DF_Result
go

select * from SunkShips

-- 7. Създайте изглед за всички класове с поне 9 оръдия. Използвайте WITH CHECK OPTION. Опитайте се 
-- да промените през изгледа броя оръдия на класа Iowa последователно на 15 и 5.
create view ClassGuns as
	select CLASS
	from CLASSES
	where NUMGUNS >= 9
	with check option
go

alter view ClassGuns as -- добавяме още една колона
	select CLASS, NUMGUNS
	from CLASSES
	where NUMGUNS >= 9
	with check option
go

select * from ClassGuns

update ClassGuns
set NUMGUNS = 15 -- ако пробваме да го сложим на 5 дава грешка понеже няма да е вече достъпно през изгледа
where CLASS = 'Iowa'

select * from CLASSES

update CLASSES
set NUMGUNS = 5
where CLASS = 'Iowa'

select * from ClassGuns -- вече не се показва

-- restore
update CLASSES
set NUMGUNS = 9
where CLASS = 'Iowa'

-- 8. Променете изгледа от задача 7, така че броят оръдия да може да се променя без ограничения.
alter view ClassGuns as -- махаме check option
	select CLASS, NUMGUNS
	from CLASSES
	where NUMGUNS >= 9
go

select * from ClassGuns

update ClassGuns
set NUMGUNS = 5
where CLASS = 'Iowa'

-- 9. Създайте изглед с имената на битките, в които са участвали поне 3 кораба с под 9 оръдия и 
--    от тях поне един е бил увреден.
create view BattleList as
	select BATTLE
	from OUTCOMES join SHIPS on OUTCOMES.SHIP = SHIPS.NAME join CLASSES on SHIPS.CLASS = CLASSES.CLASS 
	where NUMGUNS < 9 
	group by BATTLE
	having COUNT(*) >= 3 and SUM(case RESULT when 'damaged' then 1 else 0 end) >= 1
go

select * from BattleList