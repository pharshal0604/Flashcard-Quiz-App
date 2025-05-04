class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String category;
  int timesCorrect;
  int timesIncorrect;
  DateTime lastReviewed;

  Flashcard({
    required this.question,
    required this.answer,
    this.category = 'General',
    this.timesCorrect = 0,
    this.timesIncorrect = 0,
    DateTime? lastReviewed,
  })  : id = DateTime.now().millisecondsSinceEpoch.toString(),
        lastReviewed = lastReviewed ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'timesCorrect': timesCorrect,
      'timesIncorrect': timesIncorrect,
      'lastReviewed': lastReviewed.toIso8601String(),
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      question: map['question'],
      answer: map['answer'],
      category: map['category'],
      timesCorrect: map['timesCorrect'],
      timesIncorrect: map['timesIncorrect'],
      lastReviewed: DateTime.parse(map['lastReviewed']),
    );
  }

  double get masteryLevel {
    final total = timesCorrect + timesIncorrect;
    return total > 0 ? timesCorrect / total : 0;
  }

  Flashcard copyWith({
    String? question,
    String? answer,
    String? category,
    int? timesCorrect,
    int? timesIncorrect,
    DateTime? lastReviewed,
  }) {
    return Flashcard(
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      timesIncorrect: timesIncorrect ?? this.timesIncorrect,
      lastReviewed: lastReviewed ?? this.lastReviewed,
    );
  }
}
