import 'dart:math';

import 'package:final_project/home.dart';
import 'package:final_project/tutorial_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // กองตัวอักษรในการจั่ว
  List<Map<String, dynamic>> letterScores = [
    {'letter': 'A', 'count': 9},
    {'letter': 'B', 'count': 2},
    {'letter': 'C', 'count': 2},
    {'letter': 'D', 'count': 4},
    {'letter': 'E', 'count': 12},
    {'letter': 'F', 'count': 2},
    {'letter': 'G', 'count': 3},
    {'letter': 'H', 'count': 2},
    {'letter': 'I', 'count': 9},
    {'letter': 'J', 'count': 1},
    {'letter': 'K', 'count': 1},
    {'letter': 'L', 'count': 4},
    {'letter': 'M', 'count': 2},
    {'letter': 'N', 'count': 6},
    {'letter': 'O', 'count': 8},
    {'letter': 'P', 'count': 2},
    {'letter': 'Q', 'count': 1},
    {'letter': 'R', 'count': 6},
    {'letter': 'S', 'count': 4},
    {'letter': 'T', 'count': 6},
    {'letter': 'U', 'count': 4},
    {'letter': 'V', 'count': 2},
    {'letter': 'W', 'count': 2},
    {'letter': 'X', 'count': 1},
    {'letter': 'Y', 'count': 2},
    {'letter': 'Z', 'count': 1},
  ];

  List<String> bunnyBag = []; // ตัวอักษรในกระเป๋า
  List<String> selectedWord = []; // ตัวอักษรที่ถูกเลือก
  List<String> wordUsed = []; // เก็บประวัติคำที่ใช้สำเร็จ

  // สเกลแต่ละค่า ตามเลเวล
  final List<int> hpScale = [0, 10, 12, 14, 16, 18, 20];
  final List<int> carrotAtkScale = [0, 3, 4, 5, 6, 7, 8];
  final List<int> bagSizeScale = [0, 10, 12, 14, 16, 18, 20];
  final List<int> drawPerTurnScale = [0, 2, 2, 3, 4, 4, 5];

  // enemy data
  String enemyName = "";
  String enemyPic = "rat";
  String enemyTalk = "";
  int enemyHp = 10;
  int enemyBaseHp = 10;
  int enemyAtk = 0;
  int enemyBaseCooldown = 0;
  int enemyCooldown = 0;

  // bunny data
  String bunnyName = "Switch";
  String bunnyPic = "Stand";
  int bunnyHp = 10;
  int bunnyBaseHp = 10;
  int carrotAtk = 3;
  int bagSize = 10;
  int drawPerTurn = 3;

  bool isPlayerTalk = false;
  String playerSub = "";
  bool isEnemyTalk = false;
  String enemySub = "";

  // ใช้แสดงผลหน้าจอ
  double enemyX = -100;
  double playerX = 50;
  double sceneX = 0;

  // เช็คการกระทำ
  bool isAction = true;
  bool isWalking = true;

  int route = 1;
  int reward = 5;
  int money = 0;

  List<String> encounter = ['rat', 'crow', 'sneak', 'lion']; // ศัตรูในด่าน
  int state = 0;

  final Random random = Random();

  // เรียกใช้ API ตรวจคำศัพท์
  Future<bool> checkWordExists(String word) async {
    final url =
        Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word');
    final response = await http.get(url);
    return response.statusCode == 200;
  }

  void talk(String sub) {
    setState(() {
      isAction = true;
      isPlayerTalk = true; 
      playerSub = '$sub';
    });

    // รอ 2 วินาทีแล้วซ่อนกล่องคำพูด
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isPlayerTalk = false;
        isAction = false;
      });
    });
  }

  void pickWord(int count) {
    if (bunnyBag.length + selectedWord.length <= 20 - count) {
      setState(() {
        // สุ่มตัวอักษร
        for (int i = 0; i < count; i++) {
          if (bunnyBag.length >= 20) break;
          Map<String, dynamic> letter =
              letterScores[random.nextInt(letterScores.length)];
          if (letter['count'] > 0) {
            bunnyBag.add(letter['letter']);
            letter['count']--;
          } else {
            i--;
          }
        }
      });
    } else {
      talk('กระเป๋าเต็มแน้วTT');
    }
  }

  void select(String letter) {
    setState(() {
      if (selectedWord.length < carrotAtk) {
        selectedWord.add(letter);
        bunnyBag.remove(letter);
      } else {
        talk('ใส่ได้แค่ $carrotAtk ตัว');
      }
    });
  }

  void discard() {
    setState(() {
      selectedWord.clear();
    });
  }

  void drink(int count) {
    if (bunnyBag.length + selectedWord.length <= bagSize - count) {
      setState(() {
        List<String> letter = ['A', 'E', 'I', 'O', 'U'];
        bunnyBag.add(letter[Random().nextInt(letter.length)]);
        enemyAttack();
      });
    } else {
      talk('กระเป๋าเต็มแน้วTT');
    }
  }

  void clear() {
    setState(() {
      bunnyBag.addAll(selectedWord);
      selectedWord.clear();
    });
  }

  void draw(int count) {
    if (bunnyBag.length + selectedWord.length <= bagSize - count) {
      setState(() {
        for (int i = 0; i < count; i++) {
          if (bunnyBag.length >= 20) break;
          Map<String, dynamic> letter =
              letterScores[random.nextInt(letterScores.length)];
          if (letter['count'] > 0) {
            bunnyBag.add(letter['letter']);
            letter['count']--;
          } else {
            i--;
          }
        }
        enemyAttack();
      });
    } else {
      talk('กระเป๋าเต็มแน้วTT');
    }
  }

  void attack() async {
    String word = selectedWord.join('');
    if (word.isNotEmpty && !isAction) {
      setState(() {
        isAction = true;
        isPlayerTalk = true;
        bunnyPic = "Shoot";
        playerSub = '$word ! ';
      });
      bool isValid = await checkWordExists(word);
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          if (isValid && word.length > 1) {
            // ถ้าคำมีความหมาย และมากกว่า 1 ตัวอักษร
            playerSub = "เอาไปกิน";
            enemyHp = max(0, enemyHp - (word.length - 1)); 
            wordUsed.add(word); 
            selectedWord.clear(); 
          } else {
            playerSub = "ไม่ได้ผล";
            bunnyPic = "Stand";
          }
          // ถ้าแพ้
          if (enemyHp <= 0) {
            setState(() {
              isAction = true;
            });
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                isPlayerTalk = false;
                money += reward;
                retreatEnemy();
              });
            });
          } else {
            isAction = false;
            setState(() {
              isAction = true;
              isPlayerTalk = true;
              bunnyPic = "Stand";
            });
            Future.delayed(const Duration(seconds: 2), () {
              setState(() {
                isPlayerTalk = false;
                enemyAttack();
              });
            });
          }
        });
      });
    }
  }

  // เพิ่ม คำศัพท์ ลง Library
  Future<void> postWord(String word) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String uid = user.uid;
    CollectionReference wordBankRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('Library');

    QuerySnapshot querySnapshot =
        await wordBankRef.where('word', isEqualTo: word).get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot existingDoc = querySnapshot.docs.first;
      int currentTime = (existingDoc['times'] ?? 0) as int; // ป้องกัน null

      await wordBankRef.doc(existingDoc.id).update({
        'times': currentTime + 1,
      });
    } else {
      await wordBankRef.doc(word).set({
        'word': word,
        'times': 1,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // อัปเดท money
  Future<void> updateMoney(int money) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
        'money': money,
        'highScore': route,
      }, SetOptions(merge: true));
    }
  }

  // อัปเดต High Score
  Future<void> updateHighScore(int route) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('Users').doc(user.uid);

      DocumentSnapshot userSnapshot = await userRef.get();
      if (userSnapshot.exists) {
        Map<String, dynamic>? userData =
            userSnapshot.data() as Map<String, dynamic>?;

        int currentHighScore = userData?['highScore'] ?? 0;

        if (route > currentHighScore) {
          await userRef.set({
            'highScore': route,
          }, SetOptions(merge: true));
        }
      } else {
        await userRef.set({
          'highScore': route,
        });
      }
    }
  }

  // ดึงข้อมูล ผู้เล่น
  Future<Map<String, dynamic>?> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          bunnyName = doc['name'];
          money = doc['money'];
          bunnyBaseHp = hpScale[doc['hpLv']];
          bunnyHp = hpScale[doc['hpLv']];
          bagSize = bagSizeScale[doc['bagSizeLv']];
          carrotAtk = carrotAtkScale[doc['carrotLenghtLv']];
          drawPerTurn = drawPerTurnScale[doc['drawCountLv']];
        });
      }
    }
    return null; 
  }

  Future<void> fetchEnemyData(String enemy) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('enemy')
          .doc(enemy) // ชื่อเอกสารใน Firestore
          .get();

      if (doc.exists) {
        setState(() {
          enemyName = doc['name'];
          enemyPic = enemy;
          enemyTalk = doc['talk'];
          enemyHp = doc['hp'];
          enemyBaseHp = doc['hp'];
          enemyCooldown = 0;
          enemyBaseCooldown = doc['cooldown'];
          enemyAtk = doc['atk'];
        });
      }
    } catch (e) {
      print("Error fetching enemy: $e");
    }
  }

  @override
  void dispose() {
    isWalking = false; 
    super.dispose();
  }

  void MoveNextState() async {
    if (!mounted) return; 

    setState(() {
      isWalking = true;
      isAction = true;
      bunnyPic = "Walk1";
    });

    int elapsed = 0;
    while (elapsed < 200) {
      await Future.delayed(Duration(milliseconds: 500));
      if (!isWalking || !mounted)
        break; 

      if (!mounted) return; 
      setState(() {
        isAction = true;
        bunnyPic = (bunnyPic == "Walk1") ? "Walk2" : "Walk1";
        sceneX -= 10;
        if (sceneX <= -1000) sceneX = 0;
      });

      elapsed += 30;
    }

    if (!mounted) return; 
    setState(() {
      isWalking = false;
      isAction = true;
      bunnyPic = "Stand";
      if (state >= encounter.length) {
        state = 0;
        reward += 5;
      }
      spawnEnemy();
    });
  }

  void spawnEnemy() {
    setState(() {
      fetchEnemyData(encounter[state]);
      isAction = true; 
    });
    moveEnemy();
  }

  void moveEnemy() {
    // เริ่มต้นการเคลื่อนที่ของศัตรู
    Future.doWhile(() async {
      await Future.delayed(
          const Duration(milliseconds: 500)); 
      if (enemyX < 50) {
        setState(() {
          enemyX += 10; 
        });
        return true; 
      } else {
        setState(() {
          setState(() {
            isAction = true;
            isEnemyTalk = true; 
            enemySub = 'มาสู้กัน!';
          });

          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              isEnemyTalk = false;
              isAction = false;
            });
          });
        });
        return false; // หยุดลูป
      }
    });
  }

  void retreatEnemy() {
    Future.doWhile(() async {
      await Future.delayed(
          const Duration(milliseconds: 500)); 
      if (enemyX > -100) {
        setState(() {
          enemyX -= 10; 
        });
        return true; 
      } else {
        setState(() {
          state++;
          win(); 
        });
        return false; 
      }
    });
  }

  void enemyAttack() {
    if (enemyCooldown >= enemyBaseCooldown) {
      setState(() {
        isEnemyTalk = true;
        isAction = true;
        enemySub = enemyTalk;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isAction = false;
          isEnemyTalk = false;
          bunnyHp = max(0, bunnyHp - enemyAtk);
          enemyCooldown = 0;

          if (bunnyHp <= 0) {
            gameOver();
          }
        });
      });
    } else {
      setState(() {
        isEnemyTalk = true;
        isAction = true;
        enemySub =
            "ฉันจะโจมตีในอีก ${enemyBaseCooldown - enemyCooldown} เทิร์น";
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          isAction = false;
          isEnemyTalk = false;
          enemyCooldown++;
        });
      });
    }
  }

  void stop() {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) {
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
                      "ออกจากเกม?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "คุณจะไม่ได้รับรางวัลและคำศัพท์",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); 
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFB0E0E6), 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text("เล่นต่อ",
                              style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                              (route) => false, 
                            ); 
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFCC9A6), 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text("ออกจากเกม",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 🔹 หูกระต่าย (ซ้าย)
              Positioned(
                top: -60,
                left: 60,
                child: Container(
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
                ),
              ),

              // 🔹 หูกระต่าย (ขวา)
              Positioned(
                top: -60,
                right: 60,
                child: Container(
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void gameOver() {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
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
                      "คุณพ่ายแพ้",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "ได้เวลากลับบ้านไปพักแล้วเพื่อน",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        updateHighScore(route - 1);
                        updateMoney(money);
                        wordUsed.forEach((word) {
                          postWord(word);
                        });
                        Navigator.of(context).pop(); // ปิด Popup ก่อน
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                          (route) => false, 
                        ); 
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFCC9A6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text("ออกจากเกม",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),

              // 🔹 หูกระต่าย (ซ้าย)
              Positioned(
                top: -50,
                left: 60,
                child: Container(
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
                ),
              ),

              // 🔹 หูกระต่าย (ขวา)
              Positioned(
                top: -50,
                right: 60,
                child: Container(
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void win() {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
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
                      "คุณชนะแล้ว!",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "ได้รับ ${reward} แครอท 🥕",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            route++;
                            MoveNextState();
                            Navigator.of(context).pop(); 
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF98DDCA),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text("เดินหน้าต่อ",
                              style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            updateHighScore(route);
                            updateMoney(money);
                            wordUsed.forEach((word) {
                              postWord(word);
                            });

                            Navigator.of(context).pop(); 
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeScreen()),
                              (route) => false, 
                            ); 
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFCC9A6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text("กลับบ้าน",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 🔹 หูกระต่าย (ซ้าย)
              Positioned(
                top: -50,
                left: 60,
                child: Container(
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
                ),
              ),

              // 🔹 หูกระต่าย (ขวา)
              Positioned(
                top: -50,
                right: 60,
                child: Container(
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// popup วิธีเล่น
  void howtoPlay() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            height: 400,
            width: 300,
            child: TutorialSlider(),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
    pickWord(5);

    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) MoveNextState(); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFc9e9d2),
      body: Column(
        children: [
          // หน้าจอแสดงเกม
          Container(
            width: double.infinity,
            height: 220,
            child: Stack(
              children: [
                // Background ที่ขยับได้
                Positioned(
                  left: sceneX,
                  top: 0,
                  child: Image.asset("assets/images/bg.png",
                      width: 1000, height: 220, fit: BoxFit.cover),
                ),
                // Background ซ้ำ เพื่อให้ดูเหมือนไม่มีที่สิ้นสุด
                Positioned(
                  left: sceneX + 1000,
                  top: 0,
                  child: Image.asset("assets/images/bg.png",
                      width: 1000, height: 220, fit: BoxFit.cover),
                ),
                // ปุ่มหยุดเกม
                Positioned(
                    top: 10,
                    left: MediaQuery.of(context).size.width / 2 - 15,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(255, 92, 92, 92),
                              width: 2),
                          color: Colors.white),
                      child: IconButton(
                        icon: Icon(Icons.pause,
                            color: const Color.fromARGB(255, 115, 115, 115)),
                        onPressed: () {
                          stop();
                        },
                      ),
                    )),
                // ปุ่มสอนเล่น
                Positioned(
                    top: 20,
                    right: 10,
                    child: Container(
                      width: 33,
                      height: 33,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(255, 92, 92, 92),
                              width: 2),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Center(
                          child: IconButton(
                        onPressed: () {
                          howtoPlay();
                        },
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.question_mark,
                            size: 18,
                            color: const Color.fromARGB(255, 115, 115, 115)),
                      )),
                    )),
                // แสดงจำนวนคำในแครอทปัจจุบัน
                Positioned(
                  top: 40,
                  left: 15,
                  child: Row(
                    children: [
                      Transform.rotate(
                        angle: -45 * 3.14159 / 180,
                        child: Image.asset(
                          'assets/images/carrot.png',
                          height: 20,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '${money}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // โชว์ Score
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(
                    children: [
                      Text(
                        'Score ${route}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // ตัวละคร Bunny
                Positioned(
                  left: 50,
                  bottom: 30,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Column(
                        children: [
                          Text('$bunnyName',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          buildHealthBar(bunnyHp, bunnyBaseHp),
                          SizedBox(height: 5),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/bunny/${bunnyPic}.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                // กล่องคำพูดกระต่าย
                Positioned(
                  left: 120,
                  top: 110,
                  child: Visibility(
                    visible: isPlayerTalk,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color.fromARGB(255, 193, 193, 193)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 200,
                          ),
                          child: Text(
                            playerSub,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // ตัวละคร ศัตรู
                Positioned(
                  right: enemyX,
                  bottom: 30,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Column(
                        children: [
                          Text('$enemyName',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          buildHealthBar(enemyHp, enemyBaseHp),
                          SizedBox(height: 5),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/enemy/${enemyPic}.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                //กล่องคำพูด ศัตรู
                Positioned(
                  right: enemyX + 20,
                  top: 70,
                  child: Visibility(
                    visible: isEnemyTalk,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: const Color.fromARGB(255, 193, 193, 193)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 200,
                          ),
                          child: Text(
                            enemySub,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          // แครอท
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ด้ามแครอท
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 40,
                    color: Colors.green,
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 60,
                    color: Colors.green,
                  ),
                ],
              ),
              // body ของแครอทไว้ใส่คำ
              Container(
                height: 80,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 251, 122, 75),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 5.0,
                  children: selectedWord
                      .map((letter) => Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 206, 182),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              letter,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ))
                      .toList(),
                ),
              ),
              // ปลายแครอทกลมๆ
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 251, 122, 75),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 30),
          // กระเป๋าคำศัพท์ของกระต่าย
          Container(
            height: 260,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                      top: 40, left: 16, right: 16, bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.brown[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(1.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 1.3,
                            crossAxisSpacing: 2.0,
                            mainAxisSpacing: 2.0,
                          ),
                          itemCount: bunnyBag.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: isAction
                                  ? null
                                  : () => select(bunnyBag[index]),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 4,
                                color: const Color.fromARGB(255, 255, 242, 215),
                                child: Center(
                                  child: Text(
                                    bunnyBag[index],
                                    style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Bag Label
                Positioned(
                  top: -20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 180,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 139, 109, 97),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bag',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${bunnyBag.length + selectedWord.length}/$bagSize',
                            style: TextStyle(
                              fontSize: 15,
                              color: const Color.fromARGB(255, 220, 220, 220),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // แถบการกดปุ่ม Action ต่างๆ
          Container(
            width: 500,
            height: 107,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 139, 109, 97),
              border: Border(
                top: BorderSide(
                  color: const Color.fromARGB(255, 105, 83, 74),
                  width: 4,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Column 1 (Draw, Drink)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: isAction ? null : () => draw(drawPerTurn),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 255, 225, 137),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: Text('Draw (${drawPerTurn.toString()})'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: isAction ? null : () => drink(1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 173, 248, 176),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Drink (1)'),
                      ),
                    ),
                  ],
                ),
                // Column 2 (Spell)
                SizedBox(
                  width: 150,
                  height: 80,
                  child: ElevatedButton(
                    onPressed: isAction ? null : () => attack(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 251, 171, 121),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      textStyle: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Spell'),
                  ),
                ),
                // Column 3 (Clear, Delete)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: isAction ? null : () => clear(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 141, 234, 255),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Clear'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 100,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: isAction ? null : () => discard(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 255, 102, 102),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Discard'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildHealthBar(int currentHp, int maxHp) {
  double percentage = currentHp / maxHp;
  Color barColor;

  if (percentage > 0.7) {
    barColor = Colors.green; // มากกว่า 70% เป็นสีเขียว
  } else if (percentage > 0.3) {
    barColor = Colors.orange; // ระหว่าง 30% - 70% เป็นสีส้ม
  } else {
    barColor = Colors.red; // ต่ำกว่า 30% เป็นสีแดง
  }

  return Container(
    width: 100,
    height: 15,
    decoration: BoxDecoration(
      border: Border.all(color: const Color.fromARGB(255, 46, 46, 46)),
      borderRadius: BorderRadius.circular(10),
      color: Colors.grey[300],
    ),
    child: Stack(
      children: [
        // แถบพลังชีวิต
        FractionallySizedBox(
          widthFactor: percentage,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: barColor,
            ),
          ),
        ),
        // ข้อความแสดง HP
        Center(
          child: Text(
            "$currentHp / $maxHp",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ],
    ),
  );
}
