import 'dart:ui';

import 'package:final_project/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class registPage extends StatefulWidget {
  const registPage({super.key});

  @override
  State<registPage> createState() => _registPageState();
}

class _registPageState extends State<registPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _visiblePass = false;
  bool _visible = false;
  CollectionReference postCollection =
      FirebaseFirestore.instance.collection('post');

  void signUserUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      // เช็คก่อนเปิด Popup
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await setDefaultUserData(userCredential.user);

      if (mounted) {
        // ปิด popup หลังจากหน่วงเวลาเล็กน้อย
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) Navigator.pop(context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // ปิด popup ถ้าเปิดอยู่
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration failed')),
        );
      }
    }
  }

  Future<void> setDefaultUserData(User? user) async {
    if (user != null) {
      var userRef =
          FirebaseFirestore.instance.collection('Users').doc(user.uid);

      await userRef.set({
        'name': null,
        'hpLv': 1,
        'money': 100,
        'carrotLenghtLv': 1,
        'bagSizeLv': 1,
        'drawCountLv': 1,
        'highScore': 0,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/carrotBg.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.5),
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    width: 350,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFEE0),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 40),
                        const Text(
                          'Register',
                          style: TextStyle(
                              color: Color(0xFF574d54),
                              fontSize: 30,
                              fontFamily: 'LexendBlack'),
                        ),
                        const SizedBox(height: 50),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.mail),
                                  labelText: 'Email',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) =>
                                    value!.isEmpty ? 'กรุณากรอก email' : null,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: passwordController,
                                obscureText: !_visiblePass,
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.lock),
                                  labelText: 'Password',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _visiblePass = !_visiblePass;
                                      });
                                    },
                                    child: Icon(_visiblePass
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                  ),
                                ),
                                validator: (value) =>
                                    value!.isEmpty ? 'กรุณากรอกรหัสผ่าน' : null,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: confirmPasswordController,
                                obscureText: !_visible,
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.lock),
                                  labelText: 'Confirm Password',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _visible = !_visible;
                                      });
                                    },
                                    child: Icon(_visible
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                  ),
                                ),
                                validator: (value) =>
                                    value!.isEmpty ? 'กรุณากรอกรหัสยืนยัน' : null,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    signUserUp();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(100, 45),
                                  backgroundColor: const Color(0xFFED6C30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'LexendRegular'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Have an Account?',
                              style: TextStyle(fontSize: 12, fontFamily: 'LexendRegular'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 255, 43, 43),
                                    fontSize: 12,
                                    fontFamily: 'LexendRegular'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
