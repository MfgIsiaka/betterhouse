
import 'package:badges/badges.dart';
import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/screens/rental_screens/chat_messages_screen.dart';
import 'package:betterhouse/services/modal_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class MyChatsScreen extends StatefulWidget {
   MyChatsScreen({ Key? key }) : super(key: key);

  @override
  _MyChatsScreenState createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  final CollectionReference<Map<String, dynamic>> _propertiesRef=FirebaseFirestore.instance.collection("PROPERTIES");
  final DatabaseReference _chatRoomsRef=FirebaseDatabase.instance.reference().child("CHATROOMS");
  final DatabaseReference _usersRef=FirebaseDatabase.instance.reference().child("USERS");
  late AppDataProvider dataProviderListen;
  final _auth=FirebaseAuth.instance;  
  var _userId;

  @override
  Widget build(BuildContext context) {
   dataProviderListen= Provider.of<AppDataProvider>(context, listen: false);
    Size screenSize=MediaQuery.of(context).size;
    _userId=_auth.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title:const Text("Jumbe zako")
      ),
     body: SizedBox(
       width: screenSize.width,
       height: screenSize.height,
       child:StreamBuilder(
                            stream: _chatRoomsRef.child(_auth.currentUser!.uid).orderByChild("time").onValue,
                            builder: (context,AsyncSnapshot<Event> snap){
                              if(snap.connectionState==ConnectionState.active || snap.connectionState==ConnectionState.done){
                                 var chatroomsFromDb=snap.data!.snapshot.value;
                                 if(chatroomsFromDb !=null){
                                   List<ChatRoom> chatRooms=[];
                                  // List<Map<String,dynamic>> _userAcountList=[];
                                   chatroomsFromDb.forEach((key,val)async{
                                    DateTime date=DateTime.fromMillisecondsSinceEpoch(val["time"]);
                                    ChatRoom chatRoom=ChatRoom(val["personName"],val["chatRoomId"],val["smsId"] ,val["message"] ,val["sender"] ,val["receiver"] ,val["propertyId"] ,val["seenStatus"] ,date,val["unseenSms"],val['personPhoto']);              
                                    chatRooms.add(chatRoom);                                     
                                    });
                                    chatRooms=chatRooms.reversed.toList();
                           return ListView.builder(
                            itemCount: chatRooms.length,
                            itemBuilder: (context,index){
                            var chatRoom=chatRooms[index];
                            String date= "";
                            Duration difference= DateTime.now().difference(chatRoom.time);    
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
                               date="Muda huu";  
                            } 
                               var hisId="";
                                    if(chatRoom.sender==_auth.currentUser!.uid){
                                        hisId=chatRoom.receiver;
                                    }else{
                                      hisId=chatRoom.sender;
                                    }
                            return Container(
                               decoration:const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey
                                  )
                                )
                               ),
                               child: ListTile(
                                onTap: ()async{
                                 var chatUserId;
                                 if(chatRoom.sender==_userId){
                                   chatUserId=chatRoom.receiver;
                                 }else{
                                   chatUserId=chatRoom.sender;
                                 }
                                 UserReplyWindowsApi().showLoadingDialog(context);
                                 await _usersRef.child(chatUserId).once().then((val)async{
                                  var user= val.value;
                                  await _propertiesRef.doc(chatRoom.rentalId).get().then((value){
                                    var data=value.data();
                                      Navigator.pop(context);
                                      if(user!=null && data!=null){
                                         PropertyInfo building = PropertyInfo(
                                        id:data["id"],
                                        ownerInfo:data["ownerInfo"],
                                        specificInfo:data["houseOrLand"]==0 && data["purpose"]==0?
                                        CommercialBuilding(data["buildingClass"], data["buildingType"],data["subBuildingType"]):
                                        data["houseOrLand"]==0 && data["purpose"]==1?
                                        ResidentBuilding(data["buildingType"], data["buildingStatus"],data["bedRooms"] ,data["livingRooms"] ,data["diningRooms"] ,data["kitchenRooms"] ,data["storeRooms"] ,data["selfRooms"],data["bathRooms"]) :PropertyInfo(),
                                        operation:data["operation"],
                                        userRole:data["userRole"],
                                        houseOrLand:data["houseOrLand"],
                                        purpose:data["purpose"],
                                        hasFens:data["hasFens"],
                                        hasParking:data["hasParking"],
                                        areaDimension:data["areaDimension"],
                                        areaSize:data["areaSize"],
                                        socialServices:data["socialServices"],
                                        brokerPayCurrency:data["brokerPayCurrency"],
                                        brokerSalary:data["brokerSalary"],
                                        userId:data["userId"],
                                        internalViews:data["internalViews"],
                                        likes:data["likes"],
                                        payCurrency:data["payCurrency"],
                                        buildingBillAmount:data["buildingBillAmount"],
                                        minBillPeriod:data["minBillPeriod"],
                                        billPeriodsNumber:data["billPeriodsNumber"],
                                        propertyPriceAmount:data["propertyPriceAmount"],
                                        imageCount:data["imageCount"],
                                        coverImage:data["coverImage"],
                                        country:data["country"],
                                        region:data["region"],
                                        regionName:data["regionName"],
                                        district:data["district"],
                                        districtName:data["districtName"],
                                        localArea:data["localArea"],
                                        latlong:data["latlong"],
                                        insideServices:data["insideServices"]
                                        );
                                        Navigator.push(context,PageTransition(child:ChatMessagesScreen(user, _userId,building), type: PageTransitionType.rightToLeft));   
                                      }else{
                                        UserReplyWindowsApi().showToastMessage(context,"Kunatizo katika kupakua data");
                                      }
                                  });
                                 });                                                  
                                },
                                visualDensity:const VisualDensity(vertical: -3),
                                leading: Container(
                                  height: 55,width: 55,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(image: NetworkImage(chatRoom.profilePhoto))
                                      ),
                                    ),
                                subtitle: Row(
                                  children:[
                                     Expanded(
                                       flex: 2,
                                       child: Row(
                                       children: [
                                       chatRoom.sender!=_userId?Container():Icon(Icons.done_all_outlined,size: 18, color: chatRoom.seenStatus=="unseen"?Colors.grey:Colors.blue,),
                                         Expanded(child: Text(chatRoom.message.toString(),overflow: TextOverflow.ellipsis,)),
                                       ],
                                     )),
                                     Expanded(flex: 1,child: Row(
                                       children: [
                                         const Spacer(),
                                         Text(date,overflow: TextOverflow.ellipsis,),
                                       ],
                                     )),
                                  ]
                                ),
                                horizontalTitleGap: 8,
                                title:Stack(
                                  children: [
                                    Text(chatRoom.personName.toString(),style:const TextStyle(color:Colors.black)),
                                    chatRoom.unseenSms==0?Container():Align(
                                      alignment: Alignment.centerLeft,
                                      child: Badge(
                                        badgeColor: Colors.green,
                                        badgeContent: Text(chatRoom.unseenSms.toString()),
                                        child: Container()),
                                    )
                                  ],
                                )));
                              });
                                 }else{
                                   return const Center(child: Text("Hakuna aliyekutafuta kwa sasa!!"));
                                 }
                              }else{
                                return UserReplyWindowsApi().showLoadingIndicator();
                              }
                            })
               ),
  
    );
  }
}