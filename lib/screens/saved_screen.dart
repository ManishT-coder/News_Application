import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../widgets/article_widgets.dart'; // Correctly imports GridDelegate and Cards
import 'article_detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Stories')),
      body: ListenableBuilder(
        listenable: BookmarkStore.instance,
        builder: (context, _) {
          final items = BookmarkStore.instance.items;

          if (items.isEmpty) {
            return const Center(child: Text('No saved stories yet.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: articleGridDelegate, // Uses the shared delegate
            itemCount: items.length,
            itemBuilder: (context, i) {
              return ArticleCard(
                article: items[i],
                useHero: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: items[i])),
                ),
              );
            },
          );
        },
      ),
    );
  }
}