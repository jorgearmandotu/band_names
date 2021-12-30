import 'dart:io';

import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/models/band.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    // Band(id: '1', name: 'Metallica', votes: 5),
    // Band(id: '2', name: 'Queen', votes: 1),
    // Band(id: '3', name: 'Héroes del silencio', votes: 2),
    // Band(id: '4', name: 'Bon Jovi', votes: 5),
  ];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on('active-bands',  _handleActiveBands );
    super.initState();
  }

  _handleActiveBands( dynamic payload) {
    bands = (payload as List)
      .map((band) => Band.fromMap(band))
      .toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return  Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle( color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: ( socketService.serverStatus == ServerStatus.Online)
            ? Icon(Icons.check_circle, color: Colors.blue[300])
            : Icon(Icons.offline_bolt, color: Colors.red[400],)
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
            itemCount: bands.length,
            itemBuilder:   (context, i) => _bandTile(bands[i]),
              ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        elevation:  1,
        onPressed: addNewband,
      ),
    );
  }

  Widget _bandTile(Band band) {

    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( __ ) => socketService.emit('delete-band', {'id' :band.id}),
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color:Colors.red[300],
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.delete_forever_outlined,color: Colors.white,)
          ),
      ),
      child: ListTile(
          leading: CircleAvatar(
            child: Text( band.name.substring(0,2)),
            backgroundColor: Colors.blue[100],
          ),
          title: Text( band.name),
          trailing: Text('${ band.votes}', style: const TextStyle( fontSize: 20)),
          onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
        ),
    );
  }

  addNewband() {

    final textController = TextEditingController();
    if(kIsWeb){
      showCupertinoDialog(
        context: context, 
        builder: ( _ ) => CupertinoAlertDialog(
          title: const Text('new band name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('add'),
              onPressed: ()=>addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Dismiss'),
              onPressed: ()=> Navigator.pop(context),
            ),
          ],
        ),
      );
    }
    else if(Platform.isAndroid) {
      showDialog(
        context: context, 
        builder: ( _ )=> AlertDialog(
          title:const Text('New band Name:'),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              child: const Text('Add'),
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => addBandToList(textController.text)
            )
          ],
        ),
      );
    }else{

      showCupertinoDialog(
        context: context, 
        builder: ( _ ) => CupertinoAlertDialog(
          title: const Text('new band name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('add'),
              onPressed: ()=>addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Dismiss'),
              onPressed: ()=> Navigator.pop(context),
            ),
          ],
        ),
      );
    }
    
  }

  void addBandToList(String name){
    if (name.length > 1){
      //add band
      final socketService = Provider.of<SocketService>(context, listen: false);
      
      socketService.emit('add-band', {'name': name});

    }
    Navigator.pop(context);
  }

  Widget _showGraph() {

    Map<String, double> dataMap = {};//{} es literal de Map()
    //dataMap.putIfAbsent('flutter', () => 5);
    for (var band in bands) {//lteral de foreach bands
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble() );
    }

    final List<Color> colorList = [
      Colors.blue[50] as Color,
      Colors.blue[200] as Color,
      Colors.pink[50] as Color,
      Colors.pink[200] as Color,
      Colors.purple[50] as Color,
      Colors.purple[200] as Color,
    ];


    return dataMap.isEmpty ? const LinearProgressIndicator() : Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.only(top: 13),
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        //chartLegendSpacing: 32,
        //chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        //centerText: "Bands",
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          //legendShape: _BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 0,
        ),
        // gradientList: ---To add gradient colors---
        // emptyColorGradient: ---Empty Color gradient---
      ),
    );

  }
}