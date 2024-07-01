import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/screens/rental_screens/chat_messages_screen.dart';
import 'package:betterhouse/screens/rental_screens/owner_info_screen.dart';
import 'package:betterhouse/screens/rental_screens/rental_details_screen_to_client.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/server_variable_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:like_button/like_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:betterhouse/services/database_services.dart';
import 'package:betterhouse/services/modal_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemsPage extends StatefulWidget {
  const CartItemsPage({Key? key}) : super(key: key);

  @override
  State<CartItemsPage> createState() => _CartItemsPageState();
}

class _CartItemsPageState extends State<CartItemsPage> {
  final CollectionReference<Map<String, dynamic>> _itemsViewsAndCartRef=FirebaseFirestore.instance.collection("ITEMS VIEWS AND CART");
  final CollectionReference<Map<String, dynamic>> _propertiesRef=FirebaseFirestore.instance.collection("PROPERTIES");
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.reference().child("USERS"); 
  AppDataProvider? dataProvider;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<DocumentSnapshot> _buildingsDocList = [];
final ScrollController _gridAutoScrController=ScrollController();
  bool _isLoadingFirstTime = true;
  bool _isFetchingNext = false;
  final List<PropertyInfo> _buildingsList = [];
  final int _buildingsListLength = 0;
  bool _isMovingDown=false;
  int lastPropertyIndex=0;
 
 Future<void> getBuildingsFromDatabase(AppDataProvider dataProvider)async{
   List propertyIds=[];
   List cartItems=dataProvider.currentUser["cartItems"];
     for(int i=lastPropertyIndex;i<cartItems.length;i++){
         propertyIds.add(cartItems[i]);
         lastPropertyIndex=i+1;
         if((i+1)%3==0){         
            break;
         }
     }
     setState(() {
       if(lastPropertyIndex!=0){
        _isFetchingNext = true;
        }else{
          _isLoadingFirstTime = true;
        }
    });
    // UserReplyWindowsApi().showToastMessage(context,"done");
    if(propertyIds.isNotEmpty){
     _buildingsDocList.addAll(await DatabaseApi().getMyFavouriteProperties(propertyIds));     
    if (_buildingsDocList.isNotEmpty) {
      for (int i = 0; i < _buildingsDocList.length; i++) {
        Map<String, dynamic> data = 
            _buildingsDocList[i].data()! as Map<String, dynamic>;
            PropertyInfo building = PropertyInfo().initializeData(data);
           _buildingsList.add(building);
      }

      //_lastDocument.
    }
    setState(() {

      _isFetchingNext = false;
      _isLoadingFirstTime = false;
        _buildingsDocList.clear();
    });
 
    }
  }

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)async{
        AppDataProvider dataProvider =Provider.of<AppDataProvider>(context, listen: false);
      if(dataProvider.currentUser["cartItems"].isNotEmpty){
         await getBuildingsFromDatabase(dataProvider);
      _gridAutoScrController.addListener(() async {
        if (_gridAutoScrController.hasClients) {
          if (_gridAutoScrController.offset >=
                  _gridAutoScrController.position.maxScrollExtent &&
              !_gridAutoScrController.position.outOfRange) {
            if (_isFetchingNext == false || _isLoadingFirstTime==false){
              await getBuildingsFromDatabase(dataProvider);
            }
          }
          if(_gridAutoScrController.position.userScrollDirection==ScrollDirection.reverse && _isMovingDown==false){
            setState((){
              _isMovingDown=true;
            });
          }
          if(_gridAutoScrController.position.userScrollDirection==ScrollDirection.forward && _isMovingDown==true){
             setState(() {
               _isMovingDown=false;
             });
          }

        }

      }); 
 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
          dataProvider=Provider.of<AppDataProvider>(context);
  Size screenSize=MediaQuery.of(context).size;

    return (dataProvider!.currentUser["cartItems"] == null || dataProvider!.currentUser["cartItems"].isEmpty)?const Center(
                        child: Text("Hauna mali kapuni",style:TextStyle(fontWeight: FontWeight.bold)),
                      ):_isLoadingFirstTime == true
                ? Center(child: UserReplyWindowsApi().showLoadingIndicator())
                : _buildingsList.isEmpty
                    ?const Center(
                        child: Text("Hakuna mali iliyopatikana",style:TextStyle(fontWeight: FontWeight.bold)),
                      )
                    :
                    //Text(_buildingsList.length.toString());
                    Stack(
                      children: [
                        AlignedGridView.count(
                            crossAxisCount: screenSize.width <= 400
                                ? 1
                                : screenSize.width <= 640
                                    ? 2
                                    : screenSize.width <= 960
                                        ? 2
                                        : 4,
                            padding: const EdgeInsets.all(0),
                            physics: const BouncingScrollPhysics(),
                            controller: _gridAutoScrController,
                            shrinkWrap: true,
                            mainAxisSpacing: 5,
                            itemCount: _buildingsList.length,
                            itemBuilder: (context, _currentIndex) {
                              CommercialBuilding? commercial;
                              ResidentBuilding? residential;
                              PropertyInfo building =
                                  _buildingsList[_currentIndex];
                              if(building.houseOrLand==0 && building.purpose==0){
                                commercial=building.specificInfo as CommercialBuilding;
                              }
                              if(building.houseOrLand==0 && building.purpose==1){
                                residential=building.specificInfo as ResidentBuilding;
                              }
                              bool _isAddingToCart=false;
                              String date= "";
                                Duration difference= DateTime.now().difference(building.uploadTime!);    
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
                                   date="Muda huu "+difference.inSeconds.toString();  
                                } 
                              return Container(
                                    margin:const EdgeInsets.only(left: 3, right: 3),
                                    decoration:const BoxDecoration(
                                        color: kWhiteColor,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black,
                                              blurRadius: 5)
                                        ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                            Stack(
                                              children: [
                                              GestureDetector(
                                                  onTap: () {
                                                    //dataProviderListen.selectedHouse=building;
                                                   Navigator.push(context, PageTransition(
                                                    duration: const Duration(milliseconds: 300),
                                                    child: BuildingDetailsToClientScreen(building), type: PageTransitionType.rightToLeft));
                                                  },
                                                  onDoubleTap: () {
                                                    //dataProviderListen.selectedHouse=building;
                                                   Navigator.push(context, PageTransition(
                                                    duration: const Duration(milliseconds: 300),
                                                    child: BuildingDetailsToClientScreen(building), type: PageTransitionType.rightToLeft));
                                                  },
                                                  child: AbsorbPointer(
                                                    child: AspectRatio(
                                                      aspectRatio: 13/7,
                                                      child: Container(
                                                       color: kBlueGreyColor,
                                                        child: CachedNetworkImage(
                                                            fit: BoxFit.cover,
                                                            width: screenSize.width,
                                                            errorWidget: (context,
                                                                    string, dyna) =>
                                                               const Center(
                                                                    child: Icon(
                                                                  Icons.error)),
                                                                  placeholder: (context,
                                                                    sms) =>
                                                               Center(
                                                                    child: SpinKitThreeBounce(
                                                                     duration:const Duration(milliseconds: 800),
                                                                     //borderWidth: 30,
                                                                     size:20,
                                                                     color:kAppColor
                                                                          )),
                                                            imageUrl:
                                                                building.coverImage),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                  Positioned(
                                                  left: 0,bottom:0,
                                                  child: SizedBox(
                                                    width: screenSize.width-48,
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                     Row(
                                                      children:[
                                                        Container(
                                                          padding:const EdgeInsets.only(top:1,right:2),
                                                          color:Colors.black,
                                                          child: Text("1/"+building.imageCount.toString(),style:const TextStyle(color:kWhiteColor,fontSize: 11))
                                                        ),
                                                        StatefulBuilder(
                                                          builder: (context,stateSetter){
                                                            return _isAddingToCart==true? const SizedBox(
                                                              width: 13,height:13,
                                                              child:CircularProgressIndicator()):CircleAvatar(
                                                            radius: 13,
                                                            backgroundColor: Colors.transparent,
                                                             child: IconButton(onPressed: ()async{
                                                               if(_auth.currentUser!.isAnonymous==false && _auth.currentUser!=null){
                                                              if(dataProvider!.currentUser["cartItems"].contains(building.id)==false){                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                                                              stateSetter((){
                                                                _isAddingToCart=true;
                                                              });
                                                              await _itemsViewsAndCartRef.doc(_auth.currentUser!.uid).update({"cartItems":FieldValue.arrayUnion([building.id])}).then((value){
                                                                  List<dynamic> newCarts=(dataProvider!.currentUser["cartItems"] as List<dynamic>) + ([building.id]);
                                                                  dataProvider!.currentUser.addAll({"cartItems":newCarts});
                                                                  stateSetter((){
                                                                  _isAddingToCart=false;
                                                                    });
                                                                        UserReplyWindowsApi().showToastMessage(context,"Mali imeingizwa kwenye kapu");
                                                                    });
                                                                }else{
                                                                  //UserReplyWindowsApi().showToastMessage(context,dataProviderNotListen.currentUser.toString());
                                                                  UserReplyWindowsApi().showToastMessage(context,"Mali tayari ipo kwenye kapu");
                                                                }
                                                            }else{
                                                            UserReplyWindowsApi().showAuthInfoDialog("Kuweka mali kwenye kapu ingia au sajili akaunti ya better house",context);
                                                            }                                                                                                         
                                                             },padding:const EdgeInsets.all(0), icon:const Icon(Icons.shopping_cart_checkout,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)])),
                                                           );                                               
                                                          })
                                                       
                                                      ]
                                                     ) 
                                                      ,residential ==null?Container():
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                             Row(
                                                              children:[
                                                                const Icon(Icons.bed_sharp,size:18 ,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)],)
                                                                 ,Text(residential.bedRooms.toString(),style: const TextStyle(fontWeight: FontWeight.bold),)
                                                              ],
                                                            ),const Icon(Icons.circle,size:8,color: Colors.red,),
                                                             Row(
                                                              children:[
                                                                const Icon(Icons.dining_outlined,size:18,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)],)
                                                                 ,Text(residential.diningRooms.toString(),style: const TextStyle(fontWeight: FontWeight.bold),)
                                                              ],
                                                            ),Icon(Icons.circle,size:8,color:kAppColor,),
                                                             Row(
                                                              children:[
                                                                const Icon(Icons.chair,size:18 ,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)],)
                                                                 ,Text(residential.livingRooms.toString(),style: const TextStyle(fontWeight: FontWeight.bold),)
                                                              ],
                                                             ),const Icon(Icons.circle,size:8,color: Colors.green,),
                                                             Row(
                                                              children:[
                                                                const Icon(Icons.bathroom_outlined ,size:18 ,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)],)
                                                                 ,Text(residential.bathRooms.toString(),style:const TextStyle(fontWeight: FontWeight.bold),)
                                                              ],
                                                            ),const Icon(Icons.circle,size:8,color: Colors.amber,),
                                                             Row(
                                                              children:[
                                                                const Icon(Icons.kitchen ,size:18 ,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)],)
                                                                 ,Text(residential.kitchenRooms.toString(),style:const TextStyle(fontWeight: FontWeight.bold),)
                                                              ],
                                                            ),const Icon(Icons.circle,size:8,color: Colors.red,),
                                                             Row(
                                                              children:[
                                                                Row(
                                                                  children:const [
                                                                   Icon(Icons.bed_sharp,size:10 ,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)],),
                                                                   Icon(Icons.bathroom_outlined ,size:10 ,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)],),
                                                                  ],
                                                                )
                                                                 ,Text(residential.selfRoomsbathRooms.toString(),style:const TextStyle(fontWeight: FontWeight.bold),)
                                                              ],
                                                            ),
                                                          ],
                                                        )
                                                     
                                                        ],
                                                    ),
                                                  ),
                                                ),                                         
      
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [     
                                                 Container(
                                                padding:const EdgeInsets.only(left:6,right:3,bottom:3),
                                                child:Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                                        building.propertyPriceAmount !=
                                                                                null
                                                                            ? "${payCurrencyChoices[building.payCurrency]} ${building.propertyPriceAmount.toString()}"
                                                                            : "${payCurrencyChoices[building.payCurrency]} ${building.buildingBillAmount.toString()} ${payPeriodChoices[building.minBillPeriod]}",
                                                                        style:const TextStyle(
                                                          
                                                                            fontWeight:
                                                                                FontWeight
                                                                                    .bold,
                                                                            fontSize:
                                                                                15)),
                                                         Text(building.operation==0?" :Inauzwa":" :Inapangishwa",style:TextStyle(color: kAppColor,fontWeight:FontWeight.bold))
                                                        ],
                                                      ),
                                                       Row(
                                                         children: [
                                                           Expanded(
                                                             child: Row(
                                                               children: [
                                                                Icon(Icons.circle,size:12,color:kAppColor),
                                                                 Expanded(
                                                                   child: Text(building.title,maxLines:1,overflow: TextOverflow.ellipsis, style:TextStyle(color: kAppColor,fontWeight:FontWeight.bold)),
                                                                 ),
                                                               ],
                                                             ),
                                                           ),
                                                          building.houseOrLand==0 && building.purpose==1 && residential!.buildingStatus==0?
                                                          Container( 
                                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color:Colors.green,),
                                                            padding:const EdgeInsets.symmetric(horizontal:5),  child:const Text("mpya",style:TextStyle(fontSize: 10,fontWeight:FontWeight.bold))):Container() 
                                                         ],
                                                       ),
                                                        Row(
                                                          children: [
                                                            const Icon(Icons.location_on,size:15,color:Colors.amber),
                                                            Expanded(
                                                              child: Text(
                                                                          "${building.localArea.toString()} ${building.districtName.toString()}, ${building.regionName.toString()}",
                                                                          maxLines:1,overflow: TextOverflow.ellipsis,
                                                                          style:const TextStyle(
                                                                              fontSize:
                                                                                  12,fontWeight: FontWeight.w500 )),
                                                            ),
                                                            Text(date,style:const TextStyle(fontSize: 12,color:kGreyColor))
                                                          ],
                                                        ),
                                                 
                                                  ],
                                                )
                                              ) 
                                               ],
                                            ),
                                          ]),
                                        ),
                                        Container(
                                          padding:const EdgeInsets.all(2),
                                          width:40,
                                         child: Column(
                                          children:[
                                           Container(
                                            decoration:BoxDecoration(
                                              border: Border.all(
                                                color:kGreyColor
                                              )
                                            ),
                                             child: Column(
                                               children: [
                                              FittedBox(child: Text(building.userRole==0?"Dalali":"Mmiliki",
                                                         maxLines: 1,overflow: TextOverflow.ellipsis,
                                                         style:TextStyle(color:kAppColor,fontSize: 10,fontWeight: FontWeight.bold))), 
                                                Container(
                                            height: 40,
                                            child: FloatingActionButton(
                                            heroTag: UniqueKey(),
                                           onPressed: () {
                                            Navigator.push(context, PageTransition(
                                            duration: const Duration(milliseconds: 200),
                                            child:OwnerInfoScreen(building) , type: PageTransitionType.rightToLeft));
                                      },
                                      mini: true,
                                      elevation: 0,
                                    child: Container(
                                        decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: kAppColor,width: 2),
                                      image: DecorationImage(image: NetworkImage(building.ownerInfo!['photo'] ))
                                    ),
                                  ),
                              ),
                                          ),
                                                         const SizedBox(height: 5,),
                                                           CircleAvatar(
                                                            radius: 13,
                                                            backgroundColor: Colors.transparent,
                                                             child: IconButton(onPressed: ()async{
                                                              
                                                              if(_auth.currentUser!=null && _auth.currentUser!.isAnonymous==false){
                                                                if(_auth.currentUser!.uid!=building.userId){
                                                                  UserReplyWindowsApi().showLoadingDialog(context);
                                                                  await _usersRef.child(building.userId).once().then((val)async{
                                                                        Map<dynamic,dynamic> receiverInfo = val.value as Map<dynamic,dynamic>;
                                                                        Navigator.pop(context);
                                                                        if(receiverInfo != null || receiverInfo.isNotEmpty){                                                                      
                                                                           Navigator.push(context,PageTransition(child: ChatMessagesScreen(receiverInfo,_auth.currentUser!.uid ,building), type: PageTransitionType.rightToLeft));  
                                                                        }else{
                                                                          UserReplyWindowsApi().showToastMessage(context,"Hatuna taarifa za mmiliki wa mali hii");
                                                                        }

                                                                });    
                                                        
                                                                }else{
                                                                  UserReplyWindowsApi().showToastMessage(context,"Mali hii inamilikiwa na akaunti yako, huwezi chati"); 
                                                                }                                           
                                                              }else{
                                                                UserReplyWindowsApi().showAuthInfoDialog("Jisajili au ingia kwenye akaunti yako kwanza ili kuchati na wamiliki",context);
                                                              }
                                                                                                                                                         
                                                             },padding:const EdgeInsets.all(0), icon:const Icon(Icons.message)),
                                                           ),
                                                           CircleAvatar(
                                                            radius: 13,
                                                            backgroundColor: Colors.transparent,
                                                             child: IconButton(onPressed: ()async{                                
                                                               if(_auth.currentUser!.isAnonymous==false){
                                                                if(building.ownerInfo!['email'].isNotEmpty){
                                                                   String uri="mailto:${building.ownerInfo!['email']}?subject=Habari yako ${building.ownerInfo!['name'].toString().split(" ")[0]}";
                                                                      if(await canLaunch(uri)){
                                                                      await launch(uri);
                                                                      }else{
                                                                        UserReplyWindowsApi().showToastMessage(context,"Imeshindikana kufungua gmail kwa sasa!!");
                                                                      }            
                                                                }else{
                                                                  UserReplyWindowsApi().showToastMessage(context,"Mmiliki wa mali hii hajaweka barua pepe yake!!");
                                                                }
                                                        
                                                               }else{
                                                                UserReplyWindowsApi().showAuthInfoDialog("Jisajili au ingia kwenye akaunti yako kwanza ili kutuma ujumbe wa barua pepe",context);
                                                               }                                                                                         
                                                             },padding:const EdgeInsets.all(0), icon:const Icon(Icons.email)),
                                                           ),
                                                           CircleAvatar(
                                                            radius: 13,
                                                            backgroundColor: Colors.transparent,
                                                             child: IconButton(onPressed: ()async{
                                                               if(await canLaunch("tel:"+building.ownerInfo!["phone"].toString())){
                                                                 await launch("tel:"+building.ownerInfo!["phone"].toString());
                                                               }                                                                                             
                                                             },padding:const EdgeInsets.all(0), icon:const Icon(Icons.phone_in_talk)),
                                                           ),const SizedBox(height:5),
                                          
                                             ],),
                                           ),
                                            Builder(
                                                    builder: (context){
                                                      bool _isLiked=building.likes.contains(_auth.currentUser!.uid)?true:false;
                                                      return LikeButton(
                                                        likeCount: building.likes.length,
                                                        isLiked:_isLiked,  
                                                        countPostion:CountPostion.bottom,
                                                        
                                                        onTap:(liked)async{
                                                          bool success=false;
                                                           if(_auth.currentUser!.isAnonymous==false || _auth.currentUser==null){
                                                            if(_isLiked==true){
                                                              await _propertiesRef.doc(building.id).update({"likes":FieldValue.arrayRemove([_auth.currentUser!.uid])}).then((value){
                                                              success=true;
                                                              setState(() {
                                                                 _buildingsList[_currentIndex].likes.remove(_auth.currentUser!.uid);
                                                              });
                                                            });
                                                            }else{
                                                             await _propertiesRef.doc(building.id).update({"likes":FieldValue.arrayUnion([_auth.currentUser!.uid])}).then((value){
                                                              success=true;
                                                               setState(() {
                                                                 _buildingsList[_currentIndex].likes.add(_auth.currentUser!.uid);
                                                              });
                                                            });
                                                            }
                                                            
                                                          }else{
                                                          //showAuthInfoDialog("Jisajili au ingia kwenye akaunti yako ya betterhouse ili ukamilishe kitendo hiki");
                                                          } 
                                                          return success?!_isLiked:_isLiked;
                                                        },
                                                        countBuilder: (count,isLiked,text){
                                                           return Text(text,style:TextStyle(color:isLiked?Colors.purple:Colors.black));
                                                        },
                                                      );
                                                    }
                                                        ),
                                              CircleAvatar(
                                                    radius: 13,
                                                    backgroundColor: Colors.transparent,
                                                     child: IconButton(onPressed: ()async{
                                                      await Share.share("Mali hii(utambulisho:${building.id}) imepostiwa kwenye betterhouse pakua app na fungua utazame ${building.coverImage}"); 
                                                      },padding:const EdgeInsets.all(0), icon:const Icon(Icons.share)),
                                                   ),const SizedBox(width:5), ]
                                         ),
                                         ),
                                      ],
                                    ),
                                  );
                            }),
                            _isFetchingNext==true && _isLoadingFirstTime==false? const Align(
                            alignment: Alignment.bottomCenter,
                            child:SizedBox(width: 20,height: 20,
                              child: CircularProgressIndicator(),
                            ),
                          ):Container(),
                      ],
                    )
 ;
  }
}