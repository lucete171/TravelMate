import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class TravelLogPage extends StatefulWidget {
  @override
  _TravelLogPageState createState() => _TravelLogPageState();
}

class _TravelLogPageState extends State<TravelLogPage> {
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _placeNameController = TextEditingController();
  int _rating = 0;
  List<File> _images = [];
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((pickedFile) => File(pickedFile.path)).toList();
      });
    }
  }

  Future<void> _submitLog() async {
    if (_reviewController.text.isEmpty || _rating == 0 || _images.isEmpty || _placeNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('모든 필드를 채워주세요!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인이 필요합니다.')),
        );
        return;
      }

      // Firebase Storage에 이미지 업로드
      List<String> imageUrls = [];
      for (File image in _images) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('travel_logs/${DateTime.now().toIso8601String()}.jpg');
        await storageRef.putFile(image);
        final imageUrl = await storageRef.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      // Firestore에 여행 기록 저장
      await FirebaseFirestore.instance.collection('travel_logs').add({
        'userId': user.uid,
        'placeName': _placeNameController.text,
        'review': _reviewController.text,
        'rating': _rating,
        'imageUrls': imageUrls,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('여행 기록이 저장되었습니다!')),
      );

      // 기록 저장 후 페이지 닫기
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('여행 기록 작성'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            _buildTitleText('방문지명'),
            SizedBox(height: 8),
            _buildTextField(_placeNameController, '방문지 이름을 작성해주세요'),
            SizedBox(height: 16),
            _buildTitleText('사진 업로드'),
            SizedBox(height: 8),
            _images.isNotEmpty
                ? Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _images.map((image) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(
                        image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _images.remove(image);
                          });
                        },
                        child: Icon(Icons.remove_circle, color: Colors.red),
                      ),
                    ),
                  ],
                );
              }).toList(),
            )
                : Container(
              height: 200.0,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Center(
                child: Text(
                  '선택된 사진이 없습니다.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.photo_library),
              label: Text('사진 선택'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 16),
            _buildTitleText('여행 후기 작성'),
            SizedBox(height: 8),
            _buildTextField(_reviewController, '여행 후기를 작성해주세요', maxLines: 4),
            SizedBox(height: 16),
            _buildTitleText('별점'),
            SizedBox(height: 8),
            Row(
              children: [
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    icon: Icon(
                      i <= _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = i;
                      });
                    },
                  ),
              ],
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Center(
              child: ElevatedButton(
                onPressed: _submitLog,
                child: Text('저장'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.deepPurpleAccent,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurpleAccent,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
