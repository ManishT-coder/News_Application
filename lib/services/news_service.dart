import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

// Agar internet fetch mein galti ho toh yeh use hoga
class NewsException implements Exception {
  final String message;
  NewsException(this.message);
}

// Ek page ka data store karne ke liye
class NewsPage {
  final List<Article> articles;
  final int totalResults;
  NewsPage({required this.articles, required this.totalResults});
}

class NewsService {
  static const String myKey = '6d11aa80e6fa458bb7e23b218637a169';

  // Headlines laane ke liye function
  static Future<NewsPage> getTopHeadlines({required String category, int page = 1}) async {
    final url = 'https://newsapi.org/v2/top-headlines?country=us&category=$category&page=$page&apiKey=$myKey';
    return _fetchFromNetwork(url);
  }

  // Search karne ke liye function
  static Future<NewsPage> searchNews(String query, {int page = 1}) async {
    final url = 'https://newsapi.org/v2/everything?q=$query&page=$page&apiKey=$myKey';
    return _fetchFromNetwork(url);
  }

  // Common function jo internet se data lata hai
  static Future<NewsPage> _fetchFromNetwork(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List rawList = data['articles'] ?? [];

      List<Article> validArticles = [];
      for (var item in rawList) {
        final article = Article.tryParse(item);
        if (article != null) {
          validArticles.add(article); // Sirf wahi add karo jinki image aur title ho
        }
      }
      return NewsPage(articles: validArticles, totalResults: data['totalResults'] ?? 0);
    } else {
      throw NewsException("News load nahi ho saki!");
    }
  }
}