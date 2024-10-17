import 'dart:io';

import 'package:flink/views/homescreen/home_screen.dart';
import 'package:flink/views/landingscreen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up', style: TextStyle(fontSize: 24)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Consumer<SignUpProvider>(
            builder: (context, signUpProvider, _) {
              return ListView(
                children: [
                  Text(
                    'Create Your Account',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),

                  // Profile Picture Picker
                  Center(
                    child: GestureDetector(
                      onTap: () => signUpProvider.pickProfileImage(),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        backgroundImage: signUpProvider.profileImage != null
                            ? FileImage(File(signUpProvider.profileImage!.path))
                            : null,
                        child: signUpProvider.profileImage == null
                            ? Icon(Icons.camera_alt,
                                size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.person, color: Colors.white),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                    onChanged: (value) => signUpProvider.setUsername(value),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.email, color: Colors.white),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onChanged: (value) => signUpProvider.setEmail(value),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                      prefixIcon: Icon(Icons.lock, color: Colors.white),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    onChanged: (value) => signUpProvider.setPassword(value),
                  ),
                  SizedBox(height: 40),

                  // SignUp Button
                  ElevatedButton(
                    onPressed: () => _submitForm(context),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogInSheet(),
                          ),
                        );
                      },
                      child: Text(
                        'Already have an account? Log In',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _submitForm(BuildContext context) {
    final signUpProvider = Provider.of<SignUpProvider>(context, listen: false);
    if (_formKey.currentState!.validate()) {
      // Call signUp method to handle Firebase operations
      signUpProvider.signUp(context);
    }
  }
}

// SignUpProvider class
class SignUpProvider with ChangeNotifier {
  String _username = '';
  String _email = '';
  String _password = '';
  XFile? _profileImage;

  // Getters for accessing form fields and profile image
  String get username => _username;
  String get email => _email;
  String get password => _password;
  XFile? get profileImage => _profileImage;

  // Setters for updating the state
  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setProfileImage(XFile? image) {
    _profileImage = image;
    notifyListeners();
  }

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setProfileImage(pickedFile);
  }

  // Sign up and store user information
  // Sign up and store user information
  Future<void> signUp(BuildContext context) async {
    try {
      // Create user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);

      User? user = userCredential.user;
      if (user != null) {
        String uid = user.uid;
        String? profileImageUrl;

        // Upload profile image if available
        if (_profileImage != null) {
          // Convert XFile to File
          File imageFile = File(_profileImage!.path);
          profileImageUrl = await uploadProfileImage(imageFile, context, uid);
        }

        // Store user information in Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'username': _username,
          'email': _email,
          'profileImageUrl': profileImageUrl ?? '',
          'createdAt': Timestamp.now(),
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Sign up successful!'),
        ));

        // Navigate to home screen using pushReplacement
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
          (Route<dynamic> route) => false, // Remove all previous routes
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase errors
      print('FirebaseAuthException: ${e.code}'); // Debugging statement
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Email is already registered. Please use a different email.'),
        ));
      } else if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Password is too weak.'),
        ));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Invalid email format.'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to sign up: ${e.message}'),
        ));
      }
    } catch (e) {
      print('Error: $e'); // Debugging statement
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to sign up. Try again later.'),
      ));
    }
  }

// Upload profile image
  Future uploadProfileImage(
      File imageFile, BuildContext context, String uid) async {
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child(
          'userProfilePics/$uid/${DateTime.now()}.jpg'); // Use uid for unique storage path
      UploadTask uploadTask = storageRef.putFile(imageFile);
      await uploadTask.whenComplete(() => null);
      String imageUrl = await storageRef.getDownloadURL();

      // Save the image URL to Firestore under the user's document
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'profileImageUrl': imageUrl,
      });

      print('Profile image uploaded successfully: $imageUrl');
    } catch (e) {
      print('Error uploading profile image: $e');
    }
  }
}
