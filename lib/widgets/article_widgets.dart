import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/article_model.dart';
import '../services/app_state.dart';

// Hero animation ke liye unique name
String articleHeroTag(Article a) => 'img-${a.url}';

// Grid ki settings: 2 columns
const articleGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 250,
  mainAxisSpacing: 10,
  crossAxisSpacing: 10,
  childAspectRatio: 0.75,
);

// Bookmark Button Widget
class BookmarkButton extends StatelessWidget {
  final Article article;
  const BookmarkButton({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: BookmarkStore.instance,
      builder: (context, _) {
        bool saved = BookmarkStore.instance.isSaved(article.url);
        return Container(
          decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
          child: IconButton(
            icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
            color: saved ? Colors.amber : Colors.white,
            onPressed: () => BookmarkStore.instance.toggle(article),
          ),
        );
      },
    );
  }
}

// Chhota News Card (Grid ke liye)
class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final bool useHero;

  const ArticleCard({super.key, required this.article, required this.onTap, this.useHero = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: useHero ? articleHeroTag(article) : 'no-hero-${article.url}',
                    child: CachedNetworkImage(
                      imageUrl: article.urlToImage,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Container(color: Colors.grey[200]),
                      errorWidget: (c, u, e) => const Icon(Icons.broken_image),
                    ),
                  ),
                  Positioned(top: 0, right: 0, child: BookmarkButton(article: article)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(article.title, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            )
          ],
        ),
      ),
    );
  }
}

// Bada Featured Card (Top story / Hero ke liye)
class FeaturedCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final String label;

  const FeaturedCard({super.key, required this.article, required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: articleHeroTag(article),
                child: CachedNetworkImage(
                  imageUrl: article.urlToImage,
                  fit: BoxFit.cover,
                  placeholder: (c, u) => Container(color: Colors.grey[200]),
                  errorWidget: (c, u, e) => const Icon(Icons.broken_image),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              Positioned(top: 4, right: 4, child: BookmarkButton(article: article)),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      article.sourceName,
                      style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Loading ke time dikhne wale box (Skeletons)
class ArticleCardSkeleton extends StatelessWidget {
  const ArticleCardSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(color: Colors.grey[300]);
  }
}

class FeaturedCardSkeleton extends StatelessWidget {
  const FeaturedCardSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(height: 200, color: Colors.grey[300]);
  }
}