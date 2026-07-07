import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const String _cleSecretaire = 'secretaire_defaut';
  static const String _cleAssociation = 'nom_association';
  static const String _cleTypeReunion = 'type_reunion_defaut';

  Future<String> getSecretaireDefaut() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cleSecretaire) ?? '';
  }

  Future<void> setSecretaireDefaut(String nom) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleSecretaire, nom);
  }

  Future<String> getNomAssociation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cleAssociation) ?? 'Association de quartier';
  }

  Future<void> setNomAssociation(String nom) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleAssociation, nom);
  }

  Future<String> getTypeReunionDefaut() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cleTypeReunion) ?? 'Ordinaire';
  }

  Future<void> setTypeReunionDefaut(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleTypeReunion, type);
  }

  Future<void> reinitialiser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}