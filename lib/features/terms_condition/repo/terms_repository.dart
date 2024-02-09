import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:solstice/features/terms_condition/models/terms_model.dart';

class TermsRepository {
  // To get all terms and condition using json file
  Future<List<TermsModel>> fetchTerms() async {
    final String termsJson = await rootBundle.loadString('assets/terms.json');
    final List<dynamic> jsonList = json.decode(termsJson);

    return jsonList.map((json) => TermsModel.fromJson(json)).toList();
  }
}
