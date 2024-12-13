//Create express server//
const app = require("./app");//import app.js
const db = require("./config/db");
const UserModel = require('./model/user.model');

const port = 3000;

app.get('/',(req,res)=>{//create a get request then route to a root folder and decleare as a function
    res.send("Hello World !!!")
})



app.listen(port,()=>{
    console.log('port running on http://localhost:'+port)
})

