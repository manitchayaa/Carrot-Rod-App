import 'package:final_project/authPage.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // พื้นหลังเป็นรูปภาพ
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/StartMenu.png"), // เปลี่ยนเป็นตำแหน่งไฟล์รูปของคุณ
              fit: BoxFit.cover, // ให้รูปเต็มจอ
            ),
          ),
        ),

        // โลโก้และพื้นหลังหยักๆ
        Column(
          children: [
            const SizedBox(height: 90), // ระยะห่างจากด้านบน
            Container(
              margin: EdgeInsets.only(left: 30, right: 30, top: 90),
              height: 270,
              alignment: Alignment.center,
              child: const Text(
                "Spell\nBunny",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 60,
                  fontFamily: 'LexendBlack',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // ปุ่ม Start ที่อยู่ด้านล่าง
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 45), // ระยะห่างจากขอบล่าง
            child: CustomStartButton(), // เรียกปุ่มที่ออกแบบ
          ),
        ),
      ],
    ),
  );
}

}

// 🔸 ปุ่ม Start พร้อมใบแครอท
class CustomStartButton extends StatelessWidget {
  const CustomStartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🍃 ใบแครอทด้านซ้าย (3 แฉก)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: 0.5, // หมุนใบบนไปทางซ้าย
              child: CarrotLeaf(),
            ),
            const SizedBox(height: 3),
            CarrotLeaf(), // ใบกลาง ไม่หมุน
            const SizedBox(height: 3),
            Transform.rotate(
              angle: -0.5, // หมุนใบล่างไปทางขวา
              child: CarrotLeaf(),
            ),
          ],
        ),
        
       
        
        // 🥕 ปุ่มหลัก
        ElevatedButton(
          onPressed: () async {
  // แสดงหน้าโหลด (Popup)
  showDialog(
    context: context,
    barrierDismissible: false, // ป้องกันการปิดระหว่างโหลด
    builder: (context) {
      return Center(
        child: CircularProgressIndicator(
          color: Colors.orange, // สีธีมของเกม
        ),
      );
    },
  );

  // จำลองโหลดข้อมูล (เช่น โหลด Firebase หรือเตรียมข้อมูล)
  await Future.delayed(Duration(seconds: 2));

  // ปิดหน้าโหลด
  Navigator.pop(context);

  // ไปหน้า AuthPage
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => authPage()),
  );
},

          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFfabd98),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            
            minimumSize:  Size(130, 50),
            elevation: 0,
            shadowColor: Colors.black.withOpacity(0.6),
          ),
          child: Text(
            'Start',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'LexendRegular',
            ),
          ),
        ),
      ],
    );
  }
}


// 🍃 ใบแครอท
class CarrotLeaf extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFFD3E8C5), // สีเขียวอ่อน
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}


