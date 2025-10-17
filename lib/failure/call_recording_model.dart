class CallRecording {
  final String path;
  final String name;
  final DateTime modified;
  bool isSelected;

  CallRecording({
    required this.path,
    required this.name,
    required this.modified,
    this.isSelected = false,
  });
}
