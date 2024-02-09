import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:lazy_loading_list/lazy_loading_list.dart';
import 'package:solstice/core/constant/app_strings.dart';
import 'package:solstice/core/model_download_manager.dart';
import 'package:solstice/features/terms_condition/bloc/terms_condition_cubit.dart';
import 'package:solstice/features/terms_condition/bloc/terms_condition_state.dart';
import 'package:solstice/features/terms_condition/models/terms_model.dart';
import 'package:solstice/features/terms_condition/widgets/add_update_term_bottom_sheet.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final modelManager = OnDeviceTranslatorModelManager();
  @override
  void initState() {
    super.initState();
    // To fetch all terms and condition on initial time
    context.read<TermsCubit>().loadTerms();
  }

  // To check if Hindi model exist or not
  Future<bool> _isHindiModelExists() async {
    return await modelManager
        .isModelDownloaded(TranslateLanguage.hindi.bcpCode);
  }

  Widget buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  // To render terms and condition data UI
  Widget buildTermCard(TermsModel term) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return buildAddTermBottomSheet(term);
          },
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                term.value,
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.w400),
              ),
            ),
            if (term.translatedValue.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  term.translatedValue,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            buildReadInHindiButton(term),
          ],
        ),
      ),
    );
  }

  // To render ReadInHindi button UI
  Widget buildReadInHindiButton(TermsModel term) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 3, right: 5),
        child: ElevatedButton(
          onPressed: () async {
            final bool isHindiModelExists = await _isHindiModelExists();
            if (isHindiModelExists) {
              context.read<TermsCubit>().translateToHindi(term);
            } else {
              ModelDownloadManager downloadManager =
                  ModelDownloadManager(context);

              downloadManager.downloadModel(TranslateLanguage.hindi.bcpCode);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF029BD6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Text(
            AppString.readInHindi,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  // To render AddMore button UI to add terms and condition
  Widget buildAddMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return buildAddTermBottomSheet(null);
            },
          );
        },
        style: ElevatedButton.styleFrom(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text(
          AppString.addMore,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // To open bottomSheet UI
  Widget buildAddTermBottomSheet(TermsModel? term) {
    return Builder(
      builder: (builderContext) {
        return AddUpdateTermBottomSheet(
          isEdit: term != null ? true : false,
          termsModel: term,
          onAddTerm: (englishText, translatedText, termsModel) {
            if (termsModel != null) {
              final newTerm = TermsModel(
                id: termsModel.id,
                value: englishText,
                createdAt: termsModel.createdAt,
                updatedAt: DateTime.now().millisecondsSinceEpoch.toString(),
                translatedValue: translatedText,
              );
              builderContext.read<TermsCubit>().updateTerm(newTerm);
            }
            if (termsModel == null) {
              final newTerm = TermsModel(
                  id: UniqueKey().hashCode,
                  value: englishText,
                  createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
                  updatedAt: DateTime.now().millisecondsSinceEpoch.toString(),
                  translatedValue: translatedText);

              builderContext.read<TermsCubit>().addTerm(newTerm);
            }
          },
        );
      },
    );
  }

  // To render terms and condition list data UI
  Widget buildTermsList(List<TermsModel> terms) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: terms.length + 1,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              if (index < terms.length) {
                final term = terms[index];
                return LazyLoadingList(
                  initialSizeOfItems: 6,
                  index: index,
                  hasMore: true,
                  loadMore: () => print('Loading More'),
                  child: buildTermCard(term),
                );
              }
              return buildAddMoreButton();
            },
          ),
        ),
      ],
    );
  }

  // TO render error UI if no data fetched
  Widget buildErrorWidget() {
    return Center(
      child: Text(AppString.failedToLoadTermsAndConditions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppString.termsAndConditions,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<TermsCubit, TermsState>(
        buildWhen: (previousState, currentState) {
          return currentState is! TranslateTextToHindiState;
        },
        builder: (context, state) {
          if (state is TermsInitialState || state is TermsLoadingState) {
            return buildLoadingIndicator();
          } else if (state is TermsLoadedState) {
            return buildTermsList(state.terms);
          } else if (state is TermsErrorState) {
            return buildErrorWidget();
          } else {
            return buildLoadingIndicator();
          }
        },
      ),
    );
  }
}
