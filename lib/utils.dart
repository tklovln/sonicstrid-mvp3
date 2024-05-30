import 'package:flutter/material.dart';
import './NewUIPages/Mvp3MusicPlayerPage.dart';
import './NewUIPages/Mvp3SongSelectPage.dart';
import './NewUIPages/Mvp3MusicBankPage.dart';
import './NewUIPages/Mvp3SportAnalyticPage.dart';

/* This is a scaffold with safe-area, drawer, bottom navigator */
class BasicScaffoldWidget extends StatefulWidget {

  final Widget childrens;
  final ThemeData theme;
  bool avoidAppbar;
  List<bool> avoidAppbarCtrl = [true, true, true, true];
  BasicScaffoldWidget({required this.childrens, required this.theme, required this.avoidAppbar});

  @override
  _BasicScaffoldWidgetState createState() => _BasicScaffoldWidgetState();
}

class _BasicScaffoldWidgetState extends State<BasicScaffoldWidget> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {


    var bankPage = Mvp3MusicBankPageState();
    List<Widget> _widgetOptions = <Widget>[
      Padding(
              //padding: EdgeInsets.only(top: AppBar().preferredSize.height), 
              padding: widget.avoidAppbar? EdgeInsets.only(top: AppBar().preferredSize.height) : EdgeInsets.only(),
              child: widget.childrens),
      Padding(
              //padding: EdgeInsets.only(top: AppBar().preferredSize.height), 
              padding: widget.avoidAppbar? EdgeInsets.only(top: AppBar().preferredSize.height) : EdgeInsets.only(),
              child: Mvp3MusicBankPage()),
      Padding(
              //padding: EdgeInsets.only(top: AppBar().preferredSize.height), 
              padding: widget.avoidAppbar? EdgeInsets.only(top: AppBar().preferredSize.height) : EdgeInsets.only(),
              child: Mvp3SportAnalyticPage()),
      Padding(
              padding: widget.avoidAppbar? EdgeInsets.only(top: AppBar().preferredSize.height) : EdgeInsets.only(),
              child: widget.childrens),
    ];
    return Scaffold(
      drawer: createStaticDrawer(context),
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        )]),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          
          backgroundColor: Colors.transparent, // Set the background color for the BottomNavigationBar
          unselectedItemColor: Colors.white38, // Set the color for unselected items
          selectedItemColor: Colors.white,
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'sound bank',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_task),
              label: 'activity',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_day),
              label: 'profile',
            ),],
          onTap: (int index) {
            setState(() {
              _selectedIndex = index;
              print(index);
              widget.avoidAppbar = widget.avoidAppbarCtrl[_selectedIndex];
            });
          },),);
  } 
}


class CoverScaffoldWidget extends StatefulWidget {

  final Widget childrens;
  CoverScaffoldWidget({required this.childrens});

  @override
  _CoverScaffoldWidgetState createState() => _CoverScaffoldWidgetState();
}

class _CoverScaffoldWidgetState extends State<CoverScaffoldWidget> {
  Widget build(BuildContext context) {
  return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        )),
      body: Padding(padding: EdgeInsets.only(top: AppBar().preferredSize.height), child: widget.childrens)
  );
  }
}

/* implement counter for MusicPlayer */
class Counter with ChangeNotifier{
  int _count = 0;
  int _userId = -1;
  int _musicSelectionId = -1;
  get count => _count;
  set count(val) => _count = val;
  get userId => _userId;
  get musicSelectionId => _musicSelectionId;

  addCount(){
    _count++;
    notifyListeners();  
  }

  resetCount(){
    _count = 0;
    notifyListeners();
  }

  setUserId(int id){
    _userId = id;
    notifyListeners();
  }

  setMusicSelection(int id){
    _musicSelectionId = id;
    notifyListeners();
  }
}

/* Page transition function with animation, input widget is the page you want to go for*/
Route createRoute({required Widget page}) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) { return page;},
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

Widget labelBox(content){
  return Padding(padding: EdgeInsets.all(4.0),child: SizedBox(width: 100, height: 20, child: 
    Container(decoration: 
      BoxDecoration(borderRadius: BorderRadius.circular(30), color: Colors.yellow.shade700), padding: const EdgeInsets.all(2.0), 
        child: FittedBox(fit: BoxFit.contain, 
          child: Text(content)
  ))));
}

Widget createStaticDrawer(context){
  return Drawer(
          backgroundColor: Colors.white,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(height: 140, child: const DrawerHeader(
                //decoration: BoxDecoration(borderRadius: BorderRadius.zero),
                decoration: BoxDecoration(
                  color: Colors.black
                ),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(12.0),
                child: Align(alignment: Alignment.bottomLeft, child: Text('Options', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, color: Colors.white),)),
              )),
              Container(child: ListTile(
                title: const Text('Home', style: TextStyle(color: Colors.black)),
                // selected: _selectedIndex == 0,
                onTap: () {
                  // Update the state of the app
                  //_onItemTapped(0);
                  // Then close the drawer
                  Navigator.pop(context);
                },
              )),
              ListTile(
                title: const Text('User\'s info'),
                //selected: _selectedIndex == 1,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Music player page'),
                onTap: () {
                  Navigator.of(context).push(createRoute(page: Mvp3MusicPlayerPage()));
                },
              ),
              ListTile(
                title: const Text('Others'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ));
}


Widget createSongCard(String songName, BuildContext context){
  return Card(clipBehavior: Clip.hardEdge, color: Colors.white,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                debugPrint('Card tapped.');
              },
              child: SizedBox(
                width: 300,
                height: 100,
                child: Row(children: [
                  Container(
                    height: 120.0,
                    width: 120.0,
                    child: TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0),
                          )
                        ),),
                      onPressed: () {
                        /*
                        Navigator.of(context).push(
                        PageRouteBuilder(
                          // pageBuilder: (context, animation, secondaryAnimation) => Mvp3MusicPlayerPage(),
                          pageBuilder: () {},

                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.ease;

                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ));

                         */
                      },
                      child: Icon(Icons.play_circle_rounded, color: Colors.grey, size:50),
                    )),
                  Text(songName),]),))
            );
}

