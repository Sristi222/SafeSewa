const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const db = require('../config/db');


const { Schema } = mongoose;

const userSchema = new Schema({
  username:{
    type:String,
    lowercase:true,
    required :true,
    unique: true
  },
    email:{
        type:String,
        lowercase:true,
        required :true,
        unique: true
    },
    password:{
        type:String,
        required:true
    }
});

//to encrypt the password
userSchema.pre('save',async function(){
    try{
        var user = this;
        const salt = await(bcrypt.genSalt(10));
        const hashpass = await bcrypt.hash(user.password,salt);//

        user.password = hashpass;

    } catch (error){
        throw error;
    }
});

//create a function for login
userSchema.methods.comparePassword = async function(userPassword){
    try{
        const isMathch = await bcrypt.compare(userPassword, this.password);// compare both the password in database and the user entered while login
        return isMathch;
    }catch (e){
        throw error;
    }
}
const userModel = db.model('user',userSchema);

module.exports = userModel;

//compare password with the help of schema for login using mongoose with the help of bcrypt