// Import services
const UserServices = require("../services/user.services");

exports.register = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const successRes = await UserServices.registerUser(email, password);

    res.json({ status: true, success: "User registered Successfully" });
  } catch (error) {
    next(error); // Pass the error to middleware
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    console.log("------ Password entered:", password);

    // Check if the user exists
    const user = await UserServices.checkUser(email);
    console.log("-------------- User retrieved:", user);

    if (!user) {
      throw new Error("User does not exist");
    }

    // Compare passwords
    const isMatch = await user.comparePassword(password);
    console.log("Password Match:", isMatch);

    if (!isMatch) {
      throw new Error("Password InValid");
    }

    // Generate a token
    const tokenData = { _id: user._id, email: user.email };
    const token = await UserServices.generateToken(tokenData, "secretKey", "3h");

    res.status(200).json({ status: true, token });
  } catch (error) {
    console.error("Error during login:", error.message);
    next(error); // Forward the error to middleware
  }
};
