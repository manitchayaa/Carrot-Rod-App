import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Color> colors = [
    Colors.yellow[100]!,
    Colors.pink[100]!,
    Colors.blue[100]!,
  ];

  String sortBy = 'default';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 550,
        width: double.infinity,
        padding: const EdgeInsets.only(top: 20),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage("assets/images/libraryRoom.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          
          children: [
            
            SizedBox(height: 40,),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('Library')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No words in library"));
                  }

                  var words = snapshot.data!.docs.where((doc) {
                    var word = doc['word'];
                    return word != null && word.toString().trim().isNotEmpty;
                  }).toList();

                  // เรียงเมื่อกดปุ่ม
                  if (sortBy == 'word') {
                    words.sort((a, b) => (a['word'] ?? '').compareTo(b['word'] ?? ''));
                  } else if (sortBy == 'times') {
                    words.sort((a, b) => (b['times'] ?? 0).compareTo(a['times'] ?? 0));
                  }

                  if (words.isEmpty) {
                    return Center(child: Text("No words in library"));
                  }

                  return Container(
                    //color: Colors.amber,
                    height: 200, // จำกัดขนาดพื้นที่กริด
                    margin: EdgeInsets.only(top: 90, right: 90,left: 90,bottom: 125),
                    child:  GridView.builder(
                        physics: ClampingScrollPhysics(), // ให้เลื่อนเมื่อมีมากกว่า 9
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: words.length,
                        itemBuilder: (context, index) {
                          var wordData = words[index];
                          return _WordCard(
                            word: wordData['word'] ?? '',
                            times: wordData['times'] ?? 0,
                            color: colors[index % colors.length],
                          );
                        },
                      ),
                    );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 248, 229, 229),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.update),
                    title: Text("เรียงตามล่าสุด"),
                    onTap: () {
                      setState(() {
                        sortBy = 'default'; // **กลับไปใช้ Stack**
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.sort_by_alpha),
                    title: Text("เรียงตามตัวอักษร (A-Z)"),
                    onTap: () {
                      setState(() {
                        sortBy = 'word';
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.timer),
                    title: Text("เรียงตามจำนวนคำที่ใช้มากที่สุด"),
                    onTap: () {
                      setState(() {
                        sortBy = 'times';
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.filter_list),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _WordCard extends StatelessWidget {
  final String word;
  final int times;
  final Color color;

  const _WordCard({
    required this.word,
    required this.times,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(5, 5),
            spreadRadius: 1,
          )
        ],
      ),
      
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            word,
            style: TextStyle(fontSize: 12, fontFamily: 'LexendMedium'),
          ),
          SizedBox(height: 10),
          Text("$times times",
              style: TextStyle(fontSize: 10, fontFamily: 'LexendMedium')),
        ],
      ),
    );
  }
}
