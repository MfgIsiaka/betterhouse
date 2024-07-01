
import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/screens/rental_screens/chat_messages_screen.dart';
import 'package:betterhouse/screens/rental_screens/fullscreen_map_screen.dart';
import 'package:betterhouse/screens/rental_screens/owner_info_screen.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/modal_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:betterhouse/services/server_variable_services.dart';
//color: Colors.green,g 9-4

class BuildingDetailsToClientScreen extends StatefulWidget {
  PropertyInfo buildingInfo;
  BuildingDetailsToClientScreen(this.buildingInfo,{ Key? key }) : super(key: key);

  @override
  _BuildingDetailsToClientScreenState createState() => _BuildingDetailsToClientScreenState();
}

class _BuildingDetailsToClientScreenState extends State<BuildingDetailsToClientScreen> {
SharedPreferences? _sharedPreferences;
late GoogleMapController _googleMapController;
final DatabaseReference _usersRef=FirebaseDatabase.instance.reference().child("USERS");
final CollectionReference<Map<String, dynamic>> _propertiesRef=FirebaseFirestore.instance.collection("PROPERTIES");
final DatabaseReference _remainingPropertyInfoRef=FirebaseDatabase.instance.reference().child("REMAINING PROPERTY INFO");
final CollectionReference<Map<String, dynamic>> _itemsViewsAndCartRef=FirebaseFirestore.instance.collection("ITEMS VIEWS AND CART");
late AppDataProvider dataProvider;
final FirebaseAuth _auth=FirebaseAuth.instance;
late BitmapDescriptor _houseMarker,_manMarker;
Map<dynamic,dynamic> _newInfo={};
double? _separationDistance;
final List<String> _mapTypeChoices=["Kawaida","Satellite"];
String _selectedMapTypeString="Satellite";
MapType _mapType=MapType.satellite;
var myId;
final Set<Marker> _mapMarkers={};
late LatLng _currentLocation;
late LatLng _houseRegion;
var rentalOwner;
//States
bool showMap=false;
late void Function(void Function()) _mapSetter;



getThisDeviceCurrentLocation()async{
  try{
     // Position position=await Geolocator.getCurrentPosition(desiredAccuracy:LocationAccuracy.high);
     Position position= await Geolocator.getCurrentPosition(
       desiredAccuracy: LocationAccuracy.best
     );
     GeoPoint geoPoint=widget.buildingInfo.latlong["geopoint"];
    // print(widget.buildingInfo.latlong);Nj
    // GeoPoint geoPoint=widget.buildingInfo.latlong; 
    if(position!=null){
      setState((){
     _currentLocation=LatLng(position.latitude, position.longitude);
     print(_currentLocation);
     _mapMarkers.add(Marker(markerId:const MarkerId("myCurrentLocation"),
     icon: _manMarker,
     infoWindow:const InfoWindow(title: "Eneo ulipo sasa"),
      position:_currentLocation,
     ));
     _mapMarkers.add(Marker(markerId: const MarkerId("rentalLocation"),
     icon: _houseMarker,
     infoWindow: InfoWindow(title:widget.buildingInfo.userRole==0?"Dalali yupo hapa":"Nyumba ipo hapa"),
      position:LatLng(geoPoint.latitude,geoPoint.longitude),
     ));
      _separationDistance=Geolocator.distanceBetween(position.latitude, position.longitude,geoPoint.latitude,geoPoint.longitude);
        Future.delayed( const Duration(milliseconds:3000),(){
                  _googleMapController.animateCamera(CameraUpdate.newLatLng(_currentLocation));
                  Future.delayed( const Duration(milliseconds:3000),(){
                  _googleMapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(geoPoint.latitude,geoPoint.longitude),zoom: 15)));
                  });
          });          
   });
 }else{
   UserReplyWindowsApi().showToastMessage(context,"Location Not found");
 }
  }catch(e){
      UserReplyWindowsApi().showToastMessage(context,"Error"+e.toString());
  }
}
 
Future<void> getRentalOwnDetailsDetails()async{
  _sharedPreferences=await SharedPreferences.getInstance();
    await _usersRef.child(widget.buildingInfo.userId.toString()).once().then((value){
      setState(() {        
         rentalOwner=value.value;
         if(_auth.currentUser!=null){
             myId=_auth.currentUser!.uid;
         }
      });
    });
}

Future<void> getRemainingBuildingInfoInfo()async{
  String child="";
  if(widget.buildingInfo.houseOrLand == 0){
      child="BUILDINGS";
  }else{
       child="LANDS";
  }
  await _remainingPropertyInfoRef.child("${child}/${widget.buildingInfo.id}").once().then((value){
    var newInfo=value.value;
    if(newInfo!=null){
       setState(() {
         _newInfo=newInfo as Map<dynamic, dynamic>;
       });
    }
  });
}

 Future<void> getCustomeMapMarkers()async{
  var hIcon = await BitmapDescriptor.fromAssetImage(
         const ImageConfiguration(size:Size(40, 61)),
        "assets/images/house_marker1.png");
  var mIcon = await BitmapDescriptor.fromAssetImage(
         const ImageConfiguration(size:Size(40, 61)),
        "assets/images/man_marker.png");
    setState(() {
      _houseMarker = hIcon;
      _manMarker = mIcon;
    });
  //started: 20:54 - 21:10, 21:12-21:27,21:28-21:43,21:43-21:58,21:59-22:12,22:
}

Future<void> updatePropertyViewsCount()async{
  Future.delayed(Duration.zero,()async{
  int dontUpdate=0;
  List<dynamic> currentViews=dataProvider.currentUser["viewedItems"] as List<dynamic>;
     if(currentViews != null || currentViews.isNotEmpty){
       if((currentViews.contains(widget.buildingInfo.id)==false) && (widget.buildingInfo.userId != _auth.currentUser!.uid)){
         dontUpdate=1;
       }
     }else{
      if(widget.buildingInfo.userId != _auth.currentUser!.uid){
         dontUpdate=1;
      }      
     }
    if(dontUpdate==1){
      await _itemsViewsAndCartRef.doc(_auth.currentUser!.uid).update({"viewedItems":FieldValue.arrayUnion([widget.buildingInfo.id])}).then((value)async{
              List<dynamic> newViews=(dataProvider.currentUser["viewedItems"] as List<dynamic>) + ([widget.buildingInfo.id]);
              dataProvider.currentUser.addAll({"viewedItems":newViews});
              await _propertiesRef.doc(widget.buildingInfo.id).update({"internalViews":FieldValue.increment(1)});
          }); 
    }

  });
}

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 7000),(){
      if(_mapSetter != null){
        _mapSetter((){
        showMap=true;
      });
      }
    });
    updatePropertyViewsCount();
    getRemainingBuildingInfoInfo();
    getRentalOwnDetailsDetails();
  }
 

  @override
  Widget build(BuildContext context) {
  dataProvider=Provider.of<AppDataProvider>(context);
  Size screenSize=MediaQuery.of(context).size;
    return Scaffold(
    body: NestedScrollView(
      controller:ScrollController(),
      headerSliverBuilder: (context,stat){
       return [
          SliverAppBar(
            foregroundColor:const Color.fromRGBO(0, 0, 0, 0),
            backgroundColor:Colors.transparent,
            pinned:true,
            expandedHeight:screenSize.width*(2/3),
            flexibleSpace: FlexibleSpaceBar(
               background: displayBuildingImages(screenSize)
            ), systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
       ];
    }, body:MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView(
        children: [
             const SizedBox(height: 5,),
            displayBuildingDetails(screenSize),
            const SizedBox(height: 5,),
            displayBuildingLocation(screenSize),
            const SizedBox(height: 5,), 
            widget.buildingInfo.userId==_auth.currentUser!.uid?Container():Container(
            margin: const EdgeInsets.symmetric(horizontal: 0.5),
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration:BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow:const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 4
               )
              ]
             ),
              child: Row(
              children: [
               const Icon(Icons.warning_amber,size: 50,color: Colors.amber,),
                Expanded(
                  child: Column(
                   //crossAxisAlignment: CrossAxisAlignment.start,
                    children:const [
                     Text("TAHADHARI",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.red),),
                     Text("Usitoe pesa kabla ya kufuata taratibu za makabidhiano ya pango.",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold))
                     ],
                  )  ,
                )
                ,const Icon(Icons.warning_amber,size: 50,color: Colors.amber,),
              ],
            ),
            ),
            const SizedBox(height: 5,),  
             //!=
           displayRentalOwnerDetails(screenSize),
            const SizedBox(height: 5,), 
        ],
      ),
    )),
        );
  }

Widget displayBuildingImages(Size screenSize){
  int totalImageCount=0;
  List allImages=[];
  List photoTitles=[];
  if(_newInfo.isNotEmpty && _newInfo["images"] != null){
   allImages=[widget.buildingInfo.coverImage]+_newInfo["images"];
   totalImageCount=allImages.length;
   //photoTitles=_newInfo["photoLocation"];
  }
  int currentImagePosition=-1;
    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 0.5),
           child: SizedBox(
           width: screenSize.width,
           child:allImages.isEmpty?
           CachedNetworkImage(
           fit:BoxFit.fill,
           errorWidget: (context,string,dyna)=>Center(child: Shimmer.fromColors( child: Container(color: Colors.red,), baseColor: Colors.black38, highlightColor: Colors.grey)),
           placeholder: (context,sms)=>Center(child: SpinKitCircle(color:kAppColor)),
           imageUrl: widget.buildingInfo.coverImage.toString())
           :PageView.builder(
            itemCount:allImages.length,
            itemBuilder: (context,ind){
             String picTitle="";
              // if(photoTitles != null){
              //  int index= photoTitles.indexWhere((el) => el['index']==ind);
              //  picTitle=photoTitles[ind]['text'];
              //  }
              return Stack(
                   children: [
                     Container(
                      //margin: const EdgeInsets.only(top:5,),
                      width: screenSize.width,
                       child:Container(
                        alignment: Alignment.center,
                        child:PinchZoom(
                          child: CachedNetworkImage(
                         fit:BoxFit.fill,
                         errorWidget: (context,string,dyna)=>Center(child: Shimmer.fromColors( child: Container(color: Colors.red,), baseColor: Colors.black38, highlightColor: Colors.grey)),
                         placeholder: (context,sms)=>Center(child: SpinKitCircle(color:kAppColor)),
                          imageUrl: allImages[ind])
                          ),
                      ),
                    ),SafeArea(
                      child: Container(
                        margin: const EdgeInsets.only(top:8,left:4),
                        padding: const EdgeInsets.symmetric(horizontal: 4,vertical:1),
                        decoration:BoxDecoration(
                          border: Border.all(
                            color: kAppColor,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black45
                        ),
                        child: Text("${ind+1} / ${totalImageCount.toString()}",style: const TextStyle(color: kWhiteColor),),
                      ),
                    ),
                    Positioned(
                  bottom: 0,
                  left:0,
                  child:picTitle.isEmpty?Container():Container(
                    margin: const EdgeInsets.only(bottom:4,left:4),
                    padding: const EdgeInsets.symmetric(horizontal: 4,vertical:1),
                    decoration:BoxDecoration(
                      border: Border.all(
                        color: kAppColor,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black45,
                    ),
                          child:Text(picTitle,style:const TextStyle(color: kWhiteColor),),
                        ),
                    )
                   ],
                 );
           })
                //  child:SingleChildScrollView(
                //    scrollDirection: Axis.horizontal,
                //    child:_newInfo.isEmpty?Row(
                //      children: [
                //        Stack(
                //              children: [
                //                Container(
                //                 height: (2/3)*308,
                //                 margin: EdgeInsets.only(top:5,),
                //                 width: 308,
                //                 decoration: BoxDecoration(
                //                   border: Border.all(
                //                     color:kAppColor,
                //                     width: 2
                //                   )
                //                 ),
                //                 child:Container(
                //                   alignment: Alignment.center,
                //                   child:PinchZoom(
                //                     child: CachedNetworkImage(
                //                    fit:BoxFit.fill,
                //                    errorWidget: (context,string,dyna)=>Center(child: Shimmer.fromColors( child: Container(color: Colors.red,), baseColor: Colors.black38, highlightColor: Colors.grey)),
                //                    placeholder: (context,sms)=>Center(child: SpinKitCircle(color:kAppColor)),
                //                     imageUrl: widget.buildingInfo.coverImage)),
                //                 ),
                //               ),Container(
                //                 child: Container(
                //                   margin: EdgeInsets.only(top:8,left:4),
                //                   padding: EdgeInsets.symmetric(horizontal: 4,vertical:1),
                //                   decoration:BoxDecoration(
                //                     border: Border.all(
                //                       color: kAppColor,
                //                     ),
                //                     borderRadius: BorderRadius.circular(20),
                //                     color: Colors.black45
                //                   ),
                //                   child: Text("1/ ${widget.buildingInfo.imageCount.toString()}",style: TextStyle(color: kWhiteColor),),
                //                 ),
                //               ),
                //               Positioned(
                //             bottom: 0,
                //             left:0,
                //             child: Container(
                //               margin: EdgeInsets.only(bottom:4,left:4),
                //               padding: EdgeInsets.symmetric(horizontal: 4,vertical:1),
                //               decoration:BoxDecoration(
                //                 border: Border.all(
                //                   color: kAppColor,
                //                 ),
                //                 borderRadius: BorderRadius.circular(20),
                //                 color: Colors.black45,
                //               ),
                //                     child: Text("Nje"),
                //                     //Text(currentImagePosition==0?"Muonekano wa nje":_newInfo["placeNames"]!=null?"Haijatajwa":_newInfo["placeNames"][currentImagePosition+1].toString(),style: TextStyle(color: kWhiteColor)),
                //                   ),
                //           )
                //              ],
                //            ),
                //      SpinKitCircle(color:kAppColor)],
                //    )
                //      :Row(
                //      children: allImages.map<Widget>((image){
                //        currentImagePosition++;
                //        return Stack(
                //          children: [
                //            Container(
                //             height: (2/3)*308,
                //             margin: EdgeInsets.only(top:5,),
                //             width: 308,
                //             decoration: BoxDecoration(
                //               border: Border.all(
                //                 color:kAppColor,
                //                 width: 2
                //               )
                //             ),
                //             child:Container(
                //               alignment: Alignment.center,
                //               child:PinchZoom(
                //                 child: CachedNetworkImage(
                //                fit:BoxFit.fill,
                //                errorWidget: (context,string,dyna)=>Center(child: Shimmer.fromColors( child: Container(color: Colors.red,), baseColor: Colors.black38, highlightColor: Colors.grey)),
                //                placeholder: (context,sms)=>Center(child: SpinKitCircle(color:kAppColor)),
                //                 imageUrl: image)),
                //             ),
                //           ),Container(
                //             child: Container(
                //               margin: EdgeInsets.only(top:8,left:4),
                //               padding: EdgeInsets.symmetric(horizontal: 4,vertical:1),
                //               decoration:BoxDecoration(
                //                 border: Border.all(
                //                   color: kAppColor,
                //                 ),
                //                 borderRadius: BorderRadius.circular(20),
                //                 color: Colors.black45
                //               ),
                //               child: Text("${(currentImagePosition+1).toString()} / ${totalImageCount.toString()}",style: TextStyle(color: kWhiteColor),),
                //             ),
                //           ),
                //           Positioned(
                //         bottom: 0,
                //         left:0,
                //         child: Container(
                //           margin: EdgeInsets.only(bottom:4,left:4),
                //           padding: EdgeInsets.symmetric(horizontal: 4,vertical:1),
                //           decoration:BoxDecoration(
                //             border: Border.all(
                //               color: kAppColor,
                //             ),
                //             borderRadius: BorderRadius.circular(20),
                //             color: Colors.black45,
                //           ),
                //                 child: Text("Nje"),
                //                 //Text(currentImagePosition==0?"Muonekano wa nje":_newInfo["placeNames"]!=null?"Haijatajwa":_newInfo["placeNames"][currentImagePosition+1].toString(),style: TextStyle(color: kWhiteColor)),
                //               ),
                //       )
                //          ],
                //        );
                //      }).toList(),
                //    ),
                //  )
           ),  
        );
   
  }

 Widget displayBuildingLocation(Size screenSize){
    return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration:BoxDecoration(
          color: Colors.white,
           borderRadius: BorderRadius.circular(10),
            boxShadow:const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 4
              )
            ]
          ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Container(
                 width: screenSize.width,
                 padding: const EdgeInsets.all(3),
                 decoration: BoxDecoration(
                   color: kAppColor,
                   borderRadius:const BorderRadius.only(
                     topLeft: Radius.circular(10),topRight: Radius.circular(10),
                   ),
                 ),
                 child:Row(
                   children:const [
                    Icon(Icons.location_on,color: Colors.white,),Text("Eneo mali ilipo",style: TextStyle(color:Colors.white,fontWeight:FontWeight.w800)),
                   ],
                 )),
               Container(
                 padding:const EdgeInsets.all(5),
                 child:Column(
                 children: [
                 widget.buildingInfo.userRole==0?Container() : _showGoogleMap(),
                   Container(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                     children: [
                        const Text("Mkoa: ",style: TextStyle(fontWeight:FontWeight.bold)),Text(widget.buildingInfo.regionName)
                     ],
                   )),
                   Container(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                     children:[
                       const Text("Wilaya: ",style: TextStyle(fontWeight:FontWeight.bold)),Text(widget.buildingInfo.districtName)
                     ],
                   )),
                   Container(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                     children:[
                        const Text("Mtaa/kata/kitongoji: ",style: TextStyle(fontWeight:FontWeight.bold)),Expanded(child: Text(widget.buildingInfo.localArea,overflow: TextOverflow.ellipsis,))
                     ],
                   )),
                  widget.buildingInfo.userRole==0?Container():Container(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                     children:[
                       const Text("Umbali kutoka hapa ulipo: ",style: TextStyle(fontWeight:FontWeight.bold)),_separationDistance==null? const Text(""):Text(_separationDistance!<1000? "Mita ${_separationDistance!.toStringAsFixed(2) }":"Kilomita ${(_separationDistance!/1000).toStringAsFixed(2)}")
                     ],
                   )),
                    widget.buildingInfo.userRole==0?Container():Container(
                     padding:const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                       crossAxisAlignment:CrossAxisAlignment.start,
                       children: [
                         const Text("Muonekano wa ramani: ",style: TextStyle(fontWeight:FontWeight.bold)),
                         RadioGroup<String>.builder(groupValue: _selectedMapTypeString, onChanged:(val){
                                setState(() {
                                   _selectedMapTypeString=val.toString();
                                   if(val==_mapTypeChoices[0]){
                                      _mapType=MapType.normal;

                                   }else{
                                      _mapType=MapType.satellite;
                                   }
                                });   
                         }, items:_mapTypeChoices,itemBuilder: (item)=>RadioButtonBuilder(item)),
                       ],
                     )),
                 ],
               )),
             ],
           ),  
        );
  }


 Widget displayBuildingDetails(Size screenSize){
  CommercialBuilding? commercial;
  ResidentBuilding? residential;
  if(widget.buildingInfo.houseOrLand==0 && widget.buildingInfo.purpose==0){
   commercial=widget.buildingInfo.specificInfo as CommercialBuilding;
  }
 if(widget.buildingInfo.houseOrLand==0 && widget.buildingInfo.purpose==1){
   residential=widget.buildingInfo.specificInfo as ResidentBuilding;
  }
  int currentAsset=0;
  int currentSocialService=0;
  int currentInsideService=0;
  List insideServ=[];
  List nearbyServ=[];
     if(widget.buildingInfo.insideServices != null){
       insideServ=widget.buildingInfo.insideServices as List;
     }
    if(widget.buildingInfo.socialServices != null){
       nearbyServ=widget.buildingInfo.socialServices as List;
     }
     
     return Container(
          margin:const EdgeInsets.symmetric(horizontal: 2),
          decoration:BoxDecoration(
          color: Colors.white,
           borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 4
              )
            ]
          ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
              Container(
                 width: screenSize.width,
                 padding: const EdgeInsets.all(3),
                 decoration:BoxDecoration(
                   color: kAppColor,
                   borderRadius:const BorderRadius.only(
                     topLeft: Radius.circular(10),topRight: Radius.circular(10),
                   ),
                 ),
                 child:Row(
                   children: const [
                    Icon(Icons.description,color: Colors.white,),Text("Taarifa za mali hii",style: TextStyle(color:Colors.white,fontWeight:FontWeight.w800)),
                   ],
                 )),
              Container(
                padding:const EdgeInsets.symmetric(horizontal: 7),
                child: Column(
                  children: [
                    Container(
                           alignment: Alignment.topLeft,
                           padding:const EdgeInsets.symmetric(vertical: 4),
                           child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Container(
                                margin:const EdgeInsets.only(bottom: 3),
                                 child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                 children: [
                                 widget.buildingInfo.userId!=dataProvider.currentUser["id"]?Container():
                                 Container(
                                  margin:const EdgeInsets.only(bottom: 3),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.green,width:2.5)
                                  ),
                                  child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                  children: [
                                 const Text("Utambulisho: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor)),
                                  Text("${widget.buildingInfo.id}",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)
                                  ],
                                ),
                               ),
                                Container(
                                margin:const EdgeInsets.only(bottom: 3),
                                 child: Column(
                                 crossAxisAlignment:CrossAxisAlignment.start,
                                 children: [
                                 const Text("Kwa ufupi: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor)),
                                  Text(widget.buildingInfo.title,maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)
                                  ],
                                ),
                               ),
                             
                                 const Text("Aina ya mali: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor)),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(widget.buildingInfo.houseOrLand==0 && widget.buildingInfo.purpose==0?"${creBuildingClasses[widget.buildingInfo.specificInfo.buildingClass]} - ${(widget.buildingInfo.specificInfo.subBuildingType==null || widget.buildingInfo.specificInfo.subBuildingType<0)?'':commercialSubBuilding[widget.buildingInfo.specificInfo.buildingType.toString()][widget.buildingInfo.specificInfo.subBuildingType]}":
                                         widget.buildingInfo.houseOrLand==0 && widget.buildingInfo.purpose==1?residentBuildingTypes[widget.buildingInfo.specificInfo.buildingType]:"Eneo la ardhi",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),),
                                      ),residential==null?Container():Container( 
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color:Colors.green,),
                                        padding:const EdgeInsets.symmetric(horizontal:5),  child:Text(residentBuildingStatus[residential.buildingStatus],style:const TextStyle(fontSize: 10,fontWeight:FontWeight.bold))) 
                                    ],
                                  )
                                  ],
                              ),
                               ),
                              Container(
                                margin:const EdgeInsets.only(bottom: 3),
                                 child: Column(
                                 crossAxisAlignment:CrossAxisAlignment.start,
                                 children: [
                                 const Text("Matumizi: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor)),
                                  Text(propertyPurpose[widget.buildingInfo.purpose] ,maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)
                                  ],
                                ),
                               ),
                              widget.buildingInfo.houseOrLand!=0 || widget.buildingInfo.purpose!=1?Container():
                              Container(
                                decoration:BoxDecoration(
                                  border: Border(
                                    left: BorderSide(color: kAppColor,width:2),
                                  )
                                ),
                                child:Column(
                                  children: [
                                   Row(
                                      children: [
                                        const Icon(Icons.bed_outlined),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:const EdgeInsets.only(bottom: 4),
                                                child:Column(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                children: [
                                                  const Text("Vyumba vya kulala: ",style: TextStyle(fontWeight:FontWeight.bold,color:Colors.black45,fontSize: 12)),
                                                  Text("   ${residential!.bedRooms.toString()}" ,maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)                                  
                                                ],
                                              ),),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                   Row(
                                      children: [
                                        const Icon(Icons.chair_outlined),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:const EdgeInsets.only(bottom: 4),
                                                child:Column(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                children: [
                                                  const Text("Sebure za kukaa(sitting room): ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor,fontSize: 12)),
                                                  Text("   ${residential.livingRooms.toString()}" ,maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)                                  
                                                ],
                                              ),),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),                             
                                   Row(
                                      children: [
                                       const Icon(Icons.dining_outlined),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:const EdgeInsets.only(bottom: 4),
                                                child:Column(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                children: [
                                                  const Text("Sebure za chakula(dining room): ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor,fontSize: 12)),
                                                  Text("   ${residential.diningRooms.toString()}" ,maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)                                  
                                                ],
                                              ),),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                   Row(
                                      children: [
                                       const Icon(Icons.kitchen_outlined),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:const EdgeInsets.only(bottom: 4),
                                                child:Column(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                children: [
                                                  const Text("Vyumba vya jiko: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor,fontSize: 12)),
                                                  Text("   ${residential.kitchenRooms.toString()}" ,maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)                                  
                                                ],
                                              ),),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),                               
                                   Row(
                                      children: [
                                       const Icon(Icons.bathroom_outlined),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:const EdgeInsets.only(bottom: 4),
                                                child:Column(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                children: [
                                                  const Text("Vyumba vya choo/bafu(bathRooms): ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor,fontSize: 12)),
                                                  Text("   ${residential.bathRooms.toString()}" ,maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)                                  
                                                ],
                                              ),),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),        
                                   Row(
                                      children: [
                                       const Icon(Icons.storage_outlined),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:const EdgeInsets.only(bottom: 4),
                                                child:Column(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                children: [
                                                  const Text("Vyumba vya stoo: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor,fontSize: 12)),
                                                  Text("   ${residential.storeRooms .toString()}" ,maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)                                  
                                                ],
                                              ),),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),                                                                
                                   Row(
                                      children: [
                                       Row(
                                         children:const [
                                            Icon(Icons.bed_outlined,size:12),Icon(Icons.bathroom_outlined,size:12)
                                         ],
                                       ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:const EdgeInsets.only(bottom: 4),
                                                child:Column(
                                                crossAxisAlignment:CrossAxisAlignment.start,
                                                children: [
                                                  const Text("Vyumba vyenye choo/bafu(self): ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor,fontSize: 12)),
                                                  Text("   ${residential.selfRoomsbathRooms.toString()}" ,maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)                                  
                                                ],
                                              ),),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),                                                                                      
                              ],
                                )
                               ),
                               (_newInfo["assets"]==null || widget.buildingInfo.houseOrLand==1)?Container():Container(
                                margin:const EdgeInsets.only(bottom: 3),
                                 child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                 children: [
                                 const Text("Aseti zilizopo ndani: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor)),
                                 Wrap(
                                  children: _newInfo["assets"].map<Widget>((e){
                                    currentAsset++;
                                    return Container(margin:const EdgeInsets.only(right: 10), child: Text("${currentAsset.toString()}. $e",style: TextStyle(color: kAppColor),));
                                  }).toList()
                                 ) 
                                  ],
                             ),
                               ),
                               (nearbyServ ==null || nearbyServ.isEmpty)? Container():Container(
                                margin:const EdgeInsets.only(bottom: 3),
                                 child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                 children: [
                                 const Text("Huduma za kijamii za karibu: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor)),
                                 Wrap(
                                  children: widget.buildingInfo.socialServices!.map<Widget>((e){
                                    currentSocialService++;
                                    return Container(margin:const EdgeInsets.only(right: 10), child: Text("${currentSocialService.toString()}. ${nearbySocialServices[int.parse(e.toString())]}",style: TextStyle(color: kAppColor),));
                                  }).toList()
                                 ) 
                                  ],
                             ),
                               ),
                                (insideServ == null || insideServ.isEmpty)? Container():Container(
                                margin:const EdgeInsets.only(bottom: 3),
                                 child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                 children: [
                                 const Text("Huduma zilizopo kweye jengo: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor)),
                                 Wrap(
                                  children: widget.buildingInfo.insideServices!.map<Widget>((e){
                                    currentInsideService ++;
                                    return Container(margin:const EdgeInsets.only(right: 10), child: Text("${currentInsideService.toString()}. ${insideSocialServices[int.parse(e.toString())]}",style: TextStyle(color: kAppColor),));
                                  }).toList()
                                 ) 
                                  ],
                             ),
                               ),
                               widget.buildingInfo.areaSize.toString().isEmpty?Container():Container(
                                margin:const EdgeInsets.only(bottom: 3),
                                 child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                 children: [
                                 const Text("Ukubwa wa eneo: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor)),
                                  Text("${widget.buildingInfo.areaSize} .${areaDimensions[widget.buildingInfo.areaDimension]}",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)
                                  ],
                             ),
                               ),
                               widget.buildingInfo.houseOrLand==1?Container():Container(
                                margin:const EdgeInsets.only(bottom: 3),
                                 child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                 children: [
                                 const Text("Sehemu husika: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor)),
                                  Text("${rentalSize[widget.buildingInfo.partSize]}",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)
                                  ],
                             ),
                               ),
                               Container(
                                margin:const EdgeInsets.only(bottom: 3),
                                 child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                 children: [
                                 const Text("Kuhusu fensi/uzio: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor)),
                                  Text(widget.buildingInfo.hasFens==1?"Fensi ipo":"Fensi haipo",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)
                                  ],
                             ),
                               ),
                              Container(
                                margin:const EdgeInsets.only(bottom: 3),
                                 child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                 children: [
                                 const Text("Kuhusu paking: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor)),
                                  Text(widget.buildingInfo.hasParking==1?"Inapaking":"Haina paking",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)
                                  ],
                             ),
                               ),
                              widget.buildingInfo.operation==0?
                              Container(
                                margin:const EdgeInsets.only(bottom: 3),
                                 child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                 children: [
                                 const Text("Inauzwa kwa: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor)),
                                  Text("${payCurrencyChoices[widget.buildingInfo.payCurrency]}. ${widget.buildingInfo.propertyPriceAmount.toString()}",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)
                                  ],
                             ),
                               ):
                               Container(
                                margin:const EdgeInsets.only(bottom: 3),
                                 child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                 children: [
                                 const Text("Inapangishwa kwa: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor)),
                                  Text("${payCurrencyChoices[widget.buildingInfo.payCurrency]} ${widget.buildingInfo.buildingBillAmount} ${payPeriodChoices[widget.buildingInfo.minBillPeriod]}  ilipwe kwa ${payPeriodChoicesPrural[widget.buildingInfo.minBillPeriod]} ${widget.buildingInfo.billPeriodsNumber.toString()}",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)
                                  ],
                             ),
                               ),
                              widget.buildingInfo.brokerSalary.toString().isEmpty?Container():Container(
                                margin:const EdgeInsets.only(bottom: 3),
                                 child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                 children: [
                                  const Text("Posho ya dalali: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor)),
                                  Text("Dalali anahitaji ${payCurrencyChoices[widget.buildingInfo.brokerPayCurrency]} ${widget.buildingInfo.brokerSalary.toString()}",maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(fontWeight: FontWeight.w700,color:kAppColor),)
                                  ],
                             ),
                               ),
                              (_newInfo.isEmpty || _newInfo["description"]==null || _newInfo["description"].toString().trim().isEmpty)?Container():Container(                               
                               child: Column(
                                  crossAxisAlignment:CrossAxisAlignment.start,
                                 children: [
                                  const Text("Maelezo zaidi: ",style: TextStyle(fontWeight:FontWeight.bold,color: kGreyColor)),
                                  Text(_newInfo['description'],style:const TextStyle(fontWeight: FontWeight.w700,color:Colors.black),)
                                  ],
                             ),
                               ), 
                             ],
                           )),
                  ],
                ),
              ),
              Container(padding:const EdgeInsets.only(left:5,right:5),
               child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Text("Imepandishwa tar ",style:TextStyle(fontSize: 13,fontWeight:FontWeight.bold,color:Colors.green)),
                   Text(DateFormat("d MMMM y - hh:mm a").format(widget.buildingInfo.uploadTime!)  ,style:const TextStyle(fontSize: 13,fontWeight:FontWeight.bold,color:Colors.green)),
                 ],
               ))
              ],
           ),          
        );
  }
  
Widget displayRentalOwnerDetails(Size screenSize){
         String onlineStatus='';
         String date= "";
         if(rentalOwner != null && rentalOwner['onlineStatus']!="Online"){
           Duration difference= DateTime.now().difference(DateTime.parse(rentalOwner['onlineStatus'].toString()));    
                    if(difference.inDays !=0){
                      if(difference.inDays>365){
                        int years=difference.inDays~/365;
                          if(years>1){
                          date="Miaka "+years.toString();
                          }else{
                            date="Mwaka";
                          }
                      }else if(difference.inDays>12){
                        int months=difference.inDays~/12;
                          if(months>1){
                          date="Miezi "+months.toString();
                          }else{
                            date="Mwezi";
                          }
                        }else{
                          date="Siku "+difference.inDays.toString();
                        }
                    }else if(difference.inHours!=0){
                        if(difference.inHours>1){
                          date="Masaa "+difference.inHours.toString();
                        }else{
                            date="Saa 1";
                        }  
                    }else if(difference.inMinutes!=0){
                        date="Dakika "+difference.inMinutes.toString();  
                    }else if(difference.inSeconds!=0){
                        date="Sekunde "+difference.inSeconds.toString();  
                    }                    
         }           
            if(date.isNotEmpty){
                onlineStatus=date;
            }else{
              onlineStatus="Online";
            }
   return Container(
          margin:const EdgeInsets.symmetric(horizontal: 2),
          decoration:BoxDecoration(
          color: Colors.white,
           borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 4
              )
            ]
          ),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                Container(
                 width: screenSize.width,
                 padding: const EdgeInsets.all(3),
                 decoration:BoxDecoration(
                   color: kAppColor,
                   borderRadius: const BorderRadius.only(
                     topLeft: Radius.circular(10),topRight: Radius.circular(10),
                   ),
                 ),
                 child:Row(
                   children: [
                   const Icon(Icons.person,color: Colors.white,),Text(widget.buildingInfo.userRole==0?"Dalali":"  Mmiliki wa mali",style: const TextStyle(color:Colors.white,fontWeight:FontWeight.w800)),
                   ],
                 )),
                Container(
 //                color: Colors.green,g
                 padding: const EdgeInsets.all(5),
                 child:Column(
                   crossAxisAlignment:CrossAxisAlignment.start,
                    children: [
                    rentalOwner==null?Container(
                    padding: const EdgeInsets.all(5),
                    child:Center(
                      child: SpinKitThreeBounce(
                        color:kAppColor
                      )
                    ),):Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        Container(
                     padding:const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                       children: [
                         Expanded(
                           child: Column(
                           crossAxisAlignment:CrossAxisAlignment.start,
                           children: [
                           const Text("Jina: ",style: TextStyle(fontWeight:FontWeight.bold)),Text(widget.buildingInfo.userRole==0?rentalOwner['agentInfo'] ==null?"":rentalOwner["agentInfo"]['name']:rentalOwner["firstName"]+"  "+rentalOwner["lastName"])
                            , widget.buildingInfo.userRole==1?Container():Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment:CrossAxisAlignment.start,
                              children:[
                                const Text("Bio: ",style: TextStyle(fontWeight:FontWeight.bold)),Text(rentalOwner['agentInfo'] ==null?"":rentalOwner['agentInfo']['description'])
                              ],
                            ),),
                                        
                           ],
                           ),
                         ), 
                         Column(
                           children: [
                             FloatingActionButton(
                                      heroTag: "owner1",
                                        onPressed: () {
                                        Navigator.push(context,PageTransition(child: OwnerInfoScreen(widget.buildingInfo), type: PageTransitionType.rightToLeft));
                                        },
                                        mini: true,
                                        elevation: 0,
                                      child: Container(
                                          width: 120,height:120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(image: NetworkImage(rentalOwner['profilePhoto']))
                                          ),
                                        ),
                                    ),
                                    Row(
                                      children: [
                                        const Text('LS: ',style:TextStyle(fontSize:10,fontWeight: FontWeight.bold)),
                                        Text('${onlineStatus}',style:const TextStyle(fontSize:10,fontWeight: FontWeight.bold,color: Colors.green)),
                                      ],
                                    )
                           ],
                         ),
                             
                       ],
                     )),
                   Container(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                       children: [
                         Column(
                           crossAxisAlignment:CrossAxisAlignment.start,
                         children:[
                           const Text("Namba ya simu: ",style: TextStyle(fontWeight:FontWeight.bold)),Text(rentalOwner["phoneNumber"])
                         ],
                   ), const Spacer(),
                   (myId==rentalOwner["id"])?Container(): Bounce(
                     onPressed: ()async{
                          if(await canLaunch("tel:"+rentalOwner["phoneNumber"])){
                            launch("tel:"+rentalOwner["phoneNumber"]);
                          }else{
                          UserReplyWindowsApi().showToastMessage(context,"Kuna tatizo limetokea, tafadhali jaribu tena baadae!!");
                          }       
                     },
                     duration: const Duration(milliseconds:500),
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 3,vertical: 2),
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(10),
                         border:Border.all(
                           color:kAppColor,width: 1
                         ),
                       ),
                       child:Row(
                         children: [Icon(Icons.call,color: kAppColor,),Text("   Mpigie simu",style: TextStyle(color:kAppColor,fontWeight:FontWeight.bold))],)
                         ),
                   )
                       ],
                     )),
                  rentalOwner["email"].toString().isEmpty?Container():Container(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Column(
                       crossAxisAlignment:CrossAxisAlignment.start,
                     children:[
                       const Text("Barua pepe(email): ",style: TextStyle(fontWeight:FontWeight.bold)),Text(rentalOwner["email"])
                     ],
                   ),),
                 (myId==rentalOwner["id"])?Container():Bounce(
                     onPressed: ()async{
                       if(myId!=null && _sharedPreferences!.getBool("guestUser")==false){                         
                         Navigator.push(context,PageTransition(child: ChatMessagesScreen(rentalOwner,myId,widget.buildingInfo), type: PageTransitionType.bottomToTop));
                       }else{
                         UserReplyWindowsApi().showToastMessage(context,"Jisajili au ingia kwenye akaunti yako kwanza ili kuchati na "+rentalOwner["firstName"].toString());
                       }
                     },
                     duration:const Duration(milliseconds:500),
                     child: Container(
                       width: screenSize.width,
                       margin: const EdgeInsets.symmetric(vertical: 4),
                       padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 4),
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(10),
                         border:Border.all(
                           color:kAppColor,width: 1
                         ),
                       ),
                       child:Container(
                        // color:Colors.red,
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [Icon(Icons.message,color: kAppColor,),const Spacer(),Text("Chati nae",style: TextStyle(color:kAppColor,fontWeight:FontWeight.bold),),const Spacer(),Icon(Icons.message,color: kAppColor,),],),
                       )
                         ),
                   ),
                  ],
                ),   
               widget.buildingInfo.userRole==1?Container():Column(children: [
                 const Text("Ofisi au makazi yake",style:TextStyle(fontWeight:FontWeight.bold)),
                Container(
                  padding:const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: kGreyColor
                    )
                  ),
                  child:rentalOwner ==null?Container():Column(
                    children: [
                      Container(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                     children: [
                        const Text("Mkoa: ",style: TextStyle(fontWeight:FontWeight.bold)),Text(rentalOwner['agentInfo']['region'])
                     ],
                   )),
                   Container(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                     children:[
                       const Text("Wilaya: ",style: TextStyle(fontWeight:FontWeight.bold)),Text(rentalOwner['agentInfo']['district'])
                     ],
                   )),
                   Container(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                     children:[
                        const Text("Mtaa/kata/kitongoji: ",style: TextStyle(fontWeight:FontWeight.bold)),Expanded(child: Text(rentalOwner['agentInfo']['localArea'],overflow: TextOverflow.ellipsis,))
                     ],
                   )),
                   Container(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                     children:[
                       const Text("Umbali kutoka hapa ulipo: ",style: TextStyle(fontWeight:FontWeight.bold)),_separationDistance==null? const Text(""):Text(_separationDistance!<1000? "Mita ${_separationDistance!.toStringAsFixed(2) }":"Kilomita ${(_separationDistance!/1000).toStringAsFixed(2)}")
                     ],
                   )),
                   const SizedBox(height:6),
                      Container(
                        height: 250,
                        width: screenSize.width,
                        decoration: BoxDecoration(
                         border: Border.all(
                             color: Colors.grey,
                             width:3
                           )
                         ),
                        child:_showGoogleMap()
                        ),
                    ],
                  ),
                ),            
                   ],)
                 ],
               )),
             ],
           ),
        );
  }
  
 Widget _showGoogleMap() {
  return  Stack(
                children: [
                  SizedBox(
                    height:250,
                    child: Hero(
                      tag:"map",
                      child: StatefulBuilder(builder: (context,mapSetter){
                        _mapSetter=mapSetter;
                        return showMap==false?Container():GoogleMap(
                        mapType:_mapType,
                        initialCameraPosition:const CameraPosition(target: LatLng(-7.2501,38.64992),zoom: 10),
                         markers: _mapMarkers,
                         onMapCreated:(GoogleMapController controller){
                          _googleMapController=controller;
                          if(_mapMarkers.isEmpty){
                               getCustomeMapMarkers().then((value){
                               getThisDeviceCurrentLocation();
                          });
                          }
                        },
                        );                  
                      })
                    ),
                  ),Positioned(
                      right: 10,top: 0,
                      child: IconButton(
                        color: Colors.white,
                        onPressed: ()async{
                       double zoom=await _googleMapController.getZoomLevel();  
                        Navigator.push(context,PageTransition(child: FullScreenMapScreen(_currentLocation,widget.buildingInfo,_mapMarkers,zoom,_mapType),type:PageTransitionType.fade));
                      }, icon:const Icon(Icons.fullscreen,size:40)))
                ],
              );
 }
  

}