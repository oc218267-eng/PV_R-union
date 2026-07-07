import 'package:flutter/material.dart';
import '../data/prefs_service.dart';
import '../theme/app_theme.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  final _formKey = GlobalKey<FormState>();

  final _secretaireCtrl = TextEditingController();
  final _associationCtrl = TextEditingController();

  String _typeReunion = 'Ordinaire';
  bool _chargement = true;
  bool _sauvegarde = false;

  final List<String> _types = [
    'Ordinaire',
    'Extraordinaire',
    'Assemblée générale',
    'Conseil',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _chargerPreferences();
  }

  @override
  void dispose() {
    _secretaireCtrl.dispose();
    _associationCtrl.dispose();
    super.dispose();
  }

  Future<void> _chargerPreferences() async {
    final prefs = PrefsService();

    final secretaire = await prefs.getSecretaireDefaut();
    final association = await prefs.getNomAssociation();
    final type = await prefs.getTypeReunionDefaut();

    if (!mounted) return;

    setState(() {
      _secretaireCtrl.text = secretaire;
      _associationCtrl.text = association;
      if (_types.contains(type)) {
        _typeReunion = type;
      }
      _chargement = false;
    });
  }

  Future<void> _sauvegarder() async {
    setState(() {
      _sauvegarde = true;
    });

    final prefs = PrefsService();

    await prefs.setSecretaireDefaut(_secretaireCtrl.text.trim());
    await prefs.setNomAssociation(
      _associationCtrl.text.trim().isEmpty
          ? 'Association de quartier'
          : _associationCtrl.text.trim(),
    );
    await prefs.setTypeReunionDefaut(_typeReunion);

    if (!mounted) return;

    setState(() {
      _sauvegarde = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paramètres enregistrés')),
    );
  }

  Future<void> _reinitialiser() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Réinitialiser'),
          content: const Text(
            'Voulez-vous vraiment supprimer les préférences enregistrées ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;

    await PrefsService().reinitialiser();
    _secretaireCtrl.clear();
    _associationCtrl.text = 'Association de quartier';

    if (!mounted) return;

    setState(() {
      _typeReunion = 'Ordinaire';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Préférences réinitialisées')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_chargement) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Paramètres'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.successSoft,
                        child: const Icon(
                          Icons.settings,
                          color: AppColors.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Paramètres",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Personnalisez les valeurs par défaut de votre application.",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
              TextFormField(
                controller: _associationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom de l’association',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),

              TextFormField(
                controller: _secretaireCtrl,
                decoration: const InputDecoration(
                  labelText: 'Secrétaire par défaut',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                initialValue: _typeReunion,
                decoration: const InputDecoration(
                  labelText: 'Type de réunion par défaut',
                  prefixIcon: Icon(Icons.groups),
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
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _sauvegarde ? null : _sauvegarder,
                  icon: const Icon(Icons.save),
                  label: Text(_sauvegarde ? 'Sauvegarde...' : 'Enregistrer'),
                ),
              ),
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                  onPressed: _reinitialiser,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Réinitialiser'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
); 
  }
}