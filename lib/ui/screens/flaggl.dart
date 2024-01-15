import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Flaggl extends StatefulWidget {
  @override
  _FlagglState createState() => _FlagglState();
}

class _FlagglState extends State<Flaggl> {
  Map<String, dynamic>? randomCountry;
  bool isLoading = false;
  int score = 0;
  int highScoreFlaggl = 0; // Variable pour le meilleur score
  List<String> countryNames = [];
  String selectedCountry = '';

  @override
  void initState() {
    super.initState();
    fetchCountries();
    loadHighScore();
  }

  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScoreFlaggl = prefs.getInt('highScoreFlaggl') ?? 0;
    });
  }

  Future<void> saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('highScoreFlaggl', highScoreFlaggl);
  }

  Future<void> fetchCountries() async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse('https://rest-countries10.p.rapidapi.com/countries');
    var headers = {
      'X-RapidAPI-Key': '5ffebd22e0msh81794727dc35776p116ef2jsn0264b6e23bd5',
      'X-RapidAPI-Host': 'rest-countries10.p.rapidapi.com'
    };

    try {
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        countryNames = data
            .map<String>((country) => country['name']['shortnamelowercase'])
            .toList();
        setState(() {
          randomCountry = data[Random().nextInt(data.length)];
          isLoading = false;
        });
      } else {
        print('Échec de la requête avec le statut : ${response.statusCode}.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void checkGuess() {
    if (randomCountry != null &&
        selectedCountry == randomCountry!['name']['shortnamelowercase']) {
      setState(() {
        score++;
        if (score > highScoreFlaggl) {
          highScoreFlaggl = score;
          saveHighScore();
        }
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Bravo !'),
            content: const Text('Bonne réponse !'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  fetchCountries();
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        score = 0; // Réinitialiser le score
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Oops !'),
            content: const Text('Mauvaise réponse. Réessayez !'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  fetchCountries(); // Recharger un nouveau pays
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flaggl'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : randomCountry != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.network(
                        randomCountry!['flag']['officialflag']['svg'],
                        placeholderBuilder: (BuildContext context) =>
                            const CircularProgressIndicator(),
                        width: 200.0,
                        height: 100.0,
                      ),
                      const SizedBox(height: 20),
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text == '') {
                            return const Iterable<String>.empty();
                          }
                          return countryNames.where((String option) {
                            return option
                                .contains(textEditingValue.text);
                          });
                        },
                        onSelected: (String selection) {
                          setState(() {
                            selectedCountry = selection;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: checkGuess,
                        child: const Text('Vérifier'),
                      ),
                      Text('Score: $score'),
                      Text(
                          'Meilleur score: $highScoreFlaggl'), // Afficher le meilleur score
                    ],
                  )
                : const Text('Appuyez sur le bouton pour charger un pays'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchCountries,
        tooltip: 'Fetch Random Country',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: Flaggl()));
