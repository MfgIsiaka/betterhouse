import 'dart:async';
import 'dart:convert';

import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountryListScreen extends StatefulWidget {
   const CountryListScreen({ Key? key }) : super(key: key);

  @override
  _CountryListScreenState createState() => _CountryListScreenState();
}

class _CountryListScreenState extends State<CountryListScreen> {
late SharedPreferences _sharedPreferences;
final DatabaseReference _countriesRef=FirebaseDatabase.instance.reference().child("COUNTRIES");
late StreamSubscription<Event> countriesStream;

  @override
  Widget build(BuildContext context) {
  AppDataProvider dataProvider=Provider.of<AppDataProvider>(context,listen: false); 
    Size screenSize=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text("Chagua nchi"),),
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child:StreamBuilder(
                            stream:_countriesRef.onValue,
                            builder: (context,AsyncSnapshot<Event> snap){
                              if(snap.connectionState==ConnectionState.active || snap.connectionState==ConnectionState.done){
                                 var countriesFromDb=snap.data!.snapshot.value;
                                 if(countriesFromDb !=null){
                                   countries.clear();
                                for(int i=0;i< countriesFromDb.length; i++){
                                  var val=countriesFromDb[i]; 
                                  countries.add(Country(val["id"], val["name"], val["continent"], val["hR"], val["hS"], val["pR"], val["pS"], val["fR"], val["fS"]));
                                 }  
                           return ListView.builder(
                            itemCount: countries.length,
                            itemBuilder: (context,index){
                              var country=countries[index];
                            return Container(
                               decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey
                                  )
                                )
                               ),
                              child: ListTile(
                                onTap: ()async{
                                  _sharedPreferences=await SharedPreferences.getInstance();
                                  dataProvider.selectedCountry={"id":country.id.toString(),"name":country.name,"hRentalCount":country.hRentalCount,"hSaleCount":country.hSaleCount,"pRentalCount":country.pRentalCount,"pSaleCount":country.pSaleCount,"fRentalCount":country.fRentalCount,"fSaleCount":country.fSaleCount};
                                // countryValueListener.value=dataProvider.selectedCountry;
                                  await _sharedPreferences.setString("country", json.encode(dataProvider.selectedCountry));
                                  Navigator.pop(context,true);
                                },
                                dense: true,
                                visualDensity: const VisualDensity(vertical: -3),
                                subtitle: Row(
                                  children:[
                                    Row(
                                      children:[
                                        const Text("Mapango: "),Text(country.hRentalCount.toString())
                                      ]
                                    ), const Spacer(),
                                    Row(
                                      children:[
                                        const Text("Zinazouzwa: "),Text(country.hSaleCount.toString())
                                      ]
                                    )
                                  ]
                                ),
                                title: Text(country.name,style: const TextStyle(color:Colors.black)),));
                                    });
                                 }else{
                                   return  const Center(child: Text("Hakuna nchi iliyowekwa kwa sasa!!"));
                                 }
                              }else{
                                return  Center(
                                child:SpinKitThreeBounce(
                                  color:kAppColor
                                )
                              );
                              }
                            })
      ),
    );
  }
}