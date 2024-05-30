import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils.dart';
import 'package:provider/provider.dart';
import 'theme.dart';

import './NewUIPages/Mvp3CoverPage.dart';
import './NewUIPages/Mvp3MusicPlayerPage.dart';
import './NewUIPages/Mvp3SongSelectPage.dart';
import './NewUIPages/MoodSelectPage.dart';
import './NewUIPages/Mvp3LoginPage.dart';
import './NewUIPages/MoodSelectPage.dart';
import './NewUIPages/Mvp3CoverPage.dart';
import './NewUIPages/Mvp3MusicBankPage.dart';
import './NewUIPages/Mvp3SportAnalyticPage.dart';
import './NewUIPages/Mvp3SummaryPage.dart';



var USERNAME = '';
void main() async {

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{

  final Stopwatch stopwatch = Stopwatch()..start();

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        // 應用程序不活躍（例如：有來電或切換到另一個應用程序）
        debugPrint("[AppLifecycleState: INACTIVE]");
        stopwatch.stop();
        debugPrint('stopwatch.elapsed ${stopwatch.elapsed.inSeconds} seconds');
        break;
      case AppLifecycleState.paused:
        // 應用程序暫停，轉入背景運作，通常是先 inactive 再接續 pausede
        debugPrint("[AppLifecycleState: PAUSE]");
        break;
      case AppLifecycleState.resumed:
        debugPrint("[AppLifecycleState: RESUME]");
        stopwatch.start();
        break;
      case AppLifecycleState.detached:
        debugPrint("[AppLifecycleState: DETACHED]");
        break;
      default:
        debugPrint('[AppLifecycleState: default]');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider( // child widget can access Counter by using 'Provider.of<Counter>(context);'
      create: (_) => Counter(),
      child: SafeArea(child: MaterialApp(
        debugShowCheckedModeBanner:false,
        title: 'Flutter Demo',
        /******************************************/
        home: Mvp3CoverPage(), // root page
        /******************************************/
      )));
  }
}

/* No Use */
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void setLoadingTime () async{
    await Future.delayed(const Duration(seconds: 5));
    setState(() => isLoading = false);
  }
  bool isLoading = true;
  
  @override
  void initState(){
    super.initState();
    setLoadingTime();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            // Navigator.push(context, MaterialPageRoute(builder: (context) => PedoPage()));
          },
        ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(child: SpinKitCubeGrid(
            size: 140,
            color: Colors.grey.shade500,
          ),),
          Container(
          margin: const EdgeInsets.all(24),
          
          child: Center(
            child: TextButton(
              onPressed: () {
                // Navigator.of(context).push(createRoute(page: LoginPage()));
                },
              style: TextButton.styleFrom(padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),),
              child: Text('Press here to start...', 
              style: GoogleFonts.biryani(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w300,
              letterSpacing: 2.6,)),))),
        ]
      ));
  }
}
