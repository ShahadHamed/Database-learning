create database Library_MS
Use Library_MS

--DLL

create table members (
    m_id int primary key identity(200,1),
    Full_name nvarchar(100),
    MSD date not null,
    email varchar(100)unique not null,
    phone_number varchar(20)
)

create table libraryMS (
    l_id int primary key identity(1,1),
    l_name nvarchar(50)unique not null,
    contact_number varchar(20)not null,
    l_location varchar(200) not null,
    established_year int
)

create table staff (
    staff_id int primary key identity(500,1),
    l_id int,
    s_name nvarchar(100) not null,
    position varchar(50) not null,
    phone_number varchar(20),
    foreign key (l_id) references libraryMS(l_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)


create table books (
    b_id int primary key identity(110,1),
    l_id int,
    b_title nvarchar(150) not null,
    genre nvarchar(50)check (genre in ('Fiction', 'Non-fiction', 'Reference', 'Children'))not null,
    ISBN varchar(20) unique not null,
    availability_status varchar(30) default 'TRUE',
    price decimal(8,2)check (price > 0),
	shelf_location varchar(200) not null,
    foreign key (l_id) references libraryMS(l_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

create table loan (
    loan_id int primary key identity(1,1),
    b_id int,
    m_id int,
    loan_date date not null,
    due_date date not null,
    return_date date, 
	check (return_date is null or return_date >= loan_date),
    statuss varchar(30) check ( statuss in ('Issued', 'Returned', 'Overdue')) default 'Issued' not null,
    foreign key (b_id) references books(b_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
    foreign key (m_id) references members(m_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

create table review (
    r_id int primary key identity(1,1),
    b_id int,
    m_id int,
    rating int check (rating between 1 and 5) not null,
    comments nvarchar(255)default 'No comments',
    review_date date not null,
    foreign key (b_id) references books(b_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
    foreign key (m_id) references members(m_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

create table payment (
    p_id int primary key identity(1,1),
    loan_id int ,
    payment_date date not null,
    amount decimal(8,2) check (amount > 0) not null,
    method varchar(50),
    foreign key (loan_id) references loan(loan_id)
	ON DELETE CASCADE
	ON UPDATE CASCADE
)

--DML

Insert into libraryMS (l_name, contact_number, l_location, established_year)
               VALUES ('Muscat central library', '24666454', 'Muscat, oman', 2020),
                      ('Sohar city library', '26669191', 'Sohar, oman', 2014),
					  ('Salalah Public Library', '23234567', 'Salalah, Oman', 2018)
delete from payment

Insert into members (Full_name, MSD, email, phone_number)
             VALUES ('Mohammed Al-Hosni', '2016-05-10', 'mohammed.alhosni@gmail.com', '99661101'),
                    ('Fatima Al-Arthy', '2020-07-22', 'fatima112@icloud.com', '78778741'),
                    ('Ali Al-Saadi', '2025-03-15', 'ali.saif@gmail.com', '92558747'),
                    ('Layla Al-Zaabi', '2022-09-05', 'layla.alzaabi@gmail.com', '90014158'),
                    ('Ahmed Al-Mansoori', '2017-11-30', 'ahmed.almansoori@icloud.com', '77474158'),
					('Salim Al-Hinai', '2021-01-18', 'salim@gmail.com', '91234567'),
                    ('Aisha Al-Rashdi', '2023-02-20', 'aisha@gmail.com', '99887766'),
                    ('Khalid Al-Balushi', '2018-06-12', 'khalid@gmail.com', '91122334'),
                    ('Noor Al-Harthy', '2024-04-09', 'noor@gmail.com', '93334455'),
                    ('Yousef Al-Kindi', '2015-12-01', 'yousef@gmail.com', '95556677')

Insert into staff (l_id, s_name, position, phone_number)
           VALUES (5,'Mohammed Al-Hosni','Manager','9978795'),
                  (5,'Fatima Al-Busaidi','Assistant','90011112'),
                  (5,'Salem Al-Rawahi','Librarian','99663696'),
                  (4,'Ali Al-Shukri','Manager','90121214'),
                  (4,'Aisha Al-Harthy','Librarian','98787858'),
                  (4,'Khalid Al-Balushi','Assistant','96325874'),
                  (3,'Nasser Al-Hinai','Manager','74141475'),
                  (3,'Maryam Al-Siyabi','Librarian','98585874'),
                  (3,'Hamad Al-Yahyai','Assistant','95884787'),
                  (3,'Noor Al-Rashdi','Clerk','77787548')


Insert into books (l_id, b_title, genre, ISBN, availability_status, price, shelf_location)
           VALUES (3,'The Great Adventure','Fiction','ISBN101','true',18.00,'A1'),
                  (3,'World History','Non-fiction','ISBN102','true',30.00,'A2'),
                  (3,'Modern Science','Reference','ISBN103','false',45.00,'A3'),
                  (3,'Kids Stories','Children','ISBN104','true',15.00,'A4'),
                  (3,'Mystery House','Fiction','ISBN105','false',22.00,'A5'),
                  (4,'Business Basics','Non-fiction','ISBN106','true',28.00,'B1'),
                  (4,'Math Guide','Reference','ISBN107','false',40.00,'B2'),
                  (4,'Fairy Tales','Children','ISBN108','true',12.00,'B3'),
                  (4,'History of Oman','Non-fiction','ISBN109','true',35.00,'B4'),
                  (4,'Fantasy Land','Fiction','ISBN110','false',25.00,'B5'),
                  (4,'Health & Life','Non-fiction','ISBN111','true',20.00,'C1'),
                  (4,'Physics 101','Reference','ISBN112','false',50.00,'C2'),
                  (4,'Bedtime Stories','Children','ISBN113','true',14.00,'C3'),
                  (4,'The Lost City','Fiction','ISBN114','false',27.00,'C4'),
                  (4,'Programming SQL','Reference','ISBN115','true',60.00,'C5'),
                  (5,'Poetry Nights','Fiction','ISBN116','true',16.00,'A6'),
                  (5,'Ancient Civilizations','Non-fiction','ISBN117','true',38.00,'B6'),
                  (5,'Creative Writing','Fiction','ISBN118','true',21.00,'C6'),
                  (5,'Junior Encyclopedia','Children','ISBN119','true',19.00,'A7'),
                  (5,'Data Science Intro','Reference','ISBN120','false',55.00,'B7')


Insert into loan (b_id, m_id, loan_date, due_date, return_date, statuss)
          VALUES (115,208,'2025-11-01','2025-11-15',NULL,'Issued'),
                 (116,209,'2025-11-02','2025-11-16',NULL,'Overdue'),
                 (117,210,'2025-11-03','2025-11-17','2025-11-15','Returned'),
                 (118,211,'2025-11-04','2025-11-18',NULL,'Issued'),
                 (119,212,'2025-11-05','2025-11-19',NULL,'Overdue'),
                 (120,213,'2025-11-06','2025-11-20','2025-11-18','Returned'),
                 (121,214,'2025-11-07','2025-11-21',NULL,'Issued'),
                 (122,215,'2025-11-08','2025-11-22',NULL,'Overdue'),
                 (123,216,'2025-11-09','2025-11-23','2025-11-22','Returned'),
                 (124,217,'2025-11-10','2025-11-24',NULL,'Issued'),
                 (125,208,'2025-11-11','2025-11-25',NULL,'Issued'),
                 (126,209,'2025-11-12','2025-11-26','2025-11-24','Returned'),
                 (127,210,'2025-11-13','2025-11-27',NULL,'Overdue'),
                 (128,211,'2025-11-14','2025-11-28',NULL,'Issued'),
                 (129,212,'2025-11-15','2025-11-29','2025-11-28','Returned')


Insert into review (b_id, m_id, rating, comments, review_date)
            VALUES (115,208,5,'Excellent book','2025-11-20'),
                   (116,209,4,'Very useful','2025-11-21'),
                   (117,210,3,'Good but long','2025-11-22'),
                   (118,211,5,'Loved it','2025-11-23'),
                   (119,212,2,'Not very clear','2025-11-24'),
                   (120,213,4,'Well written','2025-11-25'),
                   (121,214,5,'Highly recommended','2025-11-26'),
                   (122,215,3,'Average content','2025-11-27'),
                   (123,216,4,'Helpful reference','2025-11-28'),
                   (124,217,5,'Amazing read','2025-11-29')


Insert into payment (loan_id, payment_date, amount, method)
             VALUES (6,  '2025-11-20', 5.00, 'Cash'),
                    (7,  '2025-11-21', 6.50, 'Credit Card'),
                    (8,  '2025-11-22', 4.00, 'Cash'),
                    (9,  '2025-11-23', 7.25, 'Debit Card'),
                    (10, '2025-11-24', 8.00, 'Credit Card'),
                    (11, '2025-11-25', 5.75, 'Cash'),
                    (12, '2025-11-26', 6.00, 'Debit Card'),
                    (13, '2025-11-27', 9.50, 'Credit Card'),
                    (14, '2025-11-28', 4.25, 'Cash'),
                    (15, '2025-11-29', 7.00, 'Debit Card'),
                    (16, '2025-11-30', 6.80, 'Credit Card'),
                    (17, '2025-12-01', 5.40, 'Cash'),
                    (18, '2025-12-02', 8.90, 'Debit Card'),
                    (19, '2025-12-03', 4.60, 'Cash'),
                    (20, '2025-12-04', 7.75, 'Credit Card')


-- See final tables with data
SELECT * FROM members
SELECT * FROM libraryMS
SELECT * FROM staff
SELECT * FROM books
SELECT * FROM loan
SELECT * FROM review
SELECT * FROM payment


--DQL

--Display all book records. 
SELECT * FROM books

--Display each book’s title, genre, and availability.
SELECT b_title, genre, availability_status FROM books

--Display all member names, email, and membership start date.
SELECT full_name, email, msd FROM members

--Display each book’s title and price as BookPrice.
SELECT b_title, price AS bookprice FROM books

--List books priced above 30
SELECT * FROM books
    WHERE price > 30

--List members who joined before 2023. 
SELECT * FROM members
    WHERE MSD < '2023-01-01'

--Display books ordered by price descending
SELECT * FROM books
    ORDER by price DESC

--Display maximum, minimum, and average book price
SELECT MAX(price) AS max_price,
       MIN(price) AS min_price,
       AVG(price) AS avg_price
	FROM books

--Display total number of books
SELECT COUNT(*) AS total_books
    FROM books

--Display members with NULL email
SELECT * FROM members
    WHERE email IS NULL

--Display books whose title contains 'world history'
SELECT * FROM books
    WHERE b_title LIKE '%world history%'


--DML

-- Insert yourself as a member (Member ID = 205).

Insert into members (Full_name, MSD, email, phone_number)
             VALUES ('Shahad Al-Hosni', '2025-08-11', 'shahad.alhosni@gmail.com', '96961121')

--Register yourself to borrow book ID 1011		 
Insert into loan (b_id, m_id, loan_date, due_date, return_date, statuss)
          VALUES (119, 218, '2025-12-15', '2025-12-17', NULL, 'issued')

--Insert another member with NULL email and phone
alter table members
     alter column email varchar (100) null

Insert into members (Full_name, MSD, email, phone_number)
             VALUES ('Sharooq Al-Badi', '2021-12-10',NULL, NULL)

--Update the return date of your loan to today
UPDATE loan
SET return_date = GETDATE(),
    statuss = 'returned'
    WHERE m_id = 218

--Increase book prices by 5% for books priced under 20
UPDATE books
  SET price = price * 1.05
  WHERE price < 20


--JOIN Queries 
SELECT * FROM members
SELECT * FROM libraryMS
SELECT * FROM staff
SELECT * FROM books
SELECT * FROM loan
SELECT * FROM review
SELECT * FROM payment

--1. Display library ID, name, and the name of the manager. 
select L.l_id As library_ID , L.l_name AS library_name,S.s_name, S.position 
from libraryMS L Inner join staff S
on L.l_id=S.l_id
where S.position='Manager'

--2. Display library names and the books available in each one.
select l.l_name, b.b_title
from libraryms l Inner join books b
on l.l_id = b.l_id
where b.availability_status = 'true'

--3. Display all member data along with their loan history. 
select m.* , l.loan_id, l.loan_date, l.due_date, l.statuss
from members m inner join loan l
on m.m_id = l.m_id

--4. Display all books located in 'Zamalek' or 'Downtown'. 
select b.b_title, b.shelf_location
from books b
where b.shelf_location in ('shelf d4')

--5. Display all books whose titles start with 'T'. 
select * from books
where b_title like 't%'

--6. List members who borrowed books priced between 100 and 300 LE. 
select m.full_name, b.price
from members m inner join loan l
on m.m_id = l.m_id
inner join books b
on l.b_id = b.b_id
where b.price between 20 and 30

--7. Retrieve members who borrowed and returned books titled 'The Alchemist'. 
select m.full_name
from members m inner join loan l
on m.m_id = l.m_id
inner join books b
on l.b_id = b.b_id
where b.b_title = 'world history' and l.statuss = 'returned'

--8. Find all members assisted by librarian "Sarah Fathy". 
select m.full_name
from members m inner join loan l
on m.m_id = l.m_id
inner join books b
on l.b_id = b.b_id
inner join staff s
on b.l_id = s.l_id
where s.s_name = 'ali al-shukri'
and s.position = 'librarian'

--9. Display each member’s name and the books they borrowed, ordered by book title. 
select m.full_name, b.b_title
from members m inner join loan l
on m.m_id = l.m_id
inner join books b
on l.b_id = b.b_id
order by b.b_title

--10. For each book located in 'Cairo Branch', show title, library name, manager, and shelf info. 
select b.b_title, l.l_name, s.s_name as manager_name, b.shelf_location
from books b inner join libraryms l
on b.l_id = l.l_id
inner join staff s
on l.l_id = s.l_id
where l.l_location = 'muscat, oman'
and s.position = 'manager'

--11. Display all staff members who manage libraries. 
select s.staff_id, s.s_name, l.l_name
from staff s inner join libraryms l
on s.l_id = l.l_id
where s.position = 'manager'

--12. Display all members and their reviews, even if some didn’t submit any review yet.
select m.m_id, m.full_name, r.rating, r.comments
from members m left join review r
on m.m_id = r.m_id



