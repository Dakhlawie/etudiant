import 'note.dart';

class Etudiant {
  final int id;
  final String nom;
  final String prenom;
  final String dateNaissance;
  final String urlAvatar;
  final List<Note> notes;

  const Etudiant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    required this.urlAvatar,
    required this.notes,
  });
  factory Etudiant.fromJson(Map<String, dynamic> json) {
    final List<dynamic> notesJson = json['notes'];
    final List<Note> notes =
        notesJson.map((noteJson) => Note.fromJson(noteJson)).toList();

    return Etudiant(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      dateNaissance: json['date_naissance'],
      urlAvatar: json['urlAvatar'],
      notes: notes,
    );
  }
}
