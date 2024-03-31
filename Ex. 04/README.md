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

### **Задачи върху базата MOVIES**

```sql
use movies

-- Напишете заявка, която за всеки филм, по-дълъг от 120 минути,
-- извежда заглавие, година, име и адрес на студио.
select TITLE, YEAR, STUDIONAME, ADDRESS
from MOVIE join STUDIO on STUDIONAME = NAME
where LENGTH > 120;

-- Напишете заявка, която извежда името на студиото и имената на
-- актьорите, участвали във филми, произведени от това студио,
-- подредени по име на студио.
select distinct STUDIONAME, STARNAME
from MOVIE join STARSIN on TITLE = MOVIETITLE and YEAR = MOVIEYEAR
order by STUDIONAME asc;

-- Напишете заявка, която извежда имената на продуцентите на филмите,
-- в които е играл Harrison Ford.
select distinct NAME
from MOVIE join STARSIN on TITLE = MOVIETITLE and YEAR = MOVIEYEAR
		   join MOVIEEXEC on PRODUCERC# = CERT#
where STARNAME = 'Harrison Ford';

-- Напишете заявка, която извежда имената на актрисите, играли във
-- филми на MGM.
select NAME
from MOVIE join STARSIN on TITLE = MOVIETITLE and YEAR = MOVIEYEAR
		   join MOVIESTAR on NAME = STARNAME 
where STUDIONAME = 'MGM' and GENDER = 'F';

-- Напишете заявка, която извежда името на продуцента и имената на
-- филмите, продуцирани от продуцента на 'Star Wars'.
select TITLE, NAME
from MOVIE join MOVIEEXEC on PRODUCERC# = CERT#
where NAME = 'George Lucas';

-- Напишете заявка, която извежда имената на актьорите не участвали в
-- нито един филм.
select *
from MOVIESTAR left join STARSIN on NAME = STARNAME
where STARNAME is null;
```

### **Задачи върху базата PC**

```sql
use pc

-- Напишете заявка, която извежда производител, модел и тип на продукт
-- за тези производители, за които съответния продукт не се продава
-- (няма го в таблиците PC, лаптоп или принтер).
select maker, product.model, type
from product left join (select model from laptop
				   union
				   select model from pc
				   union
				   select model from printer) av_models on product.model = av_models.model
where av_models.model is null;
```

### **Задачи върху базата SHIPS**
```sql
use ships

-- Напишете заявка, която за всеки кораб извежда името му, държавата,
-- броя оръдия и годината на пускане (launched).
select NAME, COUNTRY, NUMGUNS, LAUNCHED
from CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS;

-- Напишете заявка, която извежда имената на корабите, участвали в битка
-- от 1942г.
select SHIP
from OUTCOMES join BATTLES on BATTLE = NAME
where YEAR(DATE) = 1942;

-- За всяка страна изведете имената на корабите, които никога не са
-- участвали в битка.
select distinct *
from CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS
			 left join OUTCOMES on NAME = SHIP 
where RESULT is null

-- Имената на класовете, за които няма кораб, пуснат на вода
-- (launched) след 1921 г. Ако за класа няма пуснат никакъв кораб,
-- той също трябва да излезе в резултата.
select *
from CLASSES left join SHIPS ON CLASSES.CLASS = SHIPS.CLASS AND LAUNCHED > 1921
where NAME is null;

select *
from CLASSES
where CLASS not in (select LAUNCHED from SHIPS where LAUNCHED > 1921);
```
