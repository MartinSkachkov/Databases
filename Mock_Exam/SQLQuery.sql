use ships

select s.NAME,
	   sum(case when o.RESULT = 'ok' then 1 else 0 end) as VICTORY,
	   sum(case when o.RESULT = 'damaged' then 1 else 0 end) as LOSS,
	   (select COUNT(*) from CLASSES c2 JOIN SHIPS s2 on c2.CLASS = s2.CLASS where c2.DISPLACEMENT = c.DISPLACEMENT) AS SAME_DISPLACEMENT_SHIPS
from CLASSES c join SHIPS s on c.CLASS = s.CLASS
			   join OUTCOMES o on s.NAME = o.SHIP
where DISPLACEMENT < 64000
group by s.NAME, c.DISPLACEMENT

----------------------------------------------------------------------------------

delete from OUTCOMES
where BATTLE in (select BATTLE
				 from CLASSES c join SHIPS s on c.CLASS = s.CLASS
								join OUTCOMES o on s.NAME = o.SHIP 
				 where (COUNTRY = 'USA' and NUMGUNS > 10) or (COUNTRY = 'Gt.Britain' and 3 < (select count(*) from OUTCOMES o2 where s.NAME = o2.SHIP)))

----------------------------------------------------------------------------------
use pc

create view technika as
	select code, 'laptop' as type, price, model
	from laptop
	where price > 600
	union all
	select code, 'pc' as type, price, model
	from pc
	where price > 600
go

select * from technika


