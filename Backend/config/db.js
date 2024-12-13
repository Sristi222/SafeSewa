const mongoose = require ('mongoose');

const connection = mongoose.createConnection('mongodb://localhost:27017/newauth').on('open',()=>{
    console.log("MongoDb Connected")
}).on('error',()=>{
    console.log("Mongodb connection error")
})

module.exports = connection;