// import 'package:flutter/material.dart';

// class NouvelleReunionScreen extends StatelessWidget {
//   const NouvelleReunionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Nouvelle réunion"),
//       ),
//       body: const Center(
//         child: Text("Création d'une réunion"),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';

// class NouvelleReunionScreen extends StatelessWidget {
//   const NouvelleReunionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Nouvelle réunion'),
//       ),
//       body: const Center(
//         child: Text('Formulaire de création'),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../data/db_helper.dart';
import '../data/prefs_service.dart';

class NouvelleReunionScreen extends StatefulWidget {
  const NouvelleReunionScreen({super.key});

  @override
  State<NouvelleReunionScreen> createState() => _NouvelleReunionScreenState();
}

class _NouvelleReunionScreenState extends State<NouvelleReunionScreen> {

@override
void initState() {
  super.initState();
  _chargerPreferences();
}

Future<void> _chargerPreferences() async {
  final prefs = PrefsService();
  final secretaire = await prefs.getSecretaireDefaut();
  final type = await prefs.getTypeReunionDefaut();

  if (!mounted) return;

  setState(() {
    _secretaireCtrl.text = secretaire;
    if (_types.contains(type)) {
      _typeReunion = type;
    }
  });
}

  final _formKey = GlobalKey<FormState>();

  final _titreCtrl = TextEditingController();
  final _lieuCtrl = TextEditingController();
  final _ordreDuJourCtrl = TextEditingController();
  final _presidentCtrl = TextEditingController();
  final _secretaireCtrl = TextEditingController();

  DateTime? _dateReunion;
  TimeOfDay? _heureDebut;
  String _typeReunion = 'Ordinaire';
  bool _enregistrement = false;

  final List<String> _types = [
    'Ordinaire',
    'Extraordinaire',
    'Assemblée générale',
    'Conseil',
    'Autre',
  ];

  @override
  void dispose() {
    _titreCtrl.dispose();
    _lieuCtrl.dispose();
    _ordreDuJourCtrl.dispose();
    _presidentCtrl.dispose();
    _secretaireCtrl.dispose();
    super.dispose();
  }

  String? _champObligatoire(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  String _formatDate(DateTime date) {
    final jour = date.day.toString().padLeft(2, '0');
    final mois = date.month.toString().padLeft(2, '0');
    return '$jour/$mois/${date.year}';
  }

  String _datePourBase(DateTime date) {
    final mois = date.month.toString().padLeft(2, '0');
    final jour = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mois-$jour';
  }

  String _formatHeure(TimeOfDay heure) {
    final h = heure.hour.toString().padLeft(2, '0');
    final m = heure.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String? _valeurOuNull(String value) {
    final texte = value.trim();
    return texte.isEmpty ? null : texte;
  }

  Future<void> _choisirDate() async {
    final maintenant = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _dateReunion ?? maintenant,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (date != null) {
      setState(() {
        _dateReunion = date;
      });
    }
  }

  Future<void> _choisirHeure() async {
    final heure = await showTimePicker(
      context: context,
      initialTime: _heureDebut ?? TimeOfDay.now(),
    );

    if (heure != null) {
      setState(() {
        _heureDebut = heure;
      });
    }
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateReunion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir la date de réunion')),
      );
      return;
    }

    setState(() {
      _enregistrement = true;
    });

    final reunionId = await DbHelper().ajouterReunion({
      'titre': _titreCtrl.text.trim(),
      'date_reunion': _datePourBase(_dateReunion!),
      'heure_debut': _heureDebut == null ? null : _formatHeure(_heureDebut!),
      'lieu': _valeurOuNull(_lieuCtrl.text),
      'type_reunion': _typeReunion,
      'ordre_du_jour': _valeurOuNull(_ordreDuJourCtrl.text),
      'president': _valeurOuNull(_presidentCtrl.text),
      'secretaire': _secretaireCtrl.text.trim(),
      'statut': 'en_cours',
    });

    await PrefsService().setSecretaireDefaut(_secretaireCtrl.text.trim());
await PrefsService().setTypeReunionDefaut(_typeReunion);

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      '/seance',
      arguments: reunionId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle réunion'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titre de la réunion',
                  border: OutlineInputBorder(),
                ),
                validator: _champObligatoire,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _choisirDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        _dateReunion == null
                            ? 'Choisir la date'
                            : _formatDate(_dateReunion!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _choisirHeure,
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        _heureDebut == null
                            ? 'Choisir l’heure'
                            : _formatHeure(_heureDebut!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _typeReunion,
                decoration: const InputDecoration(
                  labelText: 'Type de réunion',
                  border: OutlineInputBorder(),
                ),
                items: _types.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _typeReunion = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _lieuCtrl,
                decoration: const InputDecoration(
                  labelText: 'Lieu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _presidentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Président de séance',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _secretaireCtrl,
                decoration: const InputDecoration(
                  labelText: 'Secrétaire',
                  border: OutlineInputBorder(),
                ),
                validator: _champObligatoire,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _ordreDuJourCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Ordre du jour',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _enregistrement ? null : _enregistrer,
                  icon: _enregistrement
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _enregistrement
                        ? 'Enregistrement...'
                        : 'Créer la réunion',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}