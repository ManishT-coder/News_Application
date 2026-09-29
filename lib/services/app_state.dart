import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article_model.dart';

// Manages dark/light mode setting
class AppSettings extends ChangeNotifier {
  AppSettings();
  static final AppSettings instance = AppSettings();

  bool isDark = false;
  bool get is_Dark => isDark;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isDark = prefs.getBool('isDark') ?? false;
    } catch (_) {}
  }

  Future<void> toggleDark() async {
    isDark = !isDark;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDark', isDark);
    } catch (_) {}
  }
}

// Manages saved / bookmarked articles
class BookmarkStore extends ChangeNotifier {
  BookmarkStore();
  static final BookmarkStore instance = BookmarkStore();

  static const key = 'bookmarks';
  final List<Article> items = [];

  List<Article> get all   => List.unmodifiable(items);
  int  get count          => items.length;
  bool isSaved(String url) =>items.any((a) => a.url == url);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final raw in prefs.getStringList(key) ?? []) {
        final decoded = json.decode(raw);
        if (decoded is Map<String, dynamic>) {
          final article = Article.tryParse(decoded);
          if (article != null) items.add(article);
        }
      }
    } catch (_) {}
  }

  Future<void> toggle(Article article) async {
    final index = items.indexWhere((a) => a.url == article.url);
    if (index >= 0) {
      items.removeAt(index);
    } else {
      items.insert(0, article);
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        key,
        items.map((a) => json.encode(a.toJson())).toList(),
      );
    } catch (_) {}
  }
}