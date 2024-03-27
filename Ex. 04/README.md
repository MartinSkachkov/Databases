### **Примери**
```sql
-- За всяка държава да се изведат имената на корабите,
-- които никога не са участвали в битка.
select COUNTRY, NAME
from CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS
			 left join OUTCOMES on OUTCOMES.SHIP = SHIPS.NAME
where BATTLE is null

-- За всеки клас, да се изведат името му, държавата и имената на всички негови кораби, пуснати през 1916г.
-- В резултата да участват и класовете без кораби пуснати през 1916г.
select CLASSES.CLASS, COUNTRY, NAME
from CLASSES left join SHIPS on CLASSES.CLASS = SHIPS.CLASS and LAUNCHED = 1916

-- За всеки клас британски кораби - да се извлече името на класа и имената на всички битки,
-- в които са участвали кораби от този клас. Ако за даден клас няма кораби или те не са участвали в битка - да се включат със стойност NULL за името на битката
select *
from OUTCOMES join SHIPS on SHIPS.NAME = OUTCOMES.SHIP
			  right join CLASSES on SHIPS.CLASS = CLASSES.CLASS
where COUNTRY = 'Gt.Britain'

-- От базата MOVIES, да се извлече таблица с три колони:
-- Име (на актьор или продуцент)
-- Дата на раждане (да съдържа датата на раждане на актьора, NULL за продуцент)
-- Богатство (стойността от NETWORTH колоната за продуцент, NULL за актьор)
select COALESCE(MOVIESTAR.NAME, MOVIEEXEC.NAME) AS NAME, BIRTHDATE, NETWORTH
from MOVIESTAR full join MOVIEEXEC on MOVIESTAR.NAME = MOVIEEXEC.NAME
```