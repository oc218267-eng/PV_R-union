import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

/// Singleton pour gérer la base SQLite de l'application PV.
/// Une seule instance dans toute l'application.
class DbHelper {
  // Pattern Singleton
  static final DbHelper _instance = DbHelper._();
  factory DbHelper() => _instance;
  DbHelper._();

  // La base, ouverte une seule fois et réutilisée
  Database? _db;

  /// Getter asynchrone : retourne la base, l'ouvre si nécessaire
  Future<Database> get db async => _db ??= await _ouvrirBase();

  /// Ouvre (et crée si besoin) la base de données
  Future<Database> _ouvrirBase() async {
    final chemin = kIsWeb 
    ? "pv_reunion_web.db"
    : join(await getDatabasesPath(), "pv_reunion.db");
    return await openDatabase(
      chemin,
      version: 1,
      onConfigure: (db) async {
        // Active les clés étrangères (par défaut désactivées dans SQLite !)
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (db, version) async {
        // ──────────────────────────────────────────────────────
        // TABLE 1 : reunions (la table "parent")
        // ──────────────────────────────────────────────────────
        await db.execute('''
          CREATE TABLE reunions (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            titre           TEXT NOT NULL,
            date_reunion    TEXT NOT NULL,
            heure_debut     TEXT,
            lieu            TEXT,
            type_reunion    TEXT NOT NULL DEFAULT 'Ordinaire',
            ordre_du_jour   TEXT,
            president       TEXT,
            secretaire      TEXT NOT NULL,
            statut          TEXT NOT NULL DEFAULT 'en_cours',
            date_creation   TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        // ──────────────────────────────────────────────────────
        // TABLE 2 : participants (les présents)
        // ──────────────────────────────────────────────────────
        await db.execute('''
          CREATE TABLE participants (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            reunion_id  INTEGER NOT NULL,
            nom         TEXT NOT NULL,
            prenom      TEXT NOT NULL,
            fonction    TEXT,
            FOREIGN KEY (reunion_id) REFERENCES reunions(id)
              ON DELETE CASCADE
          )
        ''');

        // ──────────────────────────────────────────────────────
        // TABLE 3 : interventions (les prises de parole)
        // ──────────────────────────────────────────────────────
        await db.execute('''
          CREATE TABLE interventions (
            id                INTEGER PRIMARY KEY AUTOINCREMENT,
            reunion_id        INTEGER NOT NULL,
            participant_id    INTEGER NOT NULL,
            contenu           TEXT NOT NULL,
            date_intervention TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (reunion_id) REFERENCES reunions(id)
              ON DELETE CASCADE,
            FOREIGN KEY (participant_id) REFERENCES participants(id)
              ON DELETE CASCADE
          )
        ''');

        // ──────────────────────────────────────────────────────
        // DONNÉES DE TEST (pour ne pas démarrer avec une base vide)
        // ──────────────────────────────────────────────────────
        await db.insert("reunions", {
          "titre": "Réunion du bureau — Mai 2026",
          "date_reunion": "2026-05-15",
          "heure_debut": "18:30",
          "lieu": "Maison des associations, Yoff",
          "type_reunion": "Ordinaire",
          "ordre_du_jour":
              "1. Bilan des activités\n2. Préparation de la fête de quartier\n3. Questions diverses",
          "president": "Fatou Diop",
          "secretaire": "Moussa Sow",
          "statut": "en_cours",
        });

        // Participants de la réunion 1
        for (final p in [
          {"nom": "DIOP", "prenom": "Fatou", "fonction": "Présidente"},
          {"nom": "SOW", "prenom": "Moussa", "fonction": "Secrétaire général"},
          {"nom": "BA", "prenom": "Ibrahima", "fonction": "Trésorier"},
          {"nom": "DIALLO", "prenom": "Aminata", "fonction": "Membre"},
        ]) {
          await db.insert("participants", {"reunion_id": 1, ...p});
        }

        // Deux interventions d'exemple
        await db.insert("interventions", {
          "reunion_id": 1,
          "participant_id": 1,
          "contenu":
              "Je déclare la séance ouverte et je vous remercie de votre présence.",
        });
        await db.insert("interventions", {
          "reunion_id": 1,
          "participant_id": 3,
          "contenu":
              "Le solde du compte est positif, nous avons un excédent de 420 000 FCFA ce trimestre.",
        });
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // À TOI D'ÉCRIRE TOUTES LES MÉTHODES CRUD CI-DESSOUS
  // (signatures données pour t'aider à structurer)
  // ════════════════════════════════════════════════════════════

  // ── RÉUNIONS ──
  Future<int> ajouterReunion(Map<String, Object?> reunion) async {
    final db = await this.db;
    return await db.insert('reunions', reunion);
  }

  Future<List<Map<String, dynamic>>> listerReunions() async {
    final db = await this.db;
    return await db.query(
      'reunions',
      orderBy: 'date_reunion DESC',
    );
  }

  Future<Map<String, dynamic>?> getReunion(int id) async {
    final db = await this.db;
    final result = await db.query(
      'reunions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> terminerReunion(int id) async {
    final db = await this.db;
    return await db.update(
      'reunions',
      {'statut': 'terminée'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── PARTICIPANTS ──
  Future<int> ajouterParticipant(int reunionId, String nom, String prenom, String? fonction) async {
    final db = await this.db;
    return await db.insert('participants', {
      'reunion_id': reunionId,
      'nom': nom,
      'prenom': prenom,
      'fonction': fonction,
    });
  }

  Future<List<Map<String, dynamic>>> listerParticipants(int reunionId) async {
    final db = await this.db;
    return await db.query(
      'participants',
      where: 'reunion_id = ?',
      whereArgs: [reunionId],
      orderBy: 'id ASC',
    );
  }

  // ── INTERVENTIONS ──
  Future<int> ajouterIntervention(int reunionId, int participantId, String contenu) async {
    final db = await this.db;
    return await db.insert('interventions', {
      'reunion_id': reunionId,
      'participant_id': participantId,
      'contenu': contenu,
    });
  }

  /// LA REQUÊTE LA PLUS IMPORTANTE — jointure pour le PV
  Future<List<Map<String, dynamic>>> listerInterventionsAvecParticipant(int reunionId) async {
    final db = await this.db;
    return await db.rawQuery('''
      SELECT i.id,
             i.reunion_id,
             i.participant_id,
             i.contenu,
             i.date_intervention,
             p.nom,
             p.prenom,
             p.fonction
      FROM interventions AS i
      JOIN participants AS p ON i.participant_id = p.id
      WHERE i.reunion_id = ?
      ORDER BY i.date_intervention ASC
    ''', [reunionId]);
  }
}