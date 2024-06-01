use movies

select * from MOVIE

-- Зад. 1.
-- а) Да се направи така, че да не може два филма да имат еднаква дължина.
alter table MOVIE
add constraint UC_LENGTH unique(LENGTH)

-- б) Да се направи така, че да не може едно студио да има два филма с еднаква дължина
alter table MOVIE
add constraint UC_STUDIO_MVLEN unique(STUDIONAME, LENGTH)

-- Зад. 2. Изтрийте ограниченията от първа задача от Movie.
alter table MOVIE
drop constraint UC_LENGTH

alter table MOVIE
drop constraint UC_STUDIO_MVLEN

-- Зад. 3.  
-- а) За всеки студент се съхранява следната информация: 
-- фак. номер - от 0 до 99999, първичен ключ; 
-- име - до 100 символа; 
-- ЕГН - точно 10 символа, уникално; 
-- e-mail - до 100 символа, уникален; 
-- рождена дата; 
-- дата на приемане в университета - трябва да бъде поне 18 години след рождената; 
-- за всички атрибути задължително трябва да има зададена стойност (не може NULL)
use my_db

create table Student (
	FacultyNumber int NOT NULL,
	FullName varchar(100) NOT NULL,
	EGN char(10) NOT NULL,
	Email varchar(100) NOT NULL,
	BirthDate date NOT NULL,
	EnrollmentDate date NOT NULL,

	constraint PK_F_Num PRIMARY KEY(FacultyNumber),
	constraint CK_F_Num CHECK(FacultyNumber >= 0 and FacultyNumber <= 99999),
	constraint UQ_Egn UNIQUE(EGN),
	constraint UQ_Email UNIQUE(Email),
	constraint CK_Enrollment_Date CHECK(EnrollmentDate >= DATEADD(year, 18, BirthDate))
)

select * from Student

-- б) добавете валидация за e-mail адреса - да бъде във формат <нещо>@<нещо>.<нещо>
alter table Student
add constraint CK_Email_Format CHECK(Email like '%@%.%')

-- в) създайте таблица за университетски курсове - уникален номер и име
create table Courses (
	Name varchar(100) NOT NULL,
	Number int NOT NULL,

	constraint PK_CourseNum PRIMARY KEY(Number),
	constraint UQ_CourseName UNIQUE(Name)
)

-- всеки студент може да се запише в много курсове и във всеки курс може да има записани много студенти. 
-- При изтриване на даден курс автоматично да се отписват всички студенти от него.
create table StudentCourse (
	StudentNumber int NOT NULL,
	CourseNumber int NOT NULL,

	constraint PK_StudentCourse PRIMARY KEY(StudentNumber, CourseNumber),
	constraint FK_Student FOREIGN KEY(StudentNumber) REFERENCES Student(FacultyNumber) ON DELETE CASCADE,
	constraint FK_Course FOREIGN KEY(CourseNumber) REFERENCES Courses(Number) ON DELETE CASCADE
)

-- ON DELETE CASCADE означава, че ако даден курс бъде изтрит, всички записи в StudentCourses, които се отнасят за този курс, също ще бъдат автоматично изтрити.