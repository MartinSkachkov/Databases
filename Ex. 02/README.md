### **Задачи върху базата MOVIES**

```sql
use movies

-- Напишете заявка, която извежда имената на актьорите мъже, участвали в 'Terms of Endearment'
-- 1н. (intersect намира общите данни в колоната от две sql заявки)
select STARNAME from STARSIN
where MOVIETITLE = 'Terms of Endearment'
intersect
select NAME from MOVIESTAR
where GENDER = 'M';

-- 2н.
select MOVIESTAR.NAME
from MOVIESTAR join STARSIN 
on MOVIESTAR.NAME = STARSIN.STARNAME
where STARSIN.MOVIETITLE = 'Terms of Endearment' and MOVIESTAR.GENDER = 'M';

-- 3н. (ползваме идентификатор на таблица, само когато две или повече таблици имат колкона с еднакво име)
select NAME
from MOVIESTAR join STARSIN 
on NAME = STARNAME
where MOVIETITLE = 'Terms of Endearment' and GENDER = 'M';

-- Напишете заявка, която извежда имената на актьорите, участвали във филми, продуцирани от ‘MGM’ през 1995 г.
select distinct STARNAME
from STARSIN join MOVIE
on MOVIETITLE = TITLE and MOVIEYEAR = YEAR  
where STUDIONAME = 'MGM' and MOVIEYEAR = 1995;

-- Напишете заявка, която извежда името на президента на ‘MGM’
select distinct STUDIO.NAME
from MOVIEEXEC join STUDIO
on CERT# = PRESC#
where STUDIO.NAME = 'MGM';

-- Напишете заявка, която извежда имената на всички филми с дължина, по-голяма от дължината на филма ‘Star Wars’
select m2.TITLE
from MOVIE m1 join MOVIE m2
on m1.TITLE = 'Star Wars' and m1.YEAR=1977
where m2.LENGTH > m1.LENGTH;

```

### **Задачи върху базата PC**
```sql
use pc

-- Напишете заявка, която извежда производителя и честотата на процесора на тези лаптопи с размер на диска поне 9 GB
select maker, speed
from product join pc
on product.model = pc.model
where hd >= 9;

-- Напишете заявка, която извежда номер на модел и цена на всички продукти, произведени от производител с име ‘B’.
-- Сортирайте резултата така, че първо да се изведат най-скъпите продукти
select * 
from product join (select model, price from pc union
				   select model, price from laptop union
				   select model, price from printer) u
on product.model = u.model
where product.maker = 'B'
order by price desc;

-- Напишете заявка, която извежда размерите на тези дискове, които се предлагат в
-- поне два компютъра
select distinct p1.hd
from pc p1 join pc p2 
on p1.code != p2.code
where p1.hd = p2.hd;

-- Напишете заявка, която извежда всички двойки модели на компютри, които имат
-- еднаква честота и памет. Двойките трябва да се показват само по веднъж,
-- например само (i, j), но не и (j, i)
select p1.model, p2.model
FROM pc p1 join pc p2
on p1.model < p2.model
where p1.speed = p2.speed and p1.ram = p2.ram;

-- Напишете заявка, която извежда производителите на поне два различни
-- компютъра с честота на процесора поне 500 MHz.
select distinct p1.maker
from pc pc1 
join pc pc2 on pc1.code != pc2.code
join product p1 on p1.model = pc1.model
join product p2 on p2.model = pc2.model
where pc1.speed >= 500 and pc2.speed >= 500 and p1.maker = p2.maker;
```

### **Задачи върху базата SHIPS**
```sql
use ships

-- Напишете заявка, която извежда името на корабите, по-тежки (displacement) от 35000
select distinct NAME
from SHIPS join CLASSES
on SHIPS.CLASS = CLASSES.CLASS
where DISPLACEMENT > 35000

-- Напишете заявка, която извежда имената, водоизместимостта и броя оръдия на всички кораби, участвали в битката при 'Guadalcanal'
select distinct SHIPS.NAME, DISPLACEMENT, NUMGUNS
from SHIPS
join CLASSES on SHIPS.CLASS = CLASSES.CLASS
join OUTCOMES on SHIPS.NAME = OUTCOMES.SHIP
where OUTCOMES.BATTLE = 'Guadalcanal'

-- Напишете заявка, която извежда имената на тези държави, които имат класове
-- кораби от тип ‘bb’ и ‘bc’ едновременно
select c1.COUNTRY
from CLASSES c1 join CLASSES c2
on c1.COUNTRY = c2.COUNTRY
WHERE c1.TYPE = 'bb' and c2.TYPE = 'bc'

-- Напишете заявка, която извежда имената на тези кораби, които са били
-- повредени в една битка, но по-късно са участвали в друга битка.
SELECT * --DISTINCT o1.SHIP
FROM OUTCOMES o1
    JOIN BATTLES b1 ON o1.BATTLE = b1.NAME
    JOIN OUTCOMES o2 ON o1.SHIP = o2.SHIP
    JOIN BATTLES b2 ON o2.BATTLE = b2.NAME
WHERE o1.RESULT = 'damaged' AND b1.DATE < b2.DATE
```