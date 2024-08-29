const express = require("express");
const router = express.Router();
const connection = require("../database");
const paymentVerify = require("../Queries/Admin/updateQueries");
const shipment = require("../Queries/Order/createQueries");
const product = require("../Queries/Product/createQueries");


router.put('/payVerify/:OrderId', async(req, res) => {
    try{
    const OrderId = req.params.OrderId;
    const PaymentVerified = req.body.PaymentVerified;
    await connection.query(paymentVerify.paymentAcceptQuery, [PaymentVerified, OrderId]);
    res.send({message:"updated"})
} catch(err){
    console.log(err)
}

});


router.post('/addProduct',async(req, res) => {
    try{
      await connection.query(product.productTable);
      const{ProductName, Cost, SubCategory, offer} = req.body;

      const [lastProduct] = await connection.query("SELECT ProductId FROM Product ORDER BY ProductId DESC LIMIT 1");
      let newProductId = "B2BPID0000";
      let latestProductId = newProductId
      if (lastProduct.length > 0) {
        latestProductId = lastProduct[0].ProductId;
      }
      for(const productData of req.body){
        const currentIdNumber = parseInt(latestProductId.slice(-4));
        const newIdNumber = currentIdNumber + 1;
        newProductId = `B2BPID${String(newIdNumber).padStart(4, '0')}`;
        await connection.query(product.insertProductTable, [newProductId, productData.ProductName, productData.Cost, productData.SubCategory, productData.offer]);
        latestProductId = newProductId
    }
    res.send({message:"Products added Successfully"})
    } catch(err){
        console.log(err)
    }
})


router.get('/getTransaction/:transId', async(req, res) => {
    try{
    const transId = req.params.transId;
    const result = await connection.query(paymentVerify.getTransQuery, [transId]);
    res.send(result)
} catch(err){
    console.log(err)
}
});


router.post('/createShipment/:OrderId', async(req, res) => {
    try{
    await connection.query(shipment.createShipment);
    const OrderId = req.params.OrderId;
    const ProductName = req.body.ProductName;
    const ShippingAddress = req.body.ShippingAddress;
    const [lastShipment] = await connection.query("SELECT ShipmentId FROM Shipment ORDER BY ShipmentId DESC LIMIT 1");
        
    let newShipmentId = "SHPB2B0001";
    if (lastShipment.length > 0) {
        const latestShipmentId = lastShipment[0].transactionId;
        const currentIdNumber = parseInt(latestShipmentId.slice(-4));
        const newIdNumber = currentIdNumber + 1;
        newShipmentId = `SHPB2B${String(newIdNumber).padStart(4, '0')}`;
    }
    await connection.query(shipment.insertShipment, [ newShipmentId, OrderId, ProductName, ShippingAddress]);
    res.send({message:"Shipment created"})
} catch(err){
    console.log(err)
}
});
    
module.exports = router