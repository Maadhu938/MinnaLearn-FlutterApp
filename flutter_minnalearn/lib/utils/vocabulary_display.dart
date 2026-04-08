import '../models/lesson.dart';

extension VocabularyDisplay on Vocabulary {
  static final RegExp _kanaPattern = RegExp(r'[\u3040-\u309F\u30A0-\u30FF]');
  static final RegExp _kanjiPattern = RegExp(
    r'[\u4E00-\u9FFF\u3400-\u4DBF\uF900-\uFAFF]',
  );

  /// Returns the kana reading for this vocabulary item.
  ///
  /// Handles two data layouts:
  ///   vocab*.txt : japanese="会社員", romaji="かいしゃいん"  → "かいしゃいん"
  ///   legacy     : japanese="わたし (私)", romaji="watashi" → "わたし"
  String get kanaText {
    final text = japanese.trim();

    // If japanese contains parenthesised kanji (legacy format), strip them.
    if (text.contains('(') || text.contains('（')) {
      final stripped = text
          .replaceAll(RegExp(r'\([^)]*\)'), '')
          .replaceAll(RegExp(r'（[^）]*）'), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (stripped.isNotEmpty && _kanaPattern.hasMatch(stripped)) {
        return stripped;
      }
    }

    // If japanese itself is kana, use it directly.
    if (_kanaPattern.hasMatch(text) && !_kanjiPattern.hasMatch(text)) {
      return text;
    }

    // japanese is kanji-only (vocab*.txt format) – the reading lives in romaji.
    return romaji.trim();
  }

  /// Returns the kanji form, or empty string when none exists.
  String get kanjiText {
    final text = japanese.trim();

    // Extract kanji from parenthesised blocks (legacy format).
    final parts = <String>[];
    for (final m in RegExp(r'\(([^)]+)\)').allMatches(text)) {
      final inner = m.group(1)!.trim();
      if (_kanjiPattern.hasMatch(inner)) {
        parts.add(inner);
      }
    }
    for (final m in RegExp(r'（([^）]+)）').allMatches(text)) {
      final inner = m.group(1)!.trim();
      if (_kanjiPattern.hasMatch(inner)) {
        parts.add(inner);
      }
    }
    if (parts.isNotEmpty) {
      return parts.join(' / ');
    }

    // japanese is kanji-only (vocab*.txt format).
    if (_kanjiPattern.hasMatch(text)) {
      return text;
    }

    return '';
  }

  bool get hasKanjiForm => kanjiText.isNotEmpty;
}
