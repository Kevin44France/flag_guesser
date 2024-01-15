import 'package:flag_guesser/repositories/preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../ui/screens/flaggl.dart';
import '../ui/screens/page2.dart';
import 'blocs/score_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  PreferencesRepository preferencesRepository = PreferencesRepository();
  final   ScoreCubit scoreCubit = ScoreCubit(preferencesRepository);
  scoreCubit.increment();
  runApp(BlocProvider<ScoreCubit>(
    create: (_) => scoreCubit, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Menu Principal des Jeux'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  void _navigateToFlaggl(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Flaggl()),
    );
  }

  void _navigateToPage2(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Page2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade200, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            GameButton(
              title: 'Flaggl',
              icon: Icons.flag,
              color: Colors.white,
              onPressed: () => _navigateToFlaggl(context),
            ),
            const SizedBox(height: 20),
            GameButton(
              title: 'Devine le drapeau',
              icon: Icons.gamepad,
              color: Colors.white,
              onPressed: () => _navigateToPage2(context),
            ),
          ],
        ),
      ),
    );
  }
}

class GameButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const GameButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 30),
      label: Text(title, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: onPressed,
    );
  }
}
