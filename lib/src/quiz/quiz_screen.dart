import 'dart:async';

import 'package:flutter/material.dart';

import 'question.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;

  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Timer? _timer;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _secondsRemaining = 0;
  bool _showCongratulations = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = widget.questions[_currentQuestionIndex].timerDuration;
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
        widget.questions[_currentQuestionIndex].correctOptionIndex) {
      setState(() {
        _score++;
      });
    }
    _nextQuestion();
  }

  void _nextQuestion() {
    _timer?.cancel();
    setState(() {
      if (_currentQuestionIndex < widget.questions.length - 1) {
        _currentQuestionIndex++;
        _startTimer();
      } else {
        // Quiz is completed, navigate to the result screen
        _timer?.cancel();
        if (_score >= widget.questions.length / 2) {
          _showCongratulations = true;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
                score: _score,
                totalQuestions: widget.questions.length,
                showCongratulations: _showCongratulations),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${widget.questions.length}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              widget.questions[_currentQuestionIndex].questionText,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Column(
              children: List.generate(
                widget.questions[_currentQuestionIndex].options.length,
                (index) {
                  return ElevatedButton(
                    onPressed: () => _checkAnswer(index),
                    child: Text(
                        widget.questions[_currentQuestionIndex].options[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Text('Time Remaining: $_secondsRemaining seconds'),
          ],
        ),
      ),
    );
  }
}
