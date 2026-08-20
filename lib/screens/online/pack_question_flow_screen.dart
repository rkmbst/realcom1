import 'package:flutter/material.dart';

import '../../core/utils/haptics.dart';
import '../../models/publisher.dart';
import '../../models/question_pack.dart';
import 'online_question_screen.dart';

class PackQuestionFlowScreen
    extends StatefulWidget {
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
  bool _opening = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _openCurrentQuestion(),
    );
  }

  Future<void> _openCurrentQuestion() async {
    if (!mounted || _opening) {
      return;
    }

    final questions = widget.pack.questions;

    if (questions.isEmpty ||
        _currentIndex >= questions.length) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    _opening = true;

    final isLastQuestion =
        _currentIndex ==
            questions.length - 1;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            OnlineQuestionScreen(
          question:
              questions[_currentIndex],
          publisher:
              widget.publisher,
          isLastQuestion:
              isLastQuestion,
        ),
      ),
    );

    _opening = false;

    if (!mounted) {
      return;
    }

    // The last question closes the flow
    // and returns to the previous screen.
    if (isLastQuestion) {
      Navigator.pop(context);
      return;
    }

    if (_currentIndex <
        questions.length - 1) {
      Haptics.light();

      setState(() {
        _currentIndex++;
      });

      await _openCurrentQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.transparent,
      body: Stack(
        children: [
          const ColoredBox(
            color: Colors.transparent,
          ),
          SafeArea(
            child: Center(
              child: Text(
                'جاري فتح السؤال ${_currentIndex + 1} من ${widget.pack.questions.length}…',
                textAlign:
                    TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
