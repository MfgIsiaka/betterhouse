import 'package:flutter/material.dart';

class FarmsSrListscreen extends StatefulWidget {
  const FarmsSrListscreen({ Key? key }) : super(key: key);

  @override
  State<FarmsSrListscreen> createState() => _FarmsSrListscreenState();
}

class _FarmsSrListscreenState extends State<FarmsSrListscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text("Mashamba"),
      ),
    );
  }
}