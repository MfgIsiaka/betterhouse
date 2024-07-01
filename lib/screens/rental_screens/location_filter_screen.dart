import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/location_services.dart';

class PropertyLocationFilterScreen extends StatefulWidget {
  const PropertyLocationFilterScreen({Key? key}) : super(key: key);

  @override
  State<PropertyLocationFilterScreen> createState() => _PropertyLocationFilterScreenState();
}

class _PropertyLocationFilterScreenState extends State<PropertyLocationFilterScreen> {
final DatabaseReference _districtsRef=FirebaseDatabase.instance.reference().child("DISTRICTS");
final DatabaseReference _regionsRef=FirebaseDatabase.instance.reference().child("REGIONS");
SharedPreferences? _filterPref;
  Region? _selectedRegion;
  District? _selectedDistrict;
  
  @override
  Widget build(BuildContext context) {
    AppDataProvider dataProvider=Provider.of<AppDataProvider>(context,listen: false);
    Size screenSize = MediaQuery.of(context).size;
    
    if(dataProvider.propertyFilters["region"]!=null){
       _selectedRegion=Region(dataProvider.propertyFilters["region"],dataProvider.propertyFilters["regionName"], 0, 0);
    }
    if(dataProvider.propertyFilters["district"]!=null){
      _selectedDistrict=District(dataProvider.propertyFilters["district"],dataProvider.propertyFilters["districtName"]);
    }

      return SafeArea(
      child: Scaffold(
         body:StatefulBuilder(
           builder: (context, stateSetter) {
             return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                Container(
                  decoration:const BoxDecoration(
                         border: Border(
                          bottom: BorderSide(
                            color: Colors.black
                          )
                         )
                  ),
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(child: Container()),
                      Container(                   
                         child:const Center(child: Text("Chuja kwa eneo",style:TextStyle(fontWeight: FontWeight.bold,fontSize:18))), 
                      ),
                      Expanded(child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(onPressed: (){
                          setState(() {
                            dataProvider.propertyFilters["region"]=null;
                            dataProvider.propertyFilters["regionName"]=null;
                            dataProvider.propertyFilters["district"]=null;
                            dataProvider.propertyFilters["districtName"]=null;
                            _selectedRegion=null;
                            _selectedDistrict=null;
                            });
                            Navigator.pop(context,"reload");
                        }, icon:const Icon(Icons.refresh)),
                      )),
                    ],
                  ),
                ),
                Expanded(child: Container(
                  padding:const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         const SizedBox(height: 10,),
                         const Text("Mkoa ",style:TextStyle(fontWeight:FontWeight.bold)),
                         GestureDetector(
                          onTap:(){
                            showRegionsOrDistrictsBottomsheet(dataProvider,"regions",stateSetter);
                          },
                           child: AbsorbPointer(
                             child: Container(
                              height: 40,
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(10),
                                 border: Border.all(
                                   color: Colors.grey
                                 )
                               ),
                               padding:const EdgeInsets.symmetric(horizontal: 5),
                               child: Row(children: [
                                Text(_selectedRegion==null?"Chagua mkoa":_selectedRegion!.name),
                                const Spacer(),
                                IconButton(onPressed: (){
                                   showRegionsOrDistrictsBottomsheet(dataProvider,"regions",stateSetter);   
                                }, icon: const Icon(Icons.arrow_drop_down))
                               ],),
                             ),
                           ),
                         ),
                         const SizedBox(height: 10,),
                         const Text("Wilaya",style:TextStyle(fontWeight:FontWeight.bold)),
                         GestureDetector(
                          onTap:(){
                            if(_selectedRegion!=null){
                            showRegionsOrDistrictsBottomsheet(dataProvider,"districts",stateSetter);
                            }else{
                              UserReplyWindowsApi().showToastMessage(context,"Chagua mkoa kwanza");
                            } 
                          },
                          child:AbsorbPointer(
                           child: Container(
                            height: 40,
                             decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(10),
                               border: Border.all(
                                 color: Colors.grey
                               )
                             ),
                             padding: const EdgeInsets.symmetric(horizontal: 5),
                             child: Row(children: [
                              Text(_selectedDistrict==null?"Chagua wilaya":_selectedDistrict!.name),
                              const Spacer(),
                              IconButton(onPressed:_selectedRegion==null?null:(){
                                 showRegionsOrDistrictsBottomsheet(dataProvider,"districts",stateSetter);   
                              }, icon: const Icon(Icons.arrow_drop_down))
                             ],),
                           ),
                         ),
                         ),
                         const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ), 
                    Container(
                    margin:const EdgeInsets.only(bottom:5),
                    width: screenSize.width,
                    child: ElevatedButton(
                    onPressed: ()async{
                      _filterPref=await SharedPreferences.getInstance();
                      if(_selectedRegion !=null ){
                        dataProvider.propertyFilters.addAll({"region":_selectedRegion!.id});
                        dataProvider.propertyFilters.addAll({"regionName":_selectedRegion!.name});
                      }
                      if(_selectedDistrict !=null ){
                        dataProvider.propertyFilters.addAll({"district":_selectedDistrict!.id});
                        dataProvider.propertyFilters.addAll({"districtName":_selectedDistrict!.name});
                      }
                      //_filterPref.set
                      Navigator.pop(context,"reload");
                    },
                    
                    child:const Text("Chuja",style: TextStyle(color: kWhiteColor),)),
                )
                    ],
                  ),
                ))
                ]
              ),
             );
           }
         )    
      ),
    );    
  }

 void showRegionsOrDistrictsBottomsheet(AppDataProvider provider, String choice,Function(void Function()) stateSetter){
   Size screenSize=MediaQuery.of(context).size;
    showModalBottomSheet(context: context,
     shape:const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      )
     ),
     builder: (context){
        return Container(
          decoration:const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            )
          ),
          height:screenSize.height*0.7,
          child: Column(
            children: [
              Container(
                decoration:const BoxDecoration(
                color: kGreyColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  )
                ),
                height: 40,
                child:Center(child: Text(choice=="districts"?"Wilaya za ${_selectedRegion!.name.toString()}":"Mikoa ya ${provider.selectedCountry['name']}",style: const TextStyle(fontWeight: FontWeight.bold),)),
              ),
              Expanded(
                child: StreamBuilder(
                  stream:choice=="districts"?_districtsRef.child(provider.selectedCountry["id"].toString()).child(_selectedRegion!.id.toString()) .onValue:_regionsRef.child(provider.selectedCountry["id"].toString()).onValue,
                  builder: (context,AsyncSnapshot<Event> snap){
                   if(snap.connectionState==ConnectionState.done || snap.connectionState==ConnectionState.active){
                     if(snap.data!=null){
                      if(choice=="regions"){
                        regions.clear();
                       }
                       if(choice=="districts"){
                        districts.clear();
                        }
                       if(choice=="regions"){
                        for(int i=0;i<snap.data!.snapshot.value.length;i++){
                           var val=snap.data!.snapshot.value[i];
                           regions.add(Region(val["id"],val["name"] ,val["latitude"] ,val["longitude"]));
                        }
                       }
                      if(choice=="districts"){
                        snap.data!.snapshot.value.forEach((val){
                          districts.add(District(val["id"],val["name"])) ;
                         });
                       }
                return ListView.builder(
                 itemCount:choice=="districts"?districts.length:regions.length,
                 itemBuilder: (context,index){
                   Region? thisRegion;
                   District? thisDistrict;
                   if(choice=="regions"){
                    thisRegion=regions[index];
                   }
                   if(choice=="districts"){
                    thisDistrict= districts[index];
                   }              
                    return Container(
                     margin: const EdgeInsets.only(top: 3),
                     decoration: BoxDecoration(
                       border: Border(
                         left:BorderSide(
                         color:kAppColor,
                         width:5
                       ),right:BorderSide(
                         color:kAppColor,
                         width:5
                       )
                        )
                     ),
                      child: ListTile(
                        onTap: (){
                          if(choice=="regions"){
                           stateSetter(() {
                            _selectedDistrict=null; //ukwaj
                            provider.propertyFilters["district"]=null;
                            provider.propertyFilters["districtName"]=null;                     
                            _selectedRegion=thisRegion;
                           });
                           Navigator.pop(context);
                           showRegionsOrDistrictsBottomsheet(provider,"districts",stateSetter);
                          }
                          if(choice=="districts"){
                            stateSetter(() {
                              _selectedDistrict=thisDistrict;
                            });
                           Navigator.pop(context);      
                          }
                        },
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -3),
                        title: Text(choice=="districts"?thisDistrict!.name:thisRegion!.name),
                        ),
                    ); 
                });
                     }else{
                     return UserReplyWindowsApi().showLoadingIndicator();  
                     }
                   }else{
                    return Center(child: UserReplyWindowsApi().showLoadingIndicator(),);
                   }  
                 }),
              ),
              
            ],
          ),
        );
     });
  
  }

}