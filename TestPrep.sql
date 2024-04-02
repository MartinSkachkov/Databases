use movies
use pc
use ships

-- 1. За всяка филмова звезда да се изведе името, рождената дата и с кое
--    студио е записвала най-много филми. (Ако има две студиа с еднакъв 
--    брой филми, да се изведе кое да е от тях)
select NAME, BIRTHDATE, (select TOP 1 STUDIONAME -- върни първият ред от резултата на заявката
						 from STARSIN join MOVIE on MOVIETITLE = TITLE and MOVIEYEAR = YEAR
						 where STARNAME = NAME
						 group by STUDIONAME
						 order by COUNT(*) desc)
from MOVIESTAR

-- 2. Да се изведат всички производители, за които средната цена на 
--    произведените компютри е по-ниска от средната цена на техните лаптопи.
select t1.maker, avg_pc_price
from
	(select maker, AVG(price) as avg_pc_price
	from product join pc on product.model = pc.model
	group by maker) t1 -- съдържа maker (A,B,E) и средната цена на продуктите от всеки maker
	join 
	(select maker, AVG(price) as avg_lap_price
	from product join laptop on product.model = laptop.model
	group by maker) t2 -- съдържа maker (A,B,C) и средната цена на продуктите от всеки maker
	on t1.maker = t2.maker
where avg_pc_price < avg_lap_price

-- 3. Един модел компютри може да се предлага в няколко конфигурации 
--    с евентуално различна цена. Да се изведат тези модели компютри,
--    чиято средна цена (на различните му конфигурации) е по-ниска
--    от най-евтиния лаптоп, произвеждан от същия производител.
select maker, p.model, AVG(price)
from product p join pc on p.model = pc.model
group by maker, p.model
having AVG(price) < (select MIN(price)
					 from laptop join product on laptop.model = product.model
					 where maker = p.maker)

-- 4. Битките, в които са участвали поне 3 кораба на една и съща страна.
select COUNTRY, BATTLE, COUNT(NAME) as num_ships
from (select COUNTRY, NAME
	  from CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS) t
	  join 
	  OUTCOMES on t.NAME = SHIP
group by COUNTRY, BATTLE
having COUNT(NAME) >= 3 

-- 5. За всеки кораб да се изведе броят на битките, в които е бил увреден.
--    Ако корабът не е участвал в битки или пък никога не е бил
--    увреждан, в резултата да се вписва 0.

-- Когато използвате LEFT JOIN с условие result = 'damaged',
-- вие казвате на SQL да вземе всички редове от SHIPS и да добави информация от OUTCOMES
-- само ако има съответстващ ред, който отговаря на условието result = 'damaged'.
-- Ако няма такъв ред, SQL ще добави NULL стойности за полетата от OUTCOMES.
select NAME, COUNT(RESULT)
from SHIPS left join OUTCOMES on NAME = SHIP and result = 'damaged' -- (замества ok, sunk -> NULL)
group by NAME

select NAME, COUNT(RESULT)
from SHIPS left join OUTCOMES on NAME = SHIP
where result = 'damaged' or RESULT is null	 -- (направо премахва ok & sunk)
group by NAME

-- 6. За всеки клас да се изведе името, държавата и първата година, в която 
--    е пуснат кораб от този клас
select CLASSES.CLASS, COUNTRY, MIN(LAUNCHED) as FIRST_YEAR
from CLASSES left join SHIPS on CLASSES.CLASS = SHIPS.CLASS
group by CLASSES.CLASS, COUNTRY

-- 6.1. но да извличаме и името на корабите
select NAME, COUNTRY, FIRST_YEAR
from (select CLASSES.CLASS, COUNTRY, MIN(LAUNCHED) as FIRST_YEAR
	  from CLASSES left join SHIPS on CLASSES.CLASS = SHIPS.CLASS
	  group by CLASSES.CLASS, COUNTRY) t
	  left join 
	  SHIPS on t.CLASS = SHIPS.class and t.FIRST_YEAR = LAUNCHED

-- 7. За всяка държава да се изведе броят на корабите и броят на потъналите 
--    кораби. Всяка от бройките може да бъде и нула.
select COUNTRY, COUNT(NAME) as all_ships, COUNT(RESULT) as sunk
from (CLASSES left join SHIPS on CLASSES.CLASS = SHIPS.CLASS)
	 left join OUTCOMES on NAME = SHIP and RESULT = 'sunk'
group by COUNTRY

-- 8. Намерете за всеки клас с поне 3 кораба броя на корабите от 
--    този клас, които са с резултат ok.
select CLASS, COUNT(NAME) as all_ships, COUNT(RESULT) as ok
from SHIPS left join OUTCOMES on SHIPS.NAME= OUTCOMES.SHIP and RESULT = 'ok'
group by CLASS
having COUNT(NAME) >= 3

-- 9. За всяка битка да се изведе името на битката, годината на 
--    битката и броят на потъналите кораби, броят на повредените
--    кораби и броят на корабите без промяна.
select BATTLE, YEAR(DATE) as BATTLE_YEAR, 
	SUM(case RESULT
		when 'sunk' then 1
		else 0
		end) as SUNK_COUNT,
	SUM(case RESULT
		when 'ok' then 1
		else 0
		end) as OK_COUNT,
	SUM(case RESULT
		when 'damaged' then 1
		else 0
		end) as DMG_COUNT
from OUTCOMES join BATTLES on BATTLE = NAME
group by BATTLE, DATE

-- 10. Да се изведат имената на корабите, които са участвали в битки в
--     продължение поне на две години.
select SHIP
from BATTLES join OUTCOMES on NAME = BATTLE
group by SHIP
having MAX(YEAR(DATE)) - MIN(YEAR(DATE)) >= 2

-- 11. За всеки потънал кораб колко години са минали от пускането му на вода 
--     до потъването.

-- няма разлика ако result = 'sunk' е написано в условието на join-a или е в where калуза при *inner join*
select SHIP, YEAR(DATE) - LAUNCHED as time_alive
from SHIPS join OUTCOMES on NAME = SHIP and result = 'sunk'
	 join BATTLES on BATTLE = BATTLES.NAME 

-- 12. Имената на класовете, за които няма кораб, пуснат на вода след 1921 г., 
--     но имат пуснат поне един кораб. 
select CLASS
from SHIPS
group by CLASS
having MAX(LAUNCHED) <= 1921

-------------------------------------------------------------------------------------
use movies

-- 1. Всички филми, чието заглавие съдържа едновременно думите 'Star' и 'Trek' 
--    (не непременно в този ред). Резултатите да се подредят по година (първо 
--    най-новите филми), а филмите от една и съща година - по азбучен ред.
select *
from movie
where TITLE like '%Star%' and TITLE like '%Trek%'
order by YEAR desc, TITLE asc

-- 2. Заглавията и годините на филмите, в които са играли звезди, родени между 
--    1.1.1970 и 1.7.1980
select distinct MOVIETITLE, MOVIEYEAR
from STARSIN join MOVIESTAR on STARNAME = NAME
where BIRTHDATE between '1.1.1970' and '1.7.1980'

-- 3. За всеки актьор/актриса изведете броя на различните студиа, с които са 
--    записвали филми, като не се интересуваме от тези, за които не е ясно
--    в кои филми са се снимали.
select STARNAME, COUNT(distinct STUDIONAME)
from MOVIE join STARSIN on TITLE = MOVIETITLE and MOVIEYEAR = YEAR
group by STARNAME

-- 4. За всеки актьор/актриса изведете броя на различните студиа, с които са 
--    записвали филми, като се интересуваме и от тези, за които не е ясно
--    в кои филми са се снимали (0 студиа).
select NAME, COUNT(distinct STUDIONAME)
from STARSIN right join MOVIESTAR on STARNAME = NAME
	 left join MOVIE on TITLE = MOVIETITLE and YEAR = MOVIEYEAR
group by NAME

-- 5. Изведете имената на актьорите, участвали в поне 2 филма след 1978 г.
select STARNAME, COUNT(distinct MOVIETITLE)
from STARSIN
where MOVIEYEAR > 1978
group by STARNAME
having COUNT(distinct MOVIETITLE) >= 2

-- 6. Изведете най-дългия филм (ако са няколко с еднаква максималната дължина -
--    да се изведат всичките.
select TITLE, LENGTH
from MOVIE
where LENGTH = (select MAX(LENGTH) from MOVIE)

-- 7. Заглавията и годините на всички филми (без повторения), заснети преди 1982, 
--    в които е играл поне един актьор/актриса, чието име не съдържа нито буквата
--    'k', нито 'b'. Първо да се изведат най-старите филми.
select distinct TITLE, YEAR
from MOVIE join STARSIN on TITLE = MOVIETITLE and YEAR = MOVIEYEAR
where YEAR < 1982 and STARNAME not like '%k%' and STARNAME not like '%b%'
order by YEAR asc

-- 8. Заглавието, годината и дължината на всички филми, които са от същото студио, 
--    от което е и филма Terms of Endearment от 1983г., но дължината им е по-малка 
--    от неговата или неизвестна.
select *
from MOVIE
where STUDIONAME = 'MGM' and (LENGTH < 132 or LENGTH is null)

SELECT *
FROM MOVIE m
	JOIN MOVIE mte ON  mte.TITLE = 'Terms of Endearment' 
		AND mte.YEAR = 1983 AND m.STUDIONAME = mte.STUDIONAME
WHERE m.LENGTH < mte.LENGTH OR m.LENGTH IS NULL

-- 9. Имената на всички продуценти, които са и филмови звезди и са играли в поне 
--    един филм преди 1980г. и поне един след 1985г.
SELECT DISTINCT me.NAME
FROM MOVIEEXEC me
	JOIN MOVIESTAR ms ON me.NAME = ms.NAME
	JOIN STARSIN sib ON sib.STARNAME = ms.NAME AND sib.MOVIEYEAR < 1980
	JOIN STARSIN sia ON sia.STARNAME = ms.NAME AND sia.MOVIEYEAR > 1985
		
-- 10. Всички черно-бели филми, записани преди най-стария цветен филм 
--     (InColor='y'/'n') на същото студио.
select TITLE, YEAR
from MOVIE m
where INCOLOR = 'N' and  YEAR < (select MIN(YEAR) from MOVIE where INCOLOR = 'Y' and STUDIONAME = m.STUDIONAME)
	   
	  