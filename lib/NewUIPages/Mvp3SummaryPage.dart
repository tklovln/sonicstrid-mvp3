import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';
import './Mvp3CoverPage.dart';
import '../theme.dart';
import '../utils.dart';
import './Mvp3SportAnalyticPage.dart';
import '../main.dart';

class Mvp3SummaryPage extends StatefulWidget {
  final String avgBPM;
  final String distance;
  final int musicLength;
  Mvp3SummaryPage({super.key, required this.avgBPM, required this.distance, required this.musicLength});
  final ThemeData theme = MyThemes.customTheme;

  @override
  State<Mvp3SummaryPage> createState() => _Mvp3SummaryPageState();
}

class _Mvp3SummaryPageState extends State<Mvp3SummaryPage> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = MoodSelectTheme.customTheme; 
    return Theme(
      data: theme,
      child: BasicScaffoldWidget(
        theme: theme,
        childrens: _buildPage(context, 0),
        avoidAppbar: true, 
      ),
    );
  }

  // Builds the main content of the page
  Widget _buildPage(BuildContext context, int carouselIndex) {
    List<String> musicTags = ['Deep-house', 'Ambience', 'Electronic', 'Jazz', 'Funk', 'Rock'];
    return Stack(children: [

      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            // colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
            image: AssetImage('assets/images/map_0.png')),
        ),
      ),
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
      SingleChildScrollView(child:
        Column(
            children: <Widget>[
              SizedBox(height: 30,),
              _buildTitle(),
              _buildContent(),
            ])
      )      
    ]);
  }

  Widget _buildTitle(){
    return Container(
              height: 180,
              margin: EdgeInsets.only(right: 24),
              decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.only(topRight: Radius.circular(78.0), bottomRight: Radius.circular(64.0)),
              ),
              child: Row(children: [
                Expanded(
                  flex: 1,
                  child: Align(alignment: Alignment.center, child: SizedBox(width: 100, height: 100, child: Image(image: AssetImage('assets/images/song_cover.png'))))),
                Expanded(
                  flex:2,
                  child: Align(alignment: Alignment.center, child: Padding(padding: EdgeInsets.only(left: 0, top: 32), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Starry trekker", style: widget.theme.textTheme.bodyMedium)),
                        Text("by", style: widget.theme.textTheme.bodySmall),
                        Text("${USERNAME}x"),
                        Text("Jude-PENG"),
                        Text("${widget.avgBPM} bpm / ${widget.musicLength} sec", style: widget.theme.textTheme.bodySmall)  
                      ],)
                  ))
                ),
                Expanded(
                  flex:1,
                  child: Container()
                )
              ],)
            );
  }
  Widget _buildContent(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildLine("You\'ve Move For", "${widget.distance} KM"),
      _buildLine("Average BPM", "${widget.avgBPM} BPM"),
      _buildLine("Generated Music Length", "${widget.musicLength} sec"),
      _buildLine("Location In", "Tainan"),
      _buildLine("weather", "26°C/32°C/Windy"),
      FilledButton.tonal(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black, width: 1), // Border styling
                    ),
                    onPressed: () => exit(0),
                    child: Text(
                      'Finish',
                      style: GoogleFonts.biryani(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2.6,
                      ),
                    ),
                  ),
      Container(height: 100,),
    ],));
  }

  Widget _buildLine(String title, String content){
    return Container(
      padding:EdgeInsets.symmetric(vertical: 4),
      child: 
      Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(title, textAlign: TextAlign.start, style: widget.theme.textTheme.bodyMedium),
      Text(content, textAlign: TextAlign.start, style: widget.theme.textTheme.titleSmall)
    ],));
  }
}