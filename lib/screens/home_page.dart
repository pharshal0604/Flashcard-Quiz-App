import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/flashcard.dart';
import '../providers/flashcard_data.dart';
import 'flashcard_manager_page.dart';
import 'smart_quiz_page.dart';
import 'analytics_page.dart';
import '../widgets/flashcard_search_delegate.dart';
import '../widgets/flashcard_editor.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;

  final List<Widget> _pages = [
    const FlashcardManagerPage(),
    const SmartQuizPage(),
    const AnalyticsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).colorScheme.surface, // 💡 Adapts to dark/light mode
      appBar: AppBar(
        title: const Text('SuperFlash'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: FlashcardSearchDelegate(
                  flashcards: Provider.of<FlashcardData>(
                    context,
                    listen: false,
                  ).flashcards,
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          tabs: const [
            Tab(icon: Icon(Icons.collections_bookmark), text: 'Cards'),
            Tab(icon: Icon(Icons.quiz), text: 'Quiz'),
            Tab(icon: Icon(Icons.analytics), text: 'Stats'),
          ],
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _showAddFlashcardDialog(context),
              label: const Text('Add Card'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddFlashcardDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FlashcardEditor(
          onSave: (question, answer, category) {
            Provider.of<FlashcardData>(context, listen: false).addFlashcard(
              Flashcard(
                question: question,
                answer: answer,
                category: category,
              ),
            );
          },
        );
      },
    );
  }
}
