import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/category_model.dart';

class CategoryDetailPage extends StatefulWidget {
  final Category category;

  CategoryDetailPage({required this.category});

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 네이버 검색 URL 생성
    final String searchUrl = 'https://search.naver.com/search.naver?query=제주도+${Uri.encodeComponent(widget.category.name)}';

    // WebViewController 초기화
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (finish) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(searchUrl)); // 네이버 검색 결과 로드
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.name} 검색 결과'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _controller.reload(); // 웹뷰 리로드
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading) Center(child: CircularProgressIndicator()), // 로딩 인디케이터
        ],
      ),
    );
  }
}
