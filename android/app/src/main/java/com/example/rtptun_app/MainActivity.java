package com.example.rtptun_app;

import io.flutter.embedding.android.FlutterActivity;
import id.laskarmedia.openvpn_flutter.OpenVPNFlutterPlugin;
import android.content.Intent;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example/nativeLibraryDir";

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        OpenVPNFlutterPlugin.connectWhileGranted(requestCode == 24 && resultCode == RESULT_OK);
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        new MethodCallHandler() {
                            @Override
                            public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
                                if (call.method.equals("getNativeLibraryDir")) {
                                    String nativeLibraryDir = getApplicationContext().getApplicationInfo().nativeLibraryDir;
                                    result.success(nativeLibraryDir);
                                } else {
                                    result.notImplemented();
                                }
                            }
                        }
                );
    }
}
