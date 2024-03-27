### **Задачи върху базата MOVIES**

```sql
use movies

-- филмите с по-голяма продължителност от Star Wars
select TITLE
from MOVIE
where LENGTH > (select LENGTH from movie where TITLE = 'Star Wars' and YEAR = 1977);

-- актрисите в какви филми са участвали
select *
from STARSIN
where STARNAME in (select NAME from MOVIESTAR where GENDER = 'F');

-- имената на всички филмови звезди, които са играли във филм след навършване на 40-годишна възраст
select NAME
from MOVIESTAR
where EXISTS(select * from STARSIN where MOVIESTAR.NAME = STARNAME and MOVIEYEAR >= YEAR(MOVIESTAR.BIRTHDATE) + 40);

-- Напишете заявка, която извежда имената на актрисите,
-- които са също и продуценти с нетна стойност по-голяма от 10 милиона.
select NAME
from MOVIESTAR
where GENDER = 'F' and NAME in (select NAME from MOVIEEXEC where NETWORTH > 10000000);

-- Напишете заявка, която извежда имената на тези актьори (мъже и
-- жени), които не са продуценти.
select NAME
from MOVIESTAR
where NAME not in (select NAME from MOVIEEXEC);

-- Напишете заявка, която извежда имената на всички филми с
-- дължина по-голяма от дължината на филма 'Gone With the Wind'
-- TITLE не е достатъчно за уникално идентифициране на филм в таблицата MOVIE.
-- Необходима е двойка стойности (име на филм, година).
select TITLE
from MOVIE
where LENGTH > (select LENGTH from MOVIE where TITLE = 'Gone With the Wind' and YEAR = 1938);

-- Напишете заявка, която извежда имената на продуцентите и имената на
-- продукциите за които стойността им е по-голяма от продукциите
-- на продуцента 'Merv Griffin'

SELECT NAME, TITLE
FROM MOVIE m
	JOIN MOVIEEXEC me ON m.PRODUCERC# = me.CERT#
where me.NETWORTH > (select NETWORTH from MOVIEEXEC where NAME = 'Merv Griffin');
```

### **Задачи върху базата PC**
```sql
use pc

-- Напишете заявка, която извежда производителите на персонални компютри с
-- честота поне 500.
select distinct maker
from product
where type = 'PC' and model in (select model from pc where speed >= 500);

-- Напишете заявка, която извежда принтерите с най-висока цена.
select *
from printer
where price >= all (select price from printer);

-- Напишете заявка, която извежда лаптопите, чиято честота е по-ниска от
-- честотата на който и да е персонален компютър (по-ниска от поне един).
select *
from laptop
where speed < any (select speed from pc);

-- по-ниска от тази на всички pc-та:
select *
from laptop
where speed < all (select speed from pc);

-- Напишете заявка, която извежда модела на продукта (PC, лаптоп
-- или принтер) с най-висока цена.
select t.model
from (select model, price from laptop
		union
	  select model, price from pc
	    union
	  select model, price from printer) t
where t.price >= all (select price from laptop
					union
					select price from pc
					union
					select price from printer);

-- Напишете заявка, която извежда производителя на цветния
-- принтер с най-ниска цена.
select maker
from printer join product on printer.model = product.model
where color = 'y' and price <= all (select price from printer where color = 'y');

-- Напишете заявка, която извежда производителите на тези
-- персонални компютри с най-малко RAM памет, които имат най-бързи процесори.
select maker
from product join pc on product.model = pc.model
where ram <= all (select distinct ram from pc) and speed >= all (select speed
																 from product join pc on product.model = pc.model
																 where ram <= all (select distinct ram from pc));
```

### **Задачи върху базата SHIPS**
```sql``
use ships

-- Напишете заявка, която извежда страните, чиито кораби са с
-- най-голям брой оръжия.
select distinct COUNTRY
from CLASSES
where NUMGUNS >= all (select NUMGUNS from CLASSES);

-- Напишете заявка, която извежда класовете, за които поне един
-- от корабите им е потънал в битка.
select distinct CLASS
from SHIPS
where NAME in (select SHIP from OUTCOMES where RESULT = 'sunk');

-- Напишете заявка, която извежда имената на корабите с 16 инчови
-- оръдия (bore).
select NAME
from SHIPS
where CLASS in (select CLASS from CLASSES where BORE = 16);

-- Напишете заявка, която извежда имената на битките, в които са участвали
-- кораби от клас ‘Kongo’.
select BATTLE
from OUTCOMES
where SHIP in (select NAME from SHIPS where CLASS = 'Kongo');

-- Напишете заявка, която извежда имената на корабите, чиито брой оръдия е
-- най-голям в сравнение с корабите със същия калибър оръдия (bore).
select * from SHIPS join CLASSES c1 on SHIPS.CLASS = c1.CLASS
where NUMGUNS >= all (SELECT NUMGUNS FROM CLASSES c2 WHERE c1.BORE = c2.BORE);

```
