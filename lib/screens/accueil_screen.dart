import 'package:flutter/material.dart';

import '../data/db_helper.dart';
import '../theme/app_theme.dart';

class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  late Future<List<Map<String, dynamic>>> _futureReunions;

  @override
  void initState() {
    super.initState();
    _chargerReunions();
  }

  void _chargerReunions() {
    _futureReunions = DbHelper().listerReunions();
  }

  Color _couleurStatut(String statut) {
  return statut == 'terminée'
      ? AppColors.finished
      : AppColors.primary;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PV Réunion'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/parametres');
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureReunions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur : ${snapshot.error}'),
            );
          }

          final reunions = snapshot.data ?? [];

          if (reunions.isEmpty) {
            return const Center(
              child: Text('Aucune réunion enregistrée'),
            );
          }

        return Column(
  children: [
    Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bienvenue",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${reunions.length} réunion(s) enregistrée(s)",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    ),

    Expanded(
      
         child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reunions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final reunion = reunions[index];
              final statut = reunion['statut'] as String? ?? 'en_cours';

              return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),


                    leading: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.successSoft,
                      child: const Icon(
                        Icons.groups,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      reunion['titre'] ?? 'Sans titre',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("📅 ${reunion['date_reunion']}"),
                              const SizedBox(height: 4),
                              Text("📍 ${reunion['lieu'] ?? 'Lieu non précisé'}"),
                            ],
                          ),
                        ),
                    trailing: Chip(
  label: Text(statut),
  backgroundColor: statut == 'terminée'
      ? AppColors.finishedSoft
      : AppColors.successSoft,
  labelStyle: TextStyle(
    color: _couleurStatut(statut),
    fontWeight: FontWeight.bold,
  ),
),

                  onTap: () async {
                    final route = statut == 'terminée' ? '/pv' : '/seance';
                    await Navigator.pushNamed(
                      context,
                      route,
                      arguments: reunion['id'],
                    );
                    setState(() {
                      _chargerReunions();
                    });
                  },
                ),
              );
            },
          ),
          
      ),
  ],
        );
      },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/nouvelle');
          setState(_chargerReunions);
        },
        icon: const Icon(Icons.add),
        label: const Text("Nouvelle"),
      ),
    );
  }
}