const express = require("express");
const bcrypt = require("bcryptjs");

const User = require("../models/user");

const router = express.Router();

// ===============================
// REGISTER
// ===============================

router.post("/register", async (req, res) => {
  try {
    const { name, email, password, role } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        message: "Please fill all fields",
      });
    }

    // Allow only citizen or worker registration
    const selectedRole = role || "citizen";

    if (!["citizen", "worker"].includes(selectedRole)) {
      return res.status(400).json({
        message: "Invalid registration role",
      });
    }

    const normalizedEmail = email.toLowerCase().trim();

    const existingUser = await User.findOne({
      email: normalizedEmail,
    });

    if (existingUser) {
      return res.status(400).json({
        message: "Email already registered",
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = new User({
      name: name.trim(),
      email: normalizedEmail,
      password: hashedPassword,
      role: selectedRole,
      status: selectedRole === "worker" ? "pending" : "approved",
    });

    await user.save();

    res.status(201).json({
      message:
        selectedRole === "worker"
          ? "Worker account created. Waiting for admin approval."
          : "Citizen account created successfully.",
      user: {
        id: user._id.toString(),
        name: user.name,
        email: user.email,
        role: user.role,
        status: user.status,
      },
    });

  } catch (error) {
    console.error("REGISTER ERROR:", error);

    res.status(500).json({
      message: "Server error during registration",
    });
  }
});


// ===============================
// LOGIN
// ===============================

router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        message: "Please enter email and password",
      });
    }

    const normalizedEmail = email.toLowerCase().trim();

    const user = await User.findOne({
      email: normalizedEmail,
    });

    if (!user) {
      return res.status(401).json({
        message: "Invalid email or password",
      });
    }

    const passwordMatch = await bcrypt.compare(
      password,
      user.password
    );

    if (!passwordMatch) {
      return res.status(401).json({
        message: "Invalid email or password",
      });
    }

    // Check worker approval
    if (user.role === "worker" && user.status !== "approved") {
      return res.status(403).json({
        message: "Your worker account is waiting for admin approval.",
      });
    }

    res.status(200).json({
      message: "Login successful",
      user: {
        id: user._id.toString(),
        name: user.name,
        email: user.email,
        role: user.role,
        status: user.status,
      },
    });

  } catch (error) {
    console.error("LOGIN ERROR:", error);

    res.status(500).json({
      message: "Server error during login",
    });
  }
});

module.exports = router;
