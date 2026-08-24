import 'package:flutter/material.dart';

import '../../core/utils/haptics.dart';
import '../../models/publisher.dart';
import '../../models/question_pack.dart';
import 'online_question_screen.dart';

class PackQuestionFlowScreen extends StatefulWidget {
  const PackQuestionFlowScreen({
    super.key,
    required this.publisher,
    required this.pack,
  });

  final Publisher publisher;
  final QuestionPack pack;

  @override
  State<PackQuestionFlowScreen> createState() =>
      _PackQuestionFlowScreenState();
}

class _PackQuestionFlowScreenState
    extends State<PackQuestionFlowScreen> {
  int _currentIndex = 0;
  bool _started = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _startFlow();
      },
    );
  }

  Future<void> _startFlow() async {
    if (_started || !mounted) {
      return;
    }

    _started = true;

    final questions = widget.pack.questions;

    if (questions.isEmpty) {
      Navigator.pop(context);
      return;
    }

    while (mounted &&
        _currentIndex < questions.length) {
      final index = _currentIndex;

      final isLastQuestion =
          index == questions.length - 1;

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => OnlineQuestionScreen(
            question: questions[index],
            publisher: widget.publisher,
            isLastQuestion: isLastQuestion,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      if (result != true) {
        Navigator.pop(context);
        return;
      }

      if (isLastQuestion) {
        Navigator.pop(context, true);
        return;
      }

      Haptics.light();

      setState(() {
        _currentIndex++;
      });
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.pack.questions.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Text(
            total == 0
                ? 'لا توجد أسئلة في هذه المجموعة.'
                : 'السؤال ${_currentIndex + 1} من $total',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
