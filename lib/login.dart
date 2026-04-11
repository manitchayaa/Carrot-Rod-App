import 'dart:ui';

import 'package:final_project/home.dart';
import 'package:final_project/resgister.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _visiblePass = true;

  CollectionReference postCollection =
      FirebaseFirestore.instance.collection('post');

  // ฟังก์ชันสำหรับล็อกอินด้วย email และ password
  void signUserIn() async {
    String email = emailController.text;
    String password = passwordController.text;

    try {
      // ใช้ Firebase Auth สำหรับการล็อกอิน
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // เมื่อเข้าสู่ระบบสำเร็จ นำผู้ใช้ไปยังหน้าหลัก
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (e) {
      // แสดงข้อความถ้าเกิดข้อผิดพลาด
      String message = 'เกิดข้อผิดพลาด';
      if (e.code == 'user-not-found') {
        message = 'ไม่พบอีเมลนี้ในระบบ';
      } else if (e.code == 'wrong-password') {
        message = 'รหัสผ่านไม่ถูกต้อง';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // ป้องกัน UI ขยับเมื่อคีย์บอร์ดขึ้น
      body: Stack(
        children: [
          // 🔹 พื้นหลังรูปภาพ
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/carrotBg.png" ),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.5), 
                  BlendMode.darken, 
                ),
              ),
            ),
          ),
          // 🔹 จัดให้อยู่กลางแม้คีย์บอร์ดขึ้น
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 20, vertical: 50), 
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      width: 350,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFEE0),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 🔹 ไอคอนโปรไฟล์
                          Image.asset('assets/images/login.png' ,height: 130,),
                          
                          SizedBox(height: 15),
                          // 🔹 ฟอร์ม Login
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.mail),
                                    labelText: 'Email',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty)
                                      return 'กรุณากรอก email';
                                    return null;
                                  },
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: _visiblePass,
                                  decoration: InputDecoration(
                                    icon: Icon(Icons.lock),
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
                                      child: _visiblePass 
                                      ? Icon(Icons.visibility_off)
                                      : Icon(Icons.visibility),
                                    )
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty)
                                      return 'กรุณากรอกรหัสผ่าน';
                                    return null;
                                  },
                                ),
                                SizedBox(height: 20),
                                // 🔹 ปุ่ม Login
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      signUserIn();
                                    }
                                  },
                                  child: Text(
                                    'Login',
                                    style: TextStyle(color: Colors.white,fontSize: 12,fontFamily: 'LexendRegular'),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                     minimumSize: Size(100, 45),
                                    backgroundColor:
                                        Color(0xFFED6C30),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          // 🔹 ลิงก์ไปหน้า Register
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account?" ,style: TextStyle(fontSize: 12,fontFamily: 'LexendRegular'),),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => registPage()));
                                },
                                child: Text('Register', style: TextStyle(color: Color.fromARGB(255, 255, 43, 43),fontSize: 12,fontFamily: 'LexendRegular'),),
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
          ),
        ],
      ),
    );
  }
}

