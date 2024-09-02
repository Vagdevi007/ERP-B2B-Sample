const express = require("express");
const bodyParser = require("body-parser");
const app = express();
const b2bRoutes = require("./Routes/b2bRoutes");
const admin = require("./Routes/AdminRoutes");

app.use(bodyParser.json());

app.get('/test', (req, res) => {
    res.send("hell")
})

app.use('/b2b',b2bRoutes);
app.use('/admin',admin);

app.listen(4000, () => console.log("Server running on port 4000"))