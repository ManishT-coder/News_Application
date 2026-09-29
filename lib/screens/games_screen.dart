import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Arcade Hub ──────────────────────────────────────────────────────────────

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('Games Hub', style: TextStyle(fontWeight: FontWeight.w900)),
            floating: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(context),
                const SizedBox(height: 24),

                _ArcadeTile(
                  title: 'Word Scramble',
                  subtitle: 'Unscramble news terms',
                  emoji: '🔤',
                  colors: [Colors.indigo.shade400, Colors.indigo.shade700],
                  onTap: () => _push(context, const WordScrambleGame()),
                ),

                const SizedBox(height: 16),

                _ArcadeTile(
                  title: 'News Quiz',
                  subtitle: 'Test your media literacy',
                  emoji: '🧠',
                  colors: [Colors.teal.shade400, Colors.teal.shade700],
                  onTap: () => _push(context, const QuizGame()),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Take a Break 🎮',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Earn badges by testing your knowledge',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
      ],
    );
  }
}

class _ArcadeTile extends StatelessWidget {
  final String title, subtitle, emoji;
  final List<Color> colors;
  final VoidCallback onTap;

  const _ArcadeTile({
    required this.title, required this.subtitle,
    required this.emoji, required this.colors, required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [
          BoxShadow(
              color: colors.last.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6)
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_fill, color: Colors.white, size: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Game 1: Word Scramble ────────────────────────────────────────────────────

class WordScrambleGame extends StatefulWidget {
  const WordScrambleGame({super.key});

  @override
  State<WordScrambleGame> createState() => _WordScrambleGameState();
}

class _WordScrambleGameState extends State<WordScrambleGame> {
  final List<(String, String)> _allWords = [
    ('NEWS', 'Daily information reported'),
    ('EDITOR', 'Person who manages publications'),
    ('SOURCE', 'Where the info comes from'),
    ('ARTICLE', 'A specific piece of writing'),
    ('BREAKING', 'News happening right now'),
    ('HEADLINE', 'The title of a story'),
    ('REPORTER', 'Person who hunts for stories'),
    ('TABLOID', 'Sensationalist newspaper'),
    ('JOURNAL', 'A daily record of events'),
    ('OPINION', 'A non-factual news piece'),
  ];

  late List<(String, String)> _gameSessionWords;
  int _currentIndex = 0;
  int _score = 0;
  bool _isGameOver = false;

  String _currentScrambled = "";
  String? _feedback;
  bool _isLastAnswerCorrect = false;

  final TextEditingController _textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    _gameSessionWords = List.from(_allWords)..shuffle(math.Random());
    _currentIndex = 0;
    _score = 0;
    _isGameOver = false;
    _loadWord();
  }

  void _loadWord() {
    if (_currentIndex >= _gameSessionWords.length) {
      setState(() => _isGameOver = true);
      return;
    }

    String original = _gameSessionWords[_currentIndex].$1.toUpperCase();
    String scrambled = _scrambleLogic(original);

    setState(() {
      _currentScrambled = scrambled;
      _feedback = null;
      _textCtrl.clear();
    });
  }

  String _scrambleLogic(String word) {
    List<String> chars = word.split('');
    while (true) {
      chars.shuffle(math.Random());
      if (chars.join() != word || word.length <= 1) break;
    }
    return chars.join();
  }

  void _checkAnswer() {
    final userAnswer = _textCtrl.text.trim().toUpperCase();
    final correctAnswer = _gameSessionWords[_currentIndex].$1.toUpperCase();

    if (userAnswer == correctAnswer) {
      HapticFeedback.lightImpact();
      setState(() {
        _score += 10;
        _isLastAnswerCorrect = true;
        _feedback = "CORRECT! +10 Points";
      });
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _isLastAnswerCorrect = false;
        _feedback = "WRONG! It was $correctAnswer";
      });
    }
  }

  void _handleNext() {
    _currentIndex++;
    if (_currentIndex < _gameSessionWords.length) {
      _loadWord();
    } else {
      setState(() => _isGameOver = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isGameOver) return _buildGameOverScreen();

    final (_, hint) = _gameSessionWords[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Word ${_currentIndex + 1}/${_gameSessionWords.length}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _ScoreCard(score: _score),
            const SizedBox(height: 40),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _currentScrambled.split('').map((c) => _LetterTile(char: c)).toList(),
            ),

            const SizedBox(height: 16),
            Text('Hint: $hint',
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),

            const SizedBox(height: 40),

            TextField(
              controller: _textCtrl,
              autofocus: true,
              enabled: _feedback == null,
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4),
              decoration: InputDecoration(
                hintText: '???',
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) { if (_feedback == null) _checkAnswer(); },
            ),

            const SizedBox(height: 32),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _feedback == null
                  ? SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _checkAnswer,
                  style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('CHECK ANSWER', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
                  : _ResultBanner(
                message: _feedback!,
                isSuccess: _isLastAnswerCorrect,
                isLast: _currentIndex + 1 == _gameSessionWords.length,
                onNext: _handleNext,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              const Text('ALL DONE!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('You unscrambled all our words.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              _ScoreCard(score: _score),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('BACK TO HUB'),
                ),
              ),
              TextButton(onPressed: _startNewGame, child: const Text('PLAY AGAIN')),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Game 2: News Quiz ────────────────────────────────────────────────────────

class QuizGame extends StatefulWidget {
  const QuizGame({super.key});
  @override
  State<QuizGame> createState() => _QuizGameState();
}

class _QuizGameState extends State<QuizGame> {
  static const questions = [
    ('Who owns most global media outlets?', ['Governments', 'Conglomerates', 'Non-profits', 'Public'], 1),
    ('What is "Clickbait"?', ['Fish food', 'Sensational headers', 'A mouse part', 'Legal term'], 1),
    ('Reliable news usually cites...', ['Memes', 'Anonymous blogs', 'Multiple sources', 'Twitter polls'], 2),
  ];

  int qIdx = 0, score = 0;
  int? chosen;
  bool done = false;

  void _answer(int i) {
    if (chosen != null) return;
    if (i == questions[qIdx].$3) {
      score++;
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
    setState(() => chosen = i);
  }

  @override
  Widget build(BuildContext context) {
    if (done) return _buildResults();

    final (q, options, correct) = questions[qIdx];

    return Scaffold(
      appBar: AppBar(title: Text('Question ${qIdx + 1}/${questions.length}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: (qIdx + 1) / questions.length, minHeight: 8),
            ),
            const SizedBox(height: 40),
            Text(q, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ...List.generate(options.length, (i) => _OptionTile(
              text: options[i],
              index: i,
              state: chosen == null ? _OptionState.idle : (i == correct ? _OptionState.correct : (i == chosen ? _OptionState.wrong : _OptionState.idle)),
              onTap: () => _answer(i),
            )),
            const Spacer(),
            if (chosen != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () {
                    if (qIdx + 1 < questions.length) {
                      setState(() { qIdx++; chosen = null; });
                    } else {
                      setState(() => done = true);
                    }
                  },
                  child: const Text('CONTINUE'),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            const Text('QUIZ COMPLETE', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
            Text('You scored $score/${questions.length}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 40),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('BACK TO HUB'))
          ],
        ),
      ),
    );
  }
}

// ── Shared Reusable Components ───────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  final int score;
  const _ScoreCard({required this.score});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Text('⭐ SCORE: $score', style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }
}

class _LetterTile extends StatelessWidget {
  final String char;
  const _LetterTile({required this.char});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45, height: 55,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 3))]
      ),
      child: Center(child: Text(char, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.indigo))),
    );
  }
}

enum _OptionState { idle, correct, wrong }

class _OptionTile extends StatelessWidget {
  final String text;
  final int index;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionTile({required this.text, required this.index, required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = state == _OptionState.correct ? Colors.green : (state == _OptionState.wrong ? Colors.red : Colors.grey.shade300);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 2),
            color: state == _OptionState.idle ? Colors.transparent : color.withValues(alpha: 0.1),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 12, backgroundColor: color, child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: Colors.white))),
              const SizedBox(width: 16),
              Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final String message;
  final bool isSuccess;
  final bool isLast;
  final VoidCallback onNext;
  const _ResultBanner({required this.message, required this.isSuccess, required this.isLast, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSuccess ? Colors.green : Colors.red),
          ),
          child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: isSuccess ? Colors.green.shade800 : Colors.red.shade800, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: onNext,
          icon: Icon(isLast ? Icons.check_circle : Icons.arrow_forward),
          label: Text(isLast ? 'FINISH' : 'NEXT WORD →'),
        ),
      ],
    );
  }
}