const UserServices = require("../services/user.services");

exports.register = async (req, res, next) => {
  try {
    const { username, email, password, phone, role } = req.body;
    let isApproved = role === "User"; // Volunteers need admin approval

    const newUser = await UserServices.registerUser(username, email, password, phone, role, isApproved);

    res.json({ status: true, message: "User registered successfully" });
  } catch (error) {
    next(error);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    console.log(`📡 Login attempt: ${email}`);

    const user = await UserServices.checkUser(email);
    if (!user) {
      console.log("❌ Admin not found!");
      return res.status(400).json({ status: false, error: "User does not exist" });
    }

    console.log("✅ User found:", user.email, "Role:", user.role);

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      console.log("❌ Incorrect password for:", user.email);
      return res.status(400).json({ status: false, error: "Invalid password" });
    }

    console.log("✅ Password matched for:", user.email);

    const tokenData = { _id: user._id, email: user.email, role: user.role };
    const token = await UserServices.generateToken(tokenData, process.env.JWT_SECRET, "3h");

    res.status(200).json({
      status: true,
      message: "Login successful",
      userId: user._id,
      token,
      role: user.role,
    });
  } catch (error) {
    console.error("❌ Error during login:", error);
    res.status(500).json({ status: false, error: "Internal server error" });
  }
};

exports.getPendingVolunteers = async (req, res) => {
  try {
    console.log("📡 API Call: /volunteers/pending");
    console.log("🔑 Token received:", req.headers.authorization);

    const volunteers = await UserServices.getPendingVolunteers(); // Use service function

    if (!volunteers.length) {
      return res.status(404).json({ status: false, error: "No pending volunteers" });
    }

    console.log(`✅ Found ${volunteers.length} pending volunteers`);
    res.json({ status: true, volunteers });
  } catch (error) {
    console.error("❌ Error fetching volunteers:", error);
    res.status(500).json({ status: false, error: "Server error" });
  }
};



exports.approveVolunteer = async (req, res) => {
  try {
    const volunteerId = req.params.id;

    console.log(`📡 API Call: Approving Volunteer ID: ${volunteerId}`);

    const volunteer = await User.findById(volunteerId);
    if (!volunteer) {
      return res.status(404).json({ status: false, error: "Volunteer not found" });
    }

    // ✅ Update the isApproved field to true
    volunteer.isApproved = true;
    await volunteer.save();

    console.log(`✅ Volunteer ${volunteerId} approved successfully!`);
    res.json({ status: true, message: "Volunteer approved successfully" });
  } catch (error) {
    console.error("❌ Error approving volunteer:", error);
    res.status(500).json({ status: false, error: "Server error while approving" });
  }
};


// Ensure these functions are defined
exports.getVolunteers = async (req, res) => {
  const volunteers = await UserServices.getPendingVolunteers();
  res.json(volunteers);
};

exports.approveVolunteer = async (req, res) => {
  await UserServices.approveVolunteer(req.params.id);
  res.json({ success: true, message: "Volunteer approved" });
};