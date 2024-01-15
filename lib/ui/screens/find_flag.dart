import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/country.dart';

class FindFlag extends StatefulWidget {
  @override
  State<FindFlag> createState() => _FindFlagState();
}

class _FindFlagState extends State<FindFlag> {
  List<Country> countries = [];
  List<Country> choices = [];
  int score = 0;
  int highScore = 0; // Variable pour stocker le score le plus élevé
  Country answer = Country(name: '', flagUrl: '');
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchCountries();
    loadHighScore(); // Charge le score le plus élevé au démarrage
  }

  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  Future<void> fetchCountries() async {
    setState(() => score = 0);

    if (countries.isEmpty) {
      setState(() => isLoading = true);
      var url = Uri.parse('https://rest-countries10.p.rapidapi.com/countries');
      var headers = {
        'X-RapidAPI-Key': '5ffebd22e0msh81794727dc35776p116ef2jsn0264b6e23bd5',
        'X-RapidAPI-Host': 'rest-countries10.p.rapidapi.com'
      };

      try {
        var response = await http.get(url, headers: headers);
        if (response.statusCode == 200) {
          List<dynamic> data = jsonDecode(response.body);
          setState(() {
            countries = data
                .map((json) => Country(
                    name: json['name']['shortnamelowercase'],
                    flagUrl: json['flag']['officialflag']['svg']))
                .toList();
          });
        } else {
          print('Request failed with status: ${response.statusCode}.');
        }
      } catch (e) {
        print('Error: $e');
      } finally {
        setState(() => isLoading = false);
      }
    }
    setChoices();
  }

  void setChoices() {
    setState(() {
      choices.clear();
      answer = countries[Random().nextInt(countries.length)];
      choices = generateRandomChoices(countries, answer);
    });
  }

  List<Country> generateRandomChoices(List<Country> countries, Country answer) {
    List<Country> choices = [answer];
    while (choices.length < 4) {
      Country choice = countries[Random().nextInt(countries.length)];
      if (!choices.contains(choice)) {
        choices.add(choice);
      }
    }
    choices.shuffle();
    return choices;
  }

  Future<void> checkValues(Country choice) async {
    if (choice == answer) {
      setState(() {
        score++;
      });
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Bravo!'),
            content: const Text('Tu as trouvé le bon drapeau!'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        if (score > highScore) {
          highScore = score;
          saveHighScore(); // Sauvegardez le nouveau score le plus élevé
        }
        score = 0;
      });
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Oops!'),
            content: const Text('Ce n\'est pas le bon drapeau!'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
    setChoices();
  }

  void saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('highScore', highScore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devine le drapeau'),
        backgroundColor: const Color.fromARGB(216, 104, 159, 56),
      ),
      body: isLoading
          ? const CircularProgressIndicator()
          : choices.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Devine le drapeau correspondant au pays!',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 60),
                      Text(
                        answer.name.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: choices.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () => checkValues(choices[index]),
                              child: Card(
                                clipBehavior: Clip.antiAlias,
                                elevation: 4.0,
                                child: SvgPicture.network(
                                  choices[index].flagUrl,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Text(
                        'Score: $score',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        // Affichez le score le plus élevé
                        'Score le plus élevé: $highScore',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    'Appuyez sur le bouton pour commencer le jeu',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchCountries,
        backgroundColor: const Color.fromARGB(216, 104, 159, 56),
        tooltip: 'Rafraîchir',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
