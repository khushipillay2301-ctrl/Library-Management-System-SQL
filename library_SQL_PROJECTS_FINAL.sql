DROP DATABASE library_data;   ## drop databse deletes the existing database
CREATE DATABASE library_data;  ##created database of name library_data 
USE library_data;    ## use selects databse to work with 

CREATE TABLE publisher (  ##stores publisher details
    publisher_name VARCHAR(100) PRIMARY KEY,  ## Here we have written publisher_name as the primary key so eacgh publisher is unique
    address VARCHAR(200),
    phone VARCHAR(20)
);

CREATE TABLE books (  ## This stores the books details
    book_id INT PRIMARY KEY,
    title VARCHAR(150),
    publisher_name VARCHAR(100),
    FOREIGN KEY (publisher_name)
        REFERENCES publisher(publisher_name)  ## Here Refernces is written becaus ewe used to link foreign key to a primary key of other table 
        ON DELETE CASCADE   ## Here if the Publisher is deleted the books are also deleted automatically 
);

CREATE TABLE authors (  ## This stores authors 
    book_id INT,
    author_name VARCHAR(100),
    PRIMARY KEY (book_id, author_name),  ## Here the role of primary key is that no duplicate author book entries 
    FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE CASCADE
);

CREATE TABLE library_branch (  ## This stors library branch information 
    branch_id INT PRIMARY KEY,   ## Here each branch has a unique id 
    branch_name VARCHAR(100),
    address VARCHAR(200)
);

CREATE TABLE book_copies ( ## This stores how many copies of books are available in each branch
    book_id INT,
    branch_id INT,
    no_of_copies INT,
    PRIMARY KEY (book_id, branch_id),  ## Here the role of primary key is that one record per book per branch
    FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE CASCADE,
    FOREIGN KEY (branch_id)
        REFERENCES library_branch(branch_id)
        ON DELETE CASCADE
);

CREATE TABLE borrower (   ## This stores details of borrower
    card_no INT PRIMARY KEY,  ## the card_no identifies the each borrower
    name VARCHAR(100),
    address VARCHAR(200),
    phone VARCHAR(20)
);

CREATE TABLE book_loans (   ## This checks which borrower borrowed which book and from which branch 
    book_id INT,
    branch_id INT,
    card_no INT,
    date_out DATE,   ## Stores issue date 
    due_date DATE,   ## stores due date 
    PRIMARY KEY (book_id, branch_id, card_no),
    FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE CASCADE,
    FOREIGN KEY (branch_id)
        REFERENCES library_branch(branch_id)
        ON DELETE CASCADE,
    FOREIGN KEY (card_no)
        REFERENCES borrower(card_no)
        ON DELETE CASCADE
);
## Inserting Data into Tables 
INSERT INTO publisher VALUES
('Penguin', 'New York', '111-111'),
('HarperCollins', 'London', '222-222');

INSERT INTO library_branch VALUES
(1, 'Sharpstown', 'New York'),
(2, 'Central', 'Los Angeles');

INSERT INTO borrower VALUES
(101, 'John Smith', 'NY', '999999'),
(102, 'Alice Brown', 'LA', '888888'),
(103, 'Robert King', 'TX', '777777');

INSERT INTO books VALUES
(1, 'The Lost Tribe', 'Penguin'),
(2, 'It', 'HarperCollins');

INSERT INTO authors VALUES
(1, 'Mark Lee'),
(2, 'Stephen King');

INSERT INTO book_copies VALUES
(1, 1, 5),   -- Lost Tribe at Sharpstown
(1, 2, 3),   -- Lost Tribe at Central
(2, 2, 4);  -- IT at Central

INSERT INTO book_loans VALUES
(1, 1, 101, '2018-01-20', '2018-02-03'),
(2, 2, 102, '2018-01-25', '2018-02-10');

SELECT * FROM books;   ## this shows all books records 
SELECT * FROM book_copies;

## Questions 

SELECT bc.no_of_copies
FROM books b
JOIN book_copies bc ON b.book_id = bc.book_id
JOIN library_branch lb ON bc.branch_id = lb.branch_id
WHERE b.title = 'The Lost Tribe'
AND lb.branch_name = 'Sharpstown';     ## Finds the number of copies of The lost Tribe are in sharpstown Branch
  
SELECT lb.branch_name, bc.no_of_copies
FROM books b
JOIN book_copies bc ON b.book_id = bc.book_id
JOIN library_branch lb ON bc.branch_id = lb.branch_id
WHERE b.title = 'The Lost Tribe';   ## This shows number of copies of book at each branch

SELECT br.name
FROM borrower br
LEFT JOIN book_loans bl ON br.card_no = bl.card_no  ## using left join to get borrowers having no loans
WHERE bl.card_no IS NULL; 

SELECT b.title, br.name, br.address
FROM book_loans bl
JOIN books b ON bl.book_id = b.book_id
JOIN borrower br ON bl.card_no = br.card_no
JOIN library_branch lb ON bl.branch_id = lb.branch_id
WHERE lb.branch_name = 'Sharpstown'
AND bl.due_date = '2018-02-03';  ## Showing which books are due on a specfic date at sharpstown
  
SELECT lb.branch_name, COUNT(bl.book_id) AS total_books_loaned
FROM library_branch lb
LEFT JOIN book_loans bl ON lb.branch_id = bl.branch_id
GROUP BY lb.branch_name;  ## shows number of boomk loaned at each branch

SELECT br.name, br.address, COUNT(bl.book_id) AS books_checked_out
FROM borrower br
JOIN book_loans bl ON br.card_no = bl.card_no
GROUP BY br.card_no, br.name, br.address
HAVING COUNT(bl.book_id) > 5;  ## Here we have written HAVING because this filters the aggregated data 

SELECT b.title, bc.no_of_copies
FROM authors a
JOIN books b ON a.book_id = b.book_id
JOIN book_copies bc ON b.book_id = bc.book_id
JOIN library_branch lb ON bc.branch_id = lb.branch_id
WHERE a.author_name = 'Stephen King'
AND lb.branch_name = 'Central';   ## this showing "stephen King" books and available copies at central branch

SELECT COUNT(*) FROM books;  ## Returns total number of books in the library

