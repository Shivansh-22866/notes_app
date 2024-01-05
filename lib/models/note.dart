class Note {
  int id;
  String title;
  String content;
  DateTime modifiedTime;
  String category;
  List<String> imagePaths;
  List<String> videoPaths;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.modifiedTime,
    required this.category,
    required this.imagePaths,
    required this.videoPaths
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      modifiedTime: DateTime.parse(json['modifiedTime']), // Convert String to DateTime
      category: json['category'],
      imagePaths: List<String>.from(json['imagePaths']),
      videoPaths: List<String>.from(json['videoPaths']),
    );
  }

    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'modifiedTime': modifiedTime.toIso8601String(), // Convert DateTime to String
      'category': category,
      'imagePaths': imagePaths,
      'videoPaths': videoPaths,
    };
  }
}

List<Note> sampleNotes = [];
