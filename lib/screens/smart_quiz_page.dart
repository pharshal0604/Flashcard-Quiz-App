import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

import '../../models/flashcard.dart';
import '../../providers/flashcard_data.dart';
import '../widgets/mastery_indicator.dart';

class SmartQuizPage extends StatefulWidget {
  const SmartQuizPage({super.key});

  @override
  State<SmartQuizPage> createState() => _SmartQuizPageState();
}

class _SmartQuizPageState extends State<SmartQuizPage> {
  late ConfettiController _confettiController;
  int _currentCardIndex = 0;
  bool _showAnswer = false;
  int _correctInSession = 0;
  int _totalInSession = 0;
  bool _quizCompleted = false;
  List<Flashcard> _quizCards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _loadQuizCards();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadQuizCards() async {
    final flashcardData = Provider.of<FlashcardData>(context, listen: false);
    setState(() {
      _quizCards = flashcardData.getDueCards();
      _isLoading = false;
    });
  }

  void _nextCard(bool isCorrect) {
    final card = _quizCards[_currentCardIndex];
    Provider.of<FlashcardData>(
      context,
      listen: false,
    ).recordAnswer(card.id, isCorrect);

    setState(() {
      if (isCorrect) {
        _correctInSession++;
        if (card.masteryLevel >= 0.9) {
          _confettiController.play();
        }
      }
      _totalInSession++;

      if (_currentCardIndex < _quizCards.length - 1) {
        _currentCardIndex++;
        _showAnswer = false;
      } else {
        _quizCompleted = true;
      }
    });
  }

  void _resetQuiz() {
    setState(() {
      _currentCardIndex = 0;
      _showAnswer = false;
      _correctInSession = 0;
      _totalInSession = 0;
      _quizCompleted = false;
      _loadQuizCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_quizCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(
              'No cards due for review!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('All your flashcards are mastered or not due yet.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _resetQuiz,
              child: const Text('Review All Cards Anyway'),
            ),
          ],
        ),
      );
    }

    if (_quizCompleted) {
      return Stack(
        children: [
          const Center(
            child: Column(
                // ... (rest of the quiz completed UI)
                ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      );
    }

    final currentCard = _quizCards[_currentCardIndex];

    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Card ${_currentCardIndex + 1} of ${_quizCards.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  if (!_showAnswer) {
                    setState(() {
                      _showAnswer = true;
                    });
                  }
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (
                    Widget child,
                    Animation<double> animation,
                  ) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Card(
                    key: ValueKey(_currentCardIndex),
                    margin: const EdgeInsets.all(20.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 300,
                        height: 200,
                        child: Center(
                          child: SingleChildScrollView(
                            child: Text(
                              _showAnswer
                                  ? currentCard.answer
                                  : currentCard.question,
                              style: TextStyle(
                                fontSize: _showAnswer ? 18.0 : 20.0,
                                color: _showAnswer
                                    ? Colors.blueAccent
                                    : Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!_showAnswer)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAnswer = true;
                    });
                  },
                  child: const Text('Reveal Answer'),
                ),
              if (_showAnswer) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _nextCard(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Incorrect'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () => _nextCard(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Correct'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                MasteryIndicator(mastery: currentCard.masteryLevel),
                Text(
                  'Mastery: ${(currentCard.masteryLevel * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Chip(
            label: Text('$_correctInSession/$_totalInSession'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
      ],
    );
  }
}
