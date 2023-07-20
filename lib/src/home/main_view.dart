import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:phone_auth/src/quiz/quiz_screen.dart';

import '../../login/auth_state_provider.dart';
import '../quiz/sample_question.dart';

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main view"),
        elevation: 0.0,
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logOut();
            },
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: QuizScreen(questions: sampleQuestions),
      ),
    );
  }
}
