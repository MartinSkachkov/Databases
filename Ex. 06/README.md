```
CREATE TABLE table_name (  
	column1 datatype,
	column2 datatype,
	...
)
```
**DROP TABLE <table_name>** - изтриване на цялата таблица
**DELETE FROM <table_name>** - изтриване само на инфромацията в таблицата
**CREATE DATABASE <database_name>** - създаване на база данни
**DROP DATABASE <database_name>** - изтриване на база данни (необходимо е да няма отворени връзки към базата от клиенти (това включва и връзката, която се опитва да изтрие базата; т.е. нужно е с **USE** да се премине към използване на друга база, ако се намираме в контекста на тази, която искаме да изтриеме))
**ALTER TABLE <table_name> ADD <column_name> <type_name>**
**ALTER TABLE <table_name> DROP COLUMN <column_name>**

### DEFAULT
```sql
CREATE TABLE Person (
     ID int,
     Name varchar(64),
     WorkPhone varchar(32) 

     CONSTRAINT DF_WorkPhone DEFAULT '+359-2-8161500'
)
```
При наличие на DEFAULT ограничение, колоната не може да бъде премахната. Трябва първо да се изтрие ограничението, което става с:
```sql
ALTER TABLE Person DROP CONSTRAINT DF_WorkPhone
ALTER TABLE Person DROP COLUMN WorkPhone
```
При добавяне на нова колона с DEFAULT ограничение с ALTER TABLE за съществуваща таблица, в която вече има редове,
ако искаме за съществуващите редове да се установи стойността по подразбиране, може да използваме WITH VALUES:
```sql
ALTER TABLE Person 
ADD WorkFax varchar(32) 
CONSTRAINT DF_WorkFax DEFAULT '+359-2-292831' WITH VALUES
```

DEFAULT ограничение може да бъде добавено за съществуваща колона с ALTER TABLE. Например, може да създадеме DEFAULT ограничение за колоната Name, което да задава стойност по подразбиране празен низ по следния начин:
```sql
ALTER TABLE Person
ADD CONSTRAINT DF_Name DEFAULT '' FOR Name
```
По подразбиране, колоните допускат NULL стойности. Ако искаме да ограничиме това, в описанието на колона може да добавиме NOT NULL. Например:
```sql
CREATE TABLE Person (
     ID int NOT NULL,
     Name varchar(64) NOT NULL,
     WorkPhone varchar(32) NOT NULL
     CONSTRAINT DF_WorkPhone DEFAULT '+359-2-8161500'
)
```

--------------------------------------------------------------------------------------

### PRIMARY KEY
За всяка таблица може да има едно PRIMARY KEY ограничение. Няма два реда с еднакви стойности за първичен ключ.
Не се допускат NULL стойности в колоните формиращи първичния ключ. 
```sql
-- единичен ключ
CREATE TABLE Ships (
     Name varchar(32),
     Class varchar(32),
     Launched int,

     CONSTRAINT PK_Name PRIMARY KEY (Name)
)

-- съставен ключ
CREATE TABLE Movie (
     Title varchar(32),
     Year int,
     Length int,

     CONSTRAINT PK_Movie PRIMARY KEY (Title, Year)
)
```
--------------------------------------------------------------------------------------

### UNIQUE

За една таблица може да имаме 0, 1 или повече UNIQUE ограничения. NULL стойност се допуска, но само един ред може да има такава.
Нека разгледаме следния пример за таблица с PRIMARY KEY ограничение и 2 UNIQUE ограничения:
```sql
CREATE TABLE Student (
    FacultyNumber int,
    FullName varchar(128),
    EGN char(10),
    EmailAddress varchar(128),
    EnrollmentDate date,

    CONSTRAINT PK_Student PRIMARY KEY (FacultyNumber),
    CONSTRAINT UC_Student_Email UNIQUE (EmailAddress),
    CONSTRAINT UC_Student_EGN UNIQUE (EGN),
    CONSTRAINT CHK_Student_EnrollmentDate CHECK (EnrollmentDate >= '2000-01-01')
)
```
--------------------------------------

### CHECK

CHECK ограниченията са булеви изрази, в които могат да участва колоните от таблицата, за която е създадено ограничението.
Тези изрази се проверяват за истинност при INSERT и UPDATE команди. Ако има нарушено условие, командата за добавяне на нов ред или обновяване на съществуващ бива отказана.
```sql
CREATE TABLE MOVIE (
     TITLE VARCHAR(255) NOT NULL,
     YEAR INTEGER NOT NULL CHECK (YEAR > 1888),
     LENGTH INTEGER CHECK (LENGTH > 0),
     INCOLOR CHAR(1),

     CONSTRAINT CK_INCOLOR CHECK (INCOLOR = 'n' OR (YEAR >= 1908 AND INCOLOR = 'y'))
)

ALTER TABLE Student
ADD CONSTRAINT CHK_Student_FacultyNumber CHECK (FacultyNumber > 0),
    CONSTRAINT CHK_Student_Email CHECK (EmailAddress LIKE '%@%.%')
   ```
   ---
  
### FOREIGN KEY
FOREIGN KEY ограниченията се създават за колона/колони от таблица, които се използват за рефериране към първичен ключ в друга таблица.
В колона/колони, за които има създадено FOREIGN KEY ограничение е възможно да има NULL стойности (освен ако не са NOT NULL). FOREIGN KEY ограничението не налага уникалност по отношение на колоната/колоните, за които е дефинирано.
```sql
CREATE TABLE StarsIn (  
     MovieTitle varchar(32),  
     MovieYear int,  
     StarName varchar(32) REFERENCES MovieStar(Name),  
     
     CONSTRAINT FK_StarsIn_Movie FOREIGN KEY (MovieTitle, MovieYear) REFERENCES Movie(Title, Year)  
**)
``` 
---
  
### IDENTITY
Стойностите в колона, за която е зададено IDENTITY(1,1), ще бъдат автоматично попълвани от сървъра с естествени числа (започва с 1 и увеличаване с 1 на всяка следваща стъпка).
```sql
CREATE TABLE Person (  
     ID int IDENTITY(1,1) PRIMARY KEY,  
     Name varchar(64),  
     Email varchar(64)  
)
```