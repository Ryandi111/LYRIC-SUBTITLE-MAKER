/// Model untuk field timing (start dan end).
/// Digunakan untuk operasi fine-tuning pada subtitle.
enum TimingField {
  start,
  end,
}

extension TimingFieldExtension on TimingField {
  /// Mengembalikan nama field sebagai string.
  String get name {
    switch (this) {
      case TimingField.start:
        return 'start';
      case TimingField.end:
        return 'end';
    }
  }

  /// Membuat TimingField dari string name.
  static TimingField fromName(String? name) {
    switch (name) {
      case 'start':
        return TimingField.start;
      case 'end':
        return TimingField.end;
      default:
        return TimingField.start;
    }
  }
}
