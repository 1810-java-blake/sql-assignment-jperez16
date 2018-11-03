-- Part I – Working with an existing database

-- 1.0	Setting up Oracle Chinook
-- In this section you will begin the process of working with the Oracle Chinook database
-- Task – Open the Chinook_Oracle.sql file and execute the scripts within.
-- 2.0 SQL Queries
-- In this section you will be performing various queries against the Oracle Chinook database.
-- 2.1 SELECT
-- Task – Select all records from the Employee table.
set schema 'chinook';
SELECT * FROM employee

-- Task – Select all records from the Employee table where last name is King.
set schema 'chinook';
SELECT * FROM employee WHERE lastname='King'

-- Task – Select all records from the Employee table where first name is Andrew and REPORTSTO is NULL.
set schema 'chinook';
SELECT * FROM employee WHERE firstname='Andrew' and  reportsto is NULL


-- 2.2 ORDER BY
-- Task – Select all albums in Album table and sort result set in descending order by title.
set schema 'chinook';
SELECT * FROM album
ORDER BY title DESC


-- Task – Select first name from Customer and sort result set in ascending order by city
set schema 'chinook';
SELECT * FROM customer
ORDER BY city ASC


-- 2.3 INSERT INTO
-- Task – Insert two new records into Genre table
set schema 'chinook';
INSERT INTO genre (genreid,name) VALUES(
	26,'MetalStep'
),(
	27,'PopStep'
);

-- Task – Insert two new records into Employee table
set schema 'chinook';
INSERT INTO 
employee (
	employeeid,lastname,firstname,title,reportsto,birthdate,hiredate,address,city,state,country,postalcode,phone,fax,email) 
VALUES(
	10,'Wick','John','Associate',3, '1976-04-12 00:00:00', '2018-10-01 00:00:00', '1516 Caligula Ave', 'Arlington', 'Texas', 'USA','76013','+1(956)859-8326','+1(956)859-8988','john.wick@johnnyboy.com'
),(
	9,'Perez','Jose','Associate',6, '1991-08-24 00:00:00', '2018-10-01 00:00:00', '1323 Esmer Ave', 'brownsville', 'Texas', 'USA','78520','+1(956)859-8956','+1(956)859-8258','jose.perez@googlemail.com'
)

-- Task – Insert two new records into Customer table
set schema 'chinook';
INSERT INTO customer (
	customerid,firstname,lastname,company,address,city,state,country,postalcode,phone,fax,email,supportrepid
)
VALUES(
	60, 'Dasani','PuriPuri','Home Depot', '400 S caravan ave', 'pasadena', 'tx', 'USA','79485','+1(832)782-9954','puripuri@faxme.org', 'puripuri@puri.org',3
),
(
	61, 'Edmund','GeForce','Nvidia', '2167 W Carpet RD', 'Pasadena', 'CA', 'USA','85475','+1(845)475-8574','geforceed@cornerfax.org', 'geforce@gmail.com',4
)


-- 2.4 UPDATE
-- Task – Update Aaron Mitchell in Customer table to Robert Walter
set schema 'chinook';
UPDATE customer
SET firstname='Robert', lastname='Walter'
WHERE firstname = 'Aaron' AND lastname ='Mitchell'

-- Task – Update name of artist in the Artist table “Creedence Clearwater Revival” to “CCR”
set schema 'chinook';
UPDATE artist
SET name = 'CCR'
WHERE name='Creedence Clearwater Revival'

-- 2.5 LIKE
-- Task – Select all invoices with a billing address like “T%”
set schema 'chinook';
SELECT billingaddress FROM invoice
WHERE billingaddress LIKE 'T%'

-- 2.6 BETWEEN
-- Task – Select all invoices that have a total between 15 and 50
set schema 'chinook';
SELECT * FROM invoice
WHERE total BETWEEN 15 and 50

-- Task – Select all employees hired between 1st of June 2003 and 1st of March 2004

set schema'chinook';
SELECT * from employee
WHERE hiredate BETWEEN '2003-06-01' AND '2004-03-01'
ORDER BY hiredate;

-- 2.7 DELETE
-- Task – Delete a record in Customer table where the name is Robert Walter (There may be constraints that rely on this, find out how to resolve them).

set schema 'chinook';
ALTER TABLE invoice
DROP CONSTRAINT FK_InvoiceCustomerId;

ALTER TABLE Invoice 
ADD CONSTRAINT FK_InvoiceCustomerId
FOREIGN KEY (CustomerId) REFERENCES Customer (CustomerId) 
ON DELETE CASCADE;
ALTER TABLE invoiceline
DROP CONSTRAINT FK_InvoiceLineInvoiceId;
ALTER TABLE InvoiceLine ADD CONSTRAINT FK_InvoiceLineInvoiceId
    FOREIGN KEY (InvoiceId) REFERENCES Invoice (InvoiceId) ON DELETE CASCADE;

DELETE FROM customer 
WHERE firstname = 'Robert' and lastname='Walter';


-- 3.0	SQL Functions
-- In this section you will be using the Oracle system functions, as well as your own functions, to perform various actions against the database
-- 3.1 System Defined Functions
-- Task – Create a function that returns the current time.
set schema 'chinook';
CREATE OR REPLACE FUNCTION getTime()
RETURNS TIME AS $$
	BEGIN
		RETURN current_time;
	END;
$$LANGUAGE plpgsql;

SELECT gettime();


-- Task – create a function that returns the length of a mediatype from the mediatype table
set schema 'chinook';
CREATE OR REPLACE FUNCTION GML(media_name TEXT)
RETURNS TEXT AS $$
	DECLARE
		media_length TEXT;
	BEGIN
		SELECT name INTO media_length FROM mediatype where name = media_name;
		RETURN length(media_length);
	END;
$$ LANGUAGE plpgsql;
SELECT GML('AAC audio file');

-- 3.2 System Defined Aggregate Functions
-- Task – Create a function that returns the average total of all invoices
set schema 'chinook';
CREATE OR REPLACE FUNCTION getAVG()
RETURNS TEXT AS $$
	DECLARE
		average TEXT;
	BEGIN
-- 		RETURN QUERY
		SELECT AVG(total) INTO average FROM invoice;
		RETURN average;
	END;

$$ LANGUAGE plpgsql;

SELECT getAVG();

-- Task – Create a function that returns the most expensive track
set schema 'chinook';
CREATE OR REPLACE FUNCTION getExpensiveTrack()
RETURNS TEXT AS $$
	BEGIN
		select * from track
		order by unitprice desc
		fetch first row only;
	END;
$$ LANGUAGE plpgsql;

SELECT getExpensiveTrack();

-- 3.3 User Defined Scalar Functions
-- Task – Create a function that returns the average price of invoiceline items in the invoiceline table
set schema 'chinook';
CREATE OR REPLACE FUNCTION gil()
RETURNS TEXT AS $$
DECLARE
	price DECIMAL;
	BEGIN
		SELECT AVG(unitprice) INTO price FROM invoiceline;
		RETURN price;
	END;
$$ LANGUAGE plpgsql;

SELECT gil();

-- 3.4 User Defined Table Valued Functions
-- Task – Create a function that returns all employees who are born after 1968.
set schema 'chinook';
DROP FUNCTION em1968;
CREATE OR REPLACE FUNCTION em1968()
RETURNS TABLE(
	employeeid INTEGER,
	lastname VARCHAR(20),
	firstname VARCHAR(20),
	title VARCHAR(30),
	reportsto INTEGER, birthdate timestamp, hiredate timestamp,
	address VARCHAR(70), city VARCHAR(40), state VARCHAR(40), country VARCHAR(40),
	postalcode VARCHAR(10), phone VARCHAR(24), fax VARCHAR(24), email VARCHAR(60)
) AS $$
	BEGIN
		RETURN QUERY
			SELECT * FROM employee WHERE employee.birthdate > '1968-12-31';
	END;
$$ LANGUAGE plpgsql;

SELECT  * FROM em1968();


-- 4.0 Stored Procedures
--  In this section you will be creating and executing stored procedures. You will be creating various types of stored procedures that take input and output parameters.
-- 4.1 Basic Stored Procedure
-- Task – Create a stored procedure that selects the first and last names of all the employees.

set schema 'chinook';
CREATE OR REPLACE FUNCTION getEmployees()
RETURNS TABLE(
	firstname VARCHAR(20),
	lastname VARCHAR(20)
) AS $$
	BEGIN
		RETURN QUERY
			SELECT employee.firstname, employee.lastname FROM employee;
	END;
$$ LANGUAGE plpgsql;

SELECT * FROM getEmployees();



-- 4.2 Stored Procedure Input Parameters
-- Task – Create a stored procedure that updates the personal information of an employee.

set schema 'chinook';
CREATE OR REPLACE FUNCTION CEN(oldfirst varchar(20), oldlast varchar, newfirst varchar(20), newlast varchar)RETURNS VOID AS $$
	BEGIN
		UPDATE employee 
			SET firstname = newfirst, lastname = newlast
			WHERE firstname = oldfirst AND lastname = oldlast;
	END;
$$ LANGUAGE plpgsql;

select CEN('Hello', 'Jeff', 'Hello', 'World');
select * from employee;

-- Task – Create a stored procedure that returns the managers of an employee.
set schema 'chinook';
CREATE OR REPLACE FUNCTION reportsTO(first_name Varchar(20), last_name VARCHAR(20))
RETURNS TABLE(firstname VARCHAR(20), lastname VARCHAR(20)) AS $$
DECLARE
	reportsToID_1 INTEGER;
	reportsToID_2 INTEGER;
	BEGIN
		SELECT reportsto FROM employee INTO reportsToID_1
		WHERE employee.firstname = first_name AND employee.lastname = last_name;
		IF reportsToID_1 IS NOT NULL
		THEN
			SELECT reportsto FROM employee INTO reportsToID_2
			WHERE employee.employeeid = reportsToID_1;
			RETURN QUERY
			SELECT employee.firstname, employee.lastname FROM employee 
		  	WHERE employee.employeeid = reportsToID_1 OR employee.employeeid = reportsToID_2;
	 	END IF;
	END;
$$ LANGUAGE plpgsql;

select * FROM reportsTO('Laura', 'Callahan');

-- 4.3 Stored Procedure Output Parameters
-- Task – Create a stored procedure that returns the name and company of a customer.
set schema 'chinook';
CREATE OR REPLACE FUNCTION getCustomerCompany(
	first_name varchar(20),last_name varchar(20))
 RETURNS TABLE(
 	firstname VARCHAR(20),
	lastname varchar(20),
	comapny VARCHAR(80)
 ) AS $$
	BEGIN
	 	RETURN QUERY
		SELECT customer.firstname,customer.lastname,customer.company from customer
		WHERE customer.firstname = first_name and customer.lastname=last_name;
	END;
$$ LANGUAGE plpgsql;
											 
SELECT * FROM getCustomerCompany('Tim','Goyer');

-- 5.0 Transactions
-- In this section you will be working with transactions. Transactions are usually nested within a stored procedure. You will also be working with handling errors in your SQL.
-- Task – Create a transaction that given a invoiceId will delete that invoice (There may be constraints that rely on this, find out how to resolve them).
set schema 'chinook';
CREATE OR REPLACE FUNCTION removeInvoice(invoice_ID INTEGER)
RETURNS VOID AS $$
	BEGIN
		DELETE FROM invoice
		WHERE invoice.invoiceid = invoice_ID;
	END;
$$ LANGUAGE plpgsql;

SELECT  removeInvoice(411);

-- Task – Create a transaction nested within a 
-- stored procedure that inserts a new record in the 
-- Customer table
set schema 'chinook';
CREATE OR REPLACE FUNCTION newCust(newcustomerid INTEGER, newfirstname VARCHAR(40), newlastname VARCHAR(20), newcompany VARCHAR(80), newadddress VARCHAR(70), newcity VARCHAR(40), newstate VARCHAR(40), newcountry VARCHAR(40), newpostalcode VARCHAR(10), newphone VARCHAR(24), newfax VARCHAR(24), newemail VARCHAR(60), newsupportrepid INTEGER)
RETURNS VOID AS $$
	BEGIN
		INSERT INTO customer(customerid, firstname, lastname, company, address, city, state, country, postalcode, phone, fax, email, supportrepid)
		VALUES(
			newcustomerid, newfirstname, newlastname, newcompany, newadddress, newcity, newstate, newcountry, newpostalcode, newphone, newfax, newemail, newsupportrepid
		);
	END;
$$ LANGUAGE plpgsql;

SELECT newCust(60, 'Joshua','Ligma', 'Ligma Enterprises', '123 ligma ave', 'sugon', 'POO', 'HAVA', '912', '911', 'who-has','ligma@protonmail.com', 3 );


-- 6.0 Triggers


-- In this section you will create various kinds of triggers that work when certain DML statements are executed on a table.
-- 6.1 AFTER/FOR
-- Task - Create an after insert trigger on the employee table fired after a new record is inserted into the table.
    CREATE OR REPLACE FUNCTION after_insert()
    RETURNS TRIGGER AS $$
        BEGIN
            -- STUFF HAPPENS HERE
        END;
    $$ LANGUAGE plpgsql;

    CREATE TRIGGER insert_trigger
        AFTER INSERT
        ON employee
        FOR EACH ROW
        EXECUTE PROCEDURE after_insert();
-- Task – Create an after update trigger on the album table that fires after a row is inserted in the table
    CREATE OR REPLACE FUNCTION after_update()
    RETURNS TRIGGER AS $$
        BEGIN
            --STUFF HAPPENS HERE
        END;
    $$ LANGUAGE plpgsql;

    CREATE TRIGGER update_trigger
        AFTER UPDATE
        ON album
        FOR EACH ROW
        EXECUTE after_update();
-- Task – Create an after delete trigger on the customer table that fires after a row is deleted from the table.
    CREATE OR REPLACE FUNCTION after_delete()
    RETURNS TRIGGER AS $$
        BEGIN
            --STUFF HAPPENS HERE
        END;
    $$ LANGUAGE plpgsql;

    CREATE TRIGGER delete_trigger
        AFTER DELETE
        ON customer
        FOR EACH ROW
        EXECUTE PROCEDURE after_delete();
-- 6.2 Before
-- Task – Create a before trigger that restricts the deletion of any invoice that is priced over 50 dollars.
CREATE OR REPLACE FUNCTION triggered_delete()
    RETURNS TRIGGER AS $$
        BEGIN
            IF OLD.total > 50 THEN
                RAISE EXCEPTION 'Inovices with a total greater then $50.00 cannot be deleted';
            END IF;
            RETURN NEW;
        END;
    $$ LANGUAGE plpgsql;

    CREATE  TRIGGER invoive_delete_upper_limit
        BEFORE DELETE
        ON invoice
        FOR EACH ROW
        EXECUTE PROCEDURE triggered_delete();

-- 7.0 JOINS
-- In this section you will be working with combing various tables through the use of joins. You will work with outer, inner, right, left, cross, and self joins.
-- 7.1 INNER
-- Task – Create an inner join that joins customers and orders and specifies the name of the customer and the invoiceId.

set schema 'chinook';
SELECT * FROM customer
INNER JOIN invoice ON invoice.customerid = customer.customerid
WHERE customer.firstname = 'Astrid' and customer.lastname='Gruber'


-- 7.2 OUTER
-- Task – Create an outer join that joins the customer and invoice table, specifying the CustomerId, firstname, lastname, invoiceId, and total.
set schema 'chinook';
SELECT customer.customerid,customer.firstname,customer.lastname,invoice.invoiceid,invoice.total FROM customer
LEFT OUTER JOIN invoice ON customer.customerid = invoice.customerid;

-- 7.3 RIGHT
-- Task – Create a right join that joins album and artist specifying artist name and title.
set schema 'chinook';
SELECT artist.name, album.title FROM artist
RIGHT JOIN album ON artist.artistid = album.artistid;

-- 7.4 CROSS
-- Task – Create a cross join that joins album and artist and sorts by artist name in ascending order.
set schema 'chinook';
SELECT * from artist
CROSS JOIN album
ORDER BY artist.name ASC;

-- 7.5 SELF
-- Task – Perform a self-join on the employee table, joining on the reportsto column.

set schema 'chinook';
SELECT a.employeeid AS "emp_id", a.firstname AS "emp_name", a.lastname AS "emp_last",
	   b.employeeid AS "sup_id", b.firstname AS "sup_name", b.lastname AS "sup_last"
FROM employee a, employee b
WHERE a.reportsto = b.employeeid;

