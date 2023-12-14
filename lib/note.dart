class Note {
  final String matiere;
  final double note;

 const  Note({required this.matiere, required this.note});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      matiere: json['matiere'],
      note: json['note'].toDouble(),
    );
  }
}
