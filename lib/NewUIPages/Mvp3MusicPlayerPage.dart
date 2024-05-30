// This is mvp3 Music Player 2023.10.20

import 'package:channel_test_v1/pdTestPage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../theme.dart';
import '../utils.dart';
import 'package:animated_text_kit/animated_text_kit.dart';  
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:csv/csv.dart';
import 'package:provider/provider.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:collection';
import 'dart:math';
import '../endpoint/backend_api.dart' as backend_api;

import './Mvp3SportAnalyticPage.dart';
import './Mvp3SummaryPage.dart';

class Mvp3MusicPlayerPage extends StatefulWidget {
  Mvp3MusicPlayerPage({super.key});
  final ThemeData theme = MyThemes.customTheme;
  @override
  State<Mvp3MusicPlayerPage> createState() => _Mvp3MusicPlayerPageState();
}

class _Mvp3MusicPlayerPageState extends State<Mvp3MusicPlayerPage> {
  // ----------- 位置和速度變數 -----------
  late Stream<Position> geoPositionStream;
  late StreamSubscription geoPositionSub;
  double speed = 0;
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData _locationData = LocationData.fromMap({'latitude': 0.0, 'longitude': 0.0});
  late Timer _locationTimer;
  late Timer _checkGpsTimer;

  // LEI
  // ----------- method channel timer ----------
  PDPlayer pdplayer = PDPlayer();
  var messagesToPD;
  static final int speed_thres = 110;
  bool speedState = false; // false means slow, otherwise fast

  // ----------- BPM 和步數計算變數 ----------
  var counter, stepTimer;
  late Stream<StepCount> _stepCountStream; // return total step counts since system boot
  late StreamSubscription _stepCountSub;
  int initStepRecord = -1;
  bool startStepCount = false;
  String _steps = '?'; // bpm string text
  int _bpm = 0;
  int _bpmstamp = 0;
  double avg_bpm = 0;
  int _syncRate = 0;
  int stepCount = 0;
  int stepInterval = 100;
  List<int> stepIntervals = [];
  double strideLength = 1.39; // 1.39m is the average stride length of humans
  DateTime? lastStepTime;
  String bpmByInterval = '?';
  Queue<int> _bpmQueue = Queue<int>();
  Queue<int> _bpm_eternal_queue = Queue<int>(); // LEI
  
  // ----------- 音樂播放變數 -----------
  late List<String> audioPaths;
  bool isPlaying = true;
  Duration duration = Duration.zero;
  late double songlength = duration.inMilliseconds / 1000;
  Duration position = Duration.zero;
  late AudioPlayer musicPlayer1, musicPlayer2, effectPlayer;
  int currentSongIndex = 0;
  List<String?> playlist = ['homophony/0-1Intro.wav'];
  List<String> effectWav = ['effect/bathroom.wav', 'effect/convenienceStore.wav', 'effect/crossroads.wav', 'effect/waterDispenser.wav'];
  DateTime? lastEffectTriggered;
  List<String?> playbackHistory = [];

  // ----------- POI (Points of Interest) 變數 -----------
  List<Map<String, dynamic>> bathroomCoords = [];
  List<Map<String, dynamic>> convenienceStoreCoords = [];
  List<Map<String, dynamic>> crossroadsCoords = [];
  List<Map<String, dynamic>> waterDispenserCoords = [];

  // ----------- 其他狀態和設定 -----------
  String? activeStatus = 'static'; // 活動狀態：靜止(static)、起步(start)、走路(walk)、跑步(run)
  bool songSelected = false;
  bool firstPlayer = true; // 是否當前撥放器1播放
  int sectionIndex = 1;
  int sectionPlayCount = 0;
  int effect1Num = 0, effect2Num = 0, effect3Num = 0, effect4Num = 0;

  Timer? _playerTimer;
  double _playerTime = 0.0;
  double _pausedTime = 0.0;

  Timer? _recordTimer;
  late int selectionId;


  int _calculateSyncRate(){
    return (100.5*(1 / (exp(-0.1 * (_bpm-110)) + 1) - 1 / (exp(-0.1 * (_bpm-230)) + 1))).round();
  }
  
  void _startPlayerTimer() {
    _playerTimer = Timer.periodic(
      Duration(milliseconds: 100),
      (timer) async {
        double newTime = _playerTime + 0.1;
        bool newFirstPlayer = firstPlayer;

        if (songlength > 0 && newTime >= songlength - (songlength % (60 / 90 * 4 * 4)) && !songSelected) {
          songSelected = true;
          decideNextSong();
          String? audioFilePath = playlist[++currentSongIndex];
          
          if (audioFilePath != null) {
            if (firstPlayer) {
              await musicPlayer2.play(AssetSource(audioFilePath));
              await musicPlayer1.stop();                
              newFirstPlayer = false;
            }
            else {
              await musicPlayer1.play(AssetSource(audioFilePath));
              await musicPlayer2.stop();
              newFirstPlayer = true;
            }
            songSelected = false; 
            newTime = 0;
          }
        }

        setState(() {
          _playerTime = newTime;
          firstPlayer = newFirstPlayer;
        });
      },
    );
  }
  void _pausePlayerTimer() {
    _playerTimer?.cancel();
    _pausedTime = _playerTime;
  }
  void _resumePlayerTimer() {
    if (_pausedTime > 0) {
      _playerTime = _pausedTime;
      _startPlayerTimer();
    }
  }

  void recordRealData(int selectionId) {
    String durationString = position.toString().split('.').first;

    if(durationString != "0:00:00" || _bpm != 0)
      backend_api.createRealTimeData(
        musicSelectionId: selectionId, 
        currentPlaybackPosition: durationString,
        stepBpm: _bpm, 
        gps: [_locationData.latitude, _locationData.longitude]
      );
    }

  @override
  void initState(){
    super.initState();
    _initAudioSettings();
    _initLocationAndSpeed();
    _loadPoiData();
    _initBPMAndStepCounter();
    _initMethodChannelTimer();  // LEI

    _bpm_eternal_queue.addAll([0, 0, 0, 0]);  // LEI

    
    musicPlayer1 = AudioPlayer();
    musicPlayer2 = AudioPlayer();
    effectPlayer = AudioPlayer();
    initializeMusicPlayer(musicPlayer1);
    initializeMusicPlayer(musicPlayer2);

    pdplayer.toggleAudio('musicOn', 0);

    
    // 監聽音樂播放位置，並輪流在接近結束前2.4秒時播放下一首歌
    musicPlayer1.onPositionChanged.listen((newPosition) async {
      try{
        setState(() {
          position = newPosition;
        });
      } catch (e) {
        debugPrint('position changed wrong');
      }
    });
    musicPlayer2.onPositionChanged.listen((newPosition) async {
      try{
          setState(() {
            position = newPosition;
          });
        } catch (e) {
          debugPrint('position changed wrong');
        }
    });
    // 設置每五秒執行一次紀錄數據
    _recordTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      recordRealData(selectionId);
    });
  }
  
  @override
  void dispose() {
    _playerTimer?.cancel();
    musicPlayer1.dispose();
    musicPlayer2.dispose();
    effectPlayer.dispose();
    _checkGpsTimer.cancel();
    _locationTimer.cancel();
    stepTimer?.cancel();
    messagesToPD?.cancel(); // LEI
    _stepCountSub.cancel();
    _recordTimer?.cancel();
    
    counter.resetCount();
    super.dispose();
  }

  void onStepCount(StepCount event) {
    int steps = event.steps;
    if(startStepCount){
      if(initStepRecord == -1) initStepRecord = steps;

      stepCount = (steps - initStepRecord);

      int currentInterval = DateTime.now().difference(lastStepTime!).inMilliseconds;
      int currentBpm = (60000 / currentInterval).round();
      if (currentBpm <= 250) { // 只有當BPM小於等於250時，才將間隔加入列表
        stepIntervals.add(currentInterval);
      }

      // setState((){
      //   bpmByInterval = (60000/stepInterval).round().toString();
      //   debugPrint(bpmByInterval);
      // });

      // setState(() { 
      //   _steps = stepCount.toString();
      //   _bpm = (stepCount/counter.count*60).round().toString();
      // });
      // debugPrint('BPM: $_steps/${counter.count} = $_bpm');
    }
    lastStepTime = event.timeStamp;
  }

  int calculateBPM() {
  // Calculate the average interval
  int averageInterval = stepIntervals.isNotEmpty
      ? stepIntervals.reduce((a, b) => a + b) ~/ stepIntervals.length
      : 100; // Default value to avoid division by zero
  int bpm = (60000 / averageInterval).round();
  return bpm;
}


  int maxQueueSize = 5;
  void bpmEnqueue(bpmVal){
    if (_bpmQueue.length >= maxQueueSize) {
      if (_bpmQueue.isNotEmpty){
        _bpmQueue.removeFirst();
      }
    }
    _bpmQueue.add(bpmVal);
  }

  // LEI
  void bpm_eternal_Enqueue(bpmVal){
    if (_bpm_eternal_queue.length >= 4) {
      if (_bpm_eternal_queue.isNotEmpty){
        _bpm_eternal_queue.removeFirst();
      }
    }
    _bpm_eternal_queue.add(bpmVal);
  }

  int bpmsProcessing(){
    var sum = _bpmQueue.fold(0, (previous, current) => previous + current);
    return (sum / _bpmQueue.length).round().clamp(0, 200);
  }
  Future _initBPMAndStepCounter() async {
    startStepCount = false;
    // Init streams
    _stepCountStream = Pedometer.stepCountStream;
    // Set Listeners
    _stepCountSub = _stepCountStream.listen(onStepCount);
    
    stepTimer = Timer.periodic(Duration(milliseconds: 2300), (Timer timer) async {
      if (mounted) {
        startStepCount = true;
        Provider.of<Counter>(context, listen: false).addCount();

        int bpm = calculateBPM();
        stepIntervals.clear();
        
        //final lastStepTimeDiff = DateTime.now().difference(lastStepTime ?? DateTime.now()).inMilliseconds;
        
        if(bpm == 600){
          bpm = 0;
          _bpmstamp = bpm;
        } else {
          _bpmstamp = bpm;
        }

        // _bpmstamp = bpm;//lastStepTimeDiff > 800 ? 0 : (60000 / (stepInterval)).round();
        // _bpm = lastStepTimeDiff > 800 ? 0 : (60000 / (stepInterval ?? 1)).round();
        // print("$_bpmstamp");

        int tmp_bpm = 0;

        // if(_bpmstamp == 0){
        //   _bpmQueue.clear();
        //   tmp_bpm = 0;
        //   bpm_eternal_Enqueue( (_bpm_eternal_queue.last * 0.75).round() ); // LEI
        // } else {
          
        // }

        bpmEnqueue(_bpmstamp);
        tmp_bpm = bpmsProcessing();
        bpm_eternal_Enqueue(_bpmstamp); // LEI
        // print(_bpmQueue);
        // print("BPM: $tmp_bpm");
        
        

        setState(() {
          _bpm = bpm;//tmp_bpm;
          _syncRate = _calculateSyncRate();
          // ca
        });
      }
    });
  }
  Future _initAudioSettings() async {
    debugPrint('Enter _initAudioPieces');
    // To get music paths
    final manifestContent = await rootBundle.loadString('AssetManifest.json');  
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    audioPaths = manifestMap.keys
        .where((String key) => key.contains('homophony/') && key.contains('.wav'))
        .map((String path) => path.split('assets/')[1])
        .toList();

    debugPrint('Audio paths: $audioPaths');
  }
  Future _initLocationAndSpeed() async {
    debugPrint("Start _initLocation");
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    debugPrint("Current Location: ${_locationData.latitude}, ${_locationData.longitude}");
    _locationTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      _locationData = await location.getLocation();
    });
  }
  Future _loadPoiData() async {
    await loadCsvData('assets/locationGPS/bathroom.csv', bathroomCoords);
    await loadCsvData('assets/locationGPS/convenienceStore.csv', convenienceStoreCoords);
    await loadCsvData('assets/locationGPS/crossroads.csv', crossroadsCoords);
    await loadCsvData('assets/locationGPS/waterDispenser.csv', waterDispenserCoords);

    _checkGpsTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      checkProximity(bathroomCoords, 0);
      checkProximity(convenienceStoreCoords, 1);
      checkProximity(crossroadsCoords, 2);
      checkProximity(waterDispenserCoords, 3);
    });
  }

  void initializeMusicPlayer(AudioPlayer player) {
    // 偵測曲子時間改變
    player.onDurationChanged.listen((newDuration) {
      try {
        setState(() {
          duration = newDuration;
        });
      } catch (e) {
        debugPrint('Duration change error: $e');
      }
    });
    // 偵測是否撥放中
    player.onPlayerStateChanged.listen((state) {
      if(state != PlayerState.disposed && state != PlayerState.stopped) {
        try{
          setState(() {
            isPlaying = state == PlayerState.playing;
            debugPrint('Variables isPlaying: $isPlaying');
          });
        }catch(e){
          debugPrint('isPlaying wrong');
        }
      }
    });
  }

  // Asynchronously load CSV data from a given file path and store it in the provided destination list.
  Future loadCsvData(String filePath, List<Map<String, dynamic>> destination) async {
    String csvString = await rootBundle.loadString(filePath);
    List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(csvString);
    for (int i = 1; i < rowsAsListOfValues.length; i++) {
      Map<String, dynamic> coord = {
        'Latitude': rowsAsListOfValues[i][0],
        'Longitude': rowsAsListOfValues[i][1],
      };
      destination.add(coord);
    }
  }

  // Check if the current location is within a certain range (latitudeDelta, longitudeDelta) of any of the coordinates in the list.
  void checkProximity(List<Map<String, dynamic>> coords, int effectIndex) {
    double latitudeDelta = 0.000050; // 0.000018
    double longitudeDelta = 0.0000500; // 0.0000196

    if (_locationData.latitude != null && coords.isNotEmpty && isPlaying) {
      for (var coord in coords) {
        if (_locationData.latitude! >= (coord['Latitude'] - latitudeDelta) && 
            _locationData.latitude! <= (coord['Latitude'] + latitudeDelta) && 
            _locationData.longitude! >= (coord['Longitude'] - longitudeDelta) && 
            _locationData.longitude! <= (coord['Longitude'] + longitudeDelta)) {
          playEffect(effectIndex);
        }
      }
    }
  }

  // 尋找第一個符合條件的 wav 主旋律檔案
  String? findFirstWavFile(String directoryPath, String prefix) {
    return audioPaths.firstWhere(
      (path) => path.endsWith('.wav') && path.contains(prefix),
      orElse: () => 'homophony/0-1Intro.wav',
    );
  }

  // 播放音樂
  Future<void> playMusic() async {
    String? audioFilePath = playlist[currentSongIndex] ?? 'defaultPath';
    AudioPlayer playerToUse = firstPlayer ? musicPlayer1 : musicPlayer2;
    
    try {
      await playerToUse.play(AssetSource(audioFilePath));
      if (_playerTime == 0) {
        _startPlayerTimer();
      } else {
        _resumePlayerTimer();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // 暫停音樂
  Future<void> pauseMusic() async {
    _pausePlayerTimer();
    if (musicPlayer1.state == PlayerState.playing) {
      await musicPlayer1.pause();
    }
    if (musicPlayer2.state == PlayerState.playing) {
      await musicPlayer2.pause();
    }
    if (effectPlayer.state == PlayerState.playing) {
      await effectPlayer.pause();
    }
  }

  // 停止播放音樂
  Future<void> stopMusic() async {
    await musicPlayer1.stop();
    await musicPlayer2.stop();
    await effectPlayer.stop();
    
    // 播放結尾的歌曲序列
    List<String> endingSongs = [
      'homophony/5-1Slow.wav',
      'homophony/5-2Outro.wav'
    ];

    int endingSongIndex = 0;

    musicPlayer1.onPlayerComplete.listen((event) {
      playbackHistory.add(endingSongs[endingSongIndex]);
      endingSongIndex++;
      if (endingSongIndex < endingSongs.length) {
        musicPlayer1.play(AssetSource(endingSongs[endingSongIndex]));
      }
    });
    await musicPlayer1.play(AssetSource(endingSongs[endingSongIndex]));
  }

  // 播放特效音
  Future<void> playEffect(int index) async {
    if (lastEffectTriggered != null) {
      final difference = DateTime.now().difference(lastEffectTriggered!).inSeconds;
      if (difference < 5) {
        return;
      }
    }
    lastEffectTriggered = DateTime.now();

    if (index >= 0 && index < effectWav.length) {
      await effectPlayer.play(AssetSource(effectWav[index]));
      if (index == 0) {
        effect1Num++;
      }
      else if (index == 1) {
        effect2Num++;
      }
      else if (index == 2) {
        effect3Num++;
      }
      else if (index == 3) {
        effect4Num++;
      }
    }
  }

  // 決定下一首歌的邏輯
  void decideNextSong() {
    debugPrint('ON_ENTER_DECIDENEXTSONG');
    // 如果 sectionIndex 大於 4，則重置為 1
    if (sectionIndex > 4) {
      sectionIndex = 1;
    }
    // 決定目前活動狀態
    if (_bpm == null || _bpm! < 10) {
      activeStatus = 'static';
    } else if (activeStatus == 'static' && _bpm! < 50) {
      activeStatus = 'start';
    } else if (_bpm! <= 90) {
      activeStatus = 'walk';
    } else {
      activeStatus = 'run';
    }
    debugPrint('activeStatus');

    // 根據目前活動狀態撥放歌曲
    if (activeStatus == 'static') {
      playlist.add(findFirstWavFile('homophony', '0-1'));
    } else if (activeStatus == 'start') {
      playlist.add(findFirstWavFile('homophony', '0-2'));
    } else if (activeStatus == 'walk') {
      if (_bpm! <= 90) {
        if (sectionPlayCount < 6) {
          if(sectionPlayCount % 2 == 0){
            playlist.add(findFirstWavFile('homophony', '${sectionIndex}-1'));
          } else {
            playlist.add(findFirstWavFile('homophony', '${sectionIndex}-2'));
          }
        } else {
          if(sectionPlayCount % 2 == 0){
            playlist.add(findFirstWavFile('homophony', '${sectionIndex}-3'));
          } else {
            playlist.add(findFirstWavFile('homophony', '${sectionIndex}-4'));
            sectionIndex += 1;
            sectionPlayCount = 0;
            return;
          }
        }        
      }
    } else if (activeStatus == 'run') {
      if (sectionPlayCount < 4) {
        if (sectionPlayCount == 0 || sectionPlayCount == 1) {
          playlist.add(findFirstWavFile('homophony', '${sectionIndex}-1'));
        } else {
          playlist.add(findFirstWavFile('homophony', '${sectionIndex}-3'));
        }
      } else {
        playlist.add(findFirstWavFile('homophony', '${sectionIndex}-4'));
        sectionIndex += 1;
        sectionPlayCount = 0;
        return;
      }
    }
    sectionPlayCount += 1;
    try{
      debugPrint('ON_LEAVE_DECIDENEXTSONG, playlist: \n');
    } catch (e){
      debugPrint('www');
    }
  }

  String formatTime(Duration duration){
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds
    ].join(":");
  }

  // LEI
  Future _initMethodChannelTimer() async {
    messagesToPD = Timer.periodic(Duration(milliseconds: 1150), (Timer timer) async {
      if (_bpmQueue.length == maxQueueSize){
        List<int> bpmQueue = _bpm_eternal_queue.toList();

        num ave_bpm = 0;
        bpmQueue.sublist(0, 3).forEach((element) {
          ave_bpm += element/3;
          print(element);
        });

        num std_bpm = 0;
        bpmQueue.sublist(0, 3).forEach((element) {
          std_bpm += pow((element - ave_bpm), 2);
        });
        std_bpm = sqrt(std_bpm / 3);

        num cur_bpm = (bpmQueue[3]);

        print((cur_bpm - ave_bpm) / std_bpm);

        speedState = (ave_bpm >= 80 && ave_bpm <= 200) ? true : false;

        // pdplayer.toggleAudio('bpm', ave_bpm);
        
        if (( (cur_bpm - ave_bpm) / (std_bpm*0.8)) >= 1 || (ave_bpm < 130 && cur_bpm > 130) ){
          pdplayer.toggleAudio('speedUp', 0);
        }
        else if (( (cur_bpm - ave_bpm) / std_bpm) <= -1 || (ave_bpm > 130 && cur_bpm < 130) ){
          pdplayer.toggleAudio('speedDown', 0);
        }
      }

    });
  }

  @override
  Widget build(BuildContext context){
    counter = Provider.of<Counter>(context);
    selectionId = counter.musicSelectionId ?? 1;
    /*
    return MaterialApp(
      home: Scaffold(
      // drawer: createStaticDrawer(context),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => {
            Navigator.of(context).pop(),
          }
        )],
      ),
      body:
      SafeArea(
        top:true,
        child: Container(
        margin: const EdgeInsets.all(52), 
        child: 
        Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Now playing,', style: GoogleFonts.fahkwang(fontSize: 24, fontWeight: FontWeight.w700)),
          Text(playlist[currentSongIndex]?.split("/")[1] ?? "Unknown", style: GoogleFonts.fahkwang(fontSize: 18, fontWeight: FontWeight.w700)),
          Text('廁所音效撥放: $effect1Num', style: GoogleFonts.fahkwang(fontSize: 18, fontWeight: FontWeight.w700)),
          Text('便利商店撥放: $effect2Num', style: GoogleFonts.fahkwang(fontSize: 18, fontWeight: FontWeight.w700)),
          Text('十字路口撥放: $effect3Num', style: GoogleFonts.fahkwang(fontSize: 18, fontWeight: FontWeight.w700)),
          Text('飲水機撥放: $effect4Num', style: GoogleFonts.fahkwang(fontSize: 18, fontWeight: FontWeight.w700)),
          Text('Latitude: ${_locationData.latitude ?? "Unknown"}', style: GoogleFonts.fahkwang(fontSize: 18, fontWeight: FontWeight.w700)),
          Text('Longitude: ${_locationData.longitude ?? "Unknown"}', style: GoogleFonts.fahkwang(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(_bpm != null? 'BPM: $_bpm':'BPM: IDLE', style: GoogleFonts.fahkwang(fontSize: 18, fontWeight: FontWeight.w700)),
          // Container(margin: EdgeInsets.symmetric(vertical: 32), child: Image.asset('assets/images/dawn.jpg')),
          Text('Into dawn'),
          Text('jude'),
          Slider(
            min: 0, max: duration.inSeconds.toDouble(),
            value: position.inSeconds.toDouble(),
            onChanged: (value) async {},
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(formatTime(position)),
              Text(formatTime(duration))
            ],)
          ),
          CircleAvatar(
            radius: 35,
            child: IconButton(icon: Icon(
              isPlaying? Icons.pause : Icons.play_arrow,
            ),
            iconSize: 50,
            onPressed: () async {
              if (isPlaying) {
                // debugPrint('push stop playing button');
                pauseMusic();
              } else {
                // await audioPlayer.play(AssetSource('assets/audios/SonicS-Loop&Form.mp3'));
                // await musicPlayer.resume();
                // await effectPlayer.resume();

                /* Start Timer*/
                // debugPrint('Start Timer');                
                // stepTimer = Timer.periodic(Duration(seconds: 1), (_) {
                //   if(mounted){
                //     startStepCount = true;
                //     setState(() {
                //       Provider.of<Counter>(context, listen: false).addCount();
                //       int stepCheckTimeDiff = DateTime.now().difference(lastStepTime!).inMilliseconds;
                //       // debugPrint('Time difference: $stepCheckTimeDiff'); // 2~3 seconds check
                //       if(stepCheckTimeDiff > 800){
                //         _bpm = 0;
                //         debugPrint('BPM: IDLE');
                //       } else {
                //         _bpm = (60000/stepInterval).round(); // BPM by interval
                //         debugPrint('BPM: $_bpm');
                //         // _bpm = (stepCount/counter.count*60).round().toString();
                //         // _steps = stepCount.toString();
                //         // debugPrint('BPM: $_steps/${counter.count} = $_bpm');
                //       }
                //     });
                    
                                  
                //   }
                // });
                await playMusic();
              }
            },
            )
          ),
          //以下元件暫時測試用，手機上會拿掉
          // Slider(
          //   value: speed,
          //   min: 0,
          //   max: 10,
          //   divisions: 20,
          //   label: speed.round().toString(),
          //   onChanged: (double value) {
          //     setState(() {
          //       speed = value;
          //       debugPrint('Current speed: $value $_locationData');
          //     });
          //   },
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     ElevatedButton(
          //       onPressed: () => playEffect(0),
          //       child: Text('Bathroom'),
          //     ),
          //     ElevatedButton(
          //       onPressed: () => playEffect(1),
          //       child: Text('Convenience Store'),
          //     )
          //   ],
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     ElevatedButton(
          //       onPressed: () => playEffect(2),
          //       child: Text('Crossroads'),
          //     ),
          //     ElevatedButton(
          //       onPressed: () => playEffect(3),
          //       child: Text('Water Dispenser'),
          //     ),
          //   ],
          // ),
        ]))
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async { 
          if (isPlaying) {
            await stopMusic();
          }
          /*Calculate AVG Bpm*/
          double avg_bpm = (stepCount / counter.count*60);
          showDialog(context: context, builder: (context) => AlertDialog(
            content: Container(
              //height: 200, 
              //width: 300,
              child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Done !', style: GoogleFonts.fahkwang(fontSize: 24, fontWeight: FontWeight.w700)),
                  Container(margin: EdgeInsets.symmetric(vertical: 32), child: Image.asset('assets/images/dawn.jpg')),
                  Text('You\'ve work for', style: GoogleFonts.fahkwang(fontSize: 20, fontWeight: FontWeight.w400)),
                  labelBox('${(counter.count)/60} minutes'),
                  labelBox('${0.8*stepCount/1000}KM'), // use 0.8 meter/per step
                  labelBox('Avg ${avg_bpm.toStringAsFixed(2)} bpm'),
                  
                  Text('go through', style: GoogleFonts.fahkwang(fontSize: 20, fontWeight: FontWeight.w400)),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                    labelBox('2 Zebra Crossing'),
                    labelBox('1 Restroom'),
                  ],),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                    labelBox('2 Water Fountain'),
                    labelBox('0 Convenience Store'),
                  ],),
                  Text('in', style: GoogleFonts.fahkwang(fontSize: 20, fontWeight: FontWeight.w400)),
                  labelBox('Tainan, East district'),
                ],
              )
            ))
            )).then((val){
              Navigator.of(context).pop();
            });
        },
        backgroundColor: Colors.redAccent,
        child: const Text('End')
      ),
    )
    );
    */
    return Theme(
      data: widget.theme,
      child: CoverScaffoldWidget(childrens: _buildPage(context, counter)));
  }


  Widget _buildPage(context, counter){

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF6B17),
            Color(0xFF000000)
          ]
        ),
      ),
      child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 42), 
      child: Column(children: [
        Expanded(flex:1, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Sync rate"), Text("$_syncRate/100", style: widget.theme.textTheme.titleSmall)],)),
        Expanded(flex:5, child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 4,
                blurRadius: 12,
                offset: const Offset(5, 9), // changes position of shadow
              ),
            ],
          ),
          // color: Colors.black, 
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(padding: EdgeInsets.all(8), child: Text(formatTime(Duration(seconds: counter.count)), style: widget.theme.textTheme.titleMedium)),
          Padding(padding: EdgeInsets.all(0), child: Center(child: 
            SizedBox(width: 150, height: 150, child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Image(image: AssetImage('assets/images/song_cover.png'))
            ))
          )),
          Padding(padding: EdgeInsets.all(8), child: Text("Flip the town")),
          Padding(padding: EdgeInsets.all(8), child: Text("Jude and Jack", style: widget.theme.textTheme.bodySmall)),
          Padding(padding: EdgeInsets.all(0), child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [ 
            Expanded(child: IconButton(
              icon: Image(image: AssetImage('assets/images/Refresh_2.png'), width: 30, height: 30,),
              iconSize: 20,
              onPressed: () async {}
            )),
            Expanded(child: IconButton(
              icon: Icon(
                color: Colors.white,
                isPlaying? Icons.pause : Icons.play_arrow,
              ),
              iconSize: 50,
              onPressed: () async {
                if (isPlaying) {
                  // debugPrint('push stop playing button');
                  // pauseMusic();
                  setState(() {
                    isPlaying = false;
                  });
                  pdplayer.toggleAudio('musicOff', 0);
                } else {
                  // await audioPlayer.play(AssetSource('assets/audios/SonicS-Loop&Form.mp3'));
                  // await musicPlayer.resume();
                  // await effectPlayer.resume();

                  /* Start Timer*/
                  // debugPrint('Start Timer');                
                  // stepTimer = Timer.periodic(Duration(seconds: 1), (_) {
                  //   if(mounted){
                  //     startStepCount = true;
                  //     setState(() {
                  //       Provider.of<Counter>(context, listen: false).addCount();
                  //       int stepCheckTimeDiff = DateTime.now().difference(lastStepTime!).inMilliseconds;
                  //       // debugPrint('Time difference: $stepCheckTimeDiff'); // 2~3 seconds check
                  //       if(stepCheckTimeDiff > 800){
                  //         _bpm = 0;
                  //         debugPrint('BPM: IDLE');
                  //       } else {
                  //         _bpm = (60000/stepInterval).round(); // BPM by interval
                  //         debugPrint('BPM: $_bpm');
                  //         // _bpm = (stepCount/counter.count*60).round().toString();
                  //         // _steps = stepCount.toString();
                  //         // debugPrint('BPM: $_steps/${counter.count} = $_bpm');
                  //       }
                  //     });
                      
                                    
                  //   }
                  // });

                  // await playMusic();
                  pdplayer.toggleAudio('musicOn', 0); // LEI
                  setState(() {
                    isPlaying = true;
                  });
                }
              },
            )),
            // IconButton(
            //   icon: Image(image: AssetImage('assets/images/Arrow_right_stop.png'), width: 30, height: 30,),
            //   iconSize: 20,
            //   onPressed: () async {}
            // )
            Expanded(child: RawMaterialButton(
              onPressed: () {
                

                Navigator.of(context).push(createRoute(page: Mvp3SummaryPage(
                  avgBPM: (stepCount / counter.count * 60).toStringAsFixed(2), 
                  distance: (strideLength*stepCount/1000).toStringAsFixed(2),
                  musicLength: counter.count
                  )));



                _playerTimer?.cancel();
                musicPlayer1.dispose();
                musicPlayer2.dispose();
                effectPlayer.dispose();
                _checkGpsTimer.cancel();
                _locationTimer.cancel();
                stepTimer?.cancel();
                messagesToPD?.cancel(); // LEI
                _stepCountSub.cancel();
                _recordTimer?.cancel();
                pdplayer.toggleAudio('musicOff', 0);  // LEI
                counter.resetCount();

                
                
              },
              elevation: 2.0,
              fillColor: const Color.fromARGB(158, 255, 255, 255),
              child: Center(child: Text(
                "End", style: TextStyle(fontSize: 9), textAlign: TextAlign.center,
              )),
              padding: EdgeInsets.all(6),
              shape: CircleBorder(),
            ))
          ])))
        ],))),
        Expanded(flex:2, child: Container(child: Padding(padding: EdgeInsets.symmetric(vertical: 32, horizontal: 8), child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(children: [Text("Distance"), Text("${(strideLength*stepCount/1000).toStringAsFixed(2)}KM", style: widget.theme.textTheme.titleSmall)],),
            Column(children: [Text("BPM"), Text("$_bpm", style: widget.theme.textTheme.titleSmall)],),
            ],),
          ]),)
        ))]
      )));
  
  }
}