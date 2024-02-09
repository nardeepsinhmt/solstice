import 'package:solstice/features/terms_condition/models/terms_model.dart';

abstract class TermsState {}

class TermsInitialState extends TermsState {}

class TermsLoadingState extends TermsState {}

class TermsLoadedState extends TermsState {
  final List<TermsModel> terms;

  TermsLoadedState(this.terms);
}

class TranslateTextToHindiState extends TermsState {
  final String hindiText;

  TranslateTextToHindiState({required this.hindiText});
}

class TermsErrorState extends TermsState {}
