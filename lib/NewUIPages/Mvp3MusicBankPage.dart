import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import './Mvp3SongSelectPage.dart';
import 'package:google_fonts/google_fonts.dart';
import './Mvp3CoverPage.dart';
import '../theme.dart';
import '../utils.dart';

class Mvp3MusicBankPage extends StatefulWidget {
  Mvp3MusicBankPage({super.key});
  final ThemeData theme = MyThemes.customTheme;

  @override
  State<Mvp3MusicBankPage> createState() => Mvp3MusicBankPageState();
}

class Mvp3MusicBankPageState extends State<Mvp3MusicBankPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = MoodSelectTheme.customTheme; 
    return Theme(
      data: theme,
      child: buildPage(context, 0),
    );
  }

  // Builds the main content of the page
  Widget buildPage(BuildContext context, int carouselIndex) {
    List<String> musicTags = ['Deep-house', 'Ambience', 'Electronic', 'Jazz', 'Funk', 'Rock']; // predefine some tags
    return Stack(children: [ 
      // add map image in background
      Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          // colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
          image: AssetImage('assets/images/map_0.png')),
      ),),
      // add gradient effect
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 0, 0, 0),
              Color.fromARGB(40, 255, 94, 0),
              //Colors.transparent,
            ]
          ),
        )
      ), 
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Column(children: [ 
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: IntrinsicHeight(child: SizedBox(
                  height: 25.0,
                  child: PageView.builder(
                    controller: PageController(viewportFraction: 0.32, initialPage: 1),
                    itemCount:  musicTags.length,
                    itemBuilder: (BuildContext context, int itemIndex) {
                      return  _buildMusicTagsBar(context, carouselIndex,  musicTags[itemIndex]);
                    },
                  ),
                )
              )), 
              Container(),
              Container(alignment: Alignment.centerLeft, child: 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                      child: Text('50 sound journeys', textAlign: TextAlign.start, style: widget.theme.textTheme.bodySmall),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                      child: Text('Sound Bank', textAlign: TextAlign.start, style: widget.theme.textTheme.titleSmall),
                    ),
                  ])),
              SizedBox(
                height: 200.0,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.8),
                  itemCount: 6,
                  itemBuilder: (BuildContext context, int itemIndex) {
                    return _buildMusicBankPlaylist(context, carouselIndex, (itemIndex%2).toString());
                  },
                ),
              )
            ])
          ),
          Expanded(flex:1, child: Column(children: [
            // Container(height: 200,), Center(child: 
            //   FilledButton.tonal(
            //         style: OutlinedButton.styleFrom(
            //           foregroundColor: Colors.black,
            //           backgroundColor: Colors.white,
            //           side: const BorderSide(color: Colors.black, width: 1), // Border styling
            //         ),
            //         onPressed: () {
            //           // Navigating to the login page when the button is pressed
            //           Navigator.of(context).push(createRoute(page: Mvp3CoverPage()));
            //         },
            //         child: Text(
            //           'Finish',
            //           style: GoogleFonts.biryani(
            //             fontSize: 13,
            //             fontWeight: FontWeight.w300,
            //             letterSpacing: 2.6,
            //           ),
            //         ),
            //       ),)
            ]
          )
          ),
        ],
      )
    ,
    
    ]);
  }

  // Builds individual carousel items
  Widget _buildMusicBankPlaylist(BuildContext context, int carouselIndex, String itemName) {
    var imgVariable = AssetImage('assets/images/banks/$itemName.png');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imgVariable,
            fit: BoxFit.fill,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }

  Widget _buildMusicTagsBar(BuildContext context, int carouselIndex, String itemName) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFF6B17),
          borderRadius: BorderRadius.all(Radius.circular(32.0)),
        ),
        child: Center(child: Text(itemName, textAlign: TextAlign.center, style: widget.theme.textTheme.bodySmall))
      ),
    );
  }
}