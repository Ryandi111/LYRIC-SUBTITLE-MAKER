import 'package:uuid/uuid.dart';
import 'editor_mode.dart';
import 'timing_item.dart';

/// Model data untuk proyek Lyric & Subtitle Maker.
///
/// Proyek memiliki:
/// - id: string unik
/// - title: judul proyek
/// - mode: lyric atau subtitle
/// - mediaPath: path file media (nullable)
/// - lines: daftar TimingItem
/// - lastPosition: posisi terakhir playback
/// - updatedAt: waktu terakhir update
class Project {
  final String id;
  final String title;
  final EditorMode mode;
  final String? mediaPath;
  final List<TimingItem> lines;
  final Duration lastPosition;
  final DateTime updatedAt;

  /// Constructor default dengan UUID dan timestamp otomatis.
  Project({
    String? id,
    this.title = '',
    required this.mode,
    this.mediaPath,
    List<TimingItem>? lines,
    this.lastPosition = Duration.zero,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        lines = lines ?? [],
        updatedAt = updatedAt ?? DateTime.now();

  /// Membuat salinan dengan field yang dapat diubah.
  Project copyWith({
    String? id,
    String? title,
    EditorMode? mode,
    String? mediaPath,
    List<TimingItem>? lines,
    Duration? lastPosition,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      mode: mode ?? this.mode,
      mediaPath: mediaPath ?? this.mediaPath,
      lines: lines ?? this.lines,
      lastPosition: lastPosition ?? this.lastPosition,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Mengubah model menjadi Map untuk serialisasi JSON.
  ///
  /// Duration disimpan sebagai microseconds (int).
  /// EditorMode disimpan sebagai string name.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'mode': mode.name,
      'mediaPath': mediaPath,
      'lines': lines.map((line) => line.toJson()).toList(),
      'lastPosition': lastPosition.inMicroseconds,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Membuat model dari Map JSON.
  ///
  /// Handler aman untuk field null atau hilang.
  factory Project.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Project(mode: EditorMode.lyric);
    }

    // Parse lines dengan aman
    final linesJson = json['lines'] as List<dynamic>?;
    final lines = linesJson
            ?.map((item) => TimingItem.fromJson(item as Map<String, dynamic>?))
            .toList() ??
        [];

    // Parse mode dengan aman
    final modeString = json['mode'] as String?;
    final mode = EditorModeExtension.fromName(modeString);

    // Parse updatedAt dengan aman
    final updatedAtString = json['updatedAt'] as String?;
    final updatedAt = updatedAtString != null
        ? DateTime.tryParse(updatedAtString) ?? DateTime.now()
        : DateTime.now();

    return Project(
      id: json['id'] as String? ?? const Uuid().v4(),
      title: json['title'] as String? ?? '',
      mode: mode,
      mediaPath: json['mediaPath'] as String?,
      lines: lines,
      lastPosition: json['lastPosition'] != null
          ? Duration(microseconds: json['lastPosition'] as int)
          : Duration.zero,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project &&
        other.id == id &&
        other.title == title &&
        other.mode == mode &&
        other.mediaPath == mediaPath &&
        other.lines.length == lines.length &&
        other.lastPosition == lastPosition &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        mode,
        mediaPath,
        lines,
        lastPosition,
        updatedAt,
      );

  @override
  String toString() {
    return 'Project(id: $id, title: "$title", mode: $mode, mediaPath: $mediaPath, lines: ${lines.length}, lastPosition: $lastPosition, updatedAt: $updatedAt)';
  }
}
