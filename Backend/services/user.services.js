const userModel = require('../model/user.model');
const jwt = require('jsonwebtoken');

// Create UserServices class
class UserServices {
  // Method to register a new user
  static async registerUser(username, email, password) {
    try {
      // Check if the email already exists
      const existingUser = await this.checkUser(email);
      if (existingUser) {
        throw new Error('User with this email already exists');
      }

      // Create and save a new user
      const createUser = new userModel({ username, email, password });
      return await createUser.save();
    } catch (err) {
      throw err;
    }
  }

  // Method to check if a user exists in the database
  static async checkUser(email) {
    try {
      return await userModel.findOne({ email }); // Retrieve user by email
    } catch (error) {
      throw error;
    }
  }

  // Method to generate a JWT token
  static async generateToken(tokenData, secretKey, expiresIn) {
    try {
      // Ensure `expiresIn` is provided correctly as part of the options object
      return jwt.sign(tokenData, secretKey, { expiresIn });
    } catch (error) {
      throw error;
    }
  }
}

module.exports = UserServices; // Export the class