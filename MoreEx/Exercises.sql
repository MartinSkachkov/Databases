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

-- 11. Имената и адресите на студиата, които са работили с по-малко от 4 различни 
--     филмови звезди. Студиа, за които няма посочени филми или има, но не се знае 
--     кои актьори са играли в тях, също да бъдат изведени. 
--     Първо да се изведат студиата, работили с най-много звезди. Например, ако 
--     студиото има два филма, като в първия са играли A, B и C, а във втория - 
--     C, D и Е, то студиото е работило с 5 звезди общо.
select STUDIONAME, COUNT(distinct STARNAME) as dist_stars
from MOVIE right join STUDIO on STUDIONAME = NAME -- Студиа, за които няма посочени филми или има
		   left join STARSIN on TITLE = MOVIETITLE and YEAR = MOVIEYEAR -- кои актьори са играли (има и null)
group by STUDIONAME
having COUNT(distinct STARNAME) < 4 -- по-малко от 4 различни филмови звезди
order by dist_stars desc

-- 12. Компютрите, които са по-евтини от всеки лаптоп на същия производител.
select *
from product p join pc on p.model = pc.model
where price < all (select price
				   from product join laptop on product.model = laptop.model
				   where maker = p.maker)
order by maker

-- 13. Компютрите, които са по-евтини от всеки лаптоп и принтер на същия производител.
select *
from product p join pc on p.model = pc.model
where price < all (select MIN(price)
				   from 
						(select maker, laptop.model, price
						from product join laptop on product.model = laptop.model
						union all
						select maker, printer.model, price
						from product join printer on product.model = printer.model) t
						where t.maker = p.model)

SELECT product.maker, pc.model, pc.code, pc.price, mp.min_price
FROM pc 
	JOIN product ON pc.model = product.model
	JOIN (SELECT ap.maker, MIN(ap.price) min_price
              FROM (SELECT maker, price
                  FROM product
	               JOIN laptop ON product.model = laptop.model
                  UNION 
                  SELECT maker, price
                  FROM product
	               JOIN printer ON product.model = printer.model) ap
              GROUP BY ap.maker) mp ON mp.maker = product.maker
WHERE pc.price < mp.min_price
ORDER BY maker

-- 14. Да се изведат различните модели компютри, подредени по цена на най-скъпия 
--     конкретен компютър от даден модел.
use pc
select model
from pc
group by model
order by MAX(price)

-- 15. Всички модели компютри, за които разликата в размера на най-големия и 
--     най-малкия харддиск е поне 20 GB.
select model, MAX(hd) - MIN(hd) as diff
from pc
group by model
having MAX(hd) - MIN(hd) >= 20

-- 16. За производителите на поне 2 лазерни принтера - броя на произвежданите PC-та
select maker, (select COUNT(*) from product p2 join pc pc2 on p2.model = pc2.model where p2.maker = p.maker)
from product p join printer r on p.model = r.model
where r.type = 'Laser'

-- 17. Да се изведат всички производители, за които средната цена на 
-- произведените компютри е по-ниска от средната цена на техните лаптопи
select maker
from product p join pc on p.model = pc.model
group by maker
having AVG(price) < (select AVG(price)
					 from product join laptop on product.model = laptop.model 
					 where maker = p.maker)

-- 18. Един модел компютри може да се предлага в няколко конфигурации 
--     с евентуално различна цена. Да се изведат тези модели компютри,
--     чиято средна цена (на различните му конфигурации) е по-ниска
--     от най-евтиния лаптоп, произвеждан от същия производител.
select p.model, AVG(price)
from product p join pc on p.model = pc.model
group by p.maker, p.model
having AVG(price) < (select MIN(price)
					 from product join laptop on product.model = laptop.model
					 where maker = p.maker)

------------------------------------------------------------------------------------
use ships

-- 1. Имената и годините на пускане на всички кораби, които имат 
--    същото име като своя клас.
select NAME, LAUNCHED
from SHIPS
where NAME = CLASS

-- 2. Имената на всички кораби, за които едновременно са изпълнени 
--    следните условия: 
--      1) участвали са в поне една битка
--      2) имената на корабите започват с C или K
select *
from OUTCOMES -- 1)
where SHIP like 'C%' or SHIP like 'K%' -- 2)

-- 2. Имената на всички кораби, за които едновременно са изпълнени 
--    следните условия: 
--      1) участвали са в поне две битки
--      2) имената на корабите започват с C или K
select SHIP, COUNT(distinct BATTLE) as #ofbattles
from OUTCOMES
group by SHIP
having COUNT(distinct BATTLE) >= 2 and (SHIP like 'C%' or SHIP like 'K%') -- 1) and 2)

-- 3. Всички държави, които имат потънали в битка кораби.
select distinct COUNTRY
from (CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS)
			  join OUTCOMES on NAME = SHIP
where RESULT = 'sunk'

-- 4. Всички държави, които нямат нито един потънал кораб.
select distinct COUNTRY
from CLASSES
where COUNTRY not in (select distinct COUNTRY
					  from (CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS)
					  join OUTCOMES on NAME = SHIP and RESULT = 'sunk')

SELECT c.COUNTRY
FROM CLASSES c
    LEFT OUTER JOIN SHIPS s ON c.CLASS = s.CLASS
    LEFT OUTER JOIN OUTCOMES o ON s.NAME = o.SHIP AND o.RESULT = 'sunk'
GROUP BY c.COUNTRY
HAVING COUNT(o.RESULT) = 0

-- 5. Имената на класовете, за които няма кораб, пуснат на вода 
--    (launched) след 1921 г. Ако за класа няма пуснат никакъв кораб, 
--    той също трябва да излезе в резултата.
select CLASS
from CLASSES
where CLASS not in (select distinct CLASS
					from SHIPS
					where LAUNCHED > 1921)

-- 6. Името, държавата и калибъра (bore) на всички класове кораби 
--    с 6, 8 или 10 оръдия. Калибърът да се изведе в сантиметри 
--    (1 инч е приблизително 2.54 см).
select distinct NAME, COUNTRY, BORE * 2.54 as BORECM 
from CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS
where NUMGUNS in (6, 8, 10) -- NUMGUNS = 6 or NUMGUNS = 8 or NUMGUNS = 10

-- 7. Държавите, които имат класове с различен калибър (напр. САЩ 
--    имат клас с 14 калибър и класове с 16 калибър, докато Великобритания 
--    има само класове с 15).
select COUNTRY, COUNT(distinct BORE)
from CLASSES
group by COUNTRY
having COUNT(distinct BORE) > 1

SELECT *
FROM CLASSES c1
	JOIN CLASSES c2 ON c1.COUNTRY = c2.COUNTRY AND c1.BORE != c2.BORE

-- 8. Страните, които произвеждат кораби с най-голям брой оръдия (numguns).
select distinct COUNTRY
from CLASSES
where NUMGUNS = (select MAX(NUMGUNS) from CLASSES)

-- 9. Намерете броя на потъналите американски кораби за всяка проведена 
--    битка с поне един потънал американски кораб.
select BATTLE, COUNT(distinct SHIP)
from (CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS)
			  join OUTCOMES on NAME = SHIP and RESULT = 'sunk' and COUNTRY = 'USA'
group by BATTLE

-- 10. Намерете имената на битките, в които са участвали поне 3 кораба с 
-- под 9 оръдия и от тях поне два са с резултат 'ok'.
select BATTLE
from (select distinct NAME
	  from CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS
	  where NUMGUNS < 9) as ship_guns
	  join OUTCOMES on ship_guns.NAME = SHIP
group by BATTLE
having COUNT(*) >= 3 and SUM(CASE RESULT when 'ok' then 1 else 0 end) >= 2

SELECT o.BATTLE
FROM OUTCOMES o
	JOIN SHIPS s ON o.SHIP = s.NAME
	JOIN CLASSES c ON c.CLASS = s.CLASS
WHERE c.NUMGUNS < 9 
GROUP BY o.BATTLE
HAVING COUNT(*) >= 3 AND SUM(CASE o.RESULT WHEN 'ok' THEN 1 ELSE 0 END) >= 2

-- 11. За всеки кораб, който е от клас с име, несъдържащо буквите i и k, 
--     да се изведе името на кораба и през коя година е пуснат на вода. 
--     Резултатът да бъде сортиран така, че първо да се извеждат най-скоро 
--     пуснатите кораби.
select NAME, CLASS, LAUNCHED
from SHIPS
where CLASS not like '%i%' and CLASS not like '%k%' --CLASS in (select CLASS from CLASSES where CLASS not like '%i%' and CLASS not like '%k%')
order by LAUNCHED desc	

-- 12. Да се изведат имената на всички битки, в които е потънал поне 
--     един японски кораб.
select distinct BATTLE
from (CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS)
			  join OUTCOMES on NAME = SHIP and COUNTRY = 'Japan' and RESULT = 'sunk'

-- 13. Да се изведат имената и класовете на всички кораби, пуснати на 
--     вода една година след кораба 'Rodney' и броят на оръдията им е 
--     по-голям от средния брой оръдия на класовете, произвеждани от 
--     тяхната страна.
select NAME, c.CLASS
from SHIPS join CLASSES c on SHIPS.CLASS = c.CLASS 
where LAUNCHED = (select LAUNCHED from SHIPS where NAME = 'Rodney') + 1 -- една година след кораба 'Rodney'
	  and NUMGUNS > (select AVG(NUMGUNS) from CLASSES where COUNTRY = c.COUNTRY) -- броят на оръдията им е 
																				 -- по-голям от средния брой оръдия на класовете, произвеждани от 
																				 -- тяхната страна.

-- 14. Да се изведат американските класове, за които всички техни кораби 
--     са пуснати на вода в рамките на поне 10 години (например кораби от 
--     клас North Carolina са пускани в периода от 1911 до 1941, което е 
--     повече от 10 години, докато кораби от клас Tennessee са пуснати 
--     само през 1920 и 1921 г.).
select CLASSES.CLASS
from CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS
where COUNTRY = 'USA'
group by CLASSES.CLASS
having MAX(LAUNCHED) - MIN(LAUNCHED) >= 10

-- 15. За всяка държава да се изведе: броят на корабите от тази държава; 
--     броя на битките, в които е участвала; броя на битките, в които 
--     неин кораб е потънал ('sunk') (ако някоя от бройките е 0 – да се 
--     извежда 0).
select COUNTRY, COUNT(distinct NAME) as #ships, COUNT(distinct BATTLE) as #battles, SUM(case RESULT when 'sunk' then 1 else 0 end) as #sunk
from CLASSES left join SHIPS on CLASSES.CLASS = SHIPS.CLASS
			 left join OUTCOMES on NAME = SHIP
group by COUNTRY

---------------------------------------------------------------------------------
use movies
-- Да се напише заявка, която извежда имената и годините на всички филми, които са
-- по-дълги от 120 минути и са снимани преди 1990 г. Ако дължината на филма е
-- неизвестна (NULL), името и годината на този филм също да се изведат.
select TITLE, YEAR
from MOVIE
where (LENGTH > 120 or LENGTH is null) and YEAR < 1990

-- Да се напише заявка, която извежда имената на най-младия актьор (мъж).
-- Забележка: полът на актьора може да бъде 'M' или 'F'. 
select TOP 1 NAME
from MOVIESTAR
where GENDER = 'M'
order by BIRTHDATE desc

select *
from MOVIESTAR ms
where ms.GENDER = 'M' and ms.BIRTHDATE = (select max(BIRTHDATE) from MOVIESTAR where GENDER = 'M')

use ships
-- Да се напише заявка, която извежда държавата и броят на потъналите кораби за
-- тази държава. Държави, които нямат кораби или имат кораб, но той не е участвал в
-- битка, също да бъдат изведени. 
select COUNTRY, COUNT(distinct NAME) as sunk_ships
from (CLASSES left join SHIPS on CLASSES.CLASS = SHIPS.CLASS)
			  left join OUTCOMES on NAME = SHIP
where RESULT = 'sunk' or RESULT is null
group by COUNTRY

use pc
-- Да се изведат различните модели компютри, чиято цена е по-ниска от най-евтиния
-- лаптоп, произвеждан от същия производител. 
select distinct p.model
from product p join pc on p.model = pc.model
where price < (select MIN(price)
			   from product join laptop on product.model = laptop.model
			   where maker = p.maker)

-----------------------------------------------------------------------------------------
use movies
-- Да се напише заявка, която извежда имената и пола на всички актьори, чието име
-- започва с 'J' и са родени след 1948 година. Резултатът да бъде подреден по име в
-- намаляващ ред. 
select NAME, GENDER
from MOVIESTAR
where NAME like 'J%' and YEAR(BIRTHDATE) > 1948
order by NAME desc	

use pc
-- Да се напише заявка, която извежда всички модели лаптопи, за които се предлагат
-- както разновидности с 15" екран, така и с 11" екран. 
select l1.model
from laptop l1 join laptop l2 on l1.model = l2.model
where l1.screen = 15 and l2.screen = 11

use ships
-- Да се напише заявка, която извежда име и държава на всички кораби, които никога
-- не са потъвали в битка (може и да не са участвали)
select distinct NAME, COUNTRY
from (CLASSES join SHIPS on CLASSES.CLASS = SHIPS.CLASS)
			  left join OUTCOMES on NAME = SHIP
where RESULT != 'sunk' or RESULT is null

use pc
-- Един модел компютри може да се предлага в няколко разновидности с евентуално
-- различна цена. Да се изведат тези модели компютри, чиято средна цена (на
-- различните му разновидности) е по-ниска от най-евтиния лаптоп. 
select model
from pc
group by model
having AVG(price) < (select MIN(price) from laptop)

-----------------------------------------------------------------------------------
use ships
-- Да се напише заявка, която извежда имената на всички кораби без повторения,
-- които са участвали в поне една битка и чиито имена започват с буквите C или K. select distinct SHIPfrom OUTCOMESwhere SHIP like 'C%' or SHIP like 'K%'use pc-- Да се напише заявка, която извежда за всеки компютър: код на продукта (code);
-- производител; брой компютри, които имат цена, по-голяма или равна на неговата.
select pc1.code, maker, (select COUNT(*) from pc where price >= pc1.price and code != pc1.code) as #poopy
from pc pc1 join product on pc1.model = product.model

use movies
-- Да се напише заявка, която извежда името на филма, годината и броят на актьорите
-- участвали в този филм, за тези филми с повече от 2-ма актьори.
select MOVIETITLE, MOVIEYEAR, COUNT(STARNAME)
from STARSIN
group by MOVIETITLE, MOVIEYEAR
having COUNT(distinct STARNAME) > 2

use pc
-- Един модел компютри може да се предлага в няколко разновидности с евентуално
-- различна цена. Да се изведат тези модели компютри, чиято сума от цените (на
-- различните му разновидности) е по-ниска от сумата на цените на лаптопите. 
select model
from pc
group by model
having SUM(price) < (select SUM(price) from laptop)

-------------------------------------------------------------------------------------
-- Един модел компютри може да се предлага в няколко разновидности с евентуално
-- различна цена. Да се изведат тези модели компютри, чиято средна цена (на различните му
-- разновидности) е по-ниска от най-евтиния лаптоп, произвеждан от същия производител. 
select pc.model
from pc join product p on pc.model = p.model
group by pc.model, p.maker
having AVG(pc.price) < (select MIN(price) from laptop join product on laptop.model = product.model where maker = p.maker)