import 'package:channel_test_v1/plotAvgDistance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:math';
import '../theme.dart';
import '../utils.dart';
import '../plotLine.dart';
import '../plotBar.dart';
import '../plotAvgDistance.dart';
import '../legendWidget.dart';

import 'package:fl_chart/fl_chart.dart';
import './Mvp3MusicBankPage.dart';
class Mvp3SportAnalyticPage extends StatefulWidget {
  Mvp3SportAnalyticPage({super.key});
  final ThemeData theme = MyThemes.customTheme;

  @override
  State<Mvp3SportAnalyticPage> createState() => _Mvp3SportAnalyticPageState();
}

class _Mvp3SportAnalyticPageState extends State<Mvp3SportAnalyticPage> {

  bool showAvg = false;



  @override
  Widget build(BuildContext context) {
    ThemeData theme = MoodSelectTheme.customTheme; 
    return Theme(
      data: theme,
      child: _buildPage(context, 0),
    );
  }



  Widget _buildPage(BuildContext context, int carouselIndex) {

    var color1 = const Color(0xFF5FBAD7);
    var color2 = const Color(0xFF17A63F);
    // bar chart 假資料
    var barGroupDatas = List<BarChartGroupData>.generate(
      6,
      (index) => 
      BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: Random().nextDouble()*10,
              // gradient: _barsGradient,
              color: color1,
               
            ),
            BarChartRodData(
              toY: Random().nextDouble()*10,
              color: color2,
               
            )
          ],
          // showingTooltipIndicators: [0], // show bar value on top of the bardata
        )
      
    );
    return SingleChildScrollView(child: Container(padding: EdgeInsets.symmetric(horizontal: 16),child: Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text("Sport Analytic", textAlign: TextAlign.start, style: widget.theme.textTheme.bodyMedium),
          Text("Your\'s Sport Journey", textAlign: TextAlign.start, style: widget.theme.textTheme.bodySmall)
        ],),
        Container(child: Image(width: 65, height: 65, image: AssetImage('assets/images/headshot.png')),)
      ],),
      // Expanded(flex: 1, child: 
        Stack(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.70,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  left: 12,
                  top: 24,
                  bottom: 12,
                ),
                child: LineChart(
                  showAvg ? avgData() : mainData(),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              height: 34,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    showAvg = !showAvg;
                  });
                },
                child: Text(
                  'avg',
                  style: TextStyle(
                    fontSize: 12,
                    color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        )
      //),
      ,
      // Expanded(flex:1, child: 
        Container(
          margin: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFFFF6B17),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child:
          Column(children: [
            LegendsListWidget(
              legends: [
                Legend('Long Run', color1),
                Legend('Walking', color2),
              ],
            ),
            AspectRatio(
              aspectRatio: 2.2,
              child: Padding(padding: EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 0), child:
            BarChart(  
              BarChartData(
                barTouchData: barTouchData,
                titlesData: titlesData,
                borderData: borderData,
                //barGroups: barGroups,
                barGroups: barGroupDatas,
                groupsSpace: 5, // apply only when alignment is center
                gridData: const FlGridData(show: true),
                alignment: BarChartAlignment.spaceAround,
                maxY: 10,
                // backgroundColor: Color(0xFFFF6B17)
            ),))
            )
        ],)  
        )
      // ),
      ,
      // ***************************************************************
      // Expanded(flex:1, child: 
        Container(
          margin: EdgeInsets.symmetric(vertical:8),
          decoration: BoxDecoration(
            color: Color(0xFFFF6B17),
            borderRadius: BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Stack(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1.90,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 18,
                    left: 12,
                    top: 24,
                    bottom: 12,
                  ),
                  child: LineChart(
                    avgDistanceData(),
                  ),
                ),
              ),
              SizedBox(
                width: 60,
                height: 34,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      showAvg = !showAvg;
                    });
                  },
                  child: Text(
                    'avg',
                    style: TextStyle(
                      fontSize: 12,
                      color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        )
      //),
      // ,
      // Container(
      //   margin: EdgeInsets.symmetric(vertical:8),
      //   height: 100, 
      //   child: Center(
      //     child: FilledButton.tonal(
      //               style: OutlinedButton.styleFrom(
      //                 foregroundColor: Colors.black,
      //                 backgroundColor: Colors.white,
      //                 side: const BorderSide(color: Colors.black, width: 1), // Border styling
      //               ),
      //               onPressed: () {
      //                 // Navigating to the login page when the button is pressed
      //                 Navigator.of(context).push(createRoute(page: Mvp3MusicBankPage()));
      //               },
      //               child: Text(
      //                 'Next',
      //                 style: GoogleFonts.biryani(
      //                   fontSize: 13,
      //                   fontWeight: FontWeight.w300,
      //                   letterSpacing: 2.6,
      //                 ),
      //               ),
      //             ),
      //   )
      // ),
      ,
      Container(height: 100,)
      // ****************************************************************
    ],)));
  }
}