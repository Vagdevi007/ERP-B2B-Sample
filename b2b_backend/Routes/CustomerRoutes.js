const express = require("express");
const router = express.Router();
const connection = require("../database");
const createQueries = require("../Queries/Customer/createQueries");
const getQueries = require("../Queries/Customer/getQueries");
const updateQueries = require("../Queries/Customer/updateQueries");
const OrderCreate = require("../Queries/Order/createQueries");
const OrderGet = require("../Queries/Order/getQueries");



router.post('/customerreg', async (req, res) => {
    try {
        await connection.query(createQueries.createUserTable);
        const { CompanyName, PAN, GSTNo, Email,Password, MobileNo, TelephoneNo, Address1, Address2,State,City, PinCode, DateOfReg } = req.body;
        const formatDate = DateOfReg ? new Date(DateOfReg).toISOString().split('T')[0] : new Date().toISOString().split('T')[0];

        const [lastCustomer] = await connection.query("SELECT CustomerId FROM Customer ORDER BY CustomerId DESC LIMIT 1");
        let newCustomerId = "B2BCID0001";
        if (lastCustomer.length > 0) {
            const latestCustomerId = lastCustomer[0].UserId;
            const currentIdNumber = parseInt(latestCustomerId.slice(-4));
            const newIdNumber = currentIdNumber + 1;
            newCustomerId = `B2BCID${String(newIdNumber).padStart(4, '0')}`;
        }
        await connection.query(createQueries.insertUserTable, [
            newCustomerId, CompanyName, PAN, GSTNo, Email,Password, MobileNo, TelephoneNo, Address1, Address2, City, State, PinCode, formatDate
        ]);
        res.send({ message: "Customer created successfully" });
    } catch (err) {
        console.error(err);
        res.status(500).send({ message: "User creation failed", error: err });
    }
});


router.route('/login/:pan/:pwd').get(async (req, res) => {
    try {
        const { pan, pwd } = req.params;
        const [user] = await connection.query(getQueries.getUserByPAN, [pan]);
        if (user.length === 0) {
            res.status(404).json({ message: "User not found" });
            return;
        }
        if (user[0].Password !== pwd) {
            res.status(401).json({ message: "Invalid password" });
            return;
        }
        res.status(200).json({
            message: 'Login successful',
            user: user
        });
    } catch (err) {
        res.status(500).json({ message: "Some error occurred" });
    }
});



router.put('/resetpassword/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { Password } = req.body;
        const [user] = await connection.query(getQueries.getUserId, [id]);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        user.Password = Password;
        await connection.query(updateQueries.updatePassword, [Password, id]);
        res.status(200).json({ message: 'Password reset successful. Check your email for the new password.' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

router.get('/getUser/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const [user] = await connection.query(getQueries.getUserId, [id]);
        if (user.length > 0) {
            res.send(user[0]);
        } else {
            res.status(404).send({ message: "User not found" });
        }
    } catch (err) {
        console.error(err);
        res.status(500).send({ message: "Internal server error" });
    }
});


router.post('/orders', async (req, res) => {
    try {
        await connection.query(OrderCreate.createOrderTable);
        const {
            UserId, OrderDate, TotalAmount,  ExpectedDDate, ActualDDate,Address1, Address2, MobileNo, City, State, PinCode
        } = req.body;

        const formatDate = OrderDate? new Date(OrderDate).toISOString().split('T')[0] : new Date().toISOString().split('T')[0];
        const [lastOrder] = await connection.query("SELECT OrderId FROM Orders ORDER BY OrderId DESC LIMIT 1");
        let newOrderId = "B2BOID0001";
        if (lastOrder.length > 0) {
            const latestOrderId = lastOrder[0].OrderId;
            const currentIdNumber = parseInt(latestOrderId.slice(-4));
            const newIdNumber = currentIdNumber + 1;
            newOrderId = `B2BOID${String(newIdNumber).padStart(4, '0')}`;
        }
        await connection.query(OrderCreate.insertOrderTable, [
            newOrderId, UserId, formatDate, TotalAmount ,ExpectedDDate, ActualDDate,Address1, Address2, MobileNo, City, State, PinCode
        ])
        
    } catch (err) {
        console.error(err);
        res.status(500).send({ message: "Order creation failed", error: err });
    }
});



router.get('/orders/:id', async (req, res) => {
    const { id } = req.params;
    try{
        const [order] = await connection.query(OrderGet.getOrderId, [id]);
        if (order.length > 0) {
            res.send(order[0]);
        } else {
            res.status(404).send({ message: "Order not found" });
        }
    } catch (err) {
        console.error(err);
        res.status(500).send({ message: "Internal server error" });
    }
});


// router.post('/transaction/:orderId', async (req, res) => {
//     try {
//         await connection.query(createQueries.createTransTable);

//         const { orderId } = req.params;
//         const OrderId = orderId;

//         const { InvoiceNumber, InvoiceDate, TotalAmount, AccountNo, PaymentMode, PaymentDate, PaymentStatus } = req.body;
//         const orderIDQuery = "SELECT order_id FROM orderDetails WHERE payment_status = 0 ORDER BY order_id DESC LIMIT 1";
//         const [lastOrder] = await connection.query(orderIDQuery);
        
//         if (lastOrder.length === 0) {
//             return res.status(400).send({ message: "No pending orders found" });
//         }

//         const userIDQuery = "SELECT customerId FROM orderDetails WHERE order_id = ? AND payment_status = 0";
//         const [user] = await connection.query(userIDQuery, [OrderId]);

//         if (user.length === 0) {
//             return res.status(404).send({ message: "User not found for the given OrderId" });
//         }

//         const UserId = user[0].UserId;

//         const TransId = `UTR${Math.random().toString(36).substring(2, 9).toUpperCase()}`;
//         await connection.query(createQueries.insertTransTable, [
//             UserId, OrderId, InvoiceNumber, InvoiceDate, TotalAmount, AccountNo, PaymentMode, PaymentDate, PaymentStatus, TransId
//         ]);
//         await connection.query("UPDATE Transactions SET PaymentStatus = 1 WHERE OrderId = ?", [OrderId]);
//         await connection.query("UPDATE Orders SET PaymentStatus = 1 WHERE OrderId = ?", [OrderId]);

//         res.send({ message: "Transaction created successfully" });

//     } catch (err) {
//         console.error(err);
//         res.status(500).send({ message: "Transaction creation failed", error: err });
//     }
// });


router.post('/bookorder/:customerid', async (req, res) => {
    try {
        const createTableQuery = `
        CREATE TABLE IF NOT EXISTS orderDetails (
            order_id VARCHAR(255) PRIMARY KEY,
            CustomerId varchar(255),
            phone_no VARCHAR(13),
            address1 VARCHAR(255),
            address2 VARCHAR(255),
            city VARCHAR(255),
            state VARCHAR(255),
            email VARCHAR(255),
            landmark VARCHAR(255),
            zip_code VARCHAR(255),
            gst_no VARCHAR(255),
            requested_sample BOOLEAN,
            date_of_order VARCHAR(25),
            delivery_status BOOLEAN,
            payment_status BOOLEAN default false,
            product_name VARCHAR(255),
            product_quantity INT,
            product_type VARCHAR(255),
            total_amount DECIMAL(15, 2),
            payment_verified BOOLEAN,
            invoiceUrl VARCHAR(255)
        )`;

        await connection.query(createTableQuery);

        const customerId = req.params.customerid;

        const {
            phone_no, address1, address2, city, state, email, landmark, zip_code, gst_no, requested_sample,
            delivery_status, product_name, product_quantity, product_type, total_amount,payment_verified,invoiceUrl
        } = req.body;

        const customerIdQuery = "SELECT * FROM Customer WHERE CustomerId = ?";
        if (customerIdQuery.length === 0) {
            return res.status(404).send({ error: "Customer not found" });
        }
        if (!phone_no || !address1 || !address2 || !city || !state || !email || !landmark || !zip_code || !gst_no || typeof requested_sample !== 'boolean' || typeof delivery_status !== 'boolean' || !product_name || !product_quantity || !product_type || !total_amount) {
            return res.status(400).send({ error: "All fields are required and must be valid." });
        }

        const [rows] = await connection.query('SELECT order_id FROM orderDetails ORDER BY order_id DESC LIMIT 1');
        let newOrderId = "B2BHUB000001";

        if (rows.length > 0) {
            const latestOrderId = rows[0].order_id;
            const currentIdNumber = parseInt(latestOrderId.slice(-6));
            const newIdNumber = currentIdNumber + 1;
            newOrderId = `B2BHUB${String(newIdNumber).padStart(6, '0')}`;
        }

        const insertQuery = `
        INSERT INTO orderDetails (
            order_id, customerId, phone_no, address1, address2, city, state, email, landmark, zip_code, gst_no, requested_sample,date_of_order,
            delivery_status, product_name, product_quantity, product_type, total_amount,payment_verified,invoiceUrl
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?, ?, ?, ?,?)`;


        function getCurrentDateWithoutTime() {
            const date = new Date();
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            return `${year}-${month}-${day}`;
        }
        

        await connection.execute(insertQuery, [
            newOrderId, customerId, phone_no, address1, address2, city, state, email, landmark, zip_code, gst_no, requested_sample,getCurrentDateWithoutTime(),
            delivery_status, product_name, product_quantity, product_type, total_amount,payment_verified,invoiceUrl
        ])
        //await sendMail(email, companyname, total_amount, product_quantity, product_name, total_amount,product_quantity, invoiceUrl);
        .then(()=>{connection.query(`CALL updateOrder${newOrderId}`)
            res.send({ message: "Order created successfully" });
        })
        res.status(201).send({ message: "Order added to cart." });
    } catch (error) {
        console.error("Error in cart:", error);
        return res.status(500).send({ error: "Internal server error." });
    }
});


router.get("/getorders", async (req, res) => {
    try {
        const query = `SELECT * FROM orderDetails`;
        const result = await connection.query(query);
        return res.status(200).send(result[0]);
    } catch (error) {
        console.log("Error in the getorders ", error);
        return res.status(500).send({
            error: "Internal Server error..."
        })
    }
})


router.get("/getorder/:orderId", async (req, res) => {
    try {
        const order_id = req.params.orderId;
        const query = `SELECT * FROM orderDetails WHERE order_id = ?`;
        const result = await connection.query(query, [order_id]);
        return res.status(200).send(result[0]);
    } catch (error) {
        console.log("Error in the getorders ", error);
        return res.status(500).send({
            error: "Internal Server error..."
        })
    }
});


router.post('/transaction/:orderid', async (req, res) => {
    try {
        await connection.query(createQueries.createTransTable);
        const { orderid } = req.params;
        const OrderId = orderid;
        let { accountNo, dateOfTransaction, transactionType, invoiceNo, Amount, paymentMode, paymentStatus, paymentApprovedDate } = req.body;
        if (!transactionType) {
            transactionType = 'credit';
        }

        const formatDate = dateOfTransaction ? new Date(dateOfTransaction).toISOString().split('T')[0] : new Date().toISOString().split('T')[0];

        const orderIDQuery = "SELECT order_id FROM orderDetails WHERE payment_status = 0 ORDER BY order_id DESC LIMIT 1";
        const [lastTransaction] = await connection.query("SELECT transactionId FROM Transactions ORDER BY transactionId DESC LIMIT 1");
        
        let newTransId = "TRNB2B0001";
        if (lastTransaction.length > 0) {
            const latestTransactionId = lastTransaction[0].transactionId;
            const currentIdNumber = parseInt(latestTransactionId.slice(-4));
            const newIdNumber = currentIdNumber + 1;
            newTransId = `TRNB2B${String(newIdNumber).padStart(4, '0')}`;
        }
        
        const [lastOrder] = await connection.query(orderIDQuery);
        if (lastOrder.length === 0) {
            return res.status(400).send({ message: "No pending orders found" });
        }

        const TransactionId = `UTR${Math.random().toString(36).substring(2, 9).toUpperCase()}`;
        await connection.query(createQueries.insertTransTable, [newTransId, OrderId, accountNo, TransactionId, formatDate, transactionType, invoiceNo, Amount, paymentMode, paymentStatus, paymentApprovedDate]);
        await connection.query("UPDATE Transactions SET paymentStatus = 1 WHERE orderId = ?", [OrderId]);
        await connection.query("UPDATE orderDetails SET payment_status = 1 WHERE order_id = ?", [OrderId]);

        res.send({ message: "updated" });
    } catch (err) {
        console.log(err);
        res.status(500).send({ message: "Internal server error" });
    }
});


module.exports = router;




