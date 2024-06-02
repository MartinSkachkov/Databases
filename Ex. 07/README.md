```sql
use mods

BEGIN TRANSACTION

-- Да се добави информация за актрисата Nicole Kidman. За нея знаем само, че е родена на 20-и юни 1967.
insert into MOVIESTAR (NAME, GENDER, BIRTHDATE)
values ('Nicole Kidman', 'F', '1967-06-20 00:00:00.000')

select * from MOVIESTAR

-- Да се изтрият всички продуценти с печалба (networth) под 10 милиона.
delete from MOVIEEXEC
where NETWORTH < 100000000

select * from MOVIEEXEC

-- Да се изтрие информацията за всички филмови звезди, за които не се знае адреса.
delete from MOVIESTAR
where ADDRESS is null

select * from MOVIESTAR

-- Използвайки две INSERT заявки, съхранете в базата данни факта, че персонален компютър модел 1100 
-- е направен от производителя C, има процесор 2400 MHz, RAM 2048 MB, твърд диск 500 GB, 52x DVD 
-- устройство и струва $299. Нека новият компютър има код 12. Забележка: моделът и CD са от тип низ.
insert into product
values ('C', '1100', 'PC')

insert into pc
values (12, '1100', 2400, 2048, 500, '52x', 299)

select * from pc
select * from product

-- Да се изтрие всичката налична информация за компютри модел 1100.
delete from pc
where model = 1100

select * from pc

delete from product
where model = 1100

select * from product

-- За всеки персонален компютър се продава и 15-инчов лаптоп със същите параметри, но с $500 по-скъп.
-- Кодът на такъв лаптоп е със 100 по-голям от кода на съответния компютър. Добавете тази информация в базата.
insert into laptop(code, model, speed, ram, hd, price, screen)
select code+100 as code, model, speed, ram, hd, price + 500 as price, 15 as screen
from pc

select * from pc
select * from laptop

-- Да се изтрият всички лаптопи, направени от производител, който не произвежда принтери.
-- Упътване: Мислете си, че решавате задача от познат тип - "Да се изведат всички лаптопи, ...". Накрая ще е нужна съвсем малка промяна.
-- Ако започнете директно да триете, много е вероятно при някой грешен опит да изтриете всички лаптопи и ще трябва често да възстановявате таблицата или да работите на сляпо.
delete from laptop
where model in (select model
			   from product
			   where maker not in (select maker
								   from product
								   where type = 'Printer'))

select * from laptop

-- Производител А купува производител B. На всички продукти на В променете производителя да бъде А.
update product
set maker = 'A'
where maker = 'B'

select * from product

-- Да се намали два пъти цената на всеки компютър и да се добавят по 20 GB към всеки твърд диск. Упътване: няма нужда от две отделни заявки.
update pc
set price = price / 4, hd = hd + 20

select * from pc

-- За всеки лаптоп от производител B добавете по един инч към диагонала на екрана.
update laptop
set screen = screen + 1
where model in (select model from product where maker = 'B' and type = 'Laptop')

select * from laptop

-- Два британски бойни кораба от класа Nelson - Nelson и Rodney - Nelson са били пуснати на вода едновременно през 1927 г.
-- Имали са девет 16-инчови оръдия (bore) и водоизместимост от 34 000 тона (displacement). Добавете тези факти към базата от данни.
insert into SHIPS 
values ('Nelson', 'Nelson', 1927)

insert into SHIPS
values ('Rodney', 'Nelson', 1927)

insert into CLASSES
values ('Nelson', 'bb', 'Gt.Britain', 9, 16, 34000)

select * from SHIPS
select * from CLASSES

-- Изтрийте от Ships всички кораби, които са потънали в битка.
delete from SHIPS
where NAME in (select SHIP from OUTCOMES
			   where RESULT = 'sunk')

select * from SHIPS

-- Променете данните в релацията Classes така, че калибърът (bore) да се измерва в сантиметри (в момента е в инчове, 1 инч ~ 2.5 см) и водоизместимостта да се измерва в метрични тонове (1 м.т. = 1.1 т.)
update CLASSES
set BORE = BORE * 2.5, DISPLACEMENT = DISPLACEMENT / 1.1

select * from CLASSES

-- Изтрийте всички класове, от които има по-малко от три кораба.
delete from CLASSES
where CLASS in (select CLASS 
				from SHIPS
				group by CLASS
				having COUNT(*) <= 3)

select * from CLASSES

-- Променете калибъра на оръдията и водоизместимостта на класа Iowa, така че да са същите като тези на класа Bismarck.
update CLASSES
set BORE = (select BORE from CLASSES where CLASS = 'Bismarck'),
	DISPLACEMENT = (select DISPLACEMENT from CLASSES where CLASS ='Bismarck')
where CLASS = 'Iowa'

select * from CLASSES
```