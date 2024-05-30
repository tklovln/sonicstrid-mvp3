import 'package:flutter/material.dart';
import './Mvp3MusicPlayerPage.dart';
import './LoadingPage.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import '../utils.dart';
import '../endpoint/backend_api.dart' as backend_api;
import 'LoadingPage.dart';
import 'Mvp3MusicPlayerPage.dart';

class Mvp3SongSelectPage extends StatefulWidget {
  final String moodName;
  final ThemeData theme = MoodSelectTheme.customTheme;

  Mvp3SongSelectPage({super.key, required this.moodName});
  @override
  State<Mvp3SongSelectPage> createState() => _Mvp3SongSelectPageState();
}

class _Mvp3SongSelectPageState extends State<Mvp3SongSelectPage> {
  

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.theme,
      child: BasicScaffoldWidget(theme: widget.theme, childrens: _buildPage(context), avoidAppbar: false,)
      );
      
  }

  var counter;
  void recordSelection() async {
    var userUUID = counter.userId ?? 1;
    var musicSelectionId = await backend_api.createMusicSelection(userUUID, widget.moodName) ?? 1;
    
    counter.setMusicSelection(musicSelectionId);
  }

  Widget _buildPage(BuildContext context) {

    counter = Provider.of<Counter>(context);
    
    // List of situations
    var songPool = ['Flip the town', 'Abcd', 'Efgh', 'Rwby'];
    var _isEnable = [true, false, false, false];
    return Container(alignment: Alignment.bottomLeft, child:
      Column(
        children: [
        Expanded(flex:1, child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/moods/${widget.moodName}.png'), 
                fit: BoxFit.cover, 
                onError: (err, _) {
                    setState(){
                      print('no picture');
                  };
                },
              ),
            // borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20.0), bottomRight: Radius.circular(20.0)),
          ),
          // color: widget.theme.colorScheme.background, 
          child: Padding(padding: const EdgeInsets.all(32), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
          Text(widget.moodName, style: widget.theme.textTheme.bodyLarge),
          Text('Run through the rhythm of your step ,syncing in each melody.', style: widget.theme.textTheme.bodyMedium),
          
        ],)))),
        Expanded(flex:2, child: Container(color: widget.theme.colorScheme.primaryContainer,  child: Padding(padding: const EdgeInsets.all(16), child:
            _buildSongCards(context, songPool, _isEnable),
          )
        ))
        ],),);
    }
 

  Widget _buildSongCards(BuildContext context, List<String> songs, List<bool> isEnabled) {

    const double iconSize = 25;
    return ListView.builder(
      // padding: const EdgeInsets.all(32),
      itemCount: songs.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32), child: 
        IntrinsicHeight(child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [ 
          Expanded(flex:1, child: 
                Align(alignment: Alignment.centerLeft, child: 
                  SizedBox(height: 100, width: 100,
                  child: GestureDetector(
                    onTap: !isEnabled[index]
                        ? null
                        : () {
                            recordSelection();
                            Navigator.of(context).push(createRoute(page: LoadingPage())); 
                          },
                    child: 
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(16.0)),
                          color: Colors.grey
                          ),
                        // color: Colors.grey,
                        child: Image(
                          image: AssetImage('assets/images/song_cover.png')
                        ),
            ))))
          )
          ,
          Expanded(flex:2, child: 
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Container(child: Align(alignment: Alignment.topLeft, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(songs[index], style: widget.theme.textTheme.bodyMedium, textAlign: TextAlign.left,), 
              Text("Jude and jack", style: widget.theme.textTheme.bodySmall, textAlign: TextAlign.left),
              Text("Techo/Dubstep", style: widget.theme.textTheme.bodySmall, textAlign: TextAlign.left),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Container(padding: EdgeInsets.only(right: 8), child: Image(
                  width: iconSize,
                  height: iconSize,
                  image: AssetImage('assets/images/Vector.png')
                )),
                Container(padding: EdgeInsets.only(right: 8), child: Image(
                  width: iconSize,
                  height: iconSize,
                  image: AssetImage('assets/images/Pin_light.png')
                )),
              ],)
          ])))))
        ])));
      }
    );
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 2 / 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: !isEnabled[index]
              ? null
              : () {
                  recordSelection();
                  Navigator.of(context).push(createRoute(page: Mvp3MusicPlayerPage())); 
                },
          child: Card(
            color: isEnabled[index] ? Colors.red : Colors.grey.shade300,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  songs[index],
                  style: widget.theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

    Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: <Widget>[
          Text(
            'Playlist for',
            style: widget.theme.textTheme.bodyMedium
          ),
          Text(
            widget.moodName,
            style: widget.theme.textTheme.bodyMedium
          )
        ],
      ),
    );
  }

  Widget _buildSongList(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          createSongCard('Into dawn', context),
          createSongCard('Space advanture', context),
          createSongCard('Kupachapapa', context),
          createSongCard('Kupachapapa', context),
          createSongCard('Kupachapapa', context),
        ],
      ),
    );
  }

}






