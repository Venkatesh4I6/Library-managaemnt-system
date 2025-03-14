DROP DATABASE library_management_system;
CREATE DATABASE library_management_system;
USE library_management_system;
CREATE TABLE Users(
	UserID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(50) UNIQUE NOT NULL,
    Phone VARCHAR(15),
    MembershipDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
CREATE TABLE Books(
	BookID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(255) NOT NULL,
    Author VARCHAR(100) UNIQUE NOT NULL,
    CopiesAvailable INT DEFAULT 1
    );
CREATE TABLE BorrowedBooks(
	BorrowID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    BookID INT,
    BorrowDate DATE NOT NULL DEFAULT (CURDATE()),
    DueDate DATE NOT NULL,
    ReturnDate DATE DEFAULT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
    );
CREATE TABLE Transactions(
	TransactionsID INT PRIMARY KEY AUTO_INCREMENT,
    UserID INT,
    BookID INT,
    Action ENUM('Borrowed','returned') NOT NULL,
    ActionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
    );
INSERT INTO Users (Name, Email, Phone) 
VALUES 
('Alice Johnson', 'alice@example.com', '9876543210'),
('Bob Smith', 'bob.smith@example.com', '9123456789'),
('Charlie Brown', 'charlie.b@example.com', '9988776655'),
('David Miller', 'david.m@example.com', '9678234567'),
('Emma Watson', 'emma.w@example.com', '9345612398'),
('Franklin Harris', 'frank.h@example.com', '9876543120'),
('Grace Thomas', 'grace.t@example.com', '9765432109'),
('Henry Wilson', 'henry.w@example.com', '9654321098'),
('Isabella Martinez', 'isabella.m@example.com', '9543210987'),
('Jack Anderson', 'jack.a@example.com', '9432109876');
-- Add Books
INSERT INTO Books (Title, Author,CopiesAvailable) 
VALUES 
('The Alchemist', 'Paulo Coelho',3),
('To Kill a Mockingbird', 'Harper Lee',5),
('1984', 'George Orwell', 4),
('Pride and Prejudice', 'Jane Austen', 2),
('The Great Gatsby', 'F. Scott Fitzgerald',3),
('Moby-Dick', 'Herman Melville',2),
('The Catcher in the Rye', 'J.D. Salinger', 4),
('The Hobbit', 'J.R.R. Tolkien', 6),
('War and Peace', 'Leo Tolstoy',1),
('Crime and Punishment', 'Fyodor Dostoevsky',2);
INSERT INTO BorrowedBooks (UserID, BookID, BorrowDate, DueDate)  
VALUES (1, 1, CURDATE(), CURDATE() + INTERVAL 14 DAY);
UPDATE BorrowedBooks SET ReturnDate = CURRENT_DATE WHERE BorrowID = 1;
INSERT INTO Transactions (UserID, BookID, Action) 
VALUES (1, 1, 'Returned');
UPDATE Books SET CopiesAvailable = CopiesAvailable + 1 WHERE BookID = 1;
SELECT * FROM Books WHERE Title LIKE '%Alchemist%';
SELECT * FROM Books WHERE CopiesAvailable > 0;
SELECT * FROM Books WHERE Title LIKE '%Alchemist%';
SELECT * FROM Books WHERE CopiesAvailable > 0;
SELECT bb.BorrowID,u.Name AS Borrower,b.Title AS BookTitle,bb.BorrowDate,bb.Duedate
FROM BorrowedBooks bb
JOIN Users u ON bb.userid=u.userid
JOIN Books b ON bb.bookID=b.BookID
where bb.ReturnDate is NULL;
SELECT u.Name, b.Title, bb.DueDate 
FROM BorrowedBooks bb
JOIN Users u ON bb.UserID = u.UserID
JOIN Books b ON bb.BookID = b.BookID
WHERE bb.ReturnDate IS NULL AND bb.DueDate < CURRENT_DATE;
DROP PROCEDURE IF EXISTS BorrowBook;

DELIMITER //
CREATE PROCEDURE BorrowBook(IN p_UserID INT, IN p_BookID INT)
BEGIN
    DECLARE available INT;
    
    -- Check book availability
    SELECT CopiesAvailable INTO available FROM Books WHERE BookID = p_BookID;
    
    IF available > 0 THEN
        -- Insert into BorrowedBooks
        INSERT INTO BorrowedBooks (UserID, BookID) VALUES (p_UserID, p_BookID);
        
        -- Insert into Transactions
        INSERT INTO Transactions (UserID, BookID, Action) VALUES (p_UserID, p_BookID, 'Borrowed');
        
        -- Update book count
        UPDATE Books SET CopiesAvailable = CopiesAvailable - 1 WHERE BookID = p_BookID;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book not available';
    END IF;
END //
DELIMITER ;
SELECT BookID, Title, CopiesAvailable FROM Books;
SELECT * FROM BorrowedBooks;
SELECT * FROM Transactions;

DROP TRIGGER IF EXISTS After_Return;

DELIMITER //

CREATE TRIGGER After_Return
AFTER UPDATE ON BorrowedBooks
FOR EACH ROW
BEGIN
    IF NEW.ReturnDate IS NOT NULL THEN
        UPDATE Books 
        SET CopiesAvailable = CopiesAvailable + 1 
        WHERE BookID = NEW.BookID;
        
        INSERT INTO Transactions (UserID, BookID, Action) 
        VALUES (NEW.UserID, NEW.BookID, 'Returned');
    END IF;
END //

DELIMITER ;






    
