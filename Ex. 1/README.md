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
where GENDER = 'M' or ADDRESS like '%Malibu%'