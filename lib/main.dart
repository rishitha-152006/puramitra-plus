import 'dart:convert';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const PuraMitraPlusApp());
}

// ======================================================
// CONFIGURATION
// ======================================================

const String apiUrl = 'http://localhost:5000/api';

// ======================================================
// APP
// ======================================================

class PuraMitraPlusApp extends StatelessWidget {
  const PuraMitraPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PuraMitra Plus',
      theme: ThemeData(
        primaryColor: const Color(0xFF176B3A),
        scaffoldBackgroundColor: const Color(0xFFF4F8F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B3A),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

// ======================================================
// LOGIN PAGE
// ======================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool loading = false;

 Future<void> login() async {
  FocusScope.of(context).unfocus();

  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    showMessage('Please enter email and password');
    return;
  }

  setState(() {
    loading = true;
  });

  try {
    final response = await http.post(
      Uri.parse('$apiUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final user = data['user'];
      final role = user['role'];

      if (!mounted) return;

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminComplaintsPage(),
          ),
        );
      } else if (role == 'worker') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WorkerDashboard(
              userId: user['id'],
              userName: user['name'],
              email: user['email'],
            ),
          ),
        );
      } else if (role == 'citizen') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResidentDashboard(
              userId: user['id'],
              userName: user['name'],
              email: user['email'],
            ),
          ),
        );
      } else {
        showMessage('Invalid account role. Contact administrator.');
      }
    } else {
      showMessage(
        data['message'] ?? 'Login failed',
      );
    }
  } catch (e) {
    print('LOGIN ERROR: $e');

    showMessage('Cannot connect to backend. Please try again.');
  } finally {
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }
}

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      width: 85,
                      height: 85,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.recycling,
                        size: 52,
                        color: Colors.green.shade700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'PuraMitra Plus',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF176B3A),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Smart Waste Management System',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 30),

                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF176B3A),
                          foregroundColor: Colors.white,
                        ),
                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Color(0xFF176B3A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// REGISTER PAGE
// ======================================================
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  String selectedRole = 'citizen';

  Future<void> register() async {
    FocusScope.of(context).unfocus();

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty) {
      showMessage('Please enter your full name');
      return;
    }

    if (email.isEmpty) {
      showMessage('Please enter your email');
      return;
    }

    if (password.isEmpty) {
      showMessage('Please enter your password');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': selectedRole,
        }),
      );

      print('REGISTER STATUS: ${response.statusCode}');
      print('REGISTER RESPONSE: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        showMessage(
          selectedRole == 'worker'
              ? 'Worker account created. Waiting for admin approval.'
              : 'Citizen account created successfully.',
        );

        await Future.delayed(
          const Duration(seconds: 2),
        );

        if (!mounted) return;

        Navigator.pop(context);
      } else {
        showMessage(
          data['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      print('REGISTER ERROR: $e');

      showMessage('Cannot connect to backend');
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: const Color(0xFF176B3A),
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),

          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 450,
            ),

            child: Card(
              elevation: 6,

              child: Padding(
                padding: const EdgeInsets.all(25),

                child: Column(
                  children: [
                    const Icon(
                      Icons.person_add,
                      size: 60,
                      color: Color(0xFF176B3A),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Create Your Account',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ROLE SELECTION

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Register As',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: selectedRole,

                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),

                      items: const [
                        DropdownMenuItem(
                          value: 'citizen',
                          child: Text('Citizen'),
                        ),

                        DropdownMenuItem(
                          value: 'worker',
                          child: Text('Worker'),
                        ),
                      ],

                      onChanged: loading
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  selectedRole = value;
                                });
                              }
                            },
                    ),

                    const SizedBox(height: 15),

                    if (selectedRole == 'worker')
                      const Text(
                        'Worker accounts require admin approval before login.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 13,
                        ),
                      ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: ElevatedButton(
                        onPressed: loading ? null : register,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF176B3A),
                          foregroundColor: Colors.white,
                        ),

                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text('CREATE ACCOUNT'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ======================================================
// RESIDENT DASHBOARD
// ======================================================

class ResidentDashboard extends StatefulWidget {
  final String userId;
  final String userName;
  final String email;

  const ResidentDashboard({
    super.key,
    required this.userId,
    required this.userName,
    required this.email,
  });

  @override
  State<ResidentDashboard> createState() => _ResidentDashboardState();
}

class _ResidentDashboardState extends State<ResidentDashboard> {
  List<dynamic> reports = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/reports/user/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          reports = jsonDecode(response.body);
        });
      }
    } catch (_) {}

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    'Waste Complaints',
  ),
  backgroundColor: const Color(0xFF176B3A),
  foregroundColor: Colors.white,
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Logout',
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
          (route) => false,
        );
      },
    ),
  ],
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${widget.userName} 👋',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Together, let’s keep our surroundings clean.',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 25),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: const Color(0xFF176B3A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        size: 45,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Found waste around you?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Report it and help make your community cleaner.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportWastePage(
                                userId: widget.userId,
                              ),
                            ),
                          );

                          loadReports();
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('REPORT WASTE'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'My Reports',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                if (loading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (reports.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Center(
                        child: Text(
                          'No waste reports yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else
                  ...reports.map(
                    (report) => ReportCard(report: report),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// REPORT CARD
// ======================================================

class ReportCard extends StatelessWidget {
  final dynamic report;

  const ReportCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(
            Icons.delete,
            color: Color(0xFF176B3A),
          ),
        ),
        title: Text(
          report['wasteType'] ?? 'Waste',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          report['description'] ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Chip(
          label: Text(
            report['status'] ?? 'Submitted',
          ),
        ),
      ),
    );
  }
}

// ======================================================
// REPORT WASTE PAGE
// ======================================================

class ReportWastePage extends StatefulWidget {
  final String userId;

  const ReportWastePage({
    super.key,
    required this.userId,
  });

  @override
  State<ReportWastePage> createState() => _ReportWastePageState();
}

class _ReportWastePageState extends State<ReportWastePage> {
  final descriptionController = TextEditingController();

  String selectedType = 'Garbage Dump';

  Uint8List? imageBytes;
  String? imageName;

  double? latitude;
  double? longitude;

  bool gettingLocation = false;
  bool submitting = false;

  final ImagePicker picker = ImagePicker();

  // ====================================================
  // PICK IMAGE
  // ====================================================

  Future<void> pickImage() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();

        setState(() {
          imageBytes = bytes;
          imageName = image.name;
        });
      }
    } catch (e) {
      showMessage('Unable to select image');
    }
  }

  // ====================================================
  // GET GPS
  // ====================================================

  Future<void> getGPS() async {
    setState(() {
      gettingLocation = true;
    });

    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        showMessage(
          'Please enable Location Services in your browser/device.',
        );

        setState(() {
          gettingLocation = false;
        });

        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        showMessage('Location permission denied');
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        showMessage(
          'Location permission is permanently denied.',
        );
        return;
      }

      Position position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      showMessage('GPS location captured successfully');
    } catch (e) {
      showMessage('Unable to get GPS location');
    }

    setState(() {
      gettingLocation = false;
    });
  }

  // ====================================================
  // SUBMIT REPORT
  // ====================================================

  Future<void> submitReport() async {
    final description =
        descriptionController.text.trim();

    if (description.isEmpty) {
      showMessage('Please enter a description');
      return;
    }

    if (latitude == null || longitude == null) {
      showMessage('Please capture GPS location');
      return;
    }

    setState(() {
      submitting = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$apiUrl/reports'),
      );

      request.fields['userId'] = widget.userId;
      request.fields['wasteType'] = selectedType;
      request.fields['description'] = description;
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();

      if (imageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'photo',
            imageBytes!,
            filename: imageName ?? 'waste.jpg',
          ),
        );
      }

      final streamedResponse = await request.send();

      final response =
          await http.Response.fromStream(streamedResponse);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        showMessage(
          'Waste report submitted successfully!',
        );

        await Future.delayed(
          const Duration(seconds: 1),
        );

        if (!mounted) return;

        Navigator.pop(context);
      } else {
        showMessage(
          data['message'] ?? 'Report submission failed',
        );
      }
    } catch (e) {
      showMessage(
        'Could not connect to backend.',
      );
    }

    setState(() {
      submitting = false;
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Waste'),
        backgroundColor: const Color(0xFF176B3A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Report a Waste Problem',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Provide the details below so the cleaning team can respond quickly.',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 25),

                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Waste Type',
                    prefixIcon:
                        const Icon(Icons.delete_outline),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Garbage Dump',
                      child: Text('Garbage Dump'),
                    ),
                    DropdownMenuItem(
                      value: 'Plastic Waste',
                      child: Text('Plastic Waste'),
                    ),
                    DropdownMenuItem(
                      value: 'Food Waste',
                      child: Text('Food Waste'),
                    ),
                    DropdownMenuItem(
                      value: 'Construction Waste',
                      child: Text('Construction Waste'),
                    ),
                    DropdownMenuItem(
                      value: 'E-Waste',
                      child: Text('E-Waste'),
                    ),
                    DropdownMenuItem(
                      value: 'Other',
                      child: Text('Other'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedType = value!;
                    });
                  },
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText:
                        'Describe the waste problem...',
                    prefixIcon:
                        const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // PHOTO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    children: [
                      if (imageBytes != null)
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(12),
                          child: Image.memory(
                            imageBytes!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const Icon(
                          Icons.camera_alt_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),

                      const SizedBox(height: 12),

                      Text(
                        imageName ??
                            'Add Waste Photo',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      OutlinedButton.icon(
                        onPressed: pickImage,
                        icon:
                            const Icon(Icons.upload),
                        label:
                            const Text('Upload Photo'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // GPS
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            if (latitude != null)
                              Text(
                                'Lat: ${latitude!.toStringAsFixed(6)}\n'
                                'Lng: ${longitude!.toStringAsFixed(6)}',
                                style:
                                    const TextStyle(
                                  color: Colors.green,
                                ),
                              )
                            else
                              const Text(
                                'GPS location not captured',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),

                      ElevatedButton(
                        onPressed:
                            gettingLocation
                                ? null
                                : getGPS,
                        child: gettingLocation
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('GET GPS'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed:
                        submitting
                            ? null
                            : submitReport,
                    icon: const Icon(Icons.send),
                    label: submitting
                        ? const Text('SUBMITTING...')
                        : const Text(
                            'SUBMIT REPORT',
                          ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF176B3A),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// ======================================================
// ADMIN DASHBOARD
// ======================================================

class AdminComplaintsPage extends StatefulWidget {
  const AdminComplaintsPage({super.key});

  @override
  State<AdminComplaintsPage> createState() =>
      _AdminComplaintsPageState();
}

class _AdminComplaintsPageState
    extends State<AdminComplaintsPage> {

  List<dynamic> reports = [];
  List<dynamic> workers = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
    loadWorkers();
  }

  // ======================================================
  // LOAD ALL COMPLAINTS
  // ======================================================

  Future<void> loadReports() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/reports'),
      );

      if (response.statusCode == 200) {
        setState(() {
          reports = jsonDecode(response.body);
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cannot load complaints. Check backend.',
            ),
          ),
        );
      }
    }
  }

  // ======================================================
  // LOAD WORKERS
  // ======================================================

  Future<void> loadWorkers() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/reports/workers'),
      );

      if (response.statusCode == 200) {
        setState(() {
          workers = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint('Worker loading error: $e');
    }
  }

  // ======================================================
  // ASSIGN WORKER
  // ======================================================

  Future<void> assignWorker(
    String reportId,
    String workerId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/reports/$reportId/assign'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'workerId': workerId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Complaint assigned successfully',
              ),
            ),
          );
        }

        await loadReports();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'] ?? 'Failed to assign worker',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cannot connect to backend',
            ),
          ),
        );
      }
    }
  }

  // ======================================================
  // SHOW WORKER SELECTION
  // ======================================================

  void showAssignWorkerDialog(dynamic report) {

    String? selectedWorkerId;

    showDialog(
      context: context,
      builder: (context) {

        return StatefulBuilder(
          builder: (context, setDialogState) {

            return AlertDialog(
              title: const Text(
                'Assign Worker',
              ),

              content: workers.isEmpty
                  ? const Text(
                      'No workers available.',
                    )
                  : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Worker',
                        border: OutlineInputBorder(),
                      ),

                      value: selectedWorkerId,

                      items: workers.map<DropdownMenuItem<String>>(
                        (worker) {
                          return DropdownMenuItem<String>(
                            value: worker['_id'],
                            child: Text(
                              '${worker['name']} (${worker['email']})',
                            ),
                          );
                        },
                      ).toList(),

                      onChanged: (value) {
                        setDialogState(() {
                          selectedWorkerId = value;
                        });
                      },
                    ),

              actions: [

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),

                ElevatedButton(
                  onPressed: selectedWorkerId == null
                      ? null
                      : () async {

                          Navigator.pop(context);

                          await assignWorker(
                            report['_id'],
                            selectedWorkerId!,
                          );
                        },
                  child: const Text(
                    'Assign',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
     appBar: AppBar(
  title: const Text(
    'Waste Complaints',
  ),
  backgroundColor: const Color(0xFF176B3A),
  foregroundColor: Colors.white,
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Logout',
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
          (route) => false,
        );
      },
    ),
  ],
),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )

          : reports.isEmpty
              ? const Center(
                  child: Text(
                    'No waste complaints found.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                )

              : RefreshIndicator(
                  onRefresh: loadReports,

                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),

                    itemCount: reports.length,

                    itemBuilder: (context, index) {

                      final report = reports[index];

                      final status =
                          report['status'] ?? 'Submitted';

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 15,
                        ),

                        child: Padding(
                          padding: const EdgeInsets.all(16),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              Text(
                                report['wasteType'] ??
                                    'Waste Report',

                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                report['description'] ??
                                    'No description',

                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                'Status: $status',

                                style: const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      Color(0xFF176B3A),
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Latitude: ${report['latitude'] ?? 'Not available'}',
                              ),

                              Text(
                                'Longitude: ${report['longitude'] ?? 'Not available'}',
                              ),
                              const SizedBox(height: 12),

if (report['latitude'] != null &&
    report['longitude'] != null)
  SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () async {
        final latitude = report['latitude'];
        final longitude = report['longitude'];

        final url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
        );

        await launchUrl(
          url,
         
        );
      },
      icon: const Icon(Icons.location_on),
      label: const Text('VIEW LOCATION'),
    ),
  ),
                              const SizedBox(height: 12),

                              // IMAGE
                              if (report['image'] != null)
                                Image.network(
                                  'http://localhost:5000${report['image']}',

                                  height: 180,

                                  width:
                                      double.infinity,

                                  fit: BoxFit.cover,

                                  errorBuilder:
                                      (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                    return const Text(
                                      'Image could not be loaded',
                                    );
                                  },
                                ),

                              const SizedBox(height: 15),

                              // WORKER NAME
                              if (report['workerName'] !=
                                  null)
                                Text(
                                  'Assigned Worker: ${report['workerName']}',

                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                              const SizedBox(height: 10),

                              // ASSIGN BUTTON
                              if (status != 'Completed')
                                SizedBox(
                                  width:
                                      double.infinity,

                                  child:
                                      ElevatedButton.icon(
                                    onPressed: () {
                                      showAssignWorkerDialog(
                                        report,
                                      );
                                    },

                                    icon: const Icon(
                                      Icons.person_add,
                                    ),

                                    label: Text(
                                      status ==
                                              'Assigned'
                                          ? 'Reassign Worker'
                                          : 'Assign Worker',
                                    ),

                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      backgroundColor:
                                          const Color(
                                              0xFF176B3A),
                                      foregroundColor:
                                          Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
// ======================================================
// WORKER DASHBOARD
// ======================================================

class WorkerDashboard extends StatefulWidget {
  final String userId;
  final String userName;
  final String email;

  const WorkerDashboard({
    super.key,
    required this.userId,
    required this.userName,
    required this.email,
  });

  @override
  State<WorkerDashboard> createState() =>
      _WorkerDashboardState();
}

class _WorkerDashboardState
    extends State<WorkerDashboard> {

  List<dynamic> reports = [];
  List<dynamic> workers = [];

  bool loading = true;

  int get totalComplaints => reports.length;

  int get submittedCount =>
      reports.where((r) => r['status'] == 'Submitted').length;

  int get assignedCount =>
      reports.where((r) => r['status'] == 'Assigned').length;

  int get inProgressCount =>
      reports.where((r) => r['status'] == 'In Progress').length;

  int get completedCount =>
      reports.where((r) => r['status'] == 'Completed').length;

  @override
  void initState() {
    super.initState();
    loadAssignedReports();
  }

  // ======================================================
  // LOAD ASSIGNED COMPLAINTS
  // ======================================================

  Future<void> loadAssignedReports() async {
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/reports'),
      );

      if (response.statusCode == 200) {
        final allReports = jsonDecode(response.body);

        setState(() {
          reports = allReports.where((report) {
            return report['workerId'] == widget.userId;
          }).toList();

          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cannot load assigned complaints',
            ),
          ),
        );
      }
    }
  }

  // ======================================================
  // UPDATE STATUS
  // ======================================================

  Future<void> updateStatus(
    String reportId,
    String status,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/reports/$reportId/status'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Complaint marked as $status',
              ),
            ),
          );
        }

        await loadAssignedReports();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to update status',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cannot connect to backend',
            ),
          ),
        );
      }
    }
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Worker Dashboard',
        ),

        backgroundColor: const Color(0xFF176B3A),

        foregroundColor: Colors.white,

        // ==================================================
        // LOGOUT BUTTON
        // ==================================================

        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),

            tooltip: 'Logout',

            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,

                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),

                (route) => false,
              );
            },
          ),
        ],
      ),

      // ====================================================
      // BODY
      // ====================================================

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )

          : reports.isEmpty
              ? RefreshIndicator(
                  onRefresh: loadAssignedReports,

                  child: ListView(
                    children: const [
                      SizedBox(
                        height: 180,
                      ),

                      Center(
                        child: Text(
                          'No complaints assigned to you.',

                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                )

              : RefreshIndicator(
                  onRefresh: loadAssignedReports,

                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),

                    itemCount: reports.length,

                    itemBuilder: (context, index) {
                      final report = reports[index];

                      final status =
                          report['status'] ?? 'Assigned';

                      return Card(
                        margin: const EdgeInsets.only(
                          bottom: 16,
                        ),

                        elevation: 3,

                        child: Padding(
                          padding: const EdgeInsets.all(16),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              // ==========================
                              // WASTE TYPE
                              // ==========================

                              Text(
                                report['wasteType'] ??
                                    'Waste Complaint',

                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              // ==========================
                              // DESCRIPTION
                              // ==========================

                              Text(
                                report['description'] ??
                                    'No description',

                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),

                              const SizedBox(
                                height: 15,
                              ),

                              // ==========================
                              // STATUS
                              // ==========================

                              Text(
                                'Status: $status',

                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      Color(0xFF176B3A),
                                ),
                              ),

                              const SizedBox(
                                height: 10,
                              ),

                              // ==========================
                              // LOCATION
                              // ==========================

                              Text(
                                'Latitude: ${report['latitude'] ?? 'Not available'}',
                              ),

                              Text(
                                'Longitude: ${report['longitude'] ?? 'Not available'}',
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              // ==========================
                              // IMAGE
                              // ==========================

                              if (report['image'] != null)
                                Image.network(
                                  'http://localhost:5000${report['image']}',

                                  height: 180,

                                  width: double.infinity,

                                  fit: BoxFit.cover,

                                  errorBuilder:
                                      (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                    return const Text(
                                      'Image could not be loaded',
                                    );
                                  },
                                ),

                              const SizedBox(
                                height: 15,
                              ),

                              // ==========================
                              // START WORK
                              // ==========================

                              if (status == 'Assigned')
                                SizedBox(
                                  width:
                                      double.infinity,

                                  child:
                                      ElevatedButton.icon(
                                    onPressed: () {
                                      updateStatus(
                                        report['_id'],
                                        'In Progress',
                                      );
                                    },

                                    icon: const Icon(
                                      Icons.play_arrow,
                                    ),

                                    label: const Text(
                                      'START WORK',
                                    ),

                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      backgroundColor:
                                          const Color(
                                        0xFF176B3A,
                                      ),

                                      foregroundColor:
                                          Colors.white,
                                    ),
                                  ),
                                ),

                              // ==========================
                              // COMPLETE WORK
                              // ==========================

                              if (status == 'In Progress')
                                SizedBox(
                                  width:
                                      double.infinity,

                                  child:
                                      ElevatedButton.icon(
                                    onPressed: () {
                                      updateStatus(
                                        report['_id'],
                                        'Completed',
                                      );
                                    },

                                    icon: const Icon(
                                      Icons.check,
                                    ),

                                    label: const Text(
                                      'MARK AS COMPLETED',
                                    ),

                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      backgroundColor:
                                          const Color(
                                        0xFF176B3A,
                                      ),

                                      foregroundColor:
                                          Colors.white,
                                    ),
                                  ),
                                ),

                              // ==========================
                              // COMPLETED MESSAGE
                              // ==========================

                              if (status == 'Completed')
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,

                                      color:
                                          Color(
                                        0xFF176B3A,
                                      ),
                                    ),

                                    SizedBox(
                                      width: 8,
                                    ),

                                    Text(
                                      'Work Completed',

                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,

                                        color:
                                            Color(
                                          0xFF176B3A,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
