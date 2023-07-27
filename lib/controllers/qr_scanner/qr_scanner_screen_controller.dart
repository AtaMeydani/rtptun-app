import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../data/repo/repository.dart';

class QrScannerScreenController with ChangeNotifier {
  QRViewController? controller;

  Repository repository;
  QrScannerScreenController({
    required this.repository,
  });

  void Function(QRViewController) getOnQRViewCreated(BuildContext context) {
    return (QRViewController controller) {
      // this.controller = controller;
      // notifyListeners();

      controller.scannedDataStream.listen((scanData) async {
        controller.pauseCamera();
        try {
          ({String message, bool success}) res = await repository.importConfig(json.decode(scanData.code ?? '{}'));
          if (context.mounted) {
            if (res.success) {
              controller.dispose();
              Navigator.of(context).pop();
            } else {
              // _showSnackBar(context, res.message);
              controller.resumeCamera();
            }
          }
        } on FormatException {
          // _showSnackBar(context, 'Bad Format');
          controller.resumeCamera();
        }
      });
    };
  }

  Future<void> toggleFlash() async {
    await controller?.toggleFlash();
    notifyListeners();
  }

  Future<bool?> getFlashStatus() async {
    return await controller?.getFlashStatus();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
