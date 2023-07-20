import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'quiz_screen.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final bool showCongratulations;

  const ResultScreen(
      {super.key,
      required this.score,
      required this.totalQuestions,
      required this.showCongratulations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showCongratulations)
              Lottie.asset(
                'assets/congratulations_animation.json', // Replace with the path to your congratulations animation
                height: 200,
                width: 200,
                repeat: true,
              )
            else
              Lottie.asset(
                'assets/disappointment_animation.json', // Replace with the path to your disappointment animation
                height: 200,
                width: 200,
                repeat: true,
              ),
            const SizedBox(height: 20),
            Text(
              'Your Score: $score / $totalQuestions',
              style: const TextStyle(fontSize: 24),
            ),
            ElevatedButton(
              onPressed: () {
                // Restart the quiz
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const QuizScreen(),
                  ),
                  (route) =>
                      false, // Supprime toutes les autres routes de la stack de navigation
                );
              },
              child: const Text('Restart Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}
