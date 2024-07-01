import 'package:flutter/material.dart';

class PlotsSrListScreen extends StatefulWidget {
  const PlotsSrListScreen({ Key? key }) : super(key: key);

  @override
  State<PlotsSrListScreen> createState() => _PlotsSrListScreenState();
}

class _PlotsSrListScreenState extends State<PlotsSrListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text("Viwanja"),
      ),
    );
  }
}