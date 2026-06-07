class LikesRecord {
  const LikesRecord({
    required this.liked,
    required this.passed,
  });

  final List<String> liked;
  final List<String> passed;

  static const empty = LikesRecord(liked: [], passed: []);
}
