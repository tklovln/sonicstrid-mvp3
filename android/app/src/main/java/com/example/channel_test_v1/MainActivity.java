package com.example.channel_test_v1;

import android.os.Bundle;
import android.util.Log;

import org.puredata.android.io.AudioParameters;
import org.puredata.android.io.PdAudio;
import org.puredata.android.service.PdPreferences;
import org.puredata.android.service.PdService;
import org.puredata.android.utils.PdUiDispatcher;
import org.puredata.core.PdBase;
import org.puredata.core.utils.IoUtils;

import java.io.File;
import java.io.IOException;

// import io.flutter.app.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.view.FlutterMain;

import io.flutter.embedding.android.FlutterActivity;
public class MainActivity extends FlutterActivity {

    private static String LOG_TAG = "FPWD";
    private static final String CHANNEL = "it.pixeldump.pocs.flutterpdwrapdemo";

    private PdService pdService = null;
    private PdUiDispatcher dispatcher;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        FlutterMain.startInitialization(this);
        super.onCreate(savedInstanceState);

        AudioParameters.init(this);
        PdPreferences.initPreferences(getApplicationContext());

        // GeneratedPluginRegistrant.registerWith(new FlutterEngine(this));
        // GeneratedPluginRegistrant.registerWith(this);
        initPd();
        // uncomment to test without interaction
        // PdBase.sendFloat("onOff", 1.0f);

        new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        // System.out.println(call.method);
                        if (call.method.substring(0,3).equals("bpm")) {
                            Integer value = Integer.valueOf(call.method.substring(3));
                            PdBase.sendFloat("bpm", value);
                        } else if (call.method.equals("musicOn")) {
                            PdBase.sendFloat("musicOnOff", 1.0f);
                        } else if (call.method.equals("musicOff")) {
                            PdBase.sendFloat("musicOnOff", 0.0f);
                        } else if (call.method.equals("speedUp")) {
                            PdBase.sendFloat("speedUp", 1.0f);
                            PdBase.sendFloat("speedUp", 0.0f);
                        } else if (call.method.equals("speedDown")) {
                            PdBase.sendFloat("speedDown", 1.0f);
                            PdBase.sendFloat("speedDown", 0.0f);
                        }
                    }
                });
    }

    private void startAudio() {
        try {
            pdService.initAudio(-1, -1, -1, -1);
        } catch (IOException e) {
            Log.v(LOG_TAG, "something went wrong attempting start audio");
        }
    }

    private void stopAudio() {
        pdService.stopAudio();
    }

    private void initPd() {
        dispatcher = new PdUiDispatcher();
        PdBase.setReceiver(dispatcher);

        // int sampleRate = AudioParameters.suggestSampleRate();
        int sampleRate = 44100;
        try {
            PdAudio.initAudio(sampleRate, 0, 2, 8, true);
            loadPdPatch();
        } catch (IOException e) {
            Log.v(LOG_TAG, "failed to init pd audio");
        }
    }

    private void loadPdPatch() throws IOException {
        File dir = getFilesDir();
        IoUtils.extractZipResource(getResources().openRawResource(R.raw.soundtest), dir, true);
        File patchFile = new File(dir, "1109SQE.pd");
        PdBase.openPatch(patchFile.getAbsolutePath());
    }

    @Override
    protected void onPause() {
        super.onPause();
        PdAudio.stopAudio();
    }

    @Override
    protected void onResume() {
        super.onResume();
        PdAudio.startAudio(this);
    }
}