use vtsb2b;

															-- TABLE CREATION -- 

DROP TABLE IF EXISTS Customer;

CREATE TABLE IF NOT EXISTS Customer(
    customerId VARCHAR(255) NOT NULL PRIMARY KEY, 
    CompanyName VARCHAR(200) NOT NULL, 
    PAN VARCHAR(200) NOT NULL, 
    gstNo VARCHAR(255) NOT NULL, 
    Email VARCHAR(255), 
    `Password` VARCHAR(255) DEFAULT NULL, 
    phoneNo VARCHAR(50) NOT NULL, 
    TelephoneNo VARCHAR(50) DEFAULT NULL, 
    address1 VARCHAR(300), 
    address2 VARCHAR(300),
    state VARCHAR(100), 
    city VARCHAR(100), 
    landmark varchar(255),
    pincode VARCHAR(100), 
    DateOfReg VARCHAR(40)
);

DROP TABLE IF EXISTS Product;
CREATE TABLE IF NOT EXISTS Product(
productId varchar(255),
productName varchar(255),
productImg varchar(255),
costPerUnit JSON );


DROP TABLE IF EXISTS orderDetails;

 CREATE TABLE IF NOT EXISTS orderDetails (
            orderId VARCHAR(255) PRIMARY KEY,
            customerId VARCHAR(255),
            phoneNo VARCHAR(13),
            address1 VARCHAR(255),  
            address2 VARCHAR(255),
            city VARCHAR(255),
            state VARCHAR(255),
            email VARCHAR(255),
            landmark VARCHAR(255),
            pincode VARCHAR(255),
            gstNo VARCHAR(255),
            requestedSample BOOLEAN default false,
            dateOfOrder VARCHAR(25),
            productId varchar(255),
            productName VARCHAR(255),
            productQuantity INT,
            productType VARCHAR(255),
            totalAmount DECIMAL(15, 2),
            invoiceUrl VARCHAR(255) default null,
            paymentVerified BOOLEAN default false,
			deliveryStatus BOOLEAN default false,
            paymentStatus BOOLEAN default false
        );


DROP TABLE IF EXISTS Invoice;

CREATE TABLE IF NOT EXISTS  Invoice(
invoiceId varchar(255) primary key,
invoiceLink varchar(255),
invoiceDate varchar(25),
orderId varchar(255),
transId varchar(255) default null);


DROP TABLE IF EXISTS Transactions;

CREATE TABLE IF NOT EXISTS Transactions(
transId varchar(255) primary key,
orderId varchar(255),
accountNo varchar(255),
transactionId varchar(255),
dateOfTransaction varchar(255),
transactionType varchar(255) default 'credit',
invoiceNo varchar(255),
amount varchar(255),
paymentMode varchar(255),
paymentStatus boolean default true,
paymentVerified boolean default false,
paymentApprovedDate varchar(255)
);

DROP TABLE IF EXISTS Shipment;

CREATE TABLE IF NOT EXISTS Shipment(
shipmentId varchar(50) NOT NULL,
orderId varchar(40) NOT NULL,
productName varchar(40),
shippingAddress varchar(200),
shipmentStatus boolean default false
);


															-- TRIGGERS-- 
 

DROP TRIGGER IF EXISTS AutoGen_PID;
DELIMITER //

CREATE TRIGGER AutoGen_PID
BEFORE INSERT ON product
FOR EACH ROW
BEGIN
    DECLARE p_id int;
    SELECT COALESCE(MAX(CAST(SUBSTRING(productId, 7) AS UNSIGNED)), 0) INTO p_id FROM Product;
    SET NEW.productId = CONCAT('B2BPID', LPAD(p_id + 1, 4, '0'));
END //

DELIMITER ;

DROP TRIGGER IF EXISTS autoGenCid;

DELIMITER //

CREATE TRIGGER autoGenCid
BEFORE INSERT ON Customer
FOR EACH ROW
BEGIN
    DECLARE max_id INT;
    SELECT COALESCE(MAX(CAST(SUBSTRING(CustomerId, 7) AS UNSIGNED)), 0) INTO max_id FROM Customer;
    SET NEW.CustomerId = CONCAT('B2BCID', LPAD(max_id + 1, 4, '0'));
END;
//

DELIMITER ;

DROP TRIGGER IF EXISTS autoGenOid;
DELIMITER //

CREATE TRIGGER autoGenOid
BEFORE INSERT ON orderDetails
FOR EACH ROW
BEGIN
    DECLARE max_id INT;
    SELECT COALESCE(MAX(CAST(SUBSTRING(orderId, 7) AS UNSIGNED)), 0) INTO max_id FROM orderDetails;
    SET NEW.orderId = CONCAT('B2BHUB', LPAD(max_id + 1, 4, '0'));
END;
//

DELIMITER ;

DROP TRIGGER IF EXISTS autoGenInvId;
DELIMITER //
CREATE TRIGGER autoGenInvId
BEFORE INSERT ON Invoice
FOR EACH ROW
BEGIN
	DECLARE max_id int;
    SELECT COALESCE(MAX(CAST(SUBSTRING(invoiceId, 4) AS UNSIGNED)), 0) INTO max_id FROM Invoice;
    SET NEW.invoiceId = CONCAT('INV', LPAD(max_id + 1, 4, '0'));
END;
//

DELIMITER ;

DROP TRIGGER IF EXISTS AutoGen_TID;
DELIMITER //

CREATE TRIGGER AutoGen_TID
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE t_id int;
    SELECT COALESCE(MAX(CAST(SUBSTRING(transId, 7) AS UNSIGNED)), 0) INTO t_id FROM transactions;
    SET NEW.transId = CONCAT('B2BTRN', LPAD(t_id + 1, 4, '0'));
END //

DELIMITER ;

DROP TRIGGER IF EXISTS AutoGen_SID;
DELIMITER //

CREATE TRIGGER AutoGen_SID
BEFORE INSERT ON shipment
FOR EACH ROW
BEGIN
    DECLARE s_id int;
    SELECT COALESCE(MAX(CAST(SUBSTRING(shipmentId, 7) AS UNSIGNED)), 0) INTO s_id FROM Shipment;
    SET NEW.shipmentId = CONCAT('B2BSID', LPAD(s_id + 1, 4, '0'));
END //

DELIMITER ;

DROP TRIGGER IF EXISTS OrderAddress;
DELIMITER //
 CREATE TRIGGER OrderAddress
 BEFORE INSERT ON orderDetails
 FOR EACH ROW
 BEGIN 
 DECLARE a1 varchar(255); DECLARE a2 varchar(255);
 DECLARE c varchar(255); DECLARE s varchar(255); 
 DECLARE e varchar(255); DECLARE l varchar(255);
 DECLARE p varchar(255); DECLARE m varchar(255);
 DECLARE g varchar(255);
 SELECT gstNo, address1, address2, city, state, phoneNo, Email, landmark, pincode
 INTO g, a1, a2, c, s, m, e, l, p FROM Customer WHERE CustomerId = NEW.CustomerId;
 SET NEW.gstNo = g, NEW.address1 = a1, NEW.address2 = a2, NEW.city = c, NEW.state = s, NEW.phoneNo = m, NEW.email = e, NEW.landmark = l, NEW.pincode = p;
 END;
 //
 DELIMITER ;
 
DROP TRIGGER IF EXISTS insertInvoice;
DELIMITER //
CREATE TRIGGER insertInvoice
AFTER INSERT ON orderDetails
FOR EACH ROW
BEGIN 
DECLARE Inv varchar(255);
DECLARE oId varchar(255);
SELECT invoiceUrl INTO Inv FROM orderdetails WHERE orderId = NEW.orderId;
INSERT INTO Invoice(invoiceId, invoiceLink, invoiceDate, orderId)
SELECT CONCAT('INV', LPAD(COALESCE(MAX(CAST(SUBSTRING(invoiceId, 4) AS UNSIGNED)) + 1, 1), 3, '0')), Inv ,date_format(CURDATE(), '%d-%m-%Y'), NEW.orderId FROM Invoice;

END ; 
//
DELIMITER ;

-- DROP TRIGGER IF EXISTS updateInvoice;
-- DELIMITER // 
-- CREATE TRIGGER updateInvoice
-- AFTER UPDATE ON orderDetails
-- FOR EACH ROW
-- BEGIN
-- UPDATE Invoice SET invoiceLink = 'bad' WHERE orderId = NEW.orderId;
-- END ;
-- // 
-- DELIMITER ;
 
DROP TRIGGER IF EXISTS update_payment;

DELIMITER //
CREATE TRIGGER update_payment
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
UPDATE orderDetails SET paymentStatus = TRUE WHERE orderId = NEW.orderId;
END;
 //
DELIMITER ;

DROP TRIGGER IF EXISTS verify_payment;

DELIMITER //
CREATE TRIGGER verify_payment
AFTER UPDATE ON orderDetails
FOR EACH ROW
BEGIN
IF OLD.paymentVerified != NEW.paymentVerified
THEN
UPDATE Transactions SET paymentVerified = TRUE, paymentApprovedDate = date_format(CURDATE(), '%d-%m-%Y') WHERE orderId = NEW.orderId;
END IF;
END;
//
DELIMITER ;

DELIMITER //

CREATE TRIGGER trans_to_shipment
AFTER UPDATE ON transactions
FOR EACH ROW
BEGIN
    DECLARE Address VARCHAR(255);
    IF OLD.paymentVerified != NEW.paymentVerified THEN
        SELECT CONCAT(od.address1, ', ', od.address2, ', ', od.city, ', ', od.state, ', ', od.landmark, ', ', od.zip_code) INTO Address
        FROM orderdetails od
        JOIN transactions t ON od.orderId = t.orderId
        WHERE t.transId = NEW.transId;
        INSERT INTO shipment (OrderId, ProductName, shippingAddress)
        SELECT od.orderId, od.product_name, Address
        FROM orderdetails od
        JOIN transactions t ON od.orderId = t.orderId
        WHERE t.transId = NEW.transId;
    END IF;
END;
//

DELIMITER ;

																-- INSERTION--  
                                                                        
                                                                        
INSERT INTO Customer (CompanyName, PAN, gstNo, Email, `Password`, phoneNo, TelephoneNo, address1, address2, state, city, landmark, pincode, DateOfReg) 
VALUES 
('Tech Innovations Inc.', 'AAACT1234F', '29ABCDE1234F1Z5', 'contact@techinnovations.com', 'password123', '9876543210', '0123456789', '123 Tech Park', 'Suite 456', 'California', 'San Francisco', 'Near Tech Tower', '94105', '2024-01-15'),
('Gadget World Ltd.', 'AABCB5678G', '19XYZZ6789L2A1', 'info@gadgetworld.com', 'password456', '8765432109', '0987654321', '456 Gadget Road', 'Floor 3', 'New York', 'New York', 'Next to Gadget Mall', '10001', '2024-02-20'),
('Hardware Solutions Co.', 'AABCD6789H', '27HJKE2345G9R8', 'support@hardwaresolutions.com', 'password789', '7654321098', '2345678901', '789 Hardware Avenue', '', 'Texas', 'Austin', 'Behind Hardware Park', '73301', '2024-03-25'),
('Device Enterprises', 'AACDE7890I', '37LMNO0987C7V6', 'sales@deviceenterprises.com', 'password012', '6543210987', '3456789012', '101 Device Boulevard', 'Unit 2', 'Florida', 'Miami', 'Opposite Device Plaza', '33101', '2024-04-30'),
('Component Supply LLC', 'AABEF8901J', '45PQRS7654H3J9', 'contact@componentsupply.com', 'password345', '5432109876', '4567890123', '202 Component Crescent', 'Apt 5B', 'Ohio', 'Cleveland', 'Near Component Park', '44101', '2024-05-10'),
('Electro Goods Corp.', 'AABFG9012K', '11TUVW5432M8K1', 'service@electrogoods.com', 'password678', '4321098765', '5678901234', '303 Electro Parkway', 'Suite 10', 'Illinois', 'Chicago', 'Adjacent to Electro Mall', '60601', '2024-06-15'),
('Accessory Zone Ltd.', 'AABGH0123L', '22XYZZ1234D9S5', 'support@accessoryzone.com', 'password901', '3210987654', '6789012345', '404 Accessory Street', 'Floor 4', 'Michigan', 'Detroit', 'Close to Accessory Hub', '48201', '2024-07-20'),
('Tool Makers Inc.', 'AABIJ1234M', '33ABCDE8765F3K2', 'info@toolmakers.com', 'password234', '2109876543', '7890123456', '505 Tool Lane', '', 'Georgia', 'Atlanta', 'Near Tool Center', '30301', '2024-08-25'),
('Device World LLC', 'AABJK2345N', '44FGHI0987L5N4', 'contact@deviceworld.com', 'password567', '1098765432', '8901234567', '606 Device Plaza', 'Suite 8A', 'Arizona', 'Phoenix', 'Adjacent to Device Tower', '85001', '2024-09-30'),
('Component city Corp.', 'AABKL3456O', '55JKLM6543P2Q8', 'service@componentcity.com', 'password890', '9876543210', '9012345678', '707 Component Road', 'Unit 6C', 'Washington', 'Seattle', 'Near Component HQ', '98101', '2024-10-15');


INSERT INTO orderDetails (customerId, productId, productName, productQuantity, productType, dateOfOrder, totalAmount, invoiceUrl
) VALUES 
('B2BCID0001','B2BPID0001', 'Widget X', 10, 'Electronics', '2024-08-30', 5000.00, 'https://example.com/invoice/inv001.pdf'),
('B2BCID0002', 'B2BPID0002', 'Gadget Y', 5,  'Accessories', '2024-08-29', 3000.50, 'https://example.com/invoice/inv002.pdf'),
('B2BCID0003', 'B2BPID0003', 'Tool Z',   20, 'Hardware', '2024-08-28', 7500.75, 'https://example.com/invoice/inv003.pdf'),
('B2BCID0004', 'B2BPID0004', 'Device A', 15, 'Electronics', '2024-08-27', 12000.00, 'https://example.com/invoice/inv004.pdf'),
('B2BCID0005', 'B2BPID0005', 'Component B', 50, 'Components', '2024-08-26', 2500.00, 'https://example.com/invoice/inv005.pdf'),
('B2BCID0006', 'B2BPID0006', 'Widget C', 30, 'Electronics', '2024-08-25', 9000.00, 'https://example.com/invoice/inv006.pdf'),
('B2BCID0007', 'B2BPID0007', 'Gadget D', 25, 'Accessories', '2024-08-24', 6000.00, 'https://example.com/invoice/inv007.pdf'),
('B2BCID0008', 'B2BPID0008', 'Tool E',   40, 'Hardware', '2024-08-23', 8200.00, 'https://example.com/invoice/inv008.pdf'),
('B2BCID0009', 'B2BPID0009', 'Device F', 20, 'Electronics', '2024-08-22', 4500.00, 'https://example.com/invoice/inv009.pdf'),
('B2BCID0010', 'B2BPID0010', 'Component G', 35, 'Components', '2024-08-21', 1100.00, 'https://example.com/invoice/inv010.pdf');


INSERT INTO Product (productName, productImg, costPerUnit) VALUES
('MoongDal', 'moongdal_GradeA', '[{"grade": "Mysore MoongDal", "PricePerUnit": 116, "Image": "moongdal_GradeA"},
        {"grade": "Imported MoongDal", "PricePerUnit": 260, "Image": "moongdal_GradeB"},
        {"grade": "Desi MoongDal", "PricePerUnit": 128, "Image": "moongdal_GradeC"}]'),
('ToorDal', 'toordal_GradeC', '[{"grade": "Fatka ToorDal", "PricePerUnit": 215, "Image": "toordal_GradeC"},
        {"grade": "Desi ToorDal", "PricePerUnit": 150, "Image": "toordal_GradeC"},
        {"grade": "Imported ToorDal", "PricePerUnit": 122, "Image": "toordal_GradeC"},
        {"grade": "Polished ToorDal", "PricePerUnit": 154, "Image": "toordal_GradeC"},
        {"grade": "Unpolished ToorDal", "PricePerUnit": 158, "Image": "toordal_GradeC"}]
'),
('UradDal', 'uraddal_GradeB', '[{"grade": "Black UradDal", "PricePerUnit": 100, "Image": "uraddal_GradeB"},
        {"grade": "Desi UradDal", "PricePerUnit": 60, "Image": "uraddal_GradeB"},
        {"grade": "Imported", "PricePerUnit": 110, "Image": "uraddal_GradeB"}]'),
('GramDal', 'gramdal_GradeB', '[{"grade": "Premium GramDal", "PricePerUnit": 191, "Image": "gramdal_GradeB"},
        {"grade": "Gold GramDal", "PricePerUnit": 125, "Image": "gramdal_GradeB"}]');



INSERT INTO Transactions (orderId, accountNo, transactionId, dateOfTransaction, transactionType, invoiceNo, amount, paymentMode, paymentStatus, paymentVerified, paymentApprovedDate
) VALUES 
('B2BHUB0001', 'ACC123456789', 'TXN001', '2024-08-30', 'credit', 'INV001', '5000.00', 'Credit Card', true, false, NULL),
('B2BHUB0002', 'ACC987654321', 'TXN002', '2024-08-29', 'credit', 'INV002', '3000.50', 'Debit Card', true, false, NULL),
('B2BHUB0004', 'ACC345678901', 'TXN004', '2024-08-27', 'credit', 'INV004', '12000.00', 'UPI', true, false, NULL),
('B2BHUB0005', 'ACC456789012', 'TXN005', '2024-08-26', 'credit', 'INV005', '2500.00', 'Credit Card', true, false, NULL),
('B2BHUB0006', 'ACC567890123', 'TXN006', '2024-08-25', 'credit', 'INV006', '9000.00', 'Debit Card', true, false, NULL),
('B2BHUB0008', 'ACC789012345', 'TXN008', '2024-08-23', 'credit', 'INV008', '8200.00', 'UPI', true, false, NULL),
('B2BHUB0010', 'ACC901234567', 'TXN010', '2024-08-21', 'credit', 'INV010', '1100.00', 'Debit Card', true, false, NULL);



													-- PROCEDURE--

 
-- DROP PROCEDURE IF EXISTS updateOrder;

-- DELIMITER //
-- CREATE PROCEDURE updateOrder(IN c_customerId VARCHAR(255))
-- BEGIN
--     UPDATE orderDetails o
--     JOIN Customer c ON c.customerId = o.customerId
--     SET o.address1 = c.address1, 
--         o.address2 = c.address2, 
--         o.state = c.state, 
--         o.city = c.city, 
--         o.pincode = c.pincode 
--     WHERE o.customerId = c_customerId;
-- END;
-- //
-- DELIMITER ;
-- CALL updateOrder('CUST001');