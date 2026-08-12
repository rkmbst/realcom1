import 'dart:math';

import '../../data/builtin_questions.dart';
import '../../models/player.dart';
import '../../models/question.dart';
import '../../models/vote.dart';

/// Shared local party session.
class AppSession {
  AppSession._();

  static final AppSession instance = AppSession._();

  final List<Player> players = [];
  final List<Question> allQuestions = [];
  final List<Question> roundQuestions = [];
  final List<Vote> votes = [];

  final Set<String> usedQuestionIds = {};

  int currentAdderIndex = 0;

  bool _builtInAdded = false;

  Player? get currentAdder {
    if (players.isEmpty) return null;
    return players[currentAdderIndex];
  }

  void addPlayer(Player player) {
    players.add(player);
  }

  void removePlayer(String playerId) {
    players.removeWhere((player) => player.id == playerId);
  }

  void addQuestion(Question question) {
    allQuestions.add(question);
  }

  void addQuestions(List<Question> questions) {
    allQuestions.addAll(questions);
  }

  int addBuiltInQuestions() {
    if (_builtInAdded) return 0;

    final builtIn = BuiltInQuestions.local;
    addQuestions(builtIn);
    _builtInAdded = true;

    return builtIn.length;
  }

  void nextAdder() {
    if (players.isEmpty) return;
    currentAdderIndex = (currentAdderIndex + 1) % players.length;
  }

  void prepareRound({int maxQuestions = 12}) {
    final pool = List<Question>.from(allQuestions)..shuffle();
    roundQuestions.clear();
    roundQuestions.addAll(pool.take(maxQuestions));
    usedQuestionIds.clear();
    votes.clear();
  }

  List<int> unusedRoundIndexes() {
    final indexes = <int>[];

    for (int i = 0; i < roundQuestions.length; i++) {
      if (!usedQuestionIds.contains(roundQuestions[i].id)) {
        indexes.add(i);
      }
    }

    return indexes;
  }

  Set<int> usedRoundIndexes() {
    final indexes = <int>{};

    for (int i = 0; i < roundQuestions.length; i++) {
      if (usedQuestionIds.contains(roundQuestions[i].id)) {
        indexes.add(i);
      }
    }

    return indexes;
  }

  void markQuestionUsed(String questionId) {
    usedQuestionIds.add(questionId);
  }

  void castVote({
    required String questionId,
    required String playerId,
    required String optionId,
  }) {
    votes.add(
      Vote(
        id: 'vote_${DateTime.now().millisecondsSinceEpoch}',
        questionId: questionId,
        playerId: playerId,
        optionId: optionId,
      ),
    );
  }

  Map<String, int> getResults(String questionId) {
    final results = <String, int>{};

    final questionVotes = votes
        .where((vote) => vote.questionId == questionId)
        .toList();

    for (final vote in questionVotes) {
      results[vote.optionId] = (results[vote.optionId] ?? 0) + 1;
    }

    return results;
  }

  int getTotalVotes(String questionId) {
    return votes
        .where((vote) => vote.questionId == questionId)
        .length;
  }

  void resetRound() {
    usedQuestionIds.clear();
    votes.clear();
  }

  void resetAll() {
    players.clear();
    allQuestions.clear();
    roundQuestions.clear();
    votes.clear();
    usedQuestionIds.clear();
    currentAdderIndex = 0;
    _builtInAdded = false;
  }
}
