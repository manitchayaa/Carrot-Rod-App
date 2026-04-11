import 'package:final_project/home.dart';
import 'package:final_project/login.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class authPage extends StatelessWidget {
  const authPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          //authStateChanges ตรวจสอบว่าผู้ใช้ล็อกอินหรือยัง
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            //Logged in ถ้าล็อกอินแล้วไปที่ homePage
            if (snapshot.hasData) {
              return HomeScreen();
            } else {
              //NOT logged in ถ้ายังไม่ล็อกอินไปที่ loginPage
              return LoginScreen();
            }
          }),
    );
  }
}
