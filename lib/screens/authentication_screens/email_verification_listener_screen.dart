import 'dart:async';

import 'package:betterhouse/screens/choice_selection_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class EmailVerificationListenerScreen extends StatefulWidget {
   const EmailVerificationListenerScreen({ Key? key }) : super(key: key);

  @override
  _EmailVerificationListenerScreenState createState() => _EmailVerificationListenerScreenState();
}

class _EmailVerificationListenerScreenState extends State<EmailVerificationListenerScreen> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
 late Timer _timer;  

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _timer=Timer.periodic( const Duration(milliseconds: 500), (timer)async{
       await _auth.currentUser!.reload();
       if(_auth.currentUser!.emailVerified){
         Navigator.pushAndRemoveUntil(context,PageTransition(child:  const ChoiceSelection(), type: PageTransitionType.fade), (route) => false);
       }
    });
  }

@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Uthibitisho wa baruapepe"),),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4,vertical:1),
        child: Column(
          mainAxisAlignment:MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [

            Text("Baruapepe(email address) yako haijathibitishwa!!",style:TextStyle(fontSize:17,fontWeight:FontWeight.bold)),
            SizedBox(height: 30,),
            Text("Thibitisha baruapepe yako kwa kufungua link tuliokutumia kupitia baruapepe uliojisajilia",style:TextStyle(fontSize:15)),
          ],
        ),
      ),      
    );
  }
}