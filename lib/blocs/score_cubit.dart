import 'package:flag_guesser/models/score.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repositories/preferences_repository.dart';

class ScoreCubit extends Cubit<Score> {
  final PreferencesRepository preferencesRepository;
  ScoreCubit(this.preferencesRepository) : super(const Score(0, 0));

  void increment() => emit(state);

}