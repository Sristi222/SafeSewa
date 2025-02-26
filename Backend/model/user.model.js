const mongoose = require("mongoose");
const bcrypt = require("bcrypt");

const UserSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  phone: { type: String, required: true, unique: true },
  password: { type: String, required: true, minlength: 6 },
  role: { type: String, enum: ["User", "Volunteer", "Admin"], default: "User" },
  isApproved: { type: Boolean, default: false }, // Only applies to volunteers
});

// Hash Password before saving (except for Admin)
UserSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  if (this.role === "Admin") return next(); // Skip hashing for Admin
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (error) {
    return next(error);
  }
});

// ✅ Compare Passwords (Fix issue where Admin password is stored in plain text)
UserSchema.methods.comparePassword = async function (enteredPassword) {
  if (this.role === "Admin") {
    return enteredPassword === this.password; // Direct comparison for Admin
  }
  return bcrypt.compare(enteredPassword, this.password);
};

const User = mongoose.model("User", UserSchema);

async function createAdminIfNotExists() {
  const adminEmail = "admin03@gmail.com";
  const adminPassword = "admin123"; // Admin password stored in plain text

  const existingAdmin = await User.findOne({ email: adminEmail });

  if (!existingAdmin) {
    console.log("🔹 Admin not found, creating one...");
    const adminUser = new User({
      username: "Admin",
      email: adminEmail,
      phone: "0000000000",
      password: adminPassword, // Store password without hashing for Admin
      role: "Admin",
      isApproved: true, // Admins don't need approval
    });
    await adminUser.save();
    console.log("✅ Admin user created successfully!");
  } else {
    console.log("✅ Admin user already exists.");
  }
}

module.exports = { User, createAdminIfNotExists };
