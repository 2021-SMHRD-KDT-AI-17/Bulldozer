import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class NewsBoard extends StatefulWidget {
  @override
  _NewsBoardState createState() => _NewsBoardState();
}

class _NewsBoardState extends State<NewsBoard> {
  late Future<List<NewsArticle>> articles;

  @override
  void initState() {
    super.initState();
    articles = fetchArticles();
  }

  Future<List<NewsArticle>> fetchArticles() async {
    final String query = '온라인 불법 도박';
    final String apiKey = '0qyrt38nls'; // 여기에 실제 API 키를 입력하세요.
    //primary secondary 다 안먹음
    final String url =
        'https://openapi.naver.com/v1/search/news.json?query=$query&display=4&start=1&sort=sim'; // display를 4로 수정

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'X-Naver-Client-Id': 'koFk3KEI3f6cqvu6Ofzz', // 여기에 실제 클라이언트 ID를 입력하세요.
        'X-Naver-Client-Secret': 'llgy_VBswa', // 여기에 실제 클라이언트 Secret을 입력하세요.
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final items = jsonResponse['items'] as List<dynamic>;

      final articles = items.map((item) => NewsArticle.fromJson(item)).toList();

      final updatedArticles = await fetchImagesForArticles(articles);

      return updatedArticles;
    } else {
      throw Exception('Failed to load articles');
    }
  }

  Future<List<NewsArticle>> fetchImagesForArticles(
      List<NewsArticle> articles) async {
    final response = await http.post(
      Uri.parse('http://192.168.219.66:5000/get_news_images'),
      // 서버 URL에 맞게 변경하세요.
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'articles': articles}),
    );

    if (response.statusCode == 200) {
      final jsonResponse =
      json.decode(response.body)['articles'] as List<dynamic>;
      return jsonResponse.map((item) => NewsArticle.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch images for articles');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewsArticle>>(
      future: articles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load articles'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No articles found'));
        } else {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 5,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final article = snapshot.data![index];
              final formattedDate = DateFormat('yyyy.MM.dd(E) HH:mm').format(
                  DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", "en_US")
                      .parse(article.pubDate)); // 날짜 포맷 수정
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(article.title),
                      content: Text('기사로 이동하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            launchURL(article.link);
                          },
                          child: Text('확인'),
                        ),
                      ],
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      article.img.isNotEmpty
                          ? Image.network(
                        article.img,
                        fit: BoxFit.cover,
                        height: 120,
                        width: double.infinity,
                      )
                          : Container(
                        height: 120,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          article.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          article.desc,
                          style: TextStyle(
                            fontSize: 11,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                        child: Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// 뉴스 기사 모델 클래스
class NewsArticle {
  final String title;
  final String link;
  final String img;
  final String desc;
  final String pubDate; // pubDate 필드 추가

  NewsArticle(
      {required this.title,
        required this.link,
        required this.img,
        required this.desc,
        required this.pubDate}); // pubDate 매개변수 추가

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
      // HTML 태그 제거
      link: json['originallink'] ?? json['link'],
      img: json['img'] ?? '',
      desc: json['description'].replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ''),
      // HTML 태그 제거
      pubDate: json['pubDate'], // pubDate 필드 매핑
    );
  }
}