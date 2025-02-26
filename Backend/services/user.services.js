const { User } = require("../model/user.model");
const jwt = require("jsonwebtoken");

class UserServices {
  // ✅ Register a new user (Ensures Admins, Volunteers, and Users are correctly handled)
  static async registerUser(username, email, password, phone, role) {
    try {
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        throw new Error("User with this email already exists");
      }

      const isApproved = role === "User"; // Volunteers need admin approval

      const newUser = new User({ username, email, password, phone, role, isApproved });
      return await newUser.save();
    } catch (err) {
      throw err;
    }
  }

  // ✅ Check if a user exists (Used in Login)
  static async checkUser(email) {
    try {
      return await User.findOne({ email }); // Fetch user details by email
    } catch (error) {
      throw error;
    }
  }

  // ✅ Generate a JWT token
  static async generateToken(tokenData, secretKey, expiresIn) {
    try {
      return jwt.sign(tokenData, secretKey, { expiresIn });
    } catch (error) {
      throw error;
    }
  }

  
  // ✅ Get Pending Volunteers (For Admin Approval)
static async getPendingVolunteers() {
  try {
    console.log("📡 Fetching unapproved volunteers...");

    const volunteers = await User.find(
      { role: "Volunteer", isApproved: false }, // ✅ Corrected Query
      "username email phone"
    );

    console.log(`✅ Found ${volunteers.length} pending volunteers.`);
    return volunteers;
  } catch (error) {
    console.error("❌ Error retrieving volunteers:", error);
    throw error;
  }
}

  // ✅ Approve Volunteer (Admin Action)
  static async approveVolunteer(userId) {
    try {
      return await User.findByIdAndUpdate(userId, { isApproved: true }, { new: true });
    } catch (error) {
      throw error;
    }
  }
}

module.exports = UserServices;
