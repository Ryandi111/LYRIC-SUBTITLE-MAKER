/// Mode editor untuk aplikasi Lyric & Subtitle Maker.
enum EditorMode {
  lyric,
  subtitle,
}

extension EditorModeExtension on EditorMode {
  /// Mengembalikan nama mode sebagai string untuk serialisasi JSON.
  String get name {
    switch (this) {
      case EditorMode.lyric:
        return 'lyric';
      case EditorMode.subtitle:
        return 'subtitle';
    }
  }

  /// Membuat EditorMode dari string name.
  static EditorMode fromName(String? name) {
    switch (name) {
      case 'lyric':
        return EditorMode.lyric;
      case 'subtitle':
        return EditorMode.subtitle;
      default:
        return EditorMode.lyric;
    }
  }
}
