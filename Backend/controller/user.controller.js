//import services to make use of function
const UserServices = require("../services/user.services");

exports.register = async(req,res,next)=>{
    try{
        const {email,password} = req.body;

        const successRes = await UserServices.registerUser(email,password);

        res.json({status:true,success:"User registered Successfully"});
    }
    catch (error){
        throw error
    }
}

exports.login = async(req,res,next)=>{//request is the data from frontend and responce is the data from backend
    try{
        const {email,password} = req.body;
        console.log("------",password);

       const user = await UserServices.checkUser(email);
        console.log("--------------user-------------",user);
       if(!user){
        throw new Error('User dont exist');
       }

       const isMatch = await user.comparePassword(password);//it will give password from the database that user enters to Schema in user.model
       if(isMatch == false){
        throw new Error("Password InValid");
       }

       let tokenData = {_id:user._id,email:user.email};//jwttokent packag eused
       
       const token = await UserServices.generateToken(tokenData,"secrestKey",'3h')
       res.status(200).json({status:true,token:token})
    }
    catch (error){
        throw error
        next(error);
    }
}

