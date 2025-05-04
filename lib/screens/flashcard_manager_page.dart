import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/flashcard.dart';
import '../../providers/flashcard_data.dart';
import '../widgets/mastery_indicator.dart';
import '../widgets/flashcard_editor.dart';

class FlashcardManagerPage extends StatelessWidget {
  const FlashcardManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final flashcardData = Provider.of<FlashcardData>(context);
    final categories = flashcardData.categories;

    return DefaultTabController(
      length: categories.length + 1,
      child: Column(
        children: [
          TabBar(
            isScrollable: true,
            tabs: [
              const Tab(text: 'All'),
              ...categories.map((category) => Tab(text: category)).toList(),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildFlashcardList(flashcardData.flashcards, context),
                ...categories.map(
                  (category) => _buildFlashcardList(
                    flashcardData.getCardsByCategory(category),
                    context,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcardList(List<Flashcard> cards, BuildContext context) {
    if (cards.isEmpty) {
      return const Center(child: Text('No flashcards in this category'));
    }

    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return Dismissible(
          key: Key(card.id),
          background: Container(color: Colors.red),
          secondaryBackground: Container(color: Colors.blue),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlashcardEditor(
                    initialQuestion: card.question,
                    initialAnswer: card.answer,
                    initialCategory: card.category,
                    onSave: (question, answer, category) {
                      Provider.of<FlashcardData>(
                        context,
                        listen: false,
                      ).updateFlashcard(
                        card.id,
                        question,
                        answer,
                        category,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
              );
              return false;
            }
            return true;
          },
          onDismissed: (_) {
            Provider.of<FlashcardData>(
              context,
              listen: false,
            ).deleteFlashcard(card.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Deleted "${card.question}"')),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ExpansionTile(
              title: Text(card.question),
              subtitle: Text(card.category),
              trailing: MasteryIndicator(mastery: card.masteryLevel),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    card.answer,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Chip(
                        label: Text('Correct: ${card.timesCorrect}'),
                        backgroundColor:
                            Colors.green.withAlpha((0.2 * 255).round()),
                      ),
                      Chip(
                        label: Text('Incorrect: ${card.timesIncorrect}'),
                        backgroundColor:
                            Colors.red.withAlpha((0.2 * 255).round()),
                      ),
                      Chip(
                        label: Text(
                          'Last: ${DateFormat('MMM d').format(card.lastReviewed)}',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
