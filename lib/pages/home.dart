import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/models/band.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Queen', votes: 1),
    Band(id: '3', name: 'Héroes del silencio', votes: 2),
    Band(id: '4', name: 'Bon Jovi', votes: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle( color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder:   (context, i) => _bandTile(bands[i]),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        elevation:  1,
        onPressed: addNewband,
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( direction) {
        // ignore: avoid_print
        print('direction: $direction');
        // ignore: avoid_print
        print('id: ${band.id}');
      },
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color:Colors.red[300],
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.delete_forever_outlined)
          ),
      ),
      child: ListTile(
          leading: CircleAvatar(
            child: Text( band.name.substring(0,2)),
            backgroundColor: Colors.blue[100],
          ),
          title: Text( band.name),
          trailing: Text('${ band.votes}', style: const TextStyle( fontSize: 20)),
          onTap: () {
            // ignore: avoid_print
            print(band.name);
          }
        ),
    );
  }

  addNewband() {

    final textController = TextEditingController();
    if(Platform.isAndroid) {
      showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
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
        );
        }
      );
    }else{

      showCupertinoDialog(
        context: context, 
        builder: ( _ ) {
          return CupertinoAlertDialog(
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
          );
        }
      );
    }
    
  }

  void addBandToList(String name){
    if (name.length > 1){
      bands.add(Band(id: DateTime.now().toString(), name: name));
      setState(() {});
    }
    Navigator.pop(context);
  }
}