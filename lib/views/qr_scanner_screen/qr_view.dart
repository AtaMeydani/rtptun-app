import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rtptun_app/controllers/qr_scanner/qr_scanner_screen_controller.dart';

class QRViewScreen extends StatelessWidget {
  QRViewScreen({Key? key}) : super(key: key);

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    QrScannerScreenController qrScannerScreenController = context.read<QrScannerScreenController>();
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _buildQrView(context),
              ),
            ],
          ),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              color: colorScheme.primary,
              onPressed: () async {
                await qrScannerScreenController.toggleFlash();
              },
              icon: Selector<QrScannerScreenController, Future<bool?>>(
                selector: (_, QrScannerScreenController controller) async => await controller.getFlashStatus(),
                builder: (context, value, child) {
                  return FutureBuilder(
                    future: qrScannerScreenController.getFlashStatus(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data == null) {
                          return const Icon(Icons.question_mark);
                        } else if (snapshot.data ?? false) {
                          return const Icon(Icons.flash_on);
                        } else {
                          return const Icon(Icons.flash_off);
                        }
                      } else {
                        return const Icon(Icons.flash_off);
                      }
                    },
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              color: colorScheme.primary,
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    // We check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (size.width < 400 || size.height < 400) ? 150.0 : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: context.read<QrScannerScreenController>().getOnQRViewCreated(context),
      overlay: QrScannerOverlayShape(
        borderColor: colorScheme.primary,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }
}
