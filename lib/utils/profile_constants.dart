class ProfileConstants {
  /// 디스커버리 노출 최소값 (초과해야 목록에 표시)
  static const double paceTempDiscoveryMin = 36.5;

  /// 신규 가입자 기본 신뢰도 (paceTempDiscoveryMin 초과)
  static const double activePaceTempDefault = 37.0;

  static const runStyles = {
    'scenic': '풍경 러닝',
    'speed': '스피드 러닝',
    'social': '소셜 러닝',
    'interval': '인터벌 러닝',
  };

  static const timeLabels = {
    'morning': '🌅 아침',
    'afternoon': '☀️ 오후',
    'night': '🌙 밤',
  };

  static String runStyleLabel(String key) => runStyles[key] ?? key;

  static String timeLabel(String key) => timeLabels[key] ?? key;
}
