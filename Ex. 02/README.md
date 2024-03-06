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