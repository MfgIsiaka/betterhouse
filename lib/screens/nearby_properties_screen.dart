
import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/services/database_services.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:provider/provider.dart';

class NearbyPropertiesScreen extends StatefulWidget {
  const NearbyPropertiesScreen({Key? key}) : super(key: key);

  @override
  State<NearbyPropertiesScreen> createState() => _NearbyPropertiesScreenState();
}

class _NearbyPropertiesScreenState extends State<NearbyPropertiesScreen> {
  double _newSliderVal=0.01; 
  double _distanceFromMe=0.5;  
  List<DocumentSnapshot> docsFromDb=[];

    Future<void> getNearbyBuildingsFromDb()async{
    Stream<List<DocumentSnapshot>> stream;
      AppDataProvider dataProviderListen=Provider.of<AppDataProvider>(context,listen: false);
     setState(() {
       _distanceFromMe=10;
     });
    stream= DatabaseApi().getNearbyBuildingsFromDatabae(GeoFirePoint(dataProviderListen.deviceLocation["latitude"]!, dataProviderListen.deviceLocation["latitude"]!));
    stream.listen((event) {
      docsFromDb=event;
    });
    print(docsFromDb.length);
    setState(() {
       _distanceFromMe=double.parse(docsFromDb.length.toString());
     });
    }

  @override
  Widget build(BuildContext context) {
    //getNearbyBuildingsFromDb();
    return Scaffold(
      appBar: AppBar(
        title:Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
          const Text("Karibu yako"),const Spacer(), Text("(Kilomita ${_distanceFromMe.toStringAsFixed(2)})",style:const TextStyle(fontSize: 13,color: Colors.amber),)
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
           // color: Colors.red,
            margin:const EdgeInsets.only(top: 3),
            height: 25,
            child: Row(
              children: [
                Expanded(
                  child: Slider(value:_newSliderVal,min: 0.01,label: "change distance", onChanged: (newVal){
                      setState(() {
                        _newSliderVal=newVal;
                        _distanceFromMe=(newVal/0.01)*0.5;
                      });
                  }),
                ),
              IconButton(onPressed: (){
                UserReplyWindowsApi().showToastMessage(context,"hello please wait..");  
              },
              padding:const EdgeInsets.all(0),
               icon:const Icon(Icons.search))
              ],
            ),
          ),Expanded(child: Container(
            color: kGreyColor,
          ))
        ],
      ),
    );
  }
}