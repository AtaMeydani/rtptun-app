import 'package:flutter/services.dart';

class PlatformInvoke {
  static const _platform = MethodChannel('com.example/nativeLibraryDir');

  static Future<String?> getNativeLibraryDir() async {
    try {
      final String nativeLibraryDir = await _platform.invokeMethod("getNativeLibraryDir");
      return nativeLibraryDir;
    } on PlatformException catch (e) {
      print('Failed to get native library directory: ${e.message}');
      return null;
    }
  }
}
