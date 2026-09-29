import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/article_model.dart';
import '../services/news_service.dart';
import '../widgets/article_widgets.dart';
import '../models/brand_logo.dart';
import 'article_detail_screen.dart';

const categories = [
  'general',
  'technology',
  'business',
  'sports',
  'health',
  'science',
  'entertainment',
];

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  const HomeScreen({super.key, required this.isDarkMode, required this.onThemeToggle});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String category = 'general';
  String query = '';
  bool isSearching = false;
  List<Article> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadNews();
  }

  // News load karne ka simple function
  Future<void> loadNews() async {
    setState(() => isLoading = true);
    try {
      final result = query.isEmpty
          ? await NewsService.getTopHeadlines(category: category)
          : await NewsService.searchNews(query);
      setState(() {
        articles = result.articles;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
          decoration: const InputDecoration(hintText: 'Search...'),
          onSubmitted: (val) {
            query = val;
            loadNews();
          },
        )
            : const AmNewsWordmark(),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            tooltip: isSearching ? 'Close Search' : 'Search',
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  query = '';
                  loadNews();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sports_esports),
            tooltip: 'Games Arcade',
            onPressed: () => Navigator.pushNamed(context, '/games'),
          ),
          IconButton(
            icon: const Icon(Icons.bookmarks),
            tooltip: 'Saved Stories',
            onPressed: () => Navigator.pushNamed(context, '/saved'),
          ),
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: loadNews,
        child: CustomScrollView(
          slivers: [
            // 1. Contextual Greeting Header
            const SliverToBoxAdapter(
              child: Greeting(),
            ),

            // 2. Category List & Games Shortcut Chip
            SliverToBoxAdapter(
              child: SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    // Quick-access Games Chip
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      // child: ActionChip(
                      //   avatar: const Icon(Icons.sports_esports, size: 18),
                      //   label: const Text('🎮 Games'),
                      //   backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      //   onPressed: () => Navigator.pushNamed(context, '/games'),
                      // ),
                    ),
                    ...categories.map((cat) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: ChoiceChip(
                        label: Text(cat[0].toUpperCase() + cat.substring(1)),
                        selected: category == cat && query.isEmpty,
                        onSelected: (val) {
                          setState(() {
                            category = cat;
                            query = '';
                          });
                          loadNews();
                        },
                      ),
                    )),
                  ],
                ),
              ),
            ),

            // 3. Featured / Hero Top Story Card (1st Article)
            if (articles.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: FeaturedCard(
                    article: articles.first,
                    label: '🔥 BREAKING / TOP STORY',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => ArticleDetailScreen(article: articles.first),
                      ),
                    ),
                  ),
                ),
              ),

            // 4. Main News Grid (Remaining Articles)
            if (articles.length > 1)
              SliverPadding(
                padding: const EdgeInsets.all(10),
                sliver: SliverGrid(
                  gridDelegate: articleGridDelegate,
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final article = articles[index + 1];
                      return ArticleCard(
                        article: article,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => ArticleDetailScreen(article: article),
                          ),
                        ),
                      );
                    },
                    childCount: articles.length - 1,
                  ),
                ),
              )
            else if (articles.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.all(10),
                sliver: SliverGrid(
                  gridDelegate: articleGridDelegate,
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => ArticleCard(
                      article: articles[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => ArticleDetailScreen(article: articles[index]),
                        ),
                      ),
                    ),
                    childCount: articles.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Small widgets ─────────────────────────────────────────────────────────────

class Greeting extends StatelessWidget {
  const Greeting({super.key});

  @override
  Widget build(BuildContext context) {
    final now   = DateTime.now();
    final hour  = now.hour;
    final theme = Theme.of(context);

    final (text, icon) = switch (hour) {
      < 5  => ('Up late?',         Icons.nightlight_round),
      < 12 => ('Good morning',     Icons.wb_sunny),
      < 17 => ('Good afternoon',   Icons.wb_sunny_outlined),
      < 21 => ('Good evening',     Icons.wb_twilight),
      _    => ('Good night',       Icons.nightlight_round),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: theme.colorScheme.secondary),
            const SizedBox(width: 8),
            Text(text,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 2),
          Text(
            DateFormat('EEEE, MMM d').format(now),
            style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorMessage({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.cloud_off, size: 52),
          const SizedBox(height: 16),
          Text("Couldn't load news",
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Try again')),
        ]),
      ),
    );
  }
}