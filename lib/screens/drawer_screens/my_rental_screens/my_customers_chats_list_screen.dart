import 'package:betterhouse/services/modal_services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MyCustomerChatListScreen extends StatefulWidget {
  PropertyInfo rental;
  var myId;
   MyCustomerChatListScreen(this.rental,this.myId,{Key? key }) : super(key: key);

  @override
  _MyCustomerChatListScreenState createState() => _MyCustomerChatListScreenState();
}

class _MyCustomerChatListScreenState extends State<MyCustomerChatListScreen> {
  final DatabaseReference _chatsRef=FirebaseDatabase.instance.reference().child("CHATS");
  final DatabaseReference _usersRef=FirebaseDatabase.instance.reference().child("USERS");
  List<String> customerIds=[];
  List<Widget> customersWidget=[];
  @override
  Widget build(BuildContext context){
     Size screenSize=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title:const Text("Walio kutafuta"),
      ),
      // body: FutureBuilder(
      //   future: _chatsRef.child(widget.rental.id).once(),
      //   builder: (context,AsyncSnapshot snap1){
      //        if(snap1.connectionState==ConnectionState.done){
      //           if(snap1.hasData){
      //             if(snap1.data.value!=null){
      //                snap1.data.value.forEach((k,message){
      //                int exist=0;
      //                    if(message["sender"]!=widget.rental.rentorId){
      //                        if(!customerIds.contains(message["sender"])){
      //                            customerIds.add(message["sender"]);
      //                        }
      //                    }
      //                    if(message["receiver"]!=widget.rental.rentorId){
      //                        if(!customerIds.contains(message["receiver"])){
      //                            customerIds.add(message["receiver"]);
      //                        }
      //                    }
      //              });
      //             }
      //             if(customerIds.isNotEmpty){
      //                  return  FutureBuilder(
      //                    future:_usersRef.get(),
      //                    builder: (context,AsyncSnapshot snap){
      //                      if(snap.connectionState==ConnectionState.done){
      //                          if(snap.hasData){
      //                            customersWidget.clear();
      //                           if(snap.data.value!=null){
      //                             snap.data.value.forEach((k,user){
      //                              if(customerIds.contains(user["id"])){
      //                                Widget userWidget=ListTile(
      //                                  onTap: (){
      //                                    Navigator.push(context,PageTransition(child: ChatMessagesScreen(user, widget.myId,widget.rental.id), type:PageTransitionType.fade));
      //                                  },
      //                                  title: Text(user["firstName"]+"  "+user["lastName"]),
      //                                  subtitle: Text(user["onlineStatus"]),
      //                                  leading: CircleAvatar(child: Text(user["firstName"].toString().substring(0,1).toUpperCase(),style:const TextStyle(fontWeight: FontWeight.bold,)),),
      //                                );
      //                                customersWidget.add(userWidget);
      //                              }
      //                           }); 
      //                           }
      //                           return customersWidget.isEmpty?const Center(child:Text("Hakuna aliekutafuta ")):AnimatedList(
      //                     physics:const BouncingScrollPhysics(),                         
      //                     initialItemCount: customersWidget.length,
      //                     itemBuilder: (context,index,anim){
      //                      var rental=customersWidget[index];
      //              return Container(
      //               margin:const EdgeInsets.only(top: 5,left: 3,right: 2),
      //               decoration:BoxDecoration(
      //                 color: Colors.white,
      //                 boxShadow:const [ 
      //                   BoxShadow(
      //                     blurRadius: 5,
      //                     spreadRadius: 2,
      //                     color: Colors.black
      //                   )
      //                 ],
      //                 border: Border.all(
      //                   color: Colors.grey
      //                 ),
      //                 borderRadius:BorderRadius.circular(10)
      //               ),
      //               child: customersWidget[index]
      //             );
      //                   });
      //                          }else{
      //                            return const Center(child: Text("Hakuna aliekutafuta hadi sasa"));
      //                          }
      //                      }else{
      //                         return const Center(
      //                           child:SpinKitThreeBounce(
      //                             color:kAppColor
      //                           )
      //                         );               
      //                      }  
      //                  });
      //              }else{
      //                return const Center(child: Text("Hakuna aliekutafuta hadi sasa"));
      //              }
      //           }else{
      //             return const Center(child: Text("Hakuna aliekutafuta hadi sasa"));
      //           }
      //        }else{
      //           if(!snap1.hasError){
      //               return const Center(
      //                 child:SpinKitThreeBounce(
      //                   color:kAppColor
      //                 )
      //               );
      //       }else{
      //       return const Center(child: Text("Tafadhali tazamia internet yako vizuri"),);
      //        }
      //        }
      // }),
    );
  }
}