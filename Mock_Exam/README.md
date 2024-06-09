```sql
use ships

-- 1. За всички класове, които имат кораби пуснати на вода в 3 различни години, да се извлекат:
--    - името на класа
--    - броя на корабите от този клас, които имат водоизместимост по-голяма от 30000
--    - броя на корабите от този клас победили в битка
--    - броя на корабите от този клас, пуснати на вода след 1942-ра година

select SHIPS.CLASS, SUM(case when DISPLACEMENT > 30000 then 1 else 0 end), SUM(case when LAUNCHED > 1942 then 1 else 0 end), (select count(distinct NAME) 
																															  from SHIPS as s join OUTCOMES on s.NAME = OUTCOMES.SHIP
																															  where RESULT = 'ok' and s.CLASS = SHIPS.CLASS)
from SHIPS join CLASSES on SHIPS.CLASS = CLASSES.CLASS
group by SHIPS.CLASS
having COUNT(distinct LAUNCHED) >= 3

-- 2. Да се увеличи с 10 цената на тези компютри, за които оперативната памет е по-голяма от най-голямата оперативната памет на най-скъпия лаптоп с размер на екрана 14.
use pc

update pc
set price = price + 10
where ram >= any(select ram from laptop where price = (select max(price) from laptop) and screen = '14')

select * from pc

--3. Да се създаде изглед, който извлича таблица със следните колони:
--   - име на кораб
--   - име на неговия клас
--   - име на битката, в който е участвал
--   - общ брой на корабите с поверче от 8 оръдия, участвали в битката
--   - година на пускане на вода на кораба
--  - година на провеждане на битката
-- за всички кораби, които имат повече от 8 оръдия. Ако един кораб е участвал в повече от 1 битка - за него ще има повече от 1 ред.
use ships

create view BattleShips as
select SHIPS.NAME, SHIPS.CLASS, BATTLE, LAUNCHED, YEAR(DATE) as BATTLE_YEAR, (select count(distinct SHIP)	-- използваме корелирана заявка за да филтрираме битките
																			  from OUTCOMES join SHIPS on OUTCOMES.SHIP = SHIPS.NAME 
																							join CLASSES on CLASSES.CLASS = SHIPS.CLASS
																			  where BATTLE = BATTLES.NAME and NUMGUNS > 8)  as SHIP_PARTICIPATION
from SHIPS join OUTCOMES on SHIPS.NAME = OUTCOMES.SHIP 
		   join CLASSES on SHIPS.CLASS = CLASSES.CLASS
		   join BATTLES on BATTLE = BATTLES.NAME
where NUMGUNS > 8
go

-- 4. Да се направи тригер за таблицата OUTCOMES така, че да не се допуска в битка след 1941-ва година
-- да участва кораб с по-малко от 10 оръдия. Интересуваме се само от модификации в таблицата OUTCOMES
-- (тригери за други таблици не са нужни). Да се проверяват само новите/променените данни за коректност, а не всички данни в таблицата.

use ships

begin transaction

create trigger otcomes_trigger on OUTCOMES
after insert, update, delete as
begin

	if exists(select *
			  from CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS
						   join inserted on SHIPS.NAME = inserted.SHIP -- само току-що вмъкнатият record ни интересува
						   join BATTLES on inserted.BATTLE = BATTLES.NAME
			  where year(DATE) > 1941 and NUMGUNS < 10) 

	   throw 50001, 'Data integrity violation', 1
	
end
go

rollback
```