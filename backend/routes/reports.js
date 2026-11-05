const express = require("express");
const router = express.Router();

const multer = require("multer");
const path = require("path");
const fs = require("fs");

const Report = require("../models/report");

// ======================================================
// CREATE UPLOADS FOLDER IF IT DOES NOT EXIST
// ======================================================

const uploadFolder = path.join(__dirname, "..", "uploads");

if (!fs.existsSync(uploadFolder)) {
  fs.mkdirSync(uploadFolder, { recursive: true });
}

// ======================================================
// IMAGE UPLOAD SETTINGS
// ======================================================

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadFolder);
  },

  filename: function (req, file, cb) {
    const extension = path.extname(file.originalname).toLowerCase();

    const uniqueName =
      Date.now() +
      "-" +
      Math.round(Math.random() * 1000000) +
      extension;

    cb(null, uniqueName);
  },
});

// ======================================================
// IMAGE FILE FILTER
// ======================================================

const fileFilter = function (req, file, cb) {
  const extension = path
    .extname(file.originalname)
    .toLowerCase();

  const allowedExtensions = [
    ".jpg",
    ".jpeg",
    ".png",
    ".webp",
  ];

  if (allowedExtensions.includes(extension)) {
    cb(null, true);
  } else {
    cb(
      new Error(
        "Only JPG, JPEG, PNG and WEBP image files are allowed"
      )
    );
  }
};

// ======================================================
// MULTER
// ======================================================

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5 MB
  },
});

// ======================================================
// GET ALL REPORTS
// ======================================================

router.get("/", async (req, res) => {
  try {
    const reports = await Report.find()
      .sort({ createdAt: -1 });

    res.json(reports);
  } catch (error) {
    console.error("GET REPORTS ERROR:", error);

    res.status(500).json({
      message: "Failed to fetch reports",
    });
  }
});

// ======================================================
// GET REPORTS OF ONE USER
// ======================================================

router.get("/user/:userId", async (req, res) => {
  try {
    const reports = await Report.find({
      userId: req.params.userId,
    }).sort({
      createdAt: -1,
    });

    res.json(reports);
  } catch (error) {
    console.error("USER REPORTS ERROR:", error);

    res.status(500).json({
      message: "Failed to fetch user reports",
    });
  }
});

// ======================================================
// CREATE NEW WASTE REPORT
// IMPORTANT: Flutter sends field name "photo"
// ======================================================

router.post(
  "/",
  upload.single("photo"),
  async (req, res) => {
    try {
      console.log("========== NEW WASTE REPORT ==========");

      console.log("Body:", req.body);

      if (req.file) {
        console.log("Uploaded file:", req.file.filename);
        console.log("File type:", req.file.mimetype);
      } else {
        console.log("No photo uploaded");
      }

      const {
        userId,
        wasteType,
        description,
        latitude,
        longitude,
      } = req.body;

      // ==================================================
      // CHECK REQUIRED FIELDS
      // ==================================================

      if (
        !userId ||
        !wasteType ||
        !description ||
        latitude === undefined ||
        longitude === undefined
      ) {
        return res.status(400).json({
          message: "Please provide all required fields",
        });
      }

      // ==================================================
      // CREATE REPORT
      // ==================================================

      const report = new Report({
        userId: userId,

        wasteType: wasteType,

        description: description,

        latitude: Number(latitude),

        longitude: Number(longitude),

        image: req.file
          ? `/uploads/${req.file.filename}`
          : null,

        status: "Submitted",
      });

      // ==================================================
      // SAVE TO MONGODB
      // ==================================================

      await report.save();

      console.log("Report saved successfully");

      // ==================================================
      // SEND RESPONSE
      // ==================================================

      res.status(201).json({
        message: "Waste report submitted successfully",
        report: report,
      });

    } catch (error) {
      console.error("SUBMIT REPORT ERROR:", error);

      res.status(500).json({
        message: "Failed to submit report",
        error: error.message,
      });
    }
  }
);

// ======================================================
// MULTER ERROR HANDLING
// ======================================================

router.use((error, req, res, next) => {

  if (error instanceof multer.MulterError) {

    console.error("MULTER ERROR:", error);

    if (error.code === "LIMIT_FILE_SIZE") {
      return res.status(400).json({
        message: "Image size must be less than 5 MB",
      });
    }

    if (error.code === "LIMIT_UNEXPECTED_FILE") {
      return res.status(400).json({
        message:
          "Unexpected image field. Please upload the image correctly.",
      });
    }

    return res.status(400).json({
      message: error.message,
    });
  }

  if (error) {
    console.error("UPLOAD ERROR:", error);

    return res.status(400).json({
      message: error.message,
    });
  }

  next();
});

// ======================================================
// EXPORT
// ======================================================


// ======================================================
// UPDATE REPORT STATUS
// ======================================================

router.put("/:id/status", async (req, res) => {
  try {
    const { status } = req.body;

    const allowedStatuses = [
      "Submitted",
      "In Progress",
      "Completed",
    ];

    if (!allowedStatuses.includes(status)) {
      return res.status(400).json({
        message: "Invalid status",
      });
    }

    const report = await Report.findByIdAndUpdate(
      req.params.id,
      {
        status: status,
      },
      {
        new: true,
      }
    );

    if (!report) {
      return res.status(404).json({
        message: "Report not found",
      });
    }

    res.json({
      message: "Report status updated successfully",
      report: report,
    });
  } catch (error) {
    console.error("STATUS UPDATE ERROR:", error);

    res.status(500).json({
      message: "Failed to update report status",
    });
  }
});
// ======================================================
// GET ALL WORKERS
// ======================================================

router.get("/workers", async (req, res) => {
  try {
    const User = require("../models/user");

    const workers = await User.find({
      role: "worker",
    }).select("_id name email mobile");

    res.json(workers);
  } catch (error) {
    console.error("GET WORKERS ERROR:", error);

    res.status(500).json({
      message: "Failed to fetch workers",
    });
  }
});


// ======================================================
// ASSIGN COMPLAINT TO WORKER
// ======================================================

router.put("/:id/assign", async (req, res) => {
  try {
    const { workerId } = req.body;

    if (!workerId) {
      return res.status(400).json({
        message: "Worker ID is required",
      });
    }

    const User = require("../models/user");

    const worker = await User.findOne({
      _id: workerId,
      role: "worker",
    });

    if (!worker) {
      return res.status(404).json({
        message: "Worker not found",
      });
    }

    const report = await Report.findByIdAndUpdate(
      req.params.id,
      {
        workerId: worker._id,
        workerName: worker.name,
        status: "Assigned",
        assignedAt: new Date(),
      },
      {
        new: true,
      }
    );

    if (!report) {
      return res.status(404).json({
        message: "Complaint not found",
      });
    }

    res.json({
      message: "Complaint assigned successfully",
      report: report,
    });
  } catch (error) {
    console.error("ASSIGN WORKER ERROR:", error);

    res.status(500).json({
      message: "Failed to assign complaint",
    });
  }
});
module.exports = router;