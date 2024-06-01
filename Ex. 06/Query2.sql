-- 1. Създайте нова база от данни с име test
create database test
GO

use test
-- 2. Дефинирайте следните релации:
-- а) Product(maker, model, type), където моделът е низ от точно 4 символа, maker - един символ, 
--    а type - низ до 7 символа
create table Product (
	maker char(1),
	model char(4),
	type varchar(7)
)
select * from Product

-- б) Printer(code, model, color, price), където code е цяло число, color е 'y' или 'n' и по 
--    подразбиране е 'n', price - цена с точност до два знака след десетичната запетая
create table Printer (
	code int,
    model char(4),
    color char(1),
    price decimal(9,2)

	constraint DF_Color DEFAULT 'n'
)
select * from Printer

-- в) Classes(class, type), където class е до 50 символа, а type може да бъде 'bb' или 'bc'
create table Classes (
	class varchar(50),
	type char(2),

	constraint CK_Type CHECK(type = 'bb' or type = 'bc')
)
select * from Classes

-- 2. Добавете кортежи с примерни данни към новосъздадените релации. Добавете информация за принтер, 
--    за когото знаем само кода и модела.
insert into Product
values ('a', 'abcd', 'printer')

insert into Printer (code, model)
values (1, 'abcd')

insert into Classes
values ('Bismark', 'bb')

-- 3. Добавете към Classes атрибут bore - число с плаваща запетая.
select * from Classes

alter table Classes
add bore float

-- 4. Напишете заявка, която премахва атрибута price от Printer.
ALTER TABLE Printer DROP COLUMN price
select * from Printer

-- 5. Изтрийте всички таблици, които сте създали в това упражнени
drop table Classes
drop table Printer
drop table Product

-- 6. Изтрийте базата test
use ships -- не трябва да има конекции към test когато я трием
drop database test