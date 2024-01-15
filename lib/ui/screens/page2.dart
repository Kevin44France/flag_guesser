import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import '../../models/country.dart';

class Page2 extends StatefulWidget {
  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  List<Country> countries = [];
  List<Country> choices = [];
  Country answer = Country(name: '', flagUrl: '');
  bool isLoading = false;

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
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          countries = data
              .map((json) => Country(
                  name: json['name']['shortnamelowercase'],
                  flagUrl: json['flag']['officialflag']['svg']))
              .toList();
          isLoading = false;
        });
      } else {
        print('Request failed with status: ${response.statusCode}.');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
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

  Future<void> checkValues(Country choice) async {
    if (choice == answer) {
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
          });
    } else {
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
          });
    }
    setChoices();
  }

  List<Country> generateRandomChoices(List<Country> countries, Country answer) {
    List<Country> choices = [];
    choices.add(answer);
    while (choices.length < 4) {
      Country choice = countries[Random().nextInt(countries.length)];
      if (!choices.contains(choice)) {
        choices.add(choice);
      }
    }
    choices.shuffle();
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devine le drapeau'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : choices.isNotEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'Devine le drapeau correspondant au pays!',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        answer.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: choices.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              checkValues(choices[index]);
                            },
                            child: Column(
                              children: [
                                SvgPicture.network(
                                  choices[index].flagUrl,
                                  width: 100.0,
                                  height: 60.0,
                                  fit: BoxFit.contain,
                                ),
                                // Text(
                                //   choices[index].name,
                                //   style: const TextStyle(
                                //       fontSize: 16,
                                //       fontWeight: FontWeight.bold),
                                // ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  )
                : const Text('Appuyer sur le bouton pour commencer le jeu'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchCountries,
        tooltip: 'Fetch Random Country',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
