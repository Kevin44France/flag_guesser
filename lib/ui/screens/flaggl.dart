import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Flaggl extends StatefulWidget {
  @override
  _FlagglState createState() => _FlagglState();
}

class _FlagglState extends State<Flaggl> {
  List countries = []; // Added to store countries data
  bool isLoading = false; // Added to handle loading state

  // Function to fetch countries
  Future<void> fetchCountries() async {
    setState(() {
      isLoading = true; // Start loading
    });

    var url = Uri.parse('https://rest-countries10.p.rapidapi.com/countries');
    var headers = {
      'X-RapidAPI-Key': '5ffebd22e0msh81794727dc35776p116ef2jsn0264b6e23bd5', // Replace with your API key
      'X-RapidAPI-Host': 'rest-countries10.p.rapidapi.com'
    };

    try {
      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          countries = data; // Update countries data
          isLoading = false; // Stop loading
        });
      } else {
        print('Request failed with status: ${response.statusCode}.');
        setState(() {
          isLoading = false; // Stop loading on error
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false; // Stop loading on exception
      });
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
            ? CircularProgressIndicator() // Show loading indicator
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Devine le pays!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Fetch Countries'),
              onPressed: fetchCountries,
            ),
            Expanded( // Use Expanded to fill remaining space
              child: ListView.builder( // Display countries in a list
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(countries[index]['name']), // Display country name
                    leading: Image.network(countries[index]['flag']), // Display country flag
                  );
                },
              ),
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
