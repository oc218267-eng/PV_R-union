import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import '../data/prefs_service.dart';
import '../theme/app_theme.dart';

class PvScreen extends StatefulWidget {
  const PvScreen({super.key});

  @override
  State<PvScreen> createState() => _PvScreenState();
}

class _PvScreenState extends State<PvScreen> {
  int? _reunionId;

  Map<String, dynamic>? _reunion;
  List<Map<String, dynamic>> _participants = [];
  List<Map<String, dynamic>> _interventions = [];

  String _association = 'Association de quartier';
  bool _chargement = true;
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
      final association = await PrefsService().getNomAssociation();

      if (!mounted) return;

      if (reunion == null) {
        setState(() {
          _chargement = false;
          _erreur = 'Réunion introuvable';
        });
        return;
      }

      setState(() {
        _reunion = reunion;
        _participants = participants;
        _interventions = interventions;
        _association = association;
        _chargement = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _chargement = false;
        _erreur = 'Erreur : $e';
      });
    }
  }

  Widget _section(String titre, List<Widget> enfants) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titre,
               style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Divider(height: 24),
            ...enfants,
          ],
        ),
      ),
    );
  }

  Widget _ligneInfo(String label, dynamic value, String remplacement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label : ${_valeurTexte(value, remplacement)}'),
    );
  }

  Widget _badgeStatut(String statut) {
    final terminee = statut == 'terminée';

    return Chip(
      label: Text(statut),
      backgroundColor: terminee
          ? const Color.fromARGB(255, 138, 201, 253).withOpacity(0.15)
          : const Color.fromARGB(255, 124, 240, 228).withOpacity(0.15),
      labelStyle: TextStyle(
        color: terminee ? const Color.fromARGB(255, 113, 186, 245) : const Color.fromARGB(255, 135, 248, 236),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _ordreDuJour() {
    final ordre = _valeurTexte(_reunion?['ordre_du_jour'], '');

    if (ordre.isEmpty) {
      return const SizedBox.shrink();
    }

    return _section(
      'Ordre du jour',
      [
        Text(ordre),
      ],
    );
  }

  Widget _presents() {
    if (_participants.isEmpty) {
      return _section(
        'Présents',
        const [
          Text('Aucun participant enregistré.'),
        ],
      );
    }

    return _section(
      'Présents',
      _participants.map((participant) {
        final fonction = _valeurTexte(participant['fonction'], '');
        final nomComplet = '${participant['prenom']} ${participant['nom']}';

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            fonction.isEmpty ? '• $nomComplet' : '• $nomComplet — $fonction',
          ),
        );
      }).toList(),
    );
  }

  Widget _deroule() {
    if (_interventions.isEmpty) {
      return _section(
        'Déroulé des débats',
        const [
          Text('Aucune intervention enregistrée.'),
        ],
      );
    }

    return _section(
      'Déroulé des débats',
      List.generate(_interventions.length, (index) {
        final intervention = _interventions[index];
        final fonction = _valeurTexte(intervention['fonction'], '');
        final nomComplet = '${intervention['prenom']} ${intervention['nom']}';
        final intervenant =
            fonction.isEmpty ? nomComplet : '$nomComplet ($fonction)';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '${index + 1}. $intervenant : ${intervention['contenu']}',
          ),
        );
      }),
    );
  }

  Widget _signature() {
    final reunion = _reunion!;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      ),
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Fait à Thiès, le ${_valeurTexte(reunion['date_reunion'], '')}'),
            const SizedBox(height: 28),
            Text(
              'Le secrétaire : ${_valeurTexte(reunion['secretaire'], 'Non précisé')}',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_chargement) {
      return Scaffold(
        appBar: AppBar(title: const Text('Procès-verbal')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_erreur != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Procès-verbal')),
        body: Center(child: Text(_erreur!)),
      );
    }

    final reunion = _reunion!;
    final statut = _valeurTexte(reunion['statut'], 'en_cours');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Procès-verbal'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          ),
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    _association.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 1,
      ),

                  ),
                  const SizedBox(height: 14),
                  Text(
                    'PROCÈS-VERBAL DE RÉUNION',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                                    ),
                  const SizedBox(height: 12),
                  Text(
                    reunion['titre'] ?? 'Réunion',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                  ),
                  const SizedBox(height: 12),
                  _badgeStatut(statut),
                ],
              ),
            ),
          ),

          _section(
            'Informations de la réunion',
            [
              _ligneInfo('Type', reunion['type_reunion'], 'Non précisé'),
              _ligneInfo('Date', reunion['date_reunion'], 'Non précisée'),
              _ligneInfo('Heure', reunion['heure_debut'], 'Non précisée'),
              _ligneInfo('Lieu', reunion['lieu'], 'Non précisé'),
              _ligneInfo('Président', reunion['president'], 'Non précisé'),
              _ligneInfo('Secrétaire', reunion['secretaire'], 'Non précisé'),
            ],
          ),

          _ordreDuJour(),
          _presents(),
          _deroule(),
          _signature(),
        ],
      ),
    );
  }
}