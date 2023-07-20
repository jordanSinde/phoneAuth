class Question {
  final String questionId;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final int
      timerDuration; // Durée de la minuterie pour cette question en secondes

  Question({
    required this.questionId,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.timerDuration,
  });

  factory Question.fromMap(String questionId, Map<String, dynamic> map) {
    return Question(
      questionId: questionId,
      questionText: map['questionText'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctOptionIndex: map['correctOptionIndex'] ?? 0,
      timerDuration: map['timerDuration'] ?? 10,
    );
  }
}
