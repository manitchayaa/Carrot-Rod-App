import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final List<int> hpScale = [0, 10, 12, 14, 16, 18, 20];
  final List<int> carrotAtkScale = [0, 3, 4, 5, 6, 7, 8];
  final List<int> bagSizeScale = [0, 10, 12, 14, 16, 18, 20];
  final List<int> drawPerTurnScale = [0, 2, 2, 3, 4, 4, 5];

  int hpLevel = 0;
  int carrotLenghtLevel = 0;
  int bagSizeLevel = 0;
  int drawPerTurnLevel = 0;
  int money = 0;

  final List<int> upgradeCosts = [20, 20, 20, 20];

  void upgrade(String item) {
    setState(() {
      if (item == "พลังชีวิต" &&
          hpLevel < hpScale.length - 1 &&
          money >= upgradeCosts[0]) {
        money -= upgradeCosts[0];
        hpLevel++;
      } else if (item == "แครอท" &&
          carrotLenghtLevel < carrotAtkScale.length - 1 &&
          money >= upgradeCosts[1]) {
        money -= upgradeCosts[1];
        carrotLenghtLevel++;
      } else if (item == "กระเป๋า" &&
          bagSizeLevel < bagSizeScale.length - 1 &&
          money >= upgradeCosts[2]) {
        money -= upgradeCosts[2];
        bagSizeLevel++;
      } else if (item == "จั่วตัวอักษร" &&
          drawPerTurnLevel < drawPerTurnScale.length - 1 &&
          money >= upgradeCosts[3]) {
        money -= upgradeCosts[3];
        drawPerTurnLevel++;
      }
      updateMoney();
    });
  }

  Future<void> updateMoney() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
        'money': money,
        'hpLv': hpLevel,
        'bagSizeLv': bagSizeLevel,
        'carrotLenghtLv': carrotLenghtLevel,
        'drawCountLv': drawPerTurnLevel
      }, SetOptions(merge: true));
    }
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          money = doc['money'];
          hpLevel = doc['hpLv'];
          bagSizeLevel = doc['bagSizeLv'];
          carrotLenghtLevel = doc['carrotLenghtLv'];
          drawPerTurnLevel = doc['drawCountLv'];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลังเป็นรูปภาพ
          Positioned.fill(
            child: Image.asset(
              'assets/images/room.png',
              fit: BoxFit.cover, // ขยายรูปให้เต็มพื้นที่
            ),
          ),
          // ตัวเนื้อหาของหน้า (จะอยู่ทับกับพื้นหลัง)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 200),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 220, 193),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color.fromARGB(255, 120, 120, 120),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: ListView(
                      children: [
                        buildUpgradeRow(
                            "พลังชีวิต",
                            hpScale[hpLevel],
                            hpLevel,
                            hpScale.length,
                            upgradeCosts[0],
                            'assets/images/training/HP.png'),
                        buildUpgradeRow(
                            "แครอท",
                            carrotAtkScale[carrotLenghtLevel],
                            carrotLenghtLevel,
                            carrotAtkScale.length,
                            upgradeCosts[1],
                            'assets/images/training/CarrotS.png'),
                        buildUpgradeRow(
                            "กระเป๋า",
                            bagSizeScale[bagSizeLevel],
                            bagSizeLevel,
                            bagSizeScale.length,
                            upgradeCosts[2],
                            'assets/images/training/bag.png'),
                        buildUpgradeRow(
                            "จั่วตัวอักษร",
                            drawPerTurnScale[drawPerTurnLevel],
                            drawPerTurnLevel,
                            drawPerTurnScale.length,
                            upgradeCosts[3],
                           'assets/images/training/card.png')
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUpgradeRow(String name, int value, int level, int maxLevel,
      int price, String iconPath) {
    String displayValue = "";
    if (name == "พลังชีวิต") {
      displayValue = "พลังชีวิตเริ่มต้น ${hpScale[level]} หน่วย";
    } else if (name == "แครอท") {
      displayValue = "ใส่ตัวอักษรลงแครอทได้ ${carrotAtkScale[level]} ตัว";
    } else if (name == "กระเป๋า") {
      displayValue = "เก็บตัวอักษรได้ ${bagSizeScale[level]} ช่อง";
    } else if (name == "จั่วตัวอักษร") {
      displayValue = "จั่วได้ ${drawPerTurnScale[level]} อักษรต่อรอบ ";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                iconPath, // เปลี่ยนเป็นพาธของรูปภาพที่ใช้แทนไอคอน
                width: 40,
                height: 40,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$name LV $level',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('$displayValue'),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: (level < maxLevel - 1 && money >= price)
                ? () => upgrade(name)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 240, 240),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 5), // ขนาดของปุ่ม
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color:
                      const Color.fromARGB(255, 255, 221, 221), // สีของขอบเส้น
                  width: 2, // ความหนาของขอบเส้น
                ), // ขอบมุมโค้ง
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'อัปเกรด',
                  style: TextStyle(color: Colors.red),
                ),
                Text(
                  level < maxLevel - 1 ? '$price 🥕' : 'MAX',
                  style: TextStyle(
                    color: level < maxLevel - 1 ? Colors.black : Colors.grey,
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
