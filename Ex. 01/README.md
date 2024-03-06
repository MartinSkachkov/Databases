### **Задачи върху базата MOVIES**

```sql
use movies;

-- Напишете заявка, която извежда адресът на студио ‘MGM’
select  NAME, ADDRESS
from STUDIO
where NAME = 'MGM';

-- Напишете заявка, която извежда рождената дата на актрисата Sandra Bullock
select BIRTHDATE
from MOVIESTAR
where NAME = 'Sandra Bullock';

-- Напишете заявка, която извежда имената на всички актьори, които са участвали във филм през 1980, 
-- в заглавието на които има думата ‘Empire’
select STARNAME
from STARSIN
where MOVIETITLE like '%Empire%' and MOVIEYEAR = 1980;

-- Напишете заявка, която извежда имената всички изпълнители на филми с нетна стойност над 10 000 000 долара
select NAME
from MOVIEEXEC
where NETWORTH > 10000000;

-- Напишете заявка, която извежда имената на всички актьори, които са мъже или живеят в Malibu
select NAME
from MOVIESTAR
where GENDER = 'M' or ADDRESS like '%Malibu%';
```

### **Задачи върху базата PC**

```sql
use pc

-- Напишете заявка, която извежда номер на модел, честота на процесора (speed) и размер на диска (hd) за всички компютри с цена по-малка от 1200 долара.
-- Задайте псевдоними за атрибутите честота и размер на диска, съответно MHz и GB
select model, speed as MHz , hd as GB
from pc
where price < 1200;

-- Напишете заявка, която извежда моделите и цените в евро на всички лаптопи. Нека приемем, че в базата цените се съхраняват в долари,
-- а курсът е 1.1 долара за евро. Да се изведат първо най-евтините лаптопи
select model, price * 1.1
from laptop
order by price asc;

-- Напишете заявка, която извежда номер на модел, размер на паметта, размер на екран за лаптопите,
-- чиято цена е по-голяма от 1000 долара
select model, hd, screen	
from laptop
where price > 1000;

-- Напишете заявка, която извежда всички цветни принтери
select model, color
from printer
where color = 'y';

-- Напишете заявка, която извежда номер на модел,
-- честота и размер на диска за тези компютри с DVD 12x или 24x и цена по-малка от 2000 долара
select model, speed, hd
from pc
where cd = '12x' or cd = '24x' and price < 2000;

-- Нека рейтингът на един лаптоп се определя по следната формула: честота на процесора + размер на RAM паметта + 10*размер на екрана.
-- Да се изведат кодовете, моделите и рейтингите на всички лаптопи.
select code, model, speed + ram + 10*screen as rating
from laptop;
```

### **Задачи върху базата SHIPS**
```sql
use ships

-- Напишете заявка, която извежда името на класа и страната за всички класове с брой на оръдията по-малък от 10
select CLASS, COUNTRY
from CLASSES
where NUMGUNS < 10;

-- Напишете заявка, която извежда имената на всички кораби, пуснати на вода преди 1918. Задайте псевдоним на колоната shipName
select NAME as shipName
from SHIPS
where LAUNCHED = 1918;

-- Напишете заявка, която извежда имената на корабите потънали в битка и имената на битките в които са потънали
select SHIP, BATTLE
from OUTCOMES
where RESULT = 'sunk';

-- Напишете заявка, която извежда имената на корабите с име, съвпадащо с името на техния клас
select NAME, CLASS
from SHIPS
where NAME = CLASS;

-- Напишете заявка, която извежда имената на всички кораби започващи с буквата R
select NAME
from SHIPS
where NAME like 'R%';

-- Напишете заявка, която извежда имената на всички кораби, чието име е съставено от точно две думи.
select NAME
from SHIPS
where NAME like '% %';
```