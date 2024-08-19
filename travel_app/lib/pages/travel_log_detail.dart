import 'package:flutter/material.dart';
import '../widget/reuseable_text.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 추가

class TravelLogDetailPage extends StatelessWidget {
  final List<dynamic> imageUrls; // 여러 개의 이미지 URL을 담을 리스트
  final int rating;
  final String review;
  final String placeName; // 사용자가 작성한 방문지 이름
  final DateTime timestamp; // 작성일을 받기 위해 추가

  TravelLogDetailPage({
    required this.imageUrls,
    required this.rating,
    required this.review,
    required this.placeName,
    required this.timestamp, // 작성일을 받도록 수정
  });

  @override
  Widget build(BuildContext context) {
    // 작성일을 원하는 형식으로 변환
    String formattedDate = DateFormat('yyyy년 MM월 dd일').format(timestamp);

    return Scaffold(
      appBar: AppBar(
        title: Text('여행 기록 상세'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 여러 장의 이미지를 슬라이드하여 볼 수 있도록 PageView를 사용
            imageUrls.isNotEmpty
                ? Container(
              height: 300, // 이미지를 더 크게 보여줍니다.
              child: PageView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: NetworkImage(imageUrls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            )
                : Placeholder(fallbackHeight: 300.0),
            SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.place, color: Colors.deepPurpleAccent),
                SizedBox(width: 8),
                Text(
                  placeName, // 방문지 이름을 텍스트로 표시
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                AppText(
                    text: "별점",
                    size: 18,
                    color: Colors.purple,
                    fontWeight: FontWeight.bold),
                SizedBox(width: 8),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    );
                  }),
                ),
                SizedBox(width: 8),
                Text(
                  '$rating/5',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              '작성일: $formattedDate',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 24),
            Text(
              '후기',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                review,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5, // 텍스트 간격을 적당히 조절
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
