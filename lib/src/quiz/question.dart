class Question {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final int
      timerDuration; // Durée de la minuterie pour cette question en secondes

  Question({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.timerDuration,
  });
}
