
SELECT * FROM members
SELECT * FROM libraryMS
SELECT * FROM staff
SELECT * FROM books
SELECT * FROM loan
SELECT * FROM review
SELECT * FROM payment

--====================================================
--Section 1: Complex Queries with Joins 
--====================================================

--1. Library Book Inventory Report
select 
   L.l_name AS  LibraryName,
   COUNT (b.b_id) AS total_books,
   SUM(CASE WHEN b.availability_status = 'true' THEN 1 ELSE 0 END) AS available_books,
   SUM(CASE WHEN b.availability_status = 'false' THEN 1 ELSE 0 END) AS NotAvailable_books
From libraryMS L inner join books b
ON L.l_id = b.l_id
Group by L.l_name


--2. Active Borrowers Analysis
select  
   m.Full_name AS  MembersNames , 
   m.email,
   b.b_title AS book_title,
   l.loan_date , 
   l.due_date,
   l.statuss
From loan l Inner join members m
on m.m_id=l.m_id
Inner join books b on l.b_id = b.b_id
WHERE l.statuss IN ('Issued', 'Overdue')


-- 3. Overdue Loans with Member Details 
select  
   m.Full_name AS  MembersNames , 
   m.phone_number,
   b.b_title AS book_title,
   lib.l_name AS  LibraryName,
   DATEDIFF(DAY, l.due_date, GETDATE()) AS days_overdue,
   ISNULL(SUM(p.amount), 0) AS total_fines_paid
From loan L Inner join members m
on L.m_id=m.m_id
Inner join books b 
on b.b_id=L.b_id
Inner join libraryMS lib
on lib.l_id=b.l_id
left join payment p
on l.loan_id = p.loan_id
Where p.method = 'cash'
GROUP BY m.full_name, m.phone_number, b.b_title, lib.l_name, l.due_date


--4. Staff Performance Overview
select
   l.l_name AS library_name,
   s.s_name AS staff_name,
   s.position,
   COUNT(b.b_id) AS books_managed
From libraryMS l
Inner join staff s 
on l.l_id = s.l_id
left join books b 
on l.l_id = b.l_id
GROUP BY l.l_name, s.s_name, s.position


--5. Book Popularity Report
select 
    b.b_title,
    b.ISBN,
    b.genre,
    COUNT(l.loan_id) AS times_loaned,
    AVG(r.rating) AS avg_rating
from books b
Inner join loan l 
on b.b_id = l.b_id
left join review r 
on b.b_id = r.b_id
GROUP BY b.b_title, b.ISBN, b.genre
HAVING COUNT(l.loan_id) >= 2

--6. Member Reading History
select 
    m.full_name,
    b.b_title,
    l.loan_date,
    l.return_date,
    r.rating,
    r.comments
from members m
left join loan l 
on m.m_id = l.m_id
left join books b 
on l.b_id = b.b_id
left join review r 
on m.m_id = r.m_id AND b.b_id = r.b_id
ORDER BY m.full_name, l.loan_date

-- 7. Revenue Analysis by Genre
select 
    b.genre,
    COUNT(l.loan_id) AS total_loans,
    ISNULL(SUM(p.amount), 0) AS total_fines_collected,
    ISNULL(AVG(p.amount), 0) AS avg_fine_per_loan
From books b Inner join loan l 
on b.b_id = l.b_id
LEFT JOIN payment p 
on l.loan_id = p.loan_id
GROUP BY b.genre


--====================================================
--Section 2: Aggregate Functions and Grouping
--====================================================

--8. Monthly Loan Statistics
select
    DATENAME(MONTH, loan_date) AS MonthName,
    COUNT(*) AS Total_Loans,
    SUM(CASE WHEN statuss = 'Returned' THEN 1 ELSE 0 END) AS Total_Returned,
    SUM(CASE WHEN statuss IN ('Issued', 'Overdue') THEN 1 ELSE 0 END) AS Total_Issued_Overdue
from loan
where YEAR(loan_date) = YEAR(GETDATE())
GROUP BY DATENAME(MONTH, loan_date), MONTH(loan_date)
ORDER BY MONTH(loan_date)

--9. Member Engagement Metrics
select
    m.m_id,
    m.full_name,
    COUNT(l.loan_id) AS Total_Books_Borrowed,
    SUM(CASE WHEN l.statuss IN ('Issued', 'Overdue') THEN 1 ELSE 0 END) AS Books_Currently_On_Loan,
    SUM(p.amount)AS Total_Fines_Paid,
    AVG(r.rating) AS Avg_Rating
from members m
Inner join loan l 
on m.m_id = l.m_id
LEFT JOIN payment p 
on l.loan_id = p.loan_id
LEFT JOIN review r 
on m.m_id = r.m_id
GROUP BY m.m_id, m.full_name
HAVING COUNT(l.loan_id) > 0
ORDER BY m.full_name

--10. Library Performance Comparison
select
    l.l_name AS Library_Name,
    COUNT(b.b_id) AS Total_Books,
    COUNT(lms.m_id) AS Active_Members,
    SUM(p.amount)AS Total_Revenue,
    CAST(COUNT(b.b_id) AS DECIMAL(10,2)) / NULLIF(COUNT(ln.m_id), 0) AS Avg_Books_Per_Member
From libraryMS l
LEFT JOIN books b 
on l.l_id = b.l_id
LEFT JOIN loan ln 
on b.b_id = ln.b_id
LEFT JOIN members lms
on ln.m_id = lms.m_id
LEFT JOIN payment p 
on ln.loan_id = p.loan_id
GROUP BY l.l_name
ORDER BY Total_Books DESC

--11. High-Value Books Analysis
select
    b.b_title,
    b.genre,
    b.price,
    AVG(b2.price) AS Genre_Avg_Price,
    b.price - AVG(b2.price) AS Price_Above_Avg
From books b
Inner join books b2  --b2 is just all books in the same genre.
    ON b.genre = b2.genre
GROUP BY b.b_id, b.b_title, b.genre, b.price
HAVING b.price > AVG(b2.price)
ORDER BY b.genre, Price_Above_Avg DESC


--12. Payment Pattern Analysis
select
    method AS Payment_Method,
    COUNT(*) AS Num_Transactions,
    SUM(amount) AS Total_Collected,
    AVG(amount) AS Avg_Payment,
    ROUND(SUM(amount) * 100.0 / (SELECT SUM(amount) FROM payment), 2) AS Percentage_of_Total_Revenue
From payment
GROUP BY method
ORDER BY Total_Collected DESC


--====================================================
--Section 3: Views Creation
--====================================================

--13. vw_CurrentLoans
create view vw_CurrentLoans 
AS
select 
    l.loan_id,
    m.full_name AS Member_Name,
    b.b_title AS Book_Title,
    l.loan_date,
    l.due_date,
    l.statuss,
    DATEDIFF(DAY, GETDATE(), l.due_date) AS Days_Until_Due
FROM loan l
Inner join members m 
on l.m_id = m.m_id
Inner join books b 
on l.b_id = b.b_id
WHERE l.statuss IN ('Issued', 'Overdue')


--14. vw_LibraryStatistics
create view vw_LibraryStatistics 
AS 
select  
    l.l_name AS Library_Name,
    COUNT(b.b_id) AS Total_Books,
    SUM(CASE WHEN b.availability_status = 'true' THEN 1 ELSE 0 END) AS Available_Books,
    COUNT(ln.m_id) AS Total_Members,
    SUM(CASE WHEN ln.statuss IN ('Issued', 'Overdue') THEN 1 ELSE 0 END) AS Active_Loans,
    COUNT(s.staff_id) AS Total_Staff,
    SUM(p.amount) AS Total_Revenue
From libraryMS l
LEFT JOIN books b 
on l.l_id = b.l_id
LEFT JOIN loan ln 
on b.b_id = ln.b_id
LEFT JOIN staff s 
on l.l_id = s.l_id
LEFT JOIN payment p 
on ln.loan_id = p.loan_id
GROUP BY l.l_name


--15. vw_BookDetailsWithReviews
create view vw_BookDetailsWithReviews
AS 
select  
    b.b_title,
    b.genre,
    b.availability_status,
    AVG(r.rating) AS Avg_Rating,
    COUNT(r.r_id) AS Total_Reviews,
    MAX(r.review_date) AS Latest_Review_Date
FROM books b
LEFT JOIN review r 
on b.b_id = r.b_id
GROUP BY b.b_title, b.genre, b.availability_status


--====================================================
--Section 4: Stored Procedures
--====================================================

--16. sp_IssueBook – Issue a book
CREATE PROCEDURE sp_IssueBook
    @MemberID INT,
    @BookID INT,
    @DueDate DATE
AS
BEGIN
    -- Check if book is available
    IF (SELECT availability_status FROM books WHERE b_id = @BookID) <> 'true'
    BEGIN
        PRINT 'Book not available'
        RETURN
    END

    -- Check if member has overdue books
    IF EXISTS (SELECT 1 FROM loan WHERE m_id = @MemberID AND statuss = 'Overdue')
    BEGIN
        PRINT 'Member has overdue loans'
        RETURN
    END

    -- Issue book
    INSERT INTO loan (b_id, m_id, loan_date, due_date, statuss)
    VALUES (@BookID, @MemberID, GETDATE(), @DueDate, 'Issued')

    -- Update book availability
    UPDATE books SET availability_status = 'false' WHERE b_id = @BookID

    PRINT 'Book issued successfully'
END


--17. sp_ReturnBook – Return a book
CREATE PROCEDURE sp_ReturnBook
    @LoanID INT,
    @ReturnDate DATE
AS
BEGIN
    DECLARE @DueDate DATE, @BookID INT, @Fine DECIMAL(8,2)

    -- Get loan info
    SELECT @DueDate = due_date, @BookID = b_id FROM loan WHERE loan_id = @LoanID

    -- Update loan
    UPDATE loan
    SET statuss = 'Returned', return_date = @ReturnDate
    WHERE loan_id = @LoanID

    -- Update book availability
    UPDATE books SET availability_status = 'true' WHERE b_id = @BookID;

    -- Calculate fine ($2 per day overdue)
    SET @Fine = CASE WHEN DATEDIFF(DAY, @DueDate, @ReturnDate) > 0 
                     THEN DATEDIFF(DAY, @DueDate, @ReturnDate) * 2 
                     ELSE 0 
                END

    -- Insert payment if fine exists
    IF @Fine > 0
        INSERT INTO payment (loan_id, payment_date, amount, method)
        VALUES (@LoanID, GETDATE(), @Fine, 'Pending')

    PRINT 'Total fine: ' + CAST(@Fine AS VARCHAR(10))
END


--18. sp_GetMemberReport – Member report
CREATE PROCEDURE sp_GetMemberReport
    @MemberID INT
AS
BEGIN
    -- Member info
    SELECT full_name, email, phone_number, MSD
    FROM members
    WHERE m_id = @MemberID

    -- Current loans
    SELECT l.loan_id, b.b_title, l.loan_date, l.due_date, l.statuss
    FROM loan l
    JOIN books b ON l.b_id = b.b_id
    WHERE l.m_id = @MemberID AND l.statuss IN ('Issued', 'Overdue');

    -- Loan history
    SELECT l.loan_id, b.b_title, l.loan_date, l.due_date, l.return_date, l.statuss
    FROM loan l
    JOIN books b ON l.b_id = b.b_id
    WHERE l.m_id = @MemberID

    -- Fines
    SELECT SUM(amount) AS Total_Fines
    FROM payment p
    JOIN loan l ON p.loan_id = l.loan_id
    WHERE l.m_id = @MemberID

    -- Reviews
    SELECT b.b_title, r.rating, r.comments
    FROM review r
    JOIN books b ON r.b_id = b.b_id
    WHERE r.m_id = @MemberID
END


--19. sp_MonthlyLibraryReport – Monthly report
CREATE PROCEDURE sp_MonthlyLibraryReport
    @LibraryID INT,
    @Month INT,
    @Year INT
AS
BEGIN
    -- Total loans issued
    SELECT COUNT(*) AS Total_Loans_Issued
    FROM loan l
    JOIN books b ON l.b_id = b.b_id
    WHERE b.l_id = @LibraryID
      AND MONTH(l.loan_date) = @Month
      AND YEAR(l.loan_date) = @Year

    -- Total books returned
    SELECT COUNT(*) AS Total_Books_Returned
    FROM loan l
    JOIN books b ON l.b_id = b.b_id
    WHERE b.l_id = @LibraryID
      AND MONTH(l.return_date) = @Month
      AND YEAR(l.return_date) = @Year
      AND l.statuss = 'Returned'

    -- Total revenue
    SELECT SUM(p.amount) AS Total_Revenue
    FROM payment p
    JOIN loan l ON p.loan_id = l.loan_id
    JOIN books b ON l.b_id = b.b_id
    WHERE b.l_id = @LibraryID
      AND MONTH(p.payment_date) = @Month
      AND YEAR(p.payment_date) = @Year

    -- Most borrowed genre
    SELECT TOP 1 b.genre, COUNT(*) AS Num_Borrows
    FROM loan l
    JOIN books b ON l.b_id = b.b_id
    WHERE b.l_id = @LibraryID
      AND MONTH(l.loan_date) = @Month
      AND YEAR(l.loan_date) = @Year
    GROUP BY b.genre
    ORDER BY Num_Borrows DESC

    -- Top 3 members
    SELECT TOP 3 l.m_id, m.full_name, COUNT(*) AS Num_Loans
    FROM loan l
    JOIN members m ON l.m_id = m.m_id
    JOIN books b ON l.b_id = b.b_id
    WHERE b.l_id = @LibraryID
      AND MONTH(l.loan_date) = @Month
      AND YEAR(l.loan_date) = @Year
    GROUP BY l.m_id, m.full_name
    ORDER BY Num_Loans DESC
END
