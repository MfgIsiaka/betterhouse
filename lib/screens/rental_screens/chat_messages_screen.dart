
import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/screens/rental_screens/owner_info_screen.dart';
import 'package:betterhouse/screens/rental_screens/rental_details_screen_to_client.dart';
import 'package:betterhouse/services/database_services.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/modal_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_db_cache/firebase_db_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_8.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:show_up_animation/show_up_animation.dart';

class ChatMessagesScreen extends StatefulWidget {
  var recever,myId;
  PropertyInfo propertyInfo;
  ChatMessagesScreen(this.recever,this.myId,this.propertyInfo,{ Key? key }) : super(key: key);

  @override
  _ChatMessagesScreenState createState() => _ChatMessagesScreenState();
}

class _ChatMessagesScreenState extends State<ChatMessagesScreen> {
final FirebaseAuth _auth=FirebaseAuth.instance;
final DatabaseReference _chatsRef=FirebaseDatabase.instance.reference().child("MESSAGES");
final DatabaseReference _usersRef=FirebaseDatabase.instance.reference().child("USERS");
final DatabaseReference _chatRoomsRef=FirebaseDatabase.instance.reference().child("CHATROOMS");
DatabaseReference? _usersSmsStatusRef;
final _smsTextController=TextEditingController();
final _scrollController=ScrollController();
final _dbCache=FirebaseDbCache();
int unseenSmsNo=0;
Query? _query;
final ValueNotifier<String> _onlineStatus = ValueNotifier("");
final ValueNotifier _isSending=ValueNotifier<bool>(false);

Future<void> getMessages()async{
  _query= _chatsRef.child(widget.propertyInfo.id.toString());
}
 
void getCurrentUser(){
   _usersRef.child(widget.recever["id"]).onValue.listen((event) {
     var res=event.snapshot.value["onlineStatus"];
      if(res=="Online"){
     _onlineStatus.value=res.toString();
      }else{
      String date= "";
          Duration difference= DateTime.now().difference(DateTime.parse(res.toString()));    
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
  _onlineStatus.value="Ameonekana "+ date+" nyuma";        
      }
  });
}

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _usersSmsStatusRef=FirebaseDatabase.instance.reference().child("USERS").child(widget.myId);
    //getMessages();
    getCurrentUser();
}

  @override
  Widget build(BuildContext context){
    Size screenSize = MediaQuery.of(context).size;
    if(_scrollController.hasClients){
           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    AppDataProvider dataProvider=Provider.of<AppDataProvider>(context,listen: false);
   int index=-1;
    return Scaffold(
      body:Container(
        color:const Color.fromARGB(140, 157, 158, 192),
        child: Column(
          children: [
            Container(
              //height: 85,
                decoration:const BoxDecoration(
                  color:kWhiteColor,
                  borderRadius: BorderRadius.only(
                    bottomRight:Radius.circular(40)
                  )
                 ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SafeArea(
                    //0688895154
                    child: ListTile(
                      dense: false,
                      contentPadding:const EdgeInsets.only(left:3,right: 20),
                      visualDensity:const VisualDensity(horizontal: -3,vertical:-3),
                      trailing: GestureDetector(
                        onTap:(){
                          Navigator.push(context, PageTransition(
                            duration: const Duration(milliseconds: 300),
                            child: BuildingDetailsToClientScreen(widget.propertyInfo), type: PageTransitionType.rightToLeft));
                        },
                        child: AbsorbPointer(
                          child: CachedNetworkImage(imageUrl:widget.propertyInfo.coverImage,
                          ),
                        ),
                      ),     
                            title: Text("${widget.recever["firstName"]} ${widget.recever["lastName"]}",overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize: 18,fontWeight:FontWeight.bold),),
                            leading:Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              GestureDetector(
                                onTap: (){
                                  Navigator.pop(context);
                                },
                                child: const AbsorbPointer(child: Icon(Icons.arrow_back))),
                                FloatingActionButton(
                                  heroTag: "owner",
                                    onPressed: () {
                                    Navigator.push(context,PageTransition(child: OwnerInfoScreen(widget.propertyInfo), type: PageTransitionType.rightToLeft));
                                    },
                                    mini: false,
                                    elevation: 0,
                                  child: Container(
                                      width: 120,height:120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(image: NetworkImage(widget.recever["profilePhoto"]))
                                      ),
                                    ),
                                ),
                              ],
                            ),
                            subtitle: SizedBox(
                              height: 20,width: 100,
                              child: ValueListenableBuilder(valueListenable: _onlineStatus, builder:(context,val,child){
                              return Marquee(
                              text: _onlineStatus.value.isEmpty?" ":_onlineStatus.value.toString(),
                              style: TextStyle(color: kAppColor,fontWeight: FontWeight.bold),
                              blankSpace: 50,
                              pauseAfterRound:const Duration(seconds: 4),
                              startAfter:const Duration(seconds: 4));
                              }
                              ),
                            )
                          ),
                  ),
                ),       
              ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    color: kWhiteColor,
                    width: screenSize.width,
                  ),
                  Container(                
                    decoration:const  BoxDecoration(
                      color:Color.fromARGB(140, 157, 158, 192),
                      borderRadius:BorderRadius.only(
                        topLeft: Radius.circular(50)
                      )
                    ),
                    child: Stack(
                      children: [
                        Container(
                          padding:const EdgeInsets.only(left: 5,right: 5,bottom:50,top:40),
                          child:StreamBuilder(
                            stream: _chatsRef.child(widget.propertyInfo.id).orderByChild("time").onValue,
                            builder: (context,AsyncSnapshot<Event> snap){
                              List<Message> messages=[];
                             // return Text(snap.connectionState.name);
                               if(snap.connectionState==ConnectionState.done || snap.connectionState==ConnectionState.active){
                                  if(snap.data!.snapshot.value !=null){
                                    snap.data!.snapshot.value.forEach((k,val){
                                      if((val["sender"]==widget.myId && val["receiver"]==widget.recever["id"]) || (val["receiver"]==widget.myId && val["sender"]==widget.recever["id"])){
                                       DateTime date=DateTime.fromMillisecondsSinceEpoch(val["time"]);
                                       messages.add(Message(val["id"],val["propertyId"],val["sender"],val["receiver"],val["message"],val["seenStatus"],date,DateFormat('dd/MM/yyyy').format(date)));
                                      } 
                                    });
                                    //decrementUnreadSms();l,r,3
                                    return GroupedListView<Message,dynamic>(   
                                      elements: messages, 
                               
                                      floatingHeader: true,
                                      controller: _scrollController,   
                                      groupSeparatorBuilder: (smsDate)=>Center(child: Text(smsDate,style: const TextStyle(fontWeight: FontWeight.bold),))
                                      ,groupBy: (Message el)=>el.date,             
                                      itemBuilder: (BuildContext context,Message message){
                                       index++;
                                        if(message.sender!=widget.myId && message.seenStatus=="unseen"){
                                          Future.wait([
                                            notifySmsRead(message)
                                          ]);
                                      }
                                       return ShowUpAnimation(
                                         delayStart: Duration(milliseconds: 50*index),
                                         child: Column(
                                           crossAxisAlignment:message.sender==widget.myId? CrossAxisAlignment.start:CrossAxisAlignment.end,
                                           children: [
                                             ChatBubble(
                                             shadowColor: Colors.black,
                                             //margin:const EdgeInsets.only(bottom: 2),
                                             clipper: ChatBubbleClipper8(type:message.sender==widget.myId?BubbleType.sendBubble:BubbleType.receiverBubble),
                                             alignment:message.sender==widget.myId?Alignment.topLeft:Alignment.topRight,
                                             backGroundColor:message.sender==widget.myId?const Color.fromARGB(255, 8, 45, 75):kWhiteColor,
                                             child: Text(message.message,style:TextStyle(color:message.sender==widget.myId? kWhiteColor:Colors.black),),
                                             ),Row(
                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                               mainAxisSize: MainAxisSize.min,
                                               children: [
                                                Text(DateFormat("hh:mm a").format(message.time).toString(),style:const TextStyle(fontSize:10,)),
                                                message.sender!=widget.myId?Container():Icon(Icons.done_all,size:19,color:message.seenStatus=="unseen"?Colors.grey: kAppColor,)
                                               ],
                                             )
                                           ],
                                         ),
                                       );
                                    });
                                  }else{
                                       return Center(child: Text("Anza mazungumzo na "+widget.recever["firstName"]),); 
                                  }
                               }else{
                                   return UserReplyWindowsApi().showLoadingIndicator();
                               } 
                          })
                        ),
                       
                        Align(
                          alignment:Alignment.bottomCenter,
                          child: Container(      
                                 color: Colors.transparent,
                                 constraints:const BoxConstraints(minHeight: 20),
                                 padding:const EdgeInsets.all(2),
                                 child: Row(
                                   children: [
                                     Expanded(
                                       child: Container(
                                        decoration:BoxDecoration(
                                          color: kWhiteColor,
                                          boxShadow:const [
                                            BoxShadow(
                                              color: Colors.black,
                                              blurRadius: 5
                                            )
                                          ],
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                         child: TextFormField(
                                           minLines: 1,maxLines: 5,
                                           controller: _smsTextController,
                                          decoration: InputDecoration(
                                            contentPadding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                            hintText: "Andika ujumbe hapa",
                                            border:OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(30)
                                            )
                                          ),
                                         ),
                                       ),
                                     ),SizedBox(
                                       width: 50,
                                       child: Transform.rotate(angle: -(3.142/4),
                                         child: FloatingActionButton(
                                           onPressed:()async{
                                             if(_smsTextController.text.trim().isEmpty){
                                               UserReplyWindowsApi().showToastMessage(context,"Andika ujumbe kwanza");
                                             }else{
                                               DateTime now=DateTime.now();
                                               Map<String,dynamic> userNames={
                                                 "senderName":"${dataProvider.currentUser["firstName"]} ${dataProvider.currentUser["lastName"]}",
                                                 "senderPhoto":"${dataProvider.currentUser["profilePhoto"]}",
                                                 
                                                 "receiverName":"${widget.recever["firstName"]} ${widget.recever["lastName"]}",
                                                 "receiverPhoto":"${widget.recever["profilePhoto"]}", 
                                               };
                                               Map<String,dynamic> smsInfo={
                                                 "propertyId":widget.propertyInfo.id,
                                                 "sender":widget.myId,
                                                 "receiver":widget.recever["id"],
                                                 "message":_smsTextController.text,
                                                 "seenStatus":"unseen",
                                                 "time":now.millisecondsSinceEpoch
                                               };
                                                if(_scrollController.hasClients){
                                                  _scrollController.animateTo(_scrollController.position.maxScrollExtent,duration: const Duration(seconds: 3),curve:Curves.bounceIn);
                                                }
                                                _smsTextController.clear();
                                                String res=await DatabaseApi().sendMessage(smsInfo,userNames);
                                                 UserReplyWindowsApi().showToastMessage(context,res);
                                             }
                                           },
                                           mini: true,
                                           child:ValueListenableBuilder(valueListenable: _isSending , builder:(context,val,child){
                                            return _isSending.value==true?const CircularProgressIndicator(color: Colors.white,):const Icon(Icons.send);
                                           })),
                                       ),
                                     )
                                   ],
                                 ),
                               ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }

  Future<void> notifySmsRead(Message message) async{
    DatabaseReference toMyChatRoom=_chatRoomsRef.child(widget.myId).child(widget.propertyInfo.id+"_"+widget.recever["id"]);
    DatabaseReference toHisChatRoom=_chatRoomsRef.child(widget.recever["id"]).child(widget.propertyInfo.id+"_"+widget.myId);
        //  await toMyChatRoom.once().then((value){
        //    print(value.value);
        //   });
                   
          await toMyChatRoom.child("unseenSms").runTransaction((mutableData){
              if(mutableData.value >0){                              
                mutableData.value=ServerValue.increment(-1);
              }
              return mutableData;
           }).then((value)async{
             await toMyChatRoom.child("seenStatus").runTransaction((mutableData){
                mutableData.value="seen";
              return mutableData;
             });
               await toHisChatRoom.child("seenStatus").runTransaction((mutableData){
                mutableData.value="seen";
              return mutableData;
           }).then((value)async{          
           await _chatsRef.child(message.rentalId).child(message.id).child("seenStatus").runTransaction((MutableData mutableData){
                mutableData.value="seen";
                return mutableData;
            });
           });
           await toMyChatRoom.once().then((value)async{
             if(value.value!=null){
                 if(value.value["unseenSms"]==0){
                 await _usersRef.child(widget.myId).child("unseenChats").runTransaction((mutableData){
                    if(mutableData.value >0){
                        mutableData.value=ServerValue.increment(-1);
                      }
                      return mutableData;
                  });
                 }   
              }
           });
           });

   }
}