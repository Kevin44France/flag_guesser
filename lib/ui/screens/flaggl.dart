import 'dart:math';
import 'package:flag_guesser/models/country.dart';
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
  List<Country> countries = [];
  List<String> countryNames = [];
  Country answer = Country(name: '', flagUrl: '');
  bool isLoading = false;
  int score = 0;
  int highScoreFlaggl = 0; // Variable pour le meilleur score
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
    if(countries.isEmpty){
      setState(() => isLoading = true);
      var url = Uri.parse('https://rest-countries10.p.rapidapi.com/countries');
      var headers = {
        'X-RapidAPI-Key': '5ffebd22e0msh81794727dc35776p116ef2jsn0264b6e23bd5',
        'X-RapidAPI-Host': 'rest-countries10.p.rapidapi.com'
      };

      try {
        var response = await http.get(url, headers: headers);
        if (response.statusCode == 200) {
          List data = jsonDecode(response.body);
          setState(() {
            countries = data
                .map((json) => Country(
                    name: json['name']['shortnamelowercase'],
                    flagUrl: json['flag']['officialflag']['svg']))
                .toList();
            countryNames = countries.map((country) => country.name).toList();
          });
          setState(() => isLoading = false);
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
    setGuess();
  }

  setGuess(){
    setState((){
      answer = countries[Random().nextInt(countries.length)];
    });
  }

  void checkGuess() {
    if (selectedCountry == answer.name) {
      setState(() {
        score++;
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
        if (score > highScoreFlaggl) {
          highScoreFlaggl = score;
          saveHighScore();
        }
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
        backgroundColor: const Color.fromARGB(216, 104, 159, 56),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : countries.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.network(
                        answer.flagUrl,
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
        backgroundColor: const Color.fromARGB(216, 104, 159, 56),
        tooltip: 'Fetch Random Country',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: Flaggl()));
