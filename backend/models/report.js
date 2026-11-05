const mongoose = require("mongoose");

const reportSchema = new mongoose.Schema(
  {
    // Citizen who submitted the complaint
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },

    // Type of waste
    wasteType: {
      type: String,
      required: true,
    },

    // Citizen's description
    description: {
      type: String,
      required: true,
    },

    // Uploaded waste photo
    image: {
      type: String,
      default: null,
    },

    // GPS location
    latitude: {
      type: Number,
      default: null,
    },

    longitude: {
      type: Number,
      default: null,
    },

    // Complaint status
    status: {
      type: String,
      enum: [
        "Submitted",
        "Assigned",
        "In Progress",
        "Completed",
        "Rejected",
      ],
      default: "Submitted",
    },

    // Worker assigned by admin
    workerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },

    // Worker name
    workerName: {
      type: String,
      default: null,
    },

    // Admin note
    adminNote: {
      type: String,
      default: "",
    },

    // Assignment date
    assignedAt: {
      type: Date,
      default: null,
    },

    // Completion date
    completedAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Report", reportSchema);