### **Примери**
```sql
-- Да се преброят корабите във всеки клас (да извлечеме таблица с 2 колони - име на клас, брой
-- кораби от този клас)
use ships

select CLASSES.CLASS, COUNT(NAME) AS NUMSHIPS
from CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS
group by CLASSES.CLASS;

-- Да се извлече броя корабите във всеки клас, който има повече от 2 кораба
select CLASSES.CLASS, COUNT(NAME) AS NUMSHIPS
from CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS
group by CLASSES.CLASS
having COUNT(NAME) > 2;

-- За всяко студио - името и сумата от дължините на всички негови филми
use movies

select STUDIONAME, SUM(LENGTH)
from MOVIE
group by STUDIONAME

SELECT DISTINCT STUDIONAME, (SELECT SUM(LENGTH)
							 FROM MOVIE
							 WHERE STUDIONAME = m.STUDIONAME)
FROM MOVIE m
```

### **Задачи върху базата PC**

```sql
use pc

-- Напишете заявка, която извежда средната честота на компютрите
select AVG(speed) as avg_speed
from pc;

-- Напишете заявка, която извежда средния размер на екраните на лаптопите за
-- всеки производител
select  maker, AVG(screen)
from product join laptop on product.model = laptop.model
group by maker;

-- Напишете заявка, която извежда средната честота на лаптопите с цена над 1000
select AVG(speed) as avg_speed
from laptop
where price > 1000;

-- Напишете заявка, която извежда средната цена на компютрите произведени от
-- производител ‘A’
select AVG(price) as avg_price
from product join pc on product.model = pc.model
where maker = 'A';

select AVG(price) as avg_price
from product join pc on product.model = pc.model
group by maker
having maker = 'A';

-- Напишете заявка, която извежда средната цена на компютрите и лаптопите за
-- производител ‘B’
select AVG(price) as avg_price
from (select maker, price
	  from product join pc on product.model = pc.model
	  union all
	  select maker, price
	  from product join laptop on product.model = laptop.model) t
where maker = 'B';

-- Напишете заявка, която извежда средната цена на компютрите според
-- различните им честоти
select speed, AVG(price) as avg_price
from pc
group by speed;

-- Напишете заявка, която извежда производителите, които са произвели поне по 3
-- различни модела компютри
select maker, COUNT(type) as #difmod
from product
where type = 'PC'
group by maker
having COUNT(*) >= 3;

-- Напишете заявка, която извежда производителите на компютрите с най-висока
-- цена
select maker, MAX(price) as max_price
from product join pc on product.model = pc.model
group by maker;

select maker
from product join pc on product.model = pc.model
where price = (select MAX(price) from pc);

-- Напишете заявка, която извежда средната цена на компютрите за всяка честота
-- по-голяма или равна на 600
select speed, AVG(price) as avg_price
from pc
where speed >= 600
group by speed;

select speed, AVG(price) as avg_price
from pc
group by speed
having speed >= 600;

-- Напишете заявка, която извежда средния размер на диска на тези компютри
-- произведени от производители, които произвеждат и принтери
select AVG(hd)
from product join pc on product.model = pc.model
where maker in (select maker from product where type = 'Printer');

-- Напишете заявка, която за всеки размер на лаптоп намира разликата в цената на
-- най-скъпия и най-евтиния лаптоп със същия размер
select screen, MAX(price) - MIN(price) as price_diff
from laptop
group by screen;
```

### **Задачи върху базата SHIPS**

```sql
use ships

-- Напишете заявка, която извежда броя на класовете кораби
select COUNT(CLASS) as CLASSCOUNT
from CLASSES;

-- Напишете заявка, която извежда средния брой на оръжия за всички кораби,
-- пуснати на вода
select AVG(NUMGUNS) as avg_numguns
from CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS;

-- Напишете заявка, която извежда за всеки клас първата и последната година, в
-- която кораб от съответния клас е пуснат на вода
select CLASS, MIN(LAUNCHED) as first_launch, MAX(LAUNCHED) as last_launch
from SHIPS
group by CLASS;

-- Напишете заявка, която извежда броя на корабите потънали в битка според класа
select CLASS, COUNT(RESULT) as NUMOFSUNK
from SHIPS join OUTCOMES on NAME = SHIP
where RESULT = 'sunk'
group by CLASS;

select CLASS, COUNT(RESULT) as NUMOFSUNK
from SHIPS left join OUTCOMES on NAME = SHIP and RESULT = 'sunk'
group by CLASS;

-- Напишете заявка, която извежда броя на корабите потънали в битка според
-- класа, за тези класове с повече от 4 пуснати на вода кораба
select t1.CLASS, t2.SUNKCOUNT
from (select CLASS, COUNT(LAUNCHED) as LAUNCHNUM
	  from SHIPS
	  group by CLASS
	  having COUNT(LAUNCHED) > 4) t1 -- таблица с броя на пуснатите кораби от всеки клас
	  join 
	  (select CLASS, COUNT(RESULT) as SUNKCOUNT
	  from SHIPS join OUTCOMES on NAME = SHIP and RESULT = 'sunk'
	  group by CLASS) t2 -- таблица с броя потънали кораби от всеки клас
	  on t1.CLASS = t2.CLASS; -- ако даден клас има потънал кораб и пуснат 

-- Напишете заявка, която извежда средното тегло на корабите, за всяка страна. 
select COUNTRY, AVG(DISPLACEMENT) as avg_weight
from CLASSES
group by COUNTRY;


```