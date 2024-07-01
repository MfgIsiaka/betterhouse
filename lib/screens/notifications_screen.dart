import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  var currentUser;
  NotificationsScreen(this.currentUser,{ Key? key }) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
final DatabaseReference _foundRentalNotificationsRef=FirebaseDatabase.instance.reference().child("FOUND RENTAL NOTIFICATIONS");
final DatabaseReference _usersRef=FirebaseDatabase.instance.reference().child("USERS");
String today=DateTime.now().toString().substring(0,10);
String prevDate="";
  //15:03 2,15:4-15:20 3, 15:21-
  @override
  Widget build(BuildContext context){
    Size screenSize=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Taarifa"),
      ),
      body:const Center(child: Text("Hakuna taarifa kwa sasa",style:TextStyle(fontWeight: FontWeight.bold,fontSize:18))),
      //   appBar:AppBar(
      //     //backgroundColor: Colors.white,
      //     title:const Text("Taarifa"),
      //   ),
      // body: StreamBuilder(
      //   stream: _foundRentalNotificationsRef.orderByChild("user").equalTo(widget.currentUser["id"]).onValue,
      //   builder: (context,AsyncSnapshot<Event> snap){
      //   if(snap.connectionState==ConnectionState.done || snap.connectionState==ConnectionState.active){
      //         if(snap.data!.snapshot.value !=null){
      //           List<RentalFoundNotificationModal> notificationWidgets=[];
      //          snap.data!.snapshot.value.forEach((key,val){ 
      //            notificationWidgets.add(
      //              RentalFoundNotificationModal(val["id"],val["matchingRental"],val["user"],val["requestId"],val["time"],val["status"])
      //            );
      //           });
      //         List<RentalFoundNotificationModal> reversednotificationWidgets=notificationWidgets.reversed.toList();
      //         return Container(
      //           child: AnimatedList(
      //           initialItemCount: reversednotificationWidgets.length,
      //           itemBuilder: (context,index,animation){
      //             var notification=reversednotificationWidgets[index];
      //             String date=notification.time.toString().substring(0,10);
      //             //print("Matching "+reversednotificationWidgets.length.toString());
      //             if(index > 0){
      //                 prevDate=reversednotificationWidgets[index-1].time.toString().substring(0,10);
      //              }
      //             return ScaleTransition(
      //               scale: animation,
      //               child: Container(
      //                child: Column(
      //                  children: [
      //                  date==prevDate?Container():Container(
      //                      width: screenSize.width,
      //                      padding:const EdgeInsets.all(5),
      //                      color:Colors.blueGrey,
      //                      child: Row(
      //                        children: [
      //                          Text("Taarifa za ",style: TextStyle(fontSize:18,)),
      //                          date==today?Text("leo ",style: TextStyle(fontSize:17,)):Text("tarehe "+date,style: TextStyle(fontSize:17,))
      //                        ],
      //                      )),
      //                    RaisedButton(
      //                      onPressed: ()async{
      //                         showGeneralDialog(context: context,
      //                         barrierDismissible: true,
      //                         barrierLabel:"rentalDialog",
      //                         //transitionDuration: Duration(seconds: 1),
      //                         pageBuilder: (context,anim1,anim2){
      //                           return RentalDialog(notification); 
      //                         });
                             
      //                      },
      //                      padding: EdgeInsets.all(0),
      //                      child: Container(
      //                        padding:const EdgeInsets.all(5),
      //                        decoration: BoxDecoration(
      //                          color:notification.status=="unseen"? Colors.white:Colors.black12,
      //                          border:const Border(
      //                            bottom: BorderSide(color: Colors.grey,width: 2)
      //                          )
      //                        ),
      //                        child: Text.rich(TextSpan(
      //                          children:[
      //                            TextSpan(
      //                              text:date==prevDate?"":"Habari ",
      //                              style:const TextStyle(color: kAppColor,fontSize: 15,fontWeight: FontWeight.bold)
      //                            ),
      //                            TextSpan(
      //                            text: "${widget.currentUser["firstName"].toString()}.. \n",
      //                           style:const TextStyle(color: kAppColor,fontSize: 15,fontWeight: FontWeight.bold)
      //                          ),const TextSpan(
      //                            text: " Tumepata pango lenye vigezo ulivyo tuambia ",
      //                           style: TextStyle(fontSize: 15)
      //                          ),
      //                           TextSpan(
      //                           text: date==today?"leo ":" tarehe $date ",
      //                           style:const TextStyle(fontSize: 15)
      //                          ),const TextSpan(
      //                            text: "tunaamini utapenda changamkia kabla halijachukuliwa.",
      //                           style: TextStyle(fontSize: 15)
      //                          ),
      //                          ]
      //                        ))
      //                        ),
      //                    )
      //                  ],
      //                ),
      //                                ),
      //             );
      //           }),
      //           );
      //         }
      //         else{
      //           return const Center(child:Text("Hatuna taarifa yoyote kwa sasa"));
      //         }    
      //   }else{
      //        return const Center(
      //                       child:SpinKitThreeBounce(
      //                         color:kAppColor
      //                       )
      //                     );
      //   }
      // })
    );
  }
}

// class RentalDialog extends StatefulWidget {
//  RentalFoundNotificationModal notification;

//  RentalDialog(this.notification,{ Key? key }) : super(key: key);

//   @override
//   _RentalDialogState createState() => _RentalDialogState();
// }

// class _RentalDialogState extends State<RentalDialog> {
// final DatabaseReference _rentalsRef=FirebaseDatabase.instance.reference().child("RENTALS");
// final DatabaseReference _foundRentalNotificationsRef=FirebaseDatabase.instance.reference().child("FOUND RENTAL NOTIFICATIONS");
// final DatabaseReference _usersRef=FirebaseDatabase.instance.reference().child("USERS");
// String _rentalStatus="";
// HouseAndBuilding? _rental;

// Future<void> getCurrentRental()async{
//    await _rentalsRef.child(widget.notification.matchingRental).once().then((DataSnapshot val){
//                               if(val.value !=null){
//                               var rental=val.value;  
//                                   setState(() {
//                                  _rental=HouseAndBuilding(rental["id"], rental["coverImage"], rental["productPrice"], rental["localArea"],rental["rentalCharge"], rental["imageCount"]);
//                               });
//                               }else{
//                                 setState(() {
//                                   _rentalStatus="No";
//                                 });
//                               }
//                           });
// }

// Future<void> decrementCounter()async{
//   if(widget.notification.status=="unseen"){
//      await _foundRentalNotificationsRef.child(widget.notification.id).update({"status":"seen"}).then((value)async{
//         await _usersRef.child(widget.notification.user).update({"rentalFoundNotifications":ServerValue.increment(-1)});
//       });
//   }
// }

// @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     decrementCounter();
//     getCurrentRental();
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     Size screenSize=MediaQuery.of(context).size;
//      return Center(
//       // backgroundColor:rental=="No"?Colors.white:Colors.transparent,
//       // contentPadding: EdgeInsets.all(10),
//       child: Scaffold(
//         backgroundColor:Colors.transparent,
//         body: Center(
//           child: Container(
//             width: screenSize.width,
//             child: AnimatedSwitcher(
//               duration:const Duration(milliseconds: 1000),
//               child:_rental!=null? _rentalStatus=="No"?Container(padding:const EdgeInsets.all(10), color: Colors.white, child:const Text("Pango husika halipo, mmiliki wake ameliondoa",style: TextStyle(fontSize: 15),)):
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(onPressed: (){
//                     Navigator.pop(context);
//                   }, icon:const Icon(Icons.cancel_outlined,size: 40,color: Colors.black,)),
//                   Container(
//                                   height:200,width: screenSize.width,
//                                   padding:const EdgeInsets.all(3),
//                                   decoration:BoxDecoration(
//                                     color: Colors.white,
//                                     boxShadow:const [ 
//                                       BoxShadow(
//                                         blurRadius: 5,
//                                         spreadRadius: 2,
//                                         color: Colors.black
//                                       )
//                                     ],
//                                     border: Border.all(
//                                       color: Colors.grey
//                                     ),
//                                     borderRadius:const BorderRadius.only( 
//                                       bottomLeft: Radius.circular(20),
//                                       bottomRight:Radius.circular(20), 
//                                     ),
//                                   ),
//                                   child:Column(
//                                        children: [
//                                        GestureDetector(
//                                         onTap: (){
//                                         Navigator.push(context,PageTransition(child: ImageViewingScreen("1",_rental!), type:PageTransitionType.fade));
//                                        },
//                                         child: Container(
//                                           height: 150,
//                                           padding:const EdgeInsets.only(bottom:5),
//                                           child: Row(
//                                             crossAxisAlignment:CrossAxisAlignment.stretch,
//                                             children:[
//                                               Expanded(
//                                                 child: Hero(
//                                                   tag: "1",
//                                                   child: Container(
//                                                     color: Colors.blueGrey,
//                                                     child: CachedNetworkImage(
//                                                     fit:BoxFit.fill,
//                                                     errorWidget: (context,string,dyna)=>Center(child: Icon(Icons.error)),
//                                                     placeholder: (context,sms)=> Center(child: Container(width: 30,height:30, child: CircularProgressIndicator())),
//                                                     imageUrl: _rental!.images[0])),
//                                                 ),
//                                               ),Container(width: 3,color: Colors.white,),Expanded(
//                                                 child: Container(
//                                                   color: Colors.blueGrey, 
//                                                   child:_rental!.images.length<2?Container() : CachedNetworkImage(
//                                                     fit:BoxFit.fill,
//                                                     errorWidget: (context,string,dyna)=>Center(child: Icon(Icons.error)),
//                                                     placeholder: (context,sms)=> Center(child: Container(width: 30,height:30, child: CircularProgressIndicator())),
//                                                     imageUrl: _rental!.images[1])),
//                                               ),
//                                             ]
//                                           ),
//                                         ),
//                                       ),
//                                       Expanded(child: Container(
//                                    decoration:const BoxDecoration(
//                                     borderRadius: BorderRadius.only(
//                                       bottomLeft: Radius.circular(20),
//                                       bottomRight:Radius.circular(20), 
//                                     ),
//                                       ),
//                                        child: Row(
//                                          children: [
//                                            Container(
//                                             padding:const EdgeInsets.all(3),
//                                             decoration:const BoxDecoration(
//                                               color: Colors.black54,
//                                               borderRadius:BorderRadius.only(
//                                               bottomLeft: Radius.circular(15),
//                                               topRight: Radius.circular(15),
//                                             )),
//                                             child: Row(children: [
//                                             const Icon(Icons.camera_alt_rounded, color:Colors.white),Text((_rental!.images.length-1).toString() + "+",style:const TextStyle( color:Colors.black))
//                                             ],),),
//                                            Expanded(
//                                              child: Container(
//                                               // color: Colors.red,
//                                                margin:const EdgeInsets.only(left: 10,top: 3,bottom: 3),
//                                                child: Column(
//                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                  crossAxisAlignment: CrossAxisAlignment.start,
//                                                  children: [
//                                                    Text(_rental!.localArea.toString(),
//                                                    maxLines: 1,
//                                                    style:const TextStyle(fontWeight: FontWeight.w600,overflow: TextOverflow.ellipsis,color: Colors.black),),
//                                                    Text("Kodi: Tsh ${_rental!.rentalCharge[0].toString()} @ ${_rental!.rentalCharge[1].toString()}",style:const TextStyle(color: Colors.black,fontSize: 12,overflow: TextOverflow.ellipsis),)
//                                                  ],
//                                                ),
//                                              ),
//                                            ),Container(
//                                              margin:const EdgeInsets.only(right: 5),
//                                              //color: Colors.blueGrey,
//                                                            child: TextButton.icon(onPressed: (){
//                                                            Navigator.push(context,PageTransition(child: RentalDetailsToClientScreen(_rental!), type:PageTransitionType.fade));   
//                                                            }, icon:const Icon(Icons.folder_open), label:const  Text("Ona zaidi"),),
//                                                          )
//                                          ],
//                                        ),
//                                     ))
//                                     ],
//                                   )
//                                 ),
//                 ],
//               ):ShowUpAnimation(
//                 key: UniqueKey(),
//                 animationDuration:const Duration(milliseconds: 200),
//                 child: Container(
//                   height: 30,
//                 child:const SpinKitThreeBounce(
//                   color:kAppColor
//                 ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//       );
//   }
// }

