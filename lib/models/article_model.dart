import 'package:intl/intl.dart';

class Article {
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String publishedAt;
  final String sourceName;
  final String content;

  // Constructor: Article banane ke liye
  const Article({
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.sourceName,
    required this.content,
  });

  // JSON data (Internet se aaya data) ko Article object mein badalne ke liye
  static Article? tryParse(Map<String, dynamic> json) {
    String title = json['title'] ?? "";
    String imageUrl = json['urlToImage'] ?? "";

    // Agar title ya image nahi hai, toh use skip kar do
    if (title.isEmpty || title == '[Removed]' || imageUrl.isEmpty) {
      return null;
    }

    return Article(
      title: title,
      description: json['description'] ?? "",
      url: json['url'] ?? "",
      urlToImage: imageUrl.replaceFirst('http://', 'https://'), // Safety ke liye https
      publishedAt: json['publishedAt'] ?? "",
      sourceName: json['source']?['name'] ?? "News",
      content: json['content'] ?? "",
    );
  }

  // Object ko wapas JSON banane ke liye (Saving ke liye kaam aata hai)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'source': {'name': sourceName},
      'content': content,
    };
  }

  // Time ko readable banane ke liye (e.g. "5 mins ago")
  String get timeAgo {
    DateTime? d = DateTime.tryParse(publishedAt);
    if (d == null) return "";
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    return DateFormat('MMM d').format(d);
  }
}