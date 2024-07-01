import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class BetterhouseSupportScreen extends StatefulWidget {
  const BetterhouseSupportScreen({Key? key}) : super(key: key);

  @override
  State<BetterhouseSupportScreen> createState() => _BetterhouseSupportScreenState();
}

class _BetterhouseSupportScreenState extends State<BetterhouseSupportScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late AppDataProvider dataProvider;
  @override
  Widget build(BuildContext context) {
      dataProvider=Provider.of<AppDataProvider>(context);
  Size screenSize=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title:const Text("Pata msaada"),
      ),
      body: SafeArea(
        child: Container(
          padding:const EdgeInsets.only(left: 5,right:5),
          height: screenSize.height,width: screenSize.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Expanded(child: Align(
              alignment: Alignment.bottomCenter,
               child: Container(
                 width: 150,height: 150,
                margin:const EdgeInsets.only(bottom: 50),
                 child:Image.asset("assets/images/betterhouse_logo.png",)),
             )),
             Expanded(              
              child: Column(
               children: [
              Text(_auth.currentUser!.isAnonymous==false ?"Una lolote ${dataProvider.currentUser['firstName']}?":"Una jambo lolote?",style: const TextStyle(fontSize: 25,fontWeight:FontWeight.w600)),
              const Text("Kwa tatizo lolote,swali au mapendekezo na mengineyo wasiliana nasi kupitia 'betterhousehelp@gmail.com'",textAlign: TextAlign.center,style: TextStyle(fontSize: 15,fontWeight:FontWeight.w600)),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: screenSize.width*0.8,
                child: ElevatedButton(
                  onPressed: ()async{
                    //FLD0KomYnSf5AoWkC9lh1t
                   String url="mailto:betterhousehelp@gmail.com";
                   if(await canLaunch(url)){
                     await launch(url);      
                   }else{
                    UserReplyWindowsApi().showToastMessage(context,"Samahani huwezi wasiliana nasi sasa");
                   } 
                }, child:const Text("Wasiliana nasi")),
              )
               ],
             )),
            ],
          ),
        ),
      ),
    );
  }
}