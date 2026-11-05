PuraMitra Plus – Smart Waste Management System

Project Overview

PuraMitra Plus is a smart waste management application designed to improve the process of reporting, managing, and resolving waste-related complaints.

The system connects citizens, government administrators, and sanitation workers through a single platform. Citizens can report waste problems by uploading photographs and sharing GPS locations. Administrators can review complaints and assign them to workers, while workers can update the progress of their assigned tasks.

The main objective is to make waste management more organized, transparent, and efficient.

Technologies Used

Frontend

- Flutter
- Dart

Backend

- Node.js
- Express.js

Database

- MongoDB
- Mongoose

Additional Technologies

- REST APIs
- GPS Location Services
- Image Upload
- Git and GitHub

Key Features

1. Citizen Module

- Citizen registration and login
- Report waste-related problems
- Select waste type
- Enter complaint description
- Upload photographs of waste
- Capture GPS location
- Submit complaints
- View previously submitted complaints
- Track complaint status

2. Admin Module

- Administrator login
- View all citizen complaints
- View complaint descriptions and photographs
- Access complaint locations using Google Maps
- Assign complaints to sanitation workers
- Reassign workers when necessary
- Monitor complaint progress
- View completion status

3. Worker Module

- Worker login
- View assigned complaints
- Check waste descriptions and photographs
- Start assigned work
- Update complaint status to In Progress
- Mark completed tasks as Completed

Complaint Management Workflow

1. A citizen registers or logs into the application.
2. The citizen reports a waste-related problem.
3. The citizen uploads a photograph and captures the GPS location.
4. The complaint is stored in MongoDB.
5. The administrator reviews the complaint.
6. The administrator assigns the complaint to a sanitation worker.
7. The worker views the assigned task.
8. The worker starts the work and updates its status.
9. After completing the task, the worker marks it as Completed.
10. The citizen can view the updated complaint status.

Complaint Status

The system uses the following statuses:

- Submitted: The citizen has submitted a complaint.
- Assigned: The administrator has assigned a worker.
- In Progress: The worker has started the task.
- Completed: The worker has finished the task.

Project Structure

puramitra_plus/
├── android/
├── backend/
│   ├── models/
│   ├── routes/
│   ├── uploads/
│   ├── server.js
│   └── package.json
├── ios/
├── lib/
│   └── main.dart
├── linux/
├── macos/
├── test/
├── web/
├── windows/
├── pubspec.yaml
└── README.md

How to Run the Project

Prerequisites

Install the following software:

- Flutter SDK
- Dart SDK
- Node.js
- MongoDB
- Visual Studio Code
- Google Chrome

Step 1: Clone the Repository

git clone https://github.com/rishitha-152006/puramitra-plus.git

Step 2: Open the Project

cd puramitra-plus

Step 3: Set Up the Backend

cd backend
npm install

Create a ".env" file inside the "backend" folder and configure your MongoDB connection, server port, and application secret.

Start the backend:

node server.js

Step 4: Run the Flutter Application

Open another terminal in the project root folder.

flutter pub get
flutter run -d chrome

Note: The application currently uses a locally hosted backend and MongoDB database. The backend must be running for the application's database features to work.

Future Enhancements

- Real-time complaint notifications
- Admin analytics dashboard
- Worker location tracking
- Complaint priority classification using AI
- Automatic waste detection from uploaded images
- Public cloud deployment

Project Objective

To develop a digital waste management platform that improves communication between citizens, administrators, and sanitation workers while supporting faster complaint resolution and better monitoring.

Developed By

N. Lakshmi Rishitha

B.Tech – Artificial Intelligence and Machine Learning

SRKR Engineering College, Bhimavaram

Project Status

Core citizen, admin, and worker complaint-management workflows implemented and tested locally.
