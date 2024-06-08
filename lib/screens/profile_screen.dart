import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  DatabaseReference? userRef;

  @override
  void initState() {
    super.initState();
    _initializeUserRef();
    _getUserDetails();
  }

  void _initializeUserRef() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userRef = FirebaseDatabase.instance.ref().child('users').child(user.uid);
    } else {
      Fluttertoast.showToast(msg: 'User not signed in');
    }
  }

  Future<void> _getUserDetails() async {
    if (userRef == null) return;

    try {
      DatabaseEvent event = await userRef!.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        var userData = Map<String, dynamic>.from(snapshot.value as Map);
        _nameController.text = userData['fullName'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        setState(() {});
      } else {
        Fluttertoast.showToast(msg: 'No user data found');
      }
    } catch (e) {
      print('Error fetching user details: $e');
      Fluttertoast.showToast(msg: 'Error fetching user details');
    }
  }

  Future<void> _updateUserDetails() async {
    if (_formKey.currentState!.validate()) {
      String fullName = _nameController.text.trim();
      String email = _emailController.text.trim();
      String phone = _phoneController.text.trim();

      try {
        await userRef!.update({
          'fullName': fullName,
          'email': email,
          'phone': phone,
        });
        Fluttertoast.showToast(msg: 'Profile updated successfully');
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error updating profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.green,
          actions: [Icon(Icons.person)]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Full Name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                readOnly: false,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Phone Number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUserDetails,
                child: const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
