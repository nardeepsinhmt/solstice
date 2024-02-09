import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:solstice/core/constant/app_strings.dart';
import 'package:solstice/core/model_download_manager.dart';
import 'package:solstice/features/terms_condition/bloc/terms_condition_cubit.dart';
import 'package:solstice/features/terms_condition/bloc/terms_condition_state.dart';
import 'package:solstice/features/terms_condition/models/terms_model.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart';

class AddUpdateTermBottomSheet extends StatefulWidget {
  final void Function(String, String, TermsModel?) onAddTerm;
  final bool isEdit;
  final TermsModel? termsModel;

  const AddUpdateTermBottomSheet({
    Key? key,
    required this.onAddTerm,
    this.isEdit = false,
    this.termsModel,
  }) : super(key: key);

  @override
  AddUpdateTermBottomSheetState createState() => AddUpdateTermBottomSheetState();
}

class AddUpdateTermBottomSheetState extends State<AddUpdateTermBottomSheet> {
  final TextEditingController _termTextController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ValueNotifier<bool> _isListeningNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isSubmittingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _spokenTextNotifier = ValueNotifier<String>('');
  final modelManager = OnDeviceTranslatorModelManager();
  String _translatedText = '';

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _isSubmittingNotifier.value = true;
      _termTextController.text = widget.termsModel!.value;
    }
  }

  // To translate entered text into Hindi text
  void _translateToHindi() async {
    if (_termTextController.text.isNotEmpty) {
      final bool isHindiModelExists = await _isHindiModelExists();
      if (isHindiModelExists) {
        context
            .read<TermsCubit>()
            .translateTextToHindi(_termTextController.text);
      } else {
        ModelDownloadManager downloadManager = ModelDownloadManager(context);

        downloadManager.downloadModel(TranslateLanguage.hindi.bcpCode);
      }
    }
  }

  // To check if Hindi model exist or not
  Future<bool> _isHindiModelExists() async {
    return await modelManager
        .isModelDownloaded(TranslateLanguage.hindi.bcpCode);
  }

  // To add/update user entered terms into list
  void _addTerm() {
    if (_termTextController.text.isNotEmpty) {
      final englishText = _termTextController.text;
      widget.onAddTerm(englishText, _translatedText, widget.termsModel);
      Navigator.of(context).pop();
    } else {
      SnackBar snackBar = SnackBar(
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          right: 8,
          left: 8,
        ),
        content: Text(AppString.pleaseEnterText),
        behavior: SnackBarBehavior.floating,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // To render TextField UI
  Widget buildTextField() {
    return Expanded(
      child: TextField(
        controller: _termTextController,
        onChanged: (value) {
          if (value.isNotEmpty) {
            _isSubmittingNotifier.value = true;
          } else {
            _isSubmittingNotifier.value = false;
          }
          setState(() {});
        },
        maxLines: 10,
        minLines: 2,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(
            12.0,
          ),
          labelText: AppString.enterTermAndCondition,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // To render translated Hindi text UI
  Widget buildTranslatedText() {
    return Text(
      _translatedText,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  // To render ViewInHindi button UI
  Widget buildViewInHindiButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF029BD6),
        ),
        onPressed: _translateToHindi,
        child: Text(
          AppString.viewInHindi,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // To render Submit button UI
  Widget buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isSubmittingNotifier,
        builder: (context, isSubmitting, child) {
          return ElevatedButton(
            onPressed: isSubmitting ? _addTerm : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _termTextController.text.isEmpty
                  ? Colors.grey
                  : const Color(0xFF029BD6),
            ),
            child: Text(
              widget.isEdit ? AppString.update : AppString.confirm,
              style: const TextStyle(color: Colors.black),
            ),
          );
        },
      ),
    );
  }

  // To handle listening event
  void _startListening(StateSetter setState) async {
    if (!_isListeningNotifier.value) {
      final bool available = await _speech.initialize(onStatus: (status) {
        setState(() {
          _isListeningNotifier.value =
              status == stt.SpeechToText.listeningStatus;
        });
      });
      if (available) {
        setState(() {
          _isListeningNotifier.value = true;
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _spokenTextNotifier.value = result.recognizedWords;
              _isListeningNotifier.value = false;
            });
          },
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        );
      }
    } else {
      _speech.stop();
    }
  }

  // Open dialog to spoken words to add into terms and condition
  void _openMicDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateData) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogTitle(),
                  const SizedBox(height: 10),
                  _buildMicButtons(setStateData),
                  _buildSpokenText(),
                  const SizedBox(height: 10),
                  _buildActionButtons(),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildDialogTitle() {
    return Text(
      AppString.saySomething,
      style: const TextStyle(fontSize: 16),
    );
  }

  // To render Mic button UI
  Widget _buildMicButtons(StateSetter setStateData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: ValueListenableBuilder<bool>(
            valueListenable: _isListeningNotifier,
            builder: (context, isListening, child) {
              return Icon(
                isListening ? Icons.mic : Icons.mic_none,
              );
            },
          ),
          onPressed: () {
            _spokenTextNotifier.value = '';
            _startListening(setStateData);
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: _isListeningNotifier,
          builder: (context, isListening, child) {
            return Text(isListening ? 'Listening...' : '');
          },
        )
      ],
    );
  }

  // To render spokenText UI
  Widget _buildSpokenText() {
    return Text(_spokenTextNotifier.value);
  }

  // TO render cancel and submit button UI in dialog
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _speech.stop();
              _isSubmittingNotifier.value = true;
              Navigator.of(context).pop();
            },
            child: Text(AppString.cancel),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: ValueListenableBuilder<String>(
            valueListenable: _spokenTextNotifier,
            builder: (context, spokenText, child) {
              return ElevatedButton(
                onPressed: _isListeningNotifier.value
                    ? null
                    : () {
                        if (spokenText.isEmpty) {
                          SnackBar snackBar = SnackBar(
                            margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height - 100,
                              right: 8,
                              left: 8,
                            ),
                            content: Text(AppString.pleaseSpeakSomething),
                            behavior: SnackBarBehavior.floating,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          _speech.stop();
                          _isSubmittingNotifier.value = true;
                          _termTextController.text = _spokenTextNotifier.value;
                          setState(() {});
                          Navigator.of(context).pop();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: spokenText.isEmpty ? Colors.grey : null,
                ),
                child: Text(AppString.submit),
              );
            },
          ),
        ),
      ],
    );
  }

  // To render Mic button in bottomSheet UI
  Widget buildMicButton() {
    return IconButton(
      icon: ValueListenableBuilder<bool>(
        valueListenable: _isListeningNotifier,
        builder: (context, isListening, child) {
          return Icon(
            isListening ? Icons.mic : Icons.mic_none,
          );
        },
      ),
      onPressed: () async {
        final status = await Permission.microphone.request();
        if (status.isGranted) {
          if (!_isListeningNotifier.value) {
            _spokenTextNotifier.value = '';
            _termTextController.text = '';
            _openMicDialog();
          } else {
            _speech.stop();
          }
        } else {
          showSettingsDialog(context);
        }
      },
    );
  }

  // To display permission setting dialog
  Future<void> showSettingsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppString.permissionRequired),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(AppString.permissionRequiredSubTitle),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppString.openSettings),
              onPressed: () async {
                await openAppSettings();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _isListeningNotifier.dispose();
    _isSubmittingNotifier.dispose();
    _spokenTextNotifier.dispose();
    _termTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TermsCubit, TermsState>(
      listener: (context, state) {
        if (state is TranslateTextToHindiState) {
          setState(() {
            _translatedText = state.hindiText;
          });
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 20.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: [
                buildTextField(),
                buildMicButton(),
              ],
            ),
            const SizedBox(height: 12),
            if (_translatedText.isNotEmpty) buildTranslatedText(),
            buildViewInHindiButton(),
            const SizedBox(height: 10),
            buildSubmitButton(),
          ],
        ),
      ),
    );
  }
}
