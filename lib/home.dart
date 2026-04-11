import 'package:final_project/game.dart';
import 'package:final_project/library.dart';
import 'package:final_project/login.dart';
import 'package:final_project/training.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  int selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    checkUserName();
  }

  // ตรวจว่ามีชื่อเล่นเกมยาง
  Future<void> checkUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists || userDoc['name'] == null) {
        showNameDialog();
      }
    }
  }

  //popup ให้ตั้งชื่อ กรณียังไม่มีชื่อ
  void showNameDialog() {
  String? _nameError; // ตัวแปรเก็บ error message
  TextEditingController nameController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false, // ป้องกันการปิด Popup โดยไม่ตั้งชื่อ
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                // 🔹 กล่อง Popup หลัก
                Container(
                  padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView( // เพิ่ม SingleChildScrollView
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "ตั้งชื่อของคุณ",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),

                        // 🔹 TextField พร้อม errorText
                        TextField(
                          controller: nameController,
                          maxLength: 10, // ชื่อยาวสุด 10 ตัวอักษร
                          decoration: InputDecoration(
                            hintText: "ใส่ชื่อของคุณ",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            errorText: _nameError, // แสดงข้อความผิดพลาดใต้ TextField
                          ),
                        ),

                        SizedBox(height: 20),

                        // 🔹 ปุ่ม บันทึก
                        ElevatedButton(
                          onPressed: () async {
                            String name = nameController.text.trim();

                            // ตรวจสอบว่าชื่อว่างหรือไม่
                            if (name.isEmpty) {
                              setState(() {
                                _nameError = 'กรุณากรอกชื่อ';
                              });
                              return;
                            }

                            // ตรวจสอบความยาวชื่อ
                            if (name.length > 10) {
                              setState(() {
                                _nameError = 'ชื่อยาวเกิน 10 ตัวอักษร';
                              });
                              return;
                            }

                            // ถ้าชื่อถูกต้อง ล้าง error และบันทึกลง Firebase
                            setState(() {
                              _nameError = null;
                            });

                            User? user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(user.uid)
                                  .set(
                                {'name': name},
                                SetOptions(merge: true),
                              );
                              Navigator.of(context).pop(); // ปิด Popup
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFCC9A6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12),
                          ),
                          child: Text("บันทึก",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


  // เปลี่ยนชื่อจร๊
  void changeNameDialog() {
    String? _nameError; // ตัวแปรเก็บ error message
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันการปิด Popup โดยไม่ตั้งชื่อ
      builder: (context) {
        return StatefulBuilder(
          
          // ใช้ StatefulBuilder เพื่ออัปเดต UI
          builder: (context, setState) {
            return Dialog(
              
              backgroundColor: Colors.transparent,
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  // 🔹 กล่อง Popup หลัก
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "ตั้งชื่อของคุณ",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),

                        // 🔹 TextField พร้อม errorText
                        TextField(
                          controller: nameController,
                          maxLength: 10, // ชื่อยาวสุด 10 ตัวอักษร
                          decoration: InputDecoration(
                            hintText: "ใส่ชื่อของคุณ",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            errorText:
                                _nameError, // แสดงข้อความผิดพลาดใต้ TextField
                          ),
                        ),

                        SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 🔹 ปุ่ม Cancel
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // ปิด Popup
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFB0E0E6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                              ),
                              child: Text("ยกเลิก",
                                  style: TextStyle(color: Colors.white)),
                            ),

                            // 🔹 ปุ่ม บันทึก
                            ElevatedButton(
                              onPressed: () async {
                                String name = nameController.text.trim();

                                // ตรวจสอบว่าชื่อว่างหรือไม่
                                if (name.isEmpty) {
                                  setState(() {
                                    _nameError = 'กรุณากรอกชื่อ';
                                  });
                                  return;
                                }

                                // ตรวจสอบความยาวชื่อ
                                if (name.length > 10) {
                                  setState(() {
                                    _nameError = 'ชื่อยาวเกิน 10 ตัวอักษร';
                                  });
                                  return;
                                }

                                // ถ้าชื่อถูกต้อง ล้าง error และบันทึกลง Firebase
                                setState(() {
                                  _nameError = null;
                                });

                                User? user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(user.uid)
                                      .set(
                                    {'name': name},
                                    SetOptions(merge: true),
                                  );
                                  Navigator.of(context).pop(); // ปิด Popup
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFCC9A6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                              ),
                              child: Text("บันทึก",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  //popup setting
  void settings() {
  bool isMusicOn = true;
  bool isSoundOn = true;

  List<Map<String, dynamic>> buttons = [
    {"text": "เปลี่ยนชื่อผู้เล่น", "onPressed": () => changeNameDialog()},
    {"text": "ออกจากระบบ", "onPressed": () => signUserOut()},
    {"text": "ปิด", "onPressed": () => Navigator.of(context).pop()},
  ];

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedPadding(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // ปรับตามแป้นพิมพ์
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
                    width: 320,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView( // แก้ overflow
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Settings",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 194, 214),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              children: [
                                SwitchListTile(
                                  title: Text("เพลงประกอบ"),
                                  value: isMusicOn,
                                  onChanged: (value) {
                                    setState(() => isMusicOn = value);
                                  },
                                ),
                                SwitchListTile(
                                  title: Text("เสียงเอฟเฟกต์"),
                                  value: isSoundOn,
                                  onChanged: (value) {
                                    setState(() => isSoundOn = !value);
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Column(
                            children: buttons.map((button) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(right: 10, left: 10),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: button["onPressed"],
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFFCC9A6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: Text(button["text"]),
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                  ),
                  // ตกแต่งข้างบน
                  Positioned(
                    top: -50,
                    left: 60,
                    child: buildDecorativeCircle(),
                  ),
                  Positioned(
                    top: -50,
                    right: 60,
                    child: buildDecorativeCircle(),
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Widget buildDecorativeCircle() {
  return Container(
    width: 50,
    height: 100,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFD1DC),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );
}


  final List<Widget> _widgetOptions = <Widget>[
    LibraryScreen(),
    HomePage(),
    TrainingScreen(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  //logout
  void signUserOut() async {
    await Future.delayed(Duration(milliseconds: 300)); // หน่วงก่อน Logout
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => LoginScreen()), // กลับไปหน้า Login
        (route) => false, // เคลียร์ Stack ทั้งหมด
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color(0xFFFFFEE0),
        leading: Container(
          margin: EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage('assets/images/profile.png'),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 1),
          child: Container(
            //color: Colors.amber,
            //padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'กระต่ายน้อย',
                      style: TextStyle(
                        fontSize: 15, // Adjust the font size to make it smaller
                        color: const Color.fromARGB(
                            255, 62, 62, 62), // Set the color to gray
                      ),
                    ),
                    // 🔹 ดึงชื่อ & Level
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Text(
                            'Player',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontFamily: 'LexendBlack'),
                          );
                        }
                        var userData = snapshot.data!;
                        String name = userData['name'] ?? 'Player';

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'LexendMedium',
                                ),
                              ),
                            ),
                            SizedBox(width: 30),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(width: 30),

                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Row(
                        children: [
                          Transform.rotate(
                            angle: 45 * 3.14159 / 180,
                            child: Image.asset(
                              'assets/images/carrot.png',
                              height: 30,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '0', // ค่าเริ่มต้นหากยังไม่มีข้อมูล
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'LexendRegular',
                            ),
                          ),
                        ],
                      );
                    }

                    int money = snapshot.data!['money'] ?? 0;

                    return Container(
                      width: 90, // กำหนดความกว้างตายตัว ป้องกันการขยายเกิน
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Transform.rotate(
                            angle: 45 * 3.14159 / 180,
                            child: Image.asset(
                              'assets/images/carrot.png',
                              height: 20, // ลดขนาดรูปให้สมดุล
                            ),
                          ),
                          Expanded(
                            // ปรับข้อความให้ไม่ล้น
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '$money',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'LexendRegular',
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.add,
                            size: 15,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        //เส้นขอบล่าง
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0), // กำหนดความสูงของเส้นขอบ
          child: Container(
            color: const Color.fromARGB(255, 69, 69, 69), // สีของเส้นขอบ
            height: 1.0, // ความสูงของเส้นขอบ
          ),
        ),
        actions: [
          Container(
            height: 33,
            width: 33, // กำหนดความกว้างเท่าความสูงให้เป็นวงกลม
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              // ใช้ Center ครอบ IconButton เพื่อจัดให้อยู่ตรงกลาง
              child: IconButton(
                padding: EdgeInsets.zero, // ลบ padding ของ IconButton ออก
                icon: Icon(
                  Icons.settings,
                  color: Color.fromARGB(255, 44, 44, 44),
                  size: 20,
                ),
                onPressed: () {
                  settings();
                },
              ),
            ),
          ),
        ],
      ),
      body: _widgetOptions[selectedIndex],
      bottomNavigationBar: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: Color.fromARGB(255, 77, 77, 77),
                    width: 3), // เส้นขอบด้านบน
              ),
            ),
            child: BottomNavigationBar(
              backgroundColor: const Color(0xFFFFFEE0),
              selectedItemColor: Color.fromARGB(255, 255, 81, 0),
              unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
              currentIndex: selectedIndex,
              //-ขนาดฟ้อนจร๊
              selectedLabelStyle: const TextStyle(
                fontSize: 10,
              ), // ฟอนต์ของ label ที่ถูกเลือก
              unselectedLabelStyle: const TextStyle(
                  fontSize: 10), // ฟอนต์ของ label ที่ไม่ได้เลือก
              onTap: onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.asset('assets/images/library.png'),
                  ),
                  label: 'Library',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.asset('assets/images/Adventure.png'),
                  ),
                  label: 'Adventure',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.asset('assets/images/Training.png'),
                  ),
                  label: 'Training',
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Spacer(),
                Container(
                    width: 10,
                    height: 90,
                    color: Color.fromARGB(255, 103, 53, 14)),
                const Spacer(),
                Container(
                    width: 10,
                    height: 90,
                    color: Color.fromARGB(255, 103, 53, 14)), // เส้นแบ่งสอง
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ ใช้ StreamBuilder ดึงชื่อแบบเรียลไทม์
Stream<String?> getUserNameStream() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('Users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists || !snapshot.data()!.containsKey('name')) {
      return 'Players';
    }
    return snapshot['name'];
  });
}

Stream<int> getLibraryItemCount() {
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    var userRef = FirebaseFirestore.instance.collection('Users').doc(user.uid);

    return userRef.collection('Library').snapshots().map((snapshot) {
      return snapshot.docs.length; // Return the document count in real-time
    });
  } else {
    return Stream.value(0); // Return 0 if no user is logged in
  }
}

Stream<int> getHighScore() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic>? userData = snapshot.data();
        return userData?['highScore'] ?? 0; // ถ้าไม่มีค่าให้เป็น 0
      } else {
        return 0; // ถ้าไม่มีข้อมูลเลย ให้คืนค่า 0
      }
    });
  } else {
    return const Stream.empty(); // คืนค่า Stream ว่าง ถ้าไม่มี user
  }
}

//homepage
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 🔹 ส่วนที่ 2
          Container(
            height: 522,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("assets/images/homeBg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // ✅ ทำให้ Container กดได้
                Positioned(
                  top: 10,
                  left: 50,
                  child: GestureDetector(
                    child: Container(
                      height: 90,
                      width: 290,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                             // เพิ่มระยะห่าง
                            StreamBuilder<int>(
                              stream: getHighScore(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return CircularProgressIndicator();
                                }
                                int highScore = snapshot.data ?? 0;
                                return Text(
                                  'HighScore: $highScore',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'LexendExtraL',
                                    color: const Color.fromARGB(255, 243, 33, 33),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 10),
                            StreamBuilder<int>(
                              stream: getLibraryItemCount(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return CircularProgressIndicator();
                                }
                                int wordCount = snapshot.data ?? 0;
                                return Text(
                                  'เก็บคำศัพท์ได้ $wordCount คำแล้ว',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'LexendExtraL',
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                    ),
                  ),
                ),

                // ปุ่ม Advanture
                Positioned(
                  top: 400,
                  left: 90,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GameScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFED6C30),
                      foregroundColor: const Color(0xFFFFFEE0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text('Advanture',
                            style: TextStyle(
                                fontSize: 22, fontFamily: 'LexendBlack')),
                        Image.asset('assets/images/light.png', height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

 
  
}
