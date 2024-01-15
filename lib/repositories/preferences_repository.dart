import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository{

  Future<void> saveScore(int score) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('score', score);
  }

  Future<int> loadScore() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('score') ?? 0;
  }
}