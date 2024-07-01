import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/screens/choice_selection_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:page_transition/page_transition.dart';
import 'initial_building_details_screen.dart';
import 'package:betterhouse/services/database_services.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:show_up_animation/show_up_animation.dart';

//

class RentalLocationRegistryScreen extends StatefulWidget {
 Map<String,dynamic> buildingData;
RentalLocationRegistryScreen(this.buildingData,{ Key? key }) : super(key: key);

  @override
  _RentalLocationRegistryScreenState createState() => _RentalLocationRegistryScreenState();
}

class _RentalLocationRegistryScreenState extends State<RentalLocationRegistryScreen> {
final DatabaseReference _districtsRef=FirebaseDatabase.instance.reference().child("DISTRICTS");
final DatabaseReference _regionsRef=FirebaseDatabase.instance.reference().child("REGIONS");
late GoogleMapController _googleMapController;
final  _rentalLocalAreaCntrl=TextEditingController();
bool _showingMap=false;
final Set<Marker> _mapMarkers={};
late LatLng _currentLocation;
Region? _selectedRegion;
District? _selectedDistrict;
final ValueNotifier<String> _dropdownHintText=ValueNotifier("Mkoa");

getThisDeviceCurrentLocation()async{ 
 AppDataProvider dataProvider=Provider.of<AppDataProvider>(context,listen: false);
 setState(() {
   _currentLocation=LatLng(dataProvider.deviceLocation["latitude"]!,dataProvider.deviceLocation["longitude"]!);
   _mapMarkers.add(Marker(
    draggable: true,
    onDragEnd: (newLocation){
     UserReplyWindowsApi().showToastMessage(context,"${newLocation.latitude}  ${newLocation.longitude}");
    },
    infoWindow: InfoWindow(
      title:dataProvider.userUploadRole==0?"Ofisini":"Jengo",
      snippet: dataProvider.userUploadRole==0?"Watu watakupata hapa wakihitaji kuona jengo":"Hapa ndipo jengo lako lilipo"
    ),
    markerId:const MarkerId("myBuilding"),
    position:_currentLocation,
   ));
 });
 Future.delayed(const Duration(milliseconds:3000),(){
 _googleMapController.animateCamera(CameraUpdate.newLatLng(_currentLocation));
 });
} 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 2),(){
            setState(() {
            _showingMap=true;
          });
    });
  }
  
  @override
  Widget build(BuildContext context) {
  AppDataProvider dataProvider=Provider.of<AppDataProvider>(context,listen: false);
  //Region region=dataProvider.selectedRegion;
  Size screenSize=MediaQuery.of(context).size;
  //22:45-23:1, 23:05-23:17, 23:22-23:47 p, -00:05, 00:08-00:29,
    return Column(
      children: [
       Row(
         children: [
          const CircleAvatar(
             radius: 13,
             child: Text("3"),
           ),
           const SizedBox(
             width: 20,
           ),
           const Text("Eneo mali yako ilipo",style:TextStyle(fontWeight: FontWeight.w900,fontSize: 15)),
           CustomPopupMenu(child: const Icon(Icons.help_outline,color:Colors.blueGrey),
           verticalMargin: 0.0,
            menuBuilder: (){
              return ShowUpAnimation(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  width: 200,
                  child:const Text("Taarifa hizi zitawezesha wateja kujua eneo mali yako ilipo"),),
              );
            }, pressType: PressType.singleClick)
         ],
       ),
         Expanded(
           child: SingleChildScrollView(
             child: Column(
               crossAxisAlignment:CrossAxisAlignment.start,
               children: [
                 const SizedBox(height: 10,),
                 const Text("Mkoa ",style:TextStyle(fontWeight:FontWeight.bold)),
                 GestureDetector(
                  onTap:(){
                    showRegionsOrDistrictsBottomsheet(dataProvider,"regions");
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
                           showRegionsOrDistrictsBottomsheet(dataProvider,"regions");   
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
                    showRegionsOrDistrictsBottomsheet(dataProvider,"districts");
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
                         showRegionsOrDistrictsBottomsheet(dataProvider,"districts");   
                      }, icon: const Icon(Icons.arrow_drop_down))
                     ],),
                   ),
                 ),
                 ),
                 const SizedBox(height: 10),
                   const Text("Eneo(tarafa/kata/mtaa/kitongoji) ",style:TextStyle(fontWeight:FontWeight.bold)),
                  SizedBox(
                         height:40,
                         child: TextFormField(
                           minLines:4,
                           maxLines: 5,
                          controller:_rentalLocalAreaCntrl,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            //hintText: "Elezea hapa",
                            border:OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)
                            )
                          ),
                           ),
                         ),
                     const SizedBox(
                        height:10,
                        ),             
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dataProvider.userUploadRole==0?"Ramani ya ofisini kwako":"Ramani ya jengo lilipo",style: const TextStyle(fontWeight:FontWeight.bold)),
                    Container(
                       height: 250,
                       decoration: BoxDecoration(
                       border: Border.all(
                           color: Colors.grey,
                           width:3
                         )
                       ),
                      child:_showingMap==false?Container():GoogleMap(
                      initialCameraPosition: const CameraPosition(target: LatLng(-6.8,39.2833),zoom: 10),
                       markers: _mapMarkers,
                       onMapCreated:(GoogleMapController controller){
                        _googleMapController=controller;
                        getThisDeviceCurrentLocation();
                      },
                      ),
                      ),
                  ],
                ),
                 
                   const SizedBox(height:7,),               
               ],
             ),
           ),
         ),
         Container(
           height:40,
           margin: const EdgeInsets.only(bottom: 5),
           child: Align(
                 alignment: Alignment.center,
                 child: ElevatedButton(
                    onPressed:()async{
                      //print(_selectedRegion+"  "+_selectedDistrict);
                      if(_selectedRegion==null || _selectedDistrict==null){
                       UserReplyWindowsApi().showToastMessage(context,"Chagua mkoa na wilaya pango lilipo kwanza");
                      }else if(_rentalLocalAreaCntrl.text.trim().isEmpty){
                        UserReplyWindowsApi().showToastMessage(context,"Jaza mtaa,kata au kitongoji pango lilipo");
                       }else if(_currentLocation==null){
                        UserReplyWindowsApi().showToastMessage(context,"Bado hatujapata eneo ulipo, tafadhali subiri");
                       }else{
                        final FirebaseAuth _auth=FirebaseAuth.instance;
                        if(_auth.currentUser!=null){
                           UserReplyWindowsApi().showProgressBottomSheet(context);                           
                              Map<String,dynamic> buildingData=widget.buildingData;
                               buildingData["countryName"]=dataProvider.selectedCountry["name"];
                               buildingData["country"]=dataProvider.selectedCountry["id"];
                               buildingData["region"]=_selectedRegion!.id;
                               buildingData["regionName"]=_selectedRegion!.name;
                               buildingData["district"]=_selectedDistrict!.id;
                               buildingData["districtName"]=_selectedDistrict!.name;
                               buildingData["localArea"]=_rentalLocalAreaCntrl.text;
                              buildingData["latlong"]=dataProvider.deviceLocation;
                               UserReplyWindowsApi().showProgressBottomSheet(context);
                              String res=await DatabaseApi().uploadBuildingDetails(widget.buildingData,context);
                              Navigator.pop(context);  
                              if(res=="success"){
                                Navigator.pop(context);
                                dataProvider.currentBuildingRegPage= AllDetailsScreen();
                                UserReplyWindowsApi().showToastMessage(context,"Taarifa zimetumwa kikamilifu..");
                                Navigator.pushAndRemoveUntil(
                                context,
                                PageTransition(
                                    duration:const Duration(milliseconds: 500),
                                    child: const ChoiceSelection(),
                                    type: PageTransitionType.rightToLeft),
                                (route) => false);
                                }else{  
                                  UserReplyWindowsApi().showToastMessage(context,res);
                                 }
                              }else{
                                UserReplyWindowsApi().showToastMessage(context,"Samahani inaonekana hujasajiliwa au hujaingia kwenye akaunti yako"); 
                              }
                            } 
                       },
                  // duration: Duration(milliseconds:500),
                   child:  const Center(child: Text("Tuma taarifa",style: TextStyle(fontWeight: FontWeight.w500,color: kWhiteColor),)),
                 ),
               ),
         )
      ],
    );
  }
  
  void showRegionsOrDistrictsBottomsheet(AppDataProvider provider, String choice){
   Size screenSize=MediaQuery.of(context).size;
    showModalBottomSheet(context: context,
     shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      )
     ),
     builder: (context){
        return Container(
          decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            )
          ),
          height:screenSize.height*0.7,
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
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
                        // snap.data!.snapshot.value.forEach((val){
                       
                        // });
                       }
                      if(choice=="districts"){
                        print(snap.data!.snapshot.value);
                        snap.data!.snapshot.value.forEach((val){
                          districts.add(District(val["id"],val["name"]));
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
                           setState(() {
                            _selectedDistrict=null;
                             _selectedRegion=thisRegion;
                           });
                           Navigator.pop(context);
                           showRegionsOrDistrictsBottomsheet(provider,"districts");
                          }
                          if(choice=="districts"){
                            setState(() {
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