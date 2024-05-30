import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';

import './Mvp3SongSelectPage.dart';
import '../theme.dart';
import '../utils.dart';
import 'LoadingPage.dart';

class MoodSelectPage extends StatefulWidget {
  MoodSelectPage({super.key});
  final ThemeData theme = MyThemes.customTheme;
  List<String> itemNameList = ['Casual Run', 'Long Run', 'Short Run', 'Bicycling', 'Subway', 'Walk', 'Rest'];
  List<String> exploreTypes = ["Exploration journey", "Inner tranquility"];
  List<String> exploreContents= [
    "Dynamic tunes adapting to your location, environment, and physiology for an adventurous, emotion- filled journey！",
    "Music that syncs with your steps and heart rate, providing a serene connection to the present moment."];
  @override
  State<MoodSelectPage> createState() => _MoodSelectPageState();
}

class _MoodSelectPageState extends State<MoodSelectPage> {
  late Counter counter; // Counter object from Provider

  
  @override
  Widget build(BuildContext context) {
    counter = Provider.of<Counter>(context); // Accessing the Counter object from Provider
    ThemeData theme = MoodSelectTheme.customTheme; // Using a custom theme
    // Wrapping the page content with the theme
    return Theme(
      data: theme,
      child: BasicScaffoldWidget(
        theme: theme,
        childrens: _buildPage(context, 0),
        avoidAppbar: true, // Avoiding AppBar to use the entire screen for content
      ),
    );
  }

  // Builds the main content of the page
  Widget _buildPage(BuildContext context, int carouselIndex) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('Sport Mood', style: widget.theme.textTheme.bodyLarge),
        ),
        SizedBox(
          height: 260.0,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.5),
            itemCount: widget.itemNameList.length,
            itemBuilder: (BuildContext context, int itemIndex) {
              // Only build items if the index is within the range of the list
              return _buildCarouselItem(context, carouselIndex, widget.itemNameList[itemIndex]);
            },
          ),
        ),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), child: Text('Interactive Mood', style: widget.theme.textTheme.bodyLarge)),
        _buildExploreItem(context, 0, widget.exploreTypes[0], widget.exploreContents[0]),
        _buildExploreItem(context, 1, widget.exploreTypes[1], widget.exploreContents[1])
      ],
    );
  }

  // Builds individual carousel items
  Widget _buildCarouselItem(BuildContext context, int carouselIndex, String itemName) {
    var imgVariable = AssetImage('assets/images/moods/$itemName.png');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: OpenContainer(
        closedColor: Colors.transparent,
        middleColor: Colors.transparent,
        transitionDuration: Duration(milliseconds: 500),
        openBuilder: (context, _) {
          return Mvp3SongSelectPage(moodName: itemName);
        },
        tappable: true, // Set tappable to true as we are using GestureDetector
        closedBuilder: (context, VoidCallback openContainer) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imgVariable,
              fit: BoxFit.cover,
              onError: (error, stackTrace) {
                // Fallback image if the main image fails to load
                print('Image load failed, using default image');
                setState(() {
                  imgVariable = AssetImage('assets/images/logo.png');
                });
              },
            ),
            color: Color(0xFFFF6B17),
            borderRadius: BorderRadius.all(Radius.circular(32.0)),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(itemName, style: GoogleFonts.biryani(
              fontSize: 18,
              color: Colors.white, //Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.6,),),
              ],
            ),
          ),
        ),
      ),
    );
  }



 Widget _buildExploreItem(BuildContext context, int index, String exploreType, String exploreContent) {
  return Expanded(flex:1, child: Padding(padding: const EdgeInsets.only(left: 0, right: 24, bottom: 16, top: 0), child: 
        GestureDetector(
          onTap: (){
            Navigator.of(context).push(createRoute(page: Mvp3SongSelectPage(moodName: widget.itemNameList[index])));
          },
          child:
          Container(
              decoration: const BoxDecoration(
              color: Color(0xFFFF6B17),
              borderRadius: BorderRadius.only(topRight: Radius.circular(68.0), bottomRight: Radius.circular(64.0)),
              ),
              child: Row(children: [
                Expanded(
                  flex: 1,
                  child: Align(alignment: Alignment.centerLeft, child: Image(image: AssetImage('assets/images/interactive_$index.png')))),
                Expanded(
                  flex:1,
                  // color: Colors.blueAccent,
                  child: Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left: 8, top: 32), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(exploreType, textAlign: TextAlign.left,),
                      Text(
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.visible,
                        exploreContent, style: TextStyle(fontSize: 8, color: Colors.white60))
                    ],)
                  ))
                )
              ],)
            ),
          )
        ));
 }


}


