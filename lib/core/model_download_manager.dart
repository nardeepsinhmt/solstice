import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:solstice/core/constant/app_strings.dart';

class ModelDownloadManager {
  final BuildContext context;

  ModelDownloadManager(this.context);

  final modelManager = OnDeviceTranslatorModelManager();

  Future<void> downloadModel(String languageCode) async {
    final bool isModelExists = await _isModelExists(languageCode);
    if (!isModelExists) {
      _showModelDownloadingDialog();
      await modelManager
          .downloadModel(languageCode, isWifiRequired: false)
          .then((value) {
        Navigator.pop(context);

        if (value) {
          _showSnackBar(AppString.successDownloading);
        } else {
          _showSnackBar(AppString.failedDownloading);
        }
      });
    }
  }

  Future<bool> _isModelExists(String languageCode) async {
    return await modelManager.isModelDownloaded(languageCode);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _showModelDownloadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateData) {
            return AlertDialog(
              content: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      AppString.downloadingHindiModel,
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
