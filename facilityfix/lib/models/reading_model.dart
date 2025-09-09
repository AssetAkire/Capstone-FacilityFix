class Reading {
  final String id;
  final String title;
  final String? content;

  Reading({required this.id, required this.title, this.content});

  factory Reading.fromJson(Map<String, dynamic> j) => Reading(
        id: j['id']?.toString() ?? '',
        title: j['title']?.toString() ?? '',
        content: j['content']?.toString(),
      );
}
