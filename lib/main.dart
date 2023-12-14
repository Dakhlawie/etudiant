import 'package:etudiant/etudiant.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String filterText = '';
  Future<List<Etudiant>>? etudiants;
  List<Etudiant> filteredEtudiants = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    etudiants = getEtudiants(context);

    etudiants!.then((students) {
      setState(() {
        filteredEtudiants = students;
      });
    });
  }

  Future<void> deleteStudent(int studentId) async {
    final String jsonFilePath = 'assets/etudiant.json';
    final File file = File(jsonFilePath);

    try {
      if (await file.exists()) {
        final String jsonData = await file.readAsString();
        final Map<String, dynamic> data = json.decode(jsonData);

        if (data.containsKey('etudiant')) {
          final List<dynamic> students = data['etudiant'];

          students.removeWhere((student) {
            return student['id'] == studentId;
          });

          await file.writeAsString(json.encode(data));
        }
      }
    } catch (e) {
      print("Error deleting student: $e");
    }
  }

  Future<List<Etudiant>> getEtudiants(BuildContext context) async {
    final data =
        await DefaultAssetBundle.of(context).loadString('assets/etudiant.json');
    final Map<String, dynamic> jsonData = json.decode(data);
    final List<dynamic> etudiantData = jsonData['etudiant'];

    List<Etudiant> etudiants =
        etudiantData.map((item) => Etudiant.fromJson(item)).toList();
    return etudiants;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        filterText = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ListView with JSON'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              readOnly: true,
              controller: TextEditingController(
                text: selectedDate.toLocal().toString().split(' ')[0],
              ),
              onTap: () => _selectDate(context),
              decoration: InputDecoration(labelText: 'Filtrer par date'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedStudents = await getEtudiants(context);
              setState(() {
                filteredEtudiants = updatedStudents
                    .where((etudiant) =>
                        etudiant.nom.contains(filterText) ||
                        etudiant.prenom.contains(filterText) ||
                        (selectedDate != DateTime.now() &&
                            (etudiant.dateNaissance.contains(filterText) ||
                                DateTime.parse(etudiant.dateNaissance)
                                    .toLocal()
                                    .toString()
                                    .contains(filterText))))
                    .toList();
              });
            },
            child: Text('Filtrer'),
          ),
          Expanded(
            child: FutureBuilder<List<Etudiant>>(
              future: etudiants,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final etudiants = snapshot.data!;
                  return buildEtudiant(
                      filteredEtudiants); 
                } else {
                  return Text('NO etudiant data');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEtudiant(List<Etudiant> etudiants) => ListView.builder(
        itemCount: etudiants.length,
        itemBuilder: (context, index) {
          final etudiant = etudiants[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(etudiant.urlAvatar)),
              title: Text('Nom: ${etudiant.nom}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prenom: ${etudiant.prenom}'),
                  Text('Date de Naissance: ${etudiant.dateNaissance}'),
                  Text('Notes:'),
                  for (var note in etudiant.notes)
                    Text('${note.matiere}: ${note.note}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                     
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await deleteStudent(etudiant.id);
                      final updatedStudents = await getEtudiants(context);
                      setState(() {
                        filteredEtudiants = updatedStudents
                            .where((etudiant) =>
                                etudiant.nom.contains(filterText) ||
                                etudiant.prenom.contains(filterText) ||
                                etudiant.dateNaissance.contains(filterText) ||
                                DateTime.parse(etudiant.dateNaissance)
                                    .toLocal()
                                    .toString()
                                    .contains(filterText))
                            .toList();
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
}
