import 'dart:ui';

import 'package:betterhouse/services/database_services.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/modal_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../provider_services.dart';

class OwnersRatingReviewScreen extends StatefulWidget {
  Map<dynamic,dynamic> propertyOwner;
  OwnersRatingReviewScreen(this.propertyOwner,{Key? key}) : super(key: key);

  @override
  State<OwnersRatingReviewScreen> createState() => _OwnersRatingReviewScreenState();
}

class _OwnersRatingReviewScreenState extends State<OwnersRatingReviewScreen> {
 final FirebaseAuth _auth = FirebaseAuth.instance;
 final _commentCntr=TextEditingController();
 double _stars=0.0;
 bool _uploadingComment=false;
 late AppDataProvider dataProvider;
bool _isFetchingComments=false;
List<DocumentSnapshot> _commentDocSnaps=[];
List<UserComment> _comments=[];


 Future<void> _getCommentsFromDb()async{
  setState((){
    _isFetchingComments=true;
  });
     _commentDocSnaps= await DatabaseApi().getUserCommentsFormDb(widget.propertyOwner['id']);
     if(_commentDocSnaps.isNotEmpty){
        for(int i=0;i<_commentDocSnaps.length;i++){
          var data=_commentDocSnaps[i].data()! as Map<String, dynamic>; 
          _comments.add(UserComment(data['id'],data['commenterId'],data['name'] ,data['photo'],data['ownerId'],data['comment'],data['star'],data['time']));
        }  
     }
     setState((){_isFetchingComments=false;});
 }

 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCommentsFromDb();
  }

  @override
  Widget build(BuildContext context) {
   Size screenSize = MediaQuery.of(context).size;
    dataProvider =
        Provider.of<AppDataProvider>(context, listen: false);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
         Container(
             padding:const EdgeInsets.only(left: 4,right: 4),
                 decoration:const BoxDecoration(
                  color: kWhiteColor,
                  boxShadow: [BoxShadow(blurRadius: 3.5)]
                 ),
                 child: SafeArea(
                   child: SizedBox(
                    height: 55,
                     child: Row(
                      children: [
                          GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child:const AbsorbPointer(child:CircleAvatar( child: Icon(Icons.arrow_back)))),
                            Expanded(child:Marquee(
                                  text: "${ widget.propertyOwner['agentInfo'] != null?widget.propertyOwner['agentInfo']['name']:widget.propertyOwner['firstName']}",
                                  style:const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                                  blankSpace: 50,
                                  pauseAfterRound: const Duration(seconds: 4),
                                  startAfter:const Duration(seconds: 4)))
                        ,const SizedBox(width: 10,),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              padding:const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: kAppColor
                                )
                              ),
                              child: Row(
                                children: [
                                  Text(widget.propertyOwner['stars'].toString()),const Icon(Icons.star,size: 12,)
                                ],
                              ),
                              ),
                            const SizedBox(width: 5,),
                            Container(
                              height: 25,
                              padding:const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: kAppColor
                                )
                              ),
                              child: Row(
                                children:[
                                  Text(widget.propertyOwner['comments'].toString()),Icon(Icons.comment,size: 12,)
                                ],
                              ),
                              ),                            
                            const SizedBox(width: 20,),
                            CircleAvatar(
                             radius: 18,
                             backgroundColor: Colors.transparent,
                               child: IconButton(onPressed: ()async{
                                 String phone=widget.propertyOwner['phoneNumber'].toString();
                                 if(await canLaunch("tel:"+phone)){
                                   await launch("tel:"+phone);
                                 }                                                                                             
                               },padding:const EdgeInsets.all(0), icon:const Icon(Icons.phone_in_talk)),
                        
                             ),
                            CircleAvatar(
                               radius: 18,
                               backgroundColor: Colors.transparent,
                                 child: IconButton(onPressed: ()async{                                
                                   if(widget.propertyOwner['email'] != null ){
                                       String uri="mailto:${widget.propertyOwner['email']}?subject=Habari yako ${widget.propertyOwner['firstName'].toString().split(" ")[0]}";
                                         if(await canLaunch(uri)){
                                         await launch(uri);
                                         }else{
                                           UserReplyWindowsApi().showToastMessage(context,"Imeshindikana kufungua gmail kwa sasa!!");
                                         }            
                                   }else{
                                     UserReplyWindowsApi().showToastMessage(context,"Mmiliki wa mali hii hajaweka barua pepe yake!!");
                                   }                                                                                                                
                                 },padding:const EdgeInsets.all(0), icon:const Icon(Icons.email)),
                               ),
                          ],
                        )
                        ],
                      ),
                   ),
                 )
                ),
         Expanded(
           child: Container(
             padding:const EdgeInsets.only(left: 4,right: 2),
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                (dataProvider.currentUser['commented'].contains(widget.propertyOwner['id']) == true)?Container():
                Container(
                  padding:const EdgeInsets.only(top:5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                     Text("Ongea kitu kuhusu ${widget.propertyOwner['agentInfo'] != null?widget.propertyOwner['agentInfo']['name']:widget.propertyOwner['firstName']}, maoni yako ni muhimu.",style: TextStyle(fontSize: 13),),
                      OutlinedButton(onPressed: (){
                        if(_auth.currentUser != null && _auth.currentUser!.isAnonymous==false){
                         _rateThisAgent(context);
                        }else{
                         UserReplyWindowsApi().showAuthInfoDialog("Jisajili au ingia kwenye akaunti yako kwanza ili kutoa maoni", context);
                        }
                       },style: ButtonStyle( side: MaterialStateBorderSide.resolveWith((states) => BorderSide.new(color: kAppColor,width: 2)),), child:const Text("Toa maoni")),
                    ],
                  ),
                ),
                Expanded(child:_isFetchingComments == true
                    ? Center(child: UserReplyWindowsApi().showLoadingIndicator())
                    : _comments.isEmpty
                        ?const Center(
                            child: Text("Hakuna maoni yaliyotumwa",style:TextStyle(fontWeight: FontWeight.bold)),
                          )
                        :ListView.builder(
                          key: UniqueKey(),
                          itemCount: _comments.length,
                          shrinkWrap: true,
                          padding:EdgeInsets.only(top: 10) ,
                          itemBuilder: (context,ind){
                           UserComment thisComment= _comments[ind];
                           String date=DateFormat("dd/MM/yyyy").format(thisComment.time.toDate());
                           return Container(
                            width: screenSize.width,
                            margin:const EdgeInsets.only(bottom: 5),
                            color:const Color.fromARGB(140, 157, 158, 192),
                            child: Row(
                              crossAxisAlignment:CrossAxisAlignment.start,
                              children: [
                                FloatingActionButton(
                                      heroTag: "profile",
                                        onPressed: () {
                                          
                                        },
                                        mini: true,
                                        elevation: 0,
                                      child: Container(
                                          width: 120,height:120,
                                          decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(image: NetworkImage(thisComment.photo))
                                      ),
                                    ),
                                ),   
                                Expanded(
                                  child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,  
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Row(
                                        children: [
                                          Text(thisComment.name,style: TextStyle(fontWeight: FontWeight.bold),),
                                          Spacer(),
                                          Row(
                                            children: [SizedBox(
                                              height: 25,
                                              child: ListView.builder(
                                                key: UniqueKey(),
                                                scrollDirection: Axis.horizontal,
                                                itemCount: (thisComment.star as double).toInt(),
                                                shrinkWrap: true,
                                                itemBuilder: (context,ind){          
                                                 return const Icon(Icons.star,size: 14,);        
                                              }),
                                            ),const SizedBox(width: 15,) ,Text(date,style: TextStyle(fontSize: 13),),],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      child: Text(thisComment.comment,style: TextStyle(fontWeight: FontWeight.w500)))
                                      ],
                                                              ),
                                )
                            ]),
                           );
                          }) )
               ],
             ),
           ),
         )   
         ],
      ),
    );
  }
  
  void _rateThisAgent(BuildContext context) {
    showGeneralDialog(barrierDismissible: true,barrierLabel: "comment", context: context,
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context,anim1,anim2){
      Animation<Offset> offAnim=Tween<Offset>(begin: const Offset(0,-1),end: const Offset(0,0),).animate(anim1);
     return SlideTransition(
       position:offAnim,
       child: StatefulBuilder(
         builder: (context,stateSetter) {
           return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children:const [
                    Icon(Icons.auto_graph),SizedBox(width:10),
                    Text("Mthaminishe",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                  ],
                ),
                RatingBar.builder(itemBuilder: (context,ind){
                   return const Icon(Icons.star,color:Colors.amber,);
                }, glowColor: Colors.amber, onRatingUpdate: (newRate){
                   _stars=newRate;
                }),
                  TextFormField(
                       minLines:3,
                       maxLines: 3,
                       controller:_commentCntr,
                     decoration: InputDecoration(
                       contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                       hintText: "Muelezee kidogo",
                       border:OutlineInputBorder(
                         borderRadius: BorderRadius.circular(10)
                         )
                        ),
                       ),
                       ElevatedButton(
                        onPressed:()async{
                         if(_uploadingComment==false){
                           if(_commentCntr.text.trim().isNotEmpty && _stars>0){
                             _uploadingComment=true;
                             stateSetter(() {      
                             });
                             Map<String,dynamic> commentData={
                              "name":"${dataProvider.currentUser['firstName']} ${dataProvider.currentUser['lastName']}",
                              "photo":dataProvider.currentUser['profilePhoto'],
                              "ownerId":widget.propertyOwner['id'],
                              "commenterId":dataProvider.currentUser['id'],
                              "comment":_commentCntr.text.trim(),
                              "star": _stars,
                              "time":FieldValue.serverTimestamp()
                             };
                            String res=await DatabaseApi().addUserComment(commentData);
                              _uploadingComment=false;
                               stateSetter(() {      
                               });
                            if(res=="success"){
                             List commented= dataProvider.currentUser["commented"];
                             commented.add(widget.propertyOwner['id']);
                             dataProvider.currentUser.addAll({'commented':commented});
                             //await _getCommentsFromDb(); 
                             Navigator.pop(context);
                             UserReplyWindowsApi().showToastMessage(context,"Maoni yametumwa");
                             }else{
                              UserReplyWindowsApi().showToastMessage(context,res);
                             } 
                              setState((){
                              });
                           }else{
                            UserReplyWindowsApi().showToastMessage(context,"Maelezo na nyota vinahitajika");
                           }
                         }
                       },style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => _uploadingComment?kWhiteColor:kAppColor)), child:_uploadingComment==true?UserReplyWindowsApi().showLoadingIndicator():const Text("Tuma")),
              ],
            ),
           );
         }
       ),
     );
    });
  }
 }