import '../auth/auth_session.dart';
import '../../models/vote.dart';

class VoteStore {
  VoteStore._();

  static final VoteStore instance =
      VoteStore._();

  // userId -> questionId -> optionId
  final Map<String, Map<String, String>>
      _votesByUser =
      <String, Map<String, String>>{};

  String get _currentUserId =>
      AuthSession.instance.currentUser.id;

  Map<String, String> get _currentUserVotes {
    return _votesByUser[_currentUserId] ??=
        <String, String>{};
  }

  bool hasVoted(
    String questionId,
  ) {
    return _currentUserVotes.containsKey(
      questionId,
    );
  }

  String? selectedOptionFor(
    String questionId,
  ) {
    return _currentUserVotes[questionId];
  }

  bool canVote({
    required String questionId,
    required String authorId,
  }) {
    if (_currentUserId == authorId) {
      return false;
    }

    return !hasVoted(questionId);
  }

  bool recordVote({
    required String questionId,
    required String optionId,
    required String authorId,
  }) {
    if (_currentUserId == authorId) {
      return false;
    }

    if (hasVoted(questionId)) {
      return false;
    }

    _currentUserVotes[questionId] =
        optionId;

    return true;
  }

  int countForOption(
    String questionId,
    String optionId,
  ) {
    var count = 0;

    for (final userVotes
        in _votesByUser.values) {
      if (userVotes[questionId] ==
          optionId) {
        count++;
      }
    }

    return count;
  }

  Map<String, int> resultsForQuestion(
    String questionId,
    Iterable<String> optionIds,
  ) {
    final results =
        <String, int>{};

    for (final optionId in optionIds) {
      results[optionId] =
          countForOption(
        questionId,
        optionId,
      );
    }

    return results;
  }

  List<Vote> votesForQuestion(
    String questionId,
  ) {
    final votes = <Vote>[];

    for (final entry
        in _votesByUser.entries) {
      final optionId =
          entry.value[questionId];

      if (optionId == null) {
        continue;
      }

      votes.add(
        Vote(
          id:
              'vote-${entry.key}-$questionId',
          questionId:
              questionId,
          playerId:
              entry.key,
          optionId:
              optionId,
        ),
      );
    }

    return List.unmodifiable(
      votes,
    );
  }

  void clearCurrentUser() {
    _votesByUser.remove(
      _currentUserId,
    );
  }

  void clearAll() {
    _votesByUser.clear();
  }
}
