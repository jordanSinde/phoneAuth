import 'question.dart';

List<Question> sampleQuestions = [
  Question(
    questionText: 'What is the capital of France?',
    options: ['London', 'Paris', 'Berlin', 'Madrid'],
    correctOptionIndex: 1,
    timerDuration: 20,
  ),
  Question(
    questionText: 'What is 2 + 2?',
    options: ['3', '4', '5', '6'],
    correctOptionIndex: 1,
    timerDuration: 10,
  ),
  Question(
    questionText: 'What is 2 + 9?',
    options: ['3', '4', '5', '11'],
    correctOptionIndex: 3,
    timerDuration: 10,
  ),
  // Add more questions here
];
