import 'package:flutter/material.dart';

class TutorialSlider extends StatefulWidget {
  @override
  State<TutorialSlider> createState() => _TutorialSliderState();
}

class _TutorialSliderState extends State<TutorialSlider> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  // ✅ รายการรูปภาพที่ต้องการแสดงใน Tutorial
  final List<String> _imageList = [
    "assets/images/tutorial/01.png",
    "assets/images/tutorial/02.png",
    "assets/images/tutorial/03.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔹 PageView สำหรับเลื่อน Tutorial
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _imageList.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(_imageList[index], fit: BoxFit.cover),
              );
            },
          ),
        ),

        // 🔹 จุด Indicator แสดงหน้าปัจจุบัน
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_imageList.length, (index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.orange : Colors.grey,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
        SizedBox(height: 10,),
        // 🔹 ปุ่ม "ปิด"
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("ปิด", style: TextStyle(fontSize: 18, color: const Color.fromARGB(255, 243, 114, 33))),
        ),
      ],
    );
  }
}
