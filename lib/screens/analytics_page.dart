import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/flashcard_data.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final flashcardData = Provider.of<FlashcardData>(context);
    final flashcards = flashcardData.flashcards;

    if (flashcards.isEmpty) {
      return const Center(
        child: Text('No analytics available. Add some flashcards first.'),
      );
    }

    final totalReviews = flashcards.fold(
      0,
      (sum, card) => sum + card.timesCorrect + card.timesIncorrect,
    );
    final totalCorrect = flashcards.fold(
      0,
      (sum, card) => sum + card.timesCorrect,
    );

    final overallAccuracy =
        totalReviews > 0 ? (totalCorrect / totalReviews) * 100 : 0;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Overall Accuracy: ${overallAccuracy.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            // Add more Cards or widgets here as you build out the full analytics UI
          ],
        ),
      ),
    );
  }
}
