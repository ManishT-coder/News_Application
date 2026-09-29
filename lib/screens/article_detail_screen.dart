import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/article_model.dart';
import '../widgets/article_widgets.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  // Browser mein poori news kholne ke liye
  void _openBrowser() async {
    final url = Uri.parse(article.url);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: articleHeroTag(article),
                child: CachedNetworkImage(imageUrl: article.urlToImage, fit: BoxFit.cover),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.sourceName, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(article.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text(article.description, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  // Snippet content
                  Text(article.content.replaceAll(RegExp(r'\[\+\d+ chars\]'), '')),
                  const SizedBox(height: 30),
                  // Full news button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _openBrowser,
                      child: const Text("READ FULL DOCUMENT"),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}