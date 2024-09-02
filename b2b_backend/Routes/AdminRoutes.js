const express = require("express");
const router = express.Router();
const connection = require("../database");
const Queries = require("../SQL/Queries/Queries.json");


router.put('/payVerify/:OrderId', async(req, res) => {
    try{
    const OrderId = req.params.OrderId;
    const PaymentVerified = req.body.PaymentVerified;
    await connection.query(Queries.transactionQueries.getTransactionTable, [PaymentVerified, OrderId]);
    res.send({message:"Updated"})
} catch(err){
    console.log(err)
}

});


router.post('/addProduct',async(req, res) => {
    try{
      await connection.query(Queries.productQueries.createProductTable);
      const{ProductName, Cost, SubCategory, offer} = req.body;
      for(const productData of req.body){
        await connection.query(Queries.productQueries.insertIntoProductTable, [productData.ProductName, productData.Cost, productData.SubCategory, productData.offer]);
    }
    res.send({message:"Products added Successfully"})
    } catch(err){
        console.log(err)
    }
})



router.get('/getTransaction/:transId', async(req, res) => {
    try{
    const transId = req.params.transId;
    const result = await connection.query(Queries.transactionQueries.getTransactionTableByTransId, [transId]);
    res.send(result)
} catch(err){
    console.log(err)
}
});


// router.post('/createShipment/:OrderId', async(req, res) => {
//     try{
//     await connection.query(shipment.createShipment);
//     const OrderId = req.params.OrderId;
//     const ProductName = req.body.ProductName;
//     const ShippingAddress = req.body.ShippingAddress;
//     const orderQuery = "SELECT orderId FROM orderDetails WHERE payment_status = 1 and payment_verified = 1 ORDER BY orderId DESC LIMIT 1";
//     if (orderQuery.length === 0) {
//         return res.status(400).send({ message: "No pending orders found" });
//     }
//     await connection.query(shipment.insertShipment, [OrderId, ProductName, ShippingAddress]);
//     res.send({message:"Shipment created"})
// } catch(err){
//     console.log(err)
// }
// });
    
module.exports = router;