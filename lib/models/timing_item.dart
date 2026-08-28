import 'package:uuid/uuid.dart';

/// Model data untuk setiap baris lirik atau subtitle.
///
/// Setiap baris memiliki:
/// - id: string unik
/// - text: teks lirik/subtitle
/// - startTime: waktu mulai (nullable)
/// - endTime: waktu selesai (nullable, khusus subtitle)
class TimingItem {
  final String id;
  final String text;
  final Duration? startTime;
  final Duration? endTime;

  /// Constructor default dengan UUID otomatis.
  TimingItem({
    String? id,
    this.text = '',
    this.startTime,
    this.endTime,
  }) : id = id ?? const Uuid().v4();

  /// Membuat salinan dengan field yang dapat diubah.
  TimingItem copyWith({
    String? id,
    String? text,
    Duration? startTime,
    Duration? endTime,
  }) {
    return TimingItem(
      id: id ?? this.id,
      text: text ?? this.text,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  /// Mengubah model menjadi Map untuk serialisasi JSON.
  ///
  /// Duration disimpan sebagai microseconds (int).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'startTime': startTime?.inMicroseconds,
      'endTime': endTime?.inMicroseconds,
    };
  }

  /// Membuat model dari Map JSON.
  ///
  /// Handler aman untuk field null atau hilang.
  factory TimingItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return TimingItem();
    }

    return TimingItem(
      id: json['id'] as String? ?? const Uuid().v4(),
      text: json['text'] as String? ?? '',
      startTime: json['startTime'] != null
          ? Duration(microseconds: json['startTime'] as int)
          : null,
      endTime: json['endTime'] != null
          ? Duration(microseconds: json['endTime'] as int)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimingItem &&
        other.id == id &&
        other.text == text &&
        other.startTime == startTime &&
        other.endTime == endTime;
  }

  @override
  int get hashCode => Object.hash(id, text, startTime, endTime);

  @override
  String toString() {
    return 'TimingItem(id: $id, text: "$text", start: $startTime, end: $endTime)';
  }
}
