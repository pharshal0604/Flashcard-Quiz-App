import 'package:flutter/material.dart';
import '../../models/flashcard.dart';
import 'mastery_indicator.dart';

class FlashcardSearchDelegate extends SearchDelegate {
  final List<Flashcard> flashcards;

  FlashcardSearchDelegate({required this.flashcards});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results =
        query.isEmpty
            ? flashcards
            : flashcards
                .where(
                  (card) =>
                      card.question.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      card.answer.toLowerCase().contains(query.toLowerCase()) ||
                      card.category.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final card = results[index];
        return ListTile(
          title: Text(card.question),
          subtitle: Text(card.category),
          trailing: MasteryIndicator(mastery: card.masteryLevel),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(card.question),
                  content: Text(card.answer),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
