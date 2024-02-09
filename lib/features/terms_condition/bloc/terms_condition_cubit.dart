import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:solstice/features/terms_condition/bloc/terms_condition_state.dart';
import 'package:solstice/features/terms_condition/models/terms_model.dart';
import 'package:solstice/features/terms_condition/repo/terms_repository.dart';

class TermsCubit extends Cubit<TermsState> {
  final TermsRepository repository = TermsRepository();
  List<TermsModel> terms = [];
  static const TranslateLanguage sourceLanguage = TranslateLanguage.english;
  static const TranslateLanguage targetLanguage = TranslateLanguage.hindi;

  final onDeviceTranslator = OnDeviceTranslator(
    sourceLanguage: sourceLanguage,
    targetLanguage: targetLanguage,
  );

  final modelManager = OnDeviceTranslatorModelManager();
  TermsCubit() : super(TermsInitialState());

  // To get all terms and condition from json file
  Future<void> loadTerms() async {
    emit(TermsLoadingState());
    try {
      terms = await repository.fetchTerms();
      emit(TermsLoadedState(terms));
    } catch (e) {
      emit(TermsErrorState());
    }
  }

  // To translate selected terms and condition into Hindi text
  Future<void> translateToHindi(TermsModel term) async {
    try {
      final String response =
          await onDeviceTranslator.translateText(term.value);
      term.translatedValue = response;

      final index = terms.indexWhere((newTerm) => term.id == newTerm.id);

      if (index != -1) {
        terms[index] = term;
        emit(TermsLoadedState(List.from(terms)));
      }
    } catch (e) {
      emit(TermsErrorState());
    }
  }

  // To translate user entered text into Hindi text
  Future<void> translateTextToHindi(String engText) async {
    try {
      final String response = await onDeviceTranslator.translateText(engText);
      emit(TranslateTextToHindiState(hindiText: response));
    } catch (e) {
      emit(TermsErrorState());
    }
  }

  // To add new terms and condition to existing list
  void addTerm(TermsModel term) {
    terms.add(term);
    emit(TermsLoadedState(List.from(terms)));
  }

  // To update selected terms and condition
  void updateTerm(TermsModel term) {
    final index = terms.indexWhere((newTerm) => term.id == newTerm.id);
    if (index != -1) {
      terms[index] = term;
      emit(TermsLoadedState(List.from(terms)));
    }
  }
}
