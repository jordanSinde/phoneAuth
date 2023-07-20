import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phone_auth/src/quiz/question.dart';

import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Timer? _timer;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _secondsRemaining = 0;
  bool _showCongratulations = false;
  List<Question> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('questions').get();

      setState(() {
        _questions = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Question.fromMap(doc.id, data);
        }).toList();
      });

      if (_questions.isNotEmpty) {
        _startQuiz();
      } else {
        print('No questions loaded');
      }
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  void _startQuiz() {
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = _questions[_currentQuestionIndex].timerDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _nextQuestion();
        }
      });
    });
  }

  void _checkAnswer(int selectedOptionIndex) {
    if (selectedOptionIndex ==
        _questions[_currentQuestionIndex].correctOptionIndex) {
      setState(() {
        _score++;
      });
    }
    _nextQuestion();
  }

  void _nextQuestion() {
    _timer?.cancel();
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _startTimer();
      } else {
        // Quiz is completed, navigate to the result screen
        _timer?.cancel();
        if (_score >= _questions.length / 2) {
          _showCongratulations = true;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              score: _score,
              totalQuestions: _questions.length,
              showCongratulations: _showCongratulations,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: _buildQuizUI(),
    );
  }

  // Méthode pour construire l'interface utilisateur du quiz
  Widget _buildQuizUI() {
    if (_questions.isEmpty) {
      // Afficher un indicateur de chargement s'il n'y a pas de questions chargées
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Question ${_currentQuestionIndex + 1}/${_questions.length}',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          Text(
            _questions[_currentQuestionIndex].questionText,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Column(
            children: List.generate(
              _questions[_currentQuestionIndex].options.length,
              (index) {
                return ElevatedButton(
                  onPressed: () => _checkAnswer(index),
                  child: Text(_questions[_currentQuestionIndex].options[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text('Time Remaining: $_secondsRemaining seconds'),
        ],
      ),
    );
  }
}
