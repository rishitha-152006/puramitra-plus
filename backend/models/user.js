const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
    },

    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },

    mobile: {
      type: String,
      required: false,
      trim: true,
    },

    password: {
      type: String,
      required: true,
    },

    // User role
    role: {
      type: String,
      enum: ["citizen", "admin", "worker"],
      default: "citizen",
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("User", userSchema);