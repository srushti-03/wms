-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Server version: 10.1.16-MariaDB
-- PHP Version: 5.6.24

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Name of the database : `wholesale_management`
--

DELIMITER $$
--
-- Procedures
--This procedure is creating a stored procedure in MySQL database that takes three input parameters: product, quant, and disc and
-- calculates the discount based on the total price of the product and quantity purchased.

CREATE DEFINER=`root`@`localhost` PROCEDURE `discount_calc` (IN `product` INT(10), IN `quant` INT(10), OUT `disc` INT(10))  BEGIN
declare price int; 
declare disc int; 
declare total int;
select USP into price from price_list where ProductID = product;
set total=quant*price; 
if (tot >= 20000 and tot < 40000) THEN
   set disc=tot*0.05;                                 
--If the total price is greater than or equal to 20,000 and less than 40,000, it applies a 5% discount.

elseif (tot >= 40000 and tot < 60000) THEN
   set disc=tot*0.075;
   
-- If the total price is greater than or equal to 40,000 and less than 60,000, it applies a 7.5% discount.

elseif (tot >= 100000) THEN
   set disc=tot*0.1;
   
-- If the total price is greater than or equal to 100,000, it applies a 10% discount.

end if;
end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Defining the structure for table `category`
--

CREATE TABLE `category` (
  `CategoryID` int(11) NOT NULL,
  `CategoryName` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- inserting data into table `category`
--

INSERT INTO `category` (`CategoryID`, `CategoryName`) VALUES
(1, 'pen'),
(2, 'shampoo'),
(3, 'hairoil'),
(4, 'chips');
(5, 'toothpaste');

-- --------------------------------------------------------

--
--Defining the structure for table `customer_information`
--

CREATE TABLE `customer_information` (
  `CustomerID` varchar(30) NOT NULL,
  `Name` varchar(30) NOT NULL,
  `Address` varchar(50) NOT NULL,
  `Phone` varchar(15) NOT NULL,
  `Password` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- inserting values into table `customer_information`
--

INSERT INTO `customer_information` (`CustomerID`, `Name`, `Address`, `Phone`, `Password`) VALUES
('C1', 'Shefali Shah', 'XYZ', '9090909090', 'abc123'),
('C2', 'Kashsih Jethmalani', 'ABC', '9000190001', 'xyz123'),
('C3', 'Vishwa Joshi', 'PQR', '9900990099', 'pqr123');
('C4', 'Srushti Thakar', 'RST', '9898098980', 'rst123');
('C5', 'Vishwa Joshi', 'DEF', '9191091910', 'def123');

-- --------------------------------------------------------

--
-- Defining the structure for table `depleted_product`
--

CREATE TABLE `depleted_product` (
  `ProductID` int(11) NOT NULL,
  `Quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Defining the structure for table `payment`
--

CREATE TABLE `payment` (
  `TransactionID` int(11) NOT NULL,
  `Amount_Paid` int(11) NOT NULL,
  `Mode` varchar(30) NOT NULL,
  `Transaction_Date` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- inserting the values into the table `payment`
--

INSERT INTO `payment` (`TransactionID`, `Amount_Paid`, `Mode`, `Transaction_Date`) VALUES
(21, 4000, 'online payment', 2023),
(22, 3000, 'cash', 2023),
(23, 2500, 'cash', 2023),
(24, 3200, 'debit card',2023),
(25, 1000, 'debit card', 2023);

-- --------------------------------------------------------

--
-- defining the structure for table `price_list`
--

CREATE TABLE `price_list` (
  `ProductID` int(11) NOT NULL,
  `USP` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- inserting values into the table `price_list`
--

INSERT INTO `price_list` (`ProductID`, `USP`) VALUES
(1, 70),
(2, 100),
(3, 500),
(4, 200),
(5, 120);

-- --------------------------------------------------------

--
-- defining the structure for table `product`
--

CREATE TABLE `product` (
  `ProductID` int(11) NOT NULL,
  `Pname` varchar(30) NOT NULL,
  `CategoryID` int(11) NOT NULL,
  `SupplierID` int(11) NOT NULL,
  `Quantity_in_stock` int(11) NOT NULL,
  `UnitPrice` int(11) NOT NULL,
  `ReorderLevel` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`ProductID`, `Pname`, `CategoryID`, `SupplierID`, `Quantity_in_stock`, `UnitPrice`, `ReorderLevel`) VALUES
(1, 'pen', 1, 1, 20, 60, 10),
(2, 'surf excel', 1, 1, 55, 70, 10),
(3, 'dove soap', 2, 2, 35, 40, 10),
(4, 'nivea cream', 2, 2, 55, 110, 8),
(5, 'pepsi bottle', 3, 2, 100, 250, 10);

--
-- defining various triggers on the table `product`
--

-- trigger-1 on table 'product': 
--The trigger checks if the updated "Quantity_in_stock" value of the product is less than the "ReorderLevel" value.
--If it is, then the "ProductID" and "Quantity_in_stock" values are inserted into the "depleted_product" table.

DELIMITER $$
CREATE TRIGGER `depleted_check_update` BEFORE UPDATE ON `product` FOR EACH ROW BEGIN
Declare finished integer default 0;
Declare cust varchar(30);
declare flag integer default 0;
Declare c1 cursor for select ProductID from depleted_product;
DECLARE CONTINUE HANDLER 
FOR NOT FOUND SET finished = 1;

if NEW.Quantity_in_stock < NEW.ReorderLevel THEN
insert into depleted_product(ProductID,Quantity) values(NEW.ProductID,NEW.Quantity_in_stock);
else
open c1;
get_cust: LOOP
Fetch c1 into cust;
if finished=1 then 
leave get_cust; 
end if;
if cust=NEW.ProductID then 
set finished=1;
set flag=1;
end if;
end loop get_cust;
close c1;
if flag=1 then
Delete from depleted_product where ProductID=NEW.ProductID;
END if;
end if;
END
$$
DELIMITER ;
DELIMITER $$




--Trigger-2 on table 'product':

--This trigger is creating a constraint on the product table to ensure that a valid SupplierID is inserted into the table, and it also inserts 
--data into the depleted_product table when a product's quantity in stock falls below the reorder level.

CREATE TRIGGER `supplier_check` BEFORE INSERT ON `product` FOR EACH ROW BEGIN
Declare finished integer default 0;
Declare cust varchar(30);
declare flag integer default 0;
Declare c1 cursor for select supplierID from supplier_information;
DECLARE CONTINUE HANDLER 
FOR NOT FOUND SET finished = 1;

if NEW.Quantity_in_stock < NEW.ReorderLevel THEN
insert into depleted_product(ProductID,Quantity) values(NEW.ProductID, NEW.Quantity_in_stock);
end if;

open c1;
get_cust: LOOP
Fetch c1 into cust;
if finished=1 then 
leave get_cust; 
end if;
if cust=NEW.SupplierID then 
set flag=1;
end if;
end loop get_cust;
close c1;
if flag=0 then
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Supplier does not exist';
END if;
END
$$
DELIMITER ;



-- --------------------------------------------------------

--
-- defining the structure for table `supplier_information`
--

CREATE TABLE `supplier_information` (
  `SupplierID` int(11) NOT NULL,
  `SName` varchar(30) NOT NULL,
  `Address` varchar(50) NOT NULL,
  `Phone` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- inserting values into the table `supplier_information`
--

INSERT INTO `supplier_information` (`SupplierID`, `SName`, `Address`, `Phone`) VALUES
(1, 'Kashish', 'XYZ', '123456789'),
(2, 'Vishwa', 'QWE', '987654329 ');
(2, 'Srushti', 'ABC', '9909909900 ');
(2, 'Aanal', 'PQR', '9191091910 ');

-- --------------------------------------------------------

--
-- defining the structure for table `transaction_detail`
--

CREATE TABLE `transaction_detail` (
  `TransactionID` int(11) NOT NULL,
  `ProductID` int(11) NOT NULL,
  `Quantity` int(11) NOT NULL,
  `Discount` int(11) NOT NULL DEFAULT '0',
  `Total_Amount` int(11) NOT NULL,
  `Trans_Init_Date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- inserting values into the table `transaction_detail`
--

INSERT INTO `transaction_detail` (`TransactionID`, `ProductID`, `Quantity`, `Discount`, `Total_Amount`, `Trans_Init_Date`) VALUES
(22, 1, 10, 0, 1400, '2023-04-18'),
(22, 2, 20, 0, 3000, '2023-04-17'),
(25, 3, 10, 0, 1100, '2023-04-17'),
(25, 4, 5, 0, 3000, '2023-04-17'),
(27, 1, 10, 0, 1400, '2023-04-18'),
(27, 2, 15, 0, 2000, '2023-04-17'),
(27, 3, 4, 0, 1100, '2023-04-15'),
(28, 4, 12, 0, 1500, '2023-04-16');

--

-- defining the triggers on the table `transaction_detail`
--


--Trigger-1 on table 'transaction_detail':
--This trigger is being created for the table transaction_detail and is executed BEFORE INSERT for each row that is being inserted into that table.
--this trigger ensures that the Quantity being inserted into the transaction_detail table is within the acceptable range of the corresponding ProductID 
--and updates the Quantity_in_stock value accordingly.

DELIMITER $$
CREATE TRIGGER `max_min_quantity` BEFORE INSERT ON `transaction_detail` FOR EACH ROW BEGIN
declare var1 int;
declare var2 int;
select ReorderLevel into var1 from Product where ProductID = NEW.ProductID;
select Quantity_in_stock into var2 from Product where ProductID = NEW.ProductID;
if new.Quantity<var1 THEN
   signal sqlstate '45000' set message_text = 'Less than min quantity';
end if;
if new.Quantity>var2 THEN
   signal sqlstate '45000' set message_text = 'More than max quantity';
end if;
update product set Quantity_in_stock = Quantity_in_stock - NEW.Quantity where ProductID = NEW.ProductID;
END
$$
DELIMITER ;
DELIMITER $$




--Trigger-2 on table 'transaction_detail':
-- This trigger is similar to the previous one, but it is executed BEFORE UPDATE instead of BEFORE INSERT on the transaction_detail table.
--This means that it will check the Quantity column being updated rather than inserted.
-- this trigger ensures that the updated Quantity value for a particular ProductID in the transaction_detail table is within the acceptable range
--and updates the Quantity_in_stock value in the Product table accordingly.


CREATE TRIGGER `max_min_quantity_update` BEFORE UPDATE ON `transaction_detail` FOR EACH ROW BEGIN
declare var1 int;
declare var2 int;

select ReorderLevel into var1 from Product where ProductID = NEW.ProductID;
select Quantity_in_stock into var2 from Product where ProductID = NEW.ProductID;
if new.Quantity<var1 THEN
   signal sqlstate '45000' set message_text = 'Less than min quantity';
end if;
if new.Quantity>var2 THEN
   signal sqlstate '45000' set message_text = 'More than max quantity';
end if;
update product set Quantity_in_stock = Quantity_in_stock - NEW.Quantity where ProductID=NEW.ProductID;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- defining the structure for table `transaction_information`
--

CREATE TABLE `transaction_information` (
  `TransactionID` int(11) NOT NULL,
  `CustomerID` varchar(30) NOT NULL,
  `Trans_Init_Date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- inserting values into the table `transaction_information`
--

INSERT INTO `transaction_information` (`TransactionID`, `CustomerID`, `Trans_Init_Date`) VALUES
(22, 'C1', '2023-04-17'),
(25, 'C1', '2023-04-17'),
(27, 'C3', '2023-04-15'),
(28, 'C2', '2023-04-16');
(25, 'C2', '2023-04-17');

--


--
-- defining the structure for table `sales_order`
--

CREATE TABLE `sales_order` (
  `sales_order_id` int(11) NOT NULL,
  `CustomerID` varchar(30) NOT NULL,
  `sales_order_Date` date NOT NULL,
  `sales_order_status` varchar(30) NOT NULL,
   
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- inserting values into the table `sales_order`
--

INSERT INTO `sales_order` (`sales_order_id`, `CustomerID`, `sales_order_Date`,`sales_order_status`) VALUES
(1, 'C1', '2023-04-17','delivered'),
(2, 'C1', '2023-04-17','delivered'),
(3, 'C3', '2023-04-15','not delivered'),
(4, 'C2', '2023-04-16','delivered');
(5, 'C2', '2023-04-17','delivered');

--

--
-- defining the structure for table `sales_order_item`
--

CREATE TABLE `sales_order_item` (
  `sales_order_item_id` int(11) NOT NULL,
  `sales_order_id` int(11) NOT NULL,
  `product_id` int NULL,
  `sales_quantity_item` int NOT NULL,
   `sales_order_item_unit_price` int NOT NULL,
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- inserting values into the table `transaction_information`
--

INSERT INTO `sales_order_item` (`sales_order_item_id`, `sales_order_id`, `product_id`,`sales_quantity_item`,`sales_order_item_unit_price`) VALUES
(1,1, 10, 5, 100),
(2,1 ,11 , 10, 120),
(3,3 ,12, 15, 200 ),
(4,4 ,13, 20, 230);
(5, 5, 14, 25, 500);

--




-- defining triggers on the table `transaction_information`

--trigger-1 on `transaction_information`:
--This trigger creates a check before inserting a new row into the transaction_information table. 
--The check ensures that the CustomerID specified in the new row exists in the customer_information table.
--If the CustomerID does not exist, the trigger raises an error with the message "Customer does not exist" using the SIGNAL statement.


DELIMITER $$
CREATE TRIGGER `customer_check` BEFORE INSERT ON `transaction_information` FOR EACH ROW BEGIN
Declare finished integer default 0;
Declare cust varchar(30);
declare flag integer default 0;
Declare c1 cursor for select customerID from customer_information;
DECLARE CONTINUE HANDLER 
FOR NOT FOUND SET finished = 1;
open c1;
get_cust: LOOP
Fetch c1 into cust;
if finished=1 then 
leave get_cust; 
end if;
if cust=NEW.CustomerID then 
set flag=1;
end if;
end loop get_cust;
close c1;
if flag=0 then
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer does not exist';
END if;
END
$$
DELIMITER ;
DELIMITER $$




--trigger-2 on table `transaction_information`:
--This trigger creates a check before updating a row in the transaction_information table. The check ensures that the CustomerID specified
--in the updated row exists in the customer_information table. If the CustomerID does not exist, the trigger raises an error with the message
--"Customer does not exist" using the SIGNAL statement.

CREATE TRIGGER `customer_check_update` BEFORE UPDATE ON `transaction_information` FOR EACH ROW BEGIN
Declare finished integer default 0;
Declare cust varchar(30);
declare flag integer default 0;
Declare c1 cursor for select customerID from customer_information;
DECLARE CONTINUE HANDLER 
FOR NOT FOUND SET finished = 1;
open c1;
get_cust: LOOP
Fetch c1 into cust;
if finished=1 then 
leave get_cust; 
end if;
if cust=NEW.CustomerID then 
set flag=1;
end if;
end loop get_cust;
close c1;
if flag=0 then
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer does not exist';
END if;
END
$$
DELIMITER ;
DELIMITER $$



--trigger-3 on table  `transaction_information`:
--This trigger is defined on the transaction_information table and is executed before a row is deleted from the table.
--The trigger decreases the quantity_in_stock value of the products that were included in the transaction being deleted.
--Overall, this trigger ensures that the quantity_in_stock value of the products is correctly updated whenever a transaction 
--is deleted from the transaction_information table.



CREATE TRIGGER `decrease_quantity` BEFORE DELETE ON `transaction_information` FOR EACH ROW BEGIN

Declare finished integer default 0;
Declare cust integer;
Declare quant integer default 0;
Declare c1 cursor for select ProductID from transaction_detail where TransactionID=OLD.TransactionID;
DECLARE CONTINUE HANDLER 
FOR NOT FOUND SET finished = 1;

CREATE TEMPORARY TABLE IF NOT EXISTS my_temp_table
SELECT ProductID, Quantity from transaction_detail where TransactionID=OLD.TransactionID;
open c1;
get_cust: LOOP
Fetch c1 into cust;
if finished=1 then 
leave get_cust; 
end if;
Select Quantity into quant from my_temp_table where ProductID=cust; 
Update Product set quantity_in_stock=quantity_in_stock+quant where ProductID=cust;
end loop;
close c1;
Delete from transaction_detail where transactionID=OLD.TransactionID;
END
$$
DELIMITER ;

--


--

--

-- altering the tables for adding appropraite primary key and foreign key constraints:


-- Indexes for table `category`
ALTER TABLE `category`
  ADD PRIMARY KEY (`CategoryID`);

--
-- Indexes for table `customer_information`
--
ALTER TABLE `customer_information`
  ADD PRIMARY KEY (`CustomerID`);

--
-- Indexes for table `depleted_product`
--
ALTER TABLE `depleted_product`
  ADD PRIMARY KEY (`ProductID`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`TransactionID`);

--
-- Indexes for table `price_list`
--
ALTER TABLE `price_list`
  ADD PRIMARY KEY (`ProductID`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`ProductID`),
  ADD KEY `product_ibfk_2` (`CategoryID`),
  ADD KEY `product_ibfk_3` (`SupplierID`);

--
-- Indexes for table `supplier_information`
--
ALTER TABLE `supplier_information`
  ADD PRIMARY KEY (`SupplierID`);

--
-- Indexes for table `transaction_detail`
--
ALTER TABLE `transaction_detail`
  ADD PRIMARY KEY (`TransactionID`,`ProductID`),
  ADD KEY `td_ibfk_2` (`ProductID`);

--
-- Indexes for table `transaction_information`
--
ALTER TABLE `transaction_information`
  ADD PRIMARY KEY (`TransactionID`),
  ADD KEY `ti_ibfk_1` (`CustomerID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `transaction_information`
--
ALTER TABLE `transaction_information`
  MODIFY `TransactionID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;
--
-- Constraints for dumped tables
--
-- By including the AUTO_INCREMENT value in the dumped table, you can ensure that the table will function properly and 
--maintain its data integrity when it is restored on another MySQL instance.
--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `product_ibfk_2` FOREIGN KEY (`CategoryID`) REFERENCES `category` (`CategoryID`),
  ADD CONSTRAINT `product_ibfk_3` FOREIGN KEY (`SupplierID`) REFERENCES `supplier_information` (`SupplierID`);

--
-- Constraints for table `transaction_detail`
--
ALTER TABLE `transaction_detail`
  ADD CONSTRAINT `td_ibfk_2` FOREIGN KEY (`ProductID`) REFERENCES `product` (`ProductID`);

--
-- Constraints for table `transaction_information`
--
ALTER TABLE `transaction_information`
  ADD CONSTRAINT `ti_ibfk_1` FOREIGN KEY (`CustomerID`) REFERENCES `customer_information` (`CustomerID`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
