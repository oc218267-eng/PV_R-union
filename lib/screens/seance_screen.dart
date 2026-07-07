import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../widgets/widget_audio.dart';
import '../theme/app_theme.dart';


class SeanceScreen extends StatefulWidget {
  const SeanceScreen({super.key});

  @override
  State<SeanceScreen> createState() => _SeanceScreenState();
}

class _SeanceScreenState extends State<SeanceScreen> {Widget _actionsFinales() {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!_reunionTerminee)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _terminerReunion,
                icon: const Icon(Icons.flag),
                label: const Text('Réunion terminée'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          if (!_reunionTerminee) const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/pv',
                  arguments: _reunionId,
                );
              },
              icon: const Icon(Icons.description),
              label: const Text('Voir le PV'),
            ),
          ),
        ],
      ),
    ),
  );
}



  Future<void> _terminerReunion() async {
  final id = _reunionId;
  if (id == null) return;

  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Terminer la réunion'),
        content: const Text(
          'Voulez-vous vraiment terminer cette réunion ? '
          'Vous ne pourrez plus ajouter de participants ni d’interventions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Terminer'),
          ),
        ],
      );
    },
  );

  if (ok != true) return;

  await DbHelper().terminerReunion(id);
  await _chargerDonnees();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Réunion terminée')),
  );
}

  final _formParticipantKey = GlobalKey<FormState>();
  final _formInterventionKey = GlobalKey<FormState>();

  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _fonctionCtrl = TextEditingController();
  final _contenuInterventionCtrl = TextEditingController();

  int? _reunionId;
  int? _participantSelectionneId;

  Map<String, dynamic>? _reunion;
  List<Map<String, dynamic>> _participants = [];
  List<Map<String, dynamic>> _interventions = [];

  bool _chargement = true;
  bool _ajoutParticipantEnCours = false;
  bool _ajoutInterventionEnCours = false;
  String? _erreur;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_reunionId != null) return;

    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is int) {
      _reunionId = arguments;
      _chargerDonnees();
    } else {
      setState(() {
        _chargement = false;
        _erreur = 'Aucune réunion sélectionnée';
      });
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _fonctionCtrl.dispose();
    _contenuInterventionCtrl.dispose();
    super.dispose();
  }

  bool get _reunionTerminee => _reunion?['statut'] == 'terminée';

  String? _champObligatoire(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est obligatoire';
    }
    return null;
  }

  String _valeurTexte(dynamic value, String remplacement) {
    final texte = value?.toString().trim() ?? '';
    return texte.isEmpty ? remplacement : texte;
  }

  Future<void> _chargerDonnees() async {
    final id = _reunionId;
    if (id == null) return;

    setState(() {
      _chargement = true;
      _erreur = null;
    });

    try {
      final reunion = await DbHelper().getReunion(id);
      final participants = await DbHelper().listerParticipants(id);
      final interventions =
          await DbHelper().listerInterventionsAvecParticipant(id);

      if (!mounted) return;

      if (reunion == null) {
        setState(() {
          _chargement = false;
          _erreur = 'Réunion introuvable';
        });
        return;
      }

      final participantExiste = participants.any(
        (participant) => participant['id'] == _participantSelectionneId,
      );

      setState(() {
        _reunion = reunion;
        _participants = participants;
        _interventions = interventions;
        _chargement = false;

        if (!participantExiste) {
          _participantSelectionneId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _chargement = false;
        _erreur = 'Erreur : $e';
      });
    }
  }

  Future<void> _ajouterParticipant() async {
    if (!_formParticipantKey.currentState!.validate()) return;

    final id = _reunionId;
    if (id == null) return;

    setState(() {
      _ajoutParticipantEnCours = true;
    });

    await DbHelper().ajouterParticipant(
      id,
      _nomCtrl.text.trim(),
      _prenomCtrl.text.trim(),
      _fonctionCtrl.text.trim().isEmpty ? null : _fonctionCtrl.text.trim(),
    );

    _nomCtrl.clear();
    _prenomCtrl.clear();
    _fonctionCtrl.clear();

    await _chargerDonnees();

    if (!mounted) return;

    setState(() {
      _ajoutParticipantEnCours = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Participant ajouté')),
    );
  }

  Future<void> _ajouterIntervention() async {
    if (_participants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez d’abord un participant')),
      );
      return;
    }

    if (_participantSelectionneId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir le participant')),
      );
      return;
    }

    if (!_formInterventionKey.currentState!.validate()) return;

    final id = _reunionId;
    if (id == null) return;

    setState(() {
      _ajoutInterventionEnCours = true;
    });

    await DbHelper().ajouterIntervention(
      id,
      _participantSelectionneId!,
      _contenuInterventionCtrl.text.trim(),
    );

    _contenuInterventionCtrl.clear();
    _participantSelectionneId = null;

    await _chargerDonnees();

    if (!mounted) return;

    setState(() {
      _ajoutInterventionEnCours = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Intervention enregistrée')),
    );
  }

  Widget _sectionReunion() {
    final reunion = _reunion!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
  children: [
    const Icon(
      Icons.groups,
      color: AppColors.primary,
      size: 30,
    ),
    const SizedBox(width: 10),
    Expanded(
      child: Text(
        reunion['titre'] ?? 'Réunion',
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    ),
  ],
),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text("Date"),
              subtitle: Text(
                _valeurTexte(reunion['date_reunion'], 'Non précisée'),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text("Heure"),
              subtitle: Text(
                _valeurTexte(reunion['heure_debut'], 'Non précisée'),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.place),
              title: const Text("Lieu"),
              subtitle: Text(
                _valeurTexte(reunion['lieu'], 'Non précisé'),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Président"),
              subtitle: Text(
                _valeurTexte(reunion['president'], 'Non précisé'),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text("Secrétaire"),
              subtitle: Text(
                _valeurTexte(reunion['secretaire'], 'Non précisé'),
              ),
            ),
                        const SizedBox(height: 8),
           Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: Icon(
                  _reunionTerminee ? Icons.check_circle : Icons.schedule,
                  size: 18,
                  color: _reunionTerminee
                      ? AppColors.finished
                      : AppColors.success,
                ),
                label: Text(
                  _valeurTexte(reunion['statut'], 'en_cours'),
                ),
                backgroundColor: _reunionTerminee
                    ? AppColors.finishedSoft
                    : AppColors.successSoft,
                labelStyle: TextStyle(
                  color: _reunionTerminee
                      ? AppColors.finished
                      : AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
                      ],
        ),
      ),
    );
  }

  Widget _formulaireParticipant() {
    if (_reunionTerminee) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('La réunion est terminée : ajout de participants désactivé.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formParticipantKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajouter un participant',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
                validator: _champObligatoire,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prenomCtrl,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                ),
                validator: _champObligatoire,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fonctionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Fonction',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _ajoutParticipantEnCours ? null : _ajouterParticipant,
                  icon: const Icon(Icons.person_add),
                  label: Text(
                    _ajoutParticipantEnCours ? 'Ajout...' : 'Ajouter',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listeParticipants() {
    if (_participants.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Aucun participant ajouté pour le moment.'),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text('Participants présents'),
          ),
          const Divider(height: 1),
          ..._participants.map((participant) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.successSoft,
                child: Icon(Icons.person,
                color: AppColors.primary),
              ),
              title: Text(
                '${participant['prenom']} ${participant['nom']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                _valeurTexte(participant['fonction'], 'Fonction non précisée'),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _formulaireIntervention() {
    if (_reunionTerminee) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('La réunion est terminée : ajout d’interventions désactivé.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formInterventionKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nouvelle intervention',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _participantSelectionneId,
                decoration: const InputDecoration(
                  labelText: 'Participant',
                  border: OutlineInputBorder(),
                ),
                items: _participants.map((participant) {
                  return DropdownMenuItem<int>(
                    value: participant['id'] as int,
                    child: Text('${participant['prenom']} ${participant['nom']}'),
                  );
                }).toList(),
                onChanged: _participants.isEmpty
                    ? null
                    : (value) {
                        setState(() {
                          _participantSelectionneId = value;
                        });
                      },
              ),
              const SizedBox(height: 12),
              WidgetAudio(controller: _contenuInterventionCtrl),
const SizedBox(height: 12),
              TextFormField(
                controller: _contenuInterventionCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Texte de l’intervention',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: _champObligatoire,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _ajoutInterventionEnCours
                      ? null
                      : _ajouterIntervention,
                  icon: const Icon(Icons.save),
                  label: Text(
                    _ajoutInterventionEnCours
                        ? 'Enregistrement...'
                        : 'Enregistrer l’intervention',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listeInterventions() {
    if (_interventions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Aucune intervention enregistrée pour le moment.'),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          const ListTile(
            
          ),
          const Divider(height: 1),
          ..._interventions.map((intervention) {
            final fonction = _valeurTexte(intervention['fonction'], '');
            final sousTitre = fonction.isEmpty
                ? '${intervention['prenom']} ${intervention['nom']}'
                : '${intervention['prenom']} ${intervention['nom']} • $fonction';
              
            
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),

              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.finishedSoft,
                child: Icon(
                  Icons.record_voice_over,
                  color: AppColors.primary,
                ),
              ),

              title: Text(
                intervention['contenu'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

              subtitle:  Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                sousTitre,
                style: const TextStyle(
                  color: AppColors.muted,
                ),
            ),

            ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_chargement) {
      return Scaffold(
        appBar: AppBar(title: const Text('Séance')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_erreur != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Séance')),
        body: Center(child: Text(_erreur!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Séance'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/pv',
                arguments: _reunionId,
              );
            },
            icon: const Icon(Icons.description),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _chargerDonnees,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionReunion(),
            const SizedBox(height: 12),
            _formulaireParticipant(),
            const SizedBox(height: 12),
            _listeParticipants(),
            const SizedBox(height: 12),
            _formulaireIntervention(),
            const SizedBox(height: 12),
            _listeInterventions(),

            const SizedBox(height: 12),
_actionsFinales(),
          ],
        ),
      ),
    );
  }
}