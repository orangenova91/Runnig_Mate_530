/// avgPace 문자열 파싱 — "5'42\"" → 342초
int parseAvgPaceToSeconds(String avgPace) {
  final match = RegExp(r"(\d+)['':](\d+)").firstMatch(avgPace.trim());
  if (match == null) return 0;
  final min = int.tryParse(match.group(1) ?? '') ?? 0;
  final sec = int.tryParse(match.group(2) ?? '') ?? 0;
  return min * 60 + sec;
}

String formatAvgPace(int minutes, int seconds) {
  return "$minutes'${seconds.toString().padLeft(2, '0')}\"";
}

({int minutes, int seconds})? parseAvgPaceParts(String avgPace) {
  final match = RegExp(r"(\d+)['':](\d+)").firstMatch(avgPace.trim());
  if (match == null) return null;
  final minutes = int.tryParse(match.group(1) ?? '');
  final seconds = int.tryParse(match.group(2) ?? '');
  if (minutes == null || seconds == null) return null;
  return (minutes: minutes, seconds: seconds);
}
