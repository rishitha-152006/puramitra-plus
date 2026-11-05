const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
require("dotenv").config();

const User = require("./models/user");

async function createUsers() {
  try {
    await mongoose.connect(process.env.MONGO_URI);

    console.log("MongoDB connected");

    // ===============================
    // ADMIN
    // ===============================

    const adminPassword = await bcrypt.hash("admin123", 10);

    await User.findOneAndUpdate(
      { email: "admin@puramitra.com" },
      {
        name: "PuraMitra Admin",
        email: "admin@puramitra.com",
        password: adminPassword,
        role: "admin",
      },
      {
        upsert: true,
        new: true,
      }
    );

    // ===============================
    // WORKER
    // ===============================

    const workerPassword = await bcrypt.hash("worker123", 10);

    await User.findOneAndUpdate(
      { email: "worker@puramitra.com" },
      {
        name: "PuraMitra Worker",
        email: "worker@puramitra.com",
        password: workerPassword,
        role: "worker",
      },
      {
        upsert: true,
        new: true,
      }
    );

    console.log("Admin account created successfully");
    console.log("Worker account created successfully");

    await mongoose.disconnect();
  } catch (error) {
    console.error("ERROR:", error);
  }
}

createUsers();