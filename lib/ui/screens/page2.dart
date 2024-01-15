import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
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
                  name: json['name']['common'], flagUrl: json['flag']['officialflag']['svg']))
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
  }

  void setChoices(){
    choices.clear();
    answer = countries[Random().nextInt(countries.length)];
    choices = generateRandomChoices(countries, answer);
  }

  List<Country> generateRandomChoices(List<Country> countries, Country answer){
    List<Country> choices = [];
    choices.add(answer);
    while(choices.length < 4){
      Country choice = countries[Random().nextInt(countries.length)];
      if(!choices.contains(choice)){
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
        title: const Text('Page 2'),
        backgroundColor: Colors.green,
      ),
      body: Center(
       child: isLoading ? const CircularProgressIndicator() : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            const Text('Devine le drapeau correspondant au pays!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Commencer le jeu'),
              onPressed: () {
                fetchCountries();
              },
            ),
            Expanded(
              child:
            ),
            ElevatedButton(
              child: const Text('Retour au Menu Principal'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
