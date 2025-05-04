import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';

class FlashcardData extends ChangeNotifier {
  List<Flashcard> _flashcards = [];
  final SharedPreferences _prefs;

  FlashcardData(this._prefs) {
    _loadFlashcards();
  }

  List<Flashcard> get flashcards => _flashcards;

  List<String> get categories {
    final categories =
        _flashcards.map((card) => card.category).toSet().toList();
    categories.sort();
    return categories;
  }

  void _loadFlashcards() {
    final cardsJson = _prefs.getStringList('flashcards') ?? [];
    _flashcards =
        cardsJson
            .map(
              (json) => Flashcard.fromMap(
                Map<String, dynamic>.from(jsonDecode(json)),
              ),
            )
            .toList();
    notifyListeners();
  }

  void _saveFlashcards() {
    final cardsJson =
        _flashcards.map((card) => jsonEncode(card.toMap())).toList();
    _prefs.setStringList('flashcards', cardsJson);
  }

  void addFlashcard(Flashcard card) {
    _flashcards.add(card);
    _saveFlashcards();
    notifyListeners();
  }

  void updateFlashcard(
    String id,
    String question,
    String answer,
    String category,
  ) {
    final index = _flashcards.indexWhere((card) => card.id == id);
    if (index != -1) {
      _flashcards[index] = _flashcards[index].copyWith(
        question: question,
        answer: answer,
        category: category,
      );
      _saveFlashcards();
      notifyListeners();
    }
  }

  void deleteFlashcard(String id) {
    _flashcards.removeWhere((card) => card.id == id);
    _saveFlashcards();
    notifyListeners();
  }

  void recordAnswer(String id, bool isCorrect) {
    final index = _flashcards.indexWhere((card) => card.id == id);
    if (index != -1) {
      if (isCorrect) {
        _flashcards[index].timesCorrect++;
      } else {
        _flashcards[index].timesIncorrect++;
      }
      _flashcards[index].lastReviewed = DateTime.now();
      _saveFlashcards();
      notifyListeners();
    }
  }

  List<Flashcard> getDueCards() {
    return _flashcards
        .where(
          (card) =>
              card.masteryLevel < 0.8 ||
              card.lastReviewed.isBefore(
                DateTime.now().subtract(const Duration(days: 7)),
              ),
        )
        .toList();
  }

  List<Flashcard> getCardsByCategory(String category) {
    return _flashcards.where((card) => card.category == category).toList();
  }
}
