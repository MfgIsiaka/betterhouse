import 'dart:io';

import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/screens/choice_selection_screen.dart';
import 'package:betterhouse/services/database_services.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RegistrationBottomSheet extends StatefulWidget {
  const RegistrationBottomSheet({ Key? key }) : super(key: key);

  @override
  _RegistrationBottomSheetState createState() => _RegistrationBottomSheetState();
}

class _RegistrationBottomSheetState extends State<RegistrationBottomSheet> {
final DatabaseReference _usersRef=FirebaseDatabase.instance.reference().child("USERS");  
 final FirebaseAuth _auth=FirebaseAuth.instance;
 final _firstNameTxtCntrl=TextEditingController();
 final _lastNameTxtCntrl=TextEditingController();
 final _phoneNumberTxtCntrl=TextEditingController();
 final _emailTxtCntrl=TextEditingController();
 final _passwordTxtCntrl=TextEditingController();
 final _cPasswordTxtCntrl=TextEditingController();
 File? _profileImage;
bool _termsRead=false;
bool _isFetchingAccount=false;

  @override
  Widget build(BuildContext context) {
    AppDataProvider dataProvider=Provider.of<AppDataProvider>(context,listen: false);
    String _countryCode=dataProvider.selectedCountry["countryCode"];
    //print(dataProvider.selectedCountry);
     return SingleChildScrollView(
       child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: Container(
            padding:const EdgeInsets.only(top: 8,left: 10,right: 10,bottom: 10),
            margin:const EdgeInsets.only(left: 5,right: 5,bottom: 10),
            decoration:const BoxDecoration(
              color: Colors.white,
              borderRadius:BorderRadius.all(Radius.circular(20))
            ),
            child:Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Jisajili BetterHouse",style: TextStyle(color: kAppColor, fontSize: 16, fontWeight: FontWeight.bold),),
              
                Form(child: Container(
                   padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: kGreyColor
                      )
                    ),
                  child: ListView(
                   controller: ScrollController(),
                   shrinkWrap: true,
                   children: [
                      Row(
                        children: [
                          Expanded(child: Container()),
                          Stack(     
                          children: [
                          _profileImage!=null?Container(
                            width: 120,height:120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(image: FileImage(_profileImage!))
                            ),
                          ):Container(
                            width: 120,height:120,
                            decoration:const BoxDecoration(
                              color: kBlueGreyColor,
                              shape: BoxShape.circle,
                            ),
                            child:const Icon(Icons.person),
                          ),
                            Positioned(
                              bottom:0,left: -10,
                              child: IconButton(onPressed: (){
                                takeRentalImage("gallery");
                              }, icon:Icon(Icons.image,size: 30,color:kAppColor)),
                            ),
                            Positioned(
                              bottom:0,right: -10,
                              child: IconButton(onPressed: (){
                                takeRentalImage("camera");
                              }, icon:Icon(Icons.photo_camera,size: 30,color:kAppColor,)),
                            )
                      ],
                     ),
                          Expanded(child: Container()),                       
                        ],
                      ),             
                     const SizedBox(height: 10,),
                     SizedBox(
                       height: 40,
                       child: TextFormField(
                         controller: _firstNameTxtCntrl,
                        decoration: InputDecoration(
                          contentPadding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                          labelText: "Jina la kwanza",
                          border:OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40)
                          )
                        ),
                       ),
                     ),
                     Container(
                       margin:const EdgeInsets.only(top: 10),
                       height: 40,
                       child: TextFormField(
                         controller: _lastNameTxtCntrl,
                        decoration: InputDecoration(
                          contentPadding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                          labelText: "Jina la mwisho",
                          border:OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40)
                          )
                        ),
                       ),
                     ),
                     Container(
                       margin:const EdgeInsets.only(top: 10),
                       height: 40,
                       child: TextFormField(
                         keyboardType: TextInputType.number,
                         controller: _phoneNumberTxtCntrl,
                        decoration: InputDecoration(
                          prefixIcon: FittedBox(
                            fit: BoxFit.contain,
                            child: CountryCodePicker(
                            initialSelection:dataProvider.selectedCountry["name"].toString().toLowerCase(),                          onChanged: (CountryCode code){
                             _countryCode=code.toString();
                            },
                            ),
                          ),
                         // contentPadding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                          labelText: "Namba ya simu(usianze na 0 au $_countryCode)",
                          border:OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40)
                          )
                        ),
                       ),
                     ),
                     ExpandablePanel(
                      key: UniqueKey(),
                      header: Center(child: Container(margin:const EdgeInsets.only(top: 10), child:const Text("Jaza na baruapepe(sio lazima)"))), 
                      collapsed: Container(),
                      expanded: Column(
                        children: [
                          SizedBox(
                       height: 40,
                       child: TextFormField(
                         controller: _emailTxtCntrl,
                        decoration: InputDecoration(
                          contentPadding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                          labelText: "Barua pepe(email)",
                          border:OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40)
                          )
                        ),
                       ),
                     ),
                     Container(
                       margin:const EdgeInsets.only(top: 10),
                       height: 40,
                       child: TextFormField(
                         obscureText:true,
                         controller: _passwordTxtCntrl,
                        decoration: InputDecoration(
                          contentPadding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                          labelText: "Nenosiri",
                          border:OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40)
                          )
                        ),
                       ),
                     ),
                     Container(
                       margin:const EdgeInsets.only(top: 10),
                       height: 40,
                       child: TextFormField(
                         obscureText:true,
                         controller: _cPasswordTxtCntrl,
                        decoration: InputDecoration(
                          contentPadding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                          labelText: "Rudia nenosiri",
                          border:OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40)
                          )
                        ),
                       ),
                     ),
                        ],
                      ))
                    ,Row(
                    children: [
                      Checkbox(value: _termsRead, onChanged: (val){
                        setState(() {
                           _termsRead=!_termsRead;
                        });      
                      }),
                    Flexible(
                      child: Container(
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(fontSize: 15),
                           children: [
                            const TextSpan(text: "Ninakubaliana na ",style: TextStyle(fontSize: 11),),
                             TextSpan(
                               recognizer:TapGestureRecognizer()..onTap=()async{
                                 String url="https://github.com/Izack3142/privacy-policy/blob/main/PRIVACY-POLICY.md";
                                 if(await canLaunch(url)){
                                    await launch(url);
                                 }else{
                                  UserReplyWindowsApi().showToastMessage(context,"Kuna tatizo katika kufungua ukurasa wetu, jaribu tena");
                                 }
                               },
                               text: " sera ya faragha (privacy policy) ",style: TextStyle(color: kAppColor,fontWeight: FontWeight.bold,fontSize: 11)),
                            const TextSpan(text: "ya betterhouse",style: TextStyle(fontSize: 11))
                           ]
                         )),
                      ),
                    )
                    ],
                  ),
                    UnconstrainedBox(
                   child: Bounce(
                     onPressed:()async{
                     var fName=_firstNameTxtCntrl.text.trim();
                     var lName=_lastNameTxtCntrl.text.trim();
                     var phoneNumber=_phoneNumberTxtCntrl.text.trim();
                     var email=_emailTxtCntrl.text.trim();
                     var password=_passwordTxtCntrl.text.trim();
                     var cPassword=_cPasswordTxtCntrl.text.trim();
                    
                     if(fName.isEmpty || lName.isEmpty || phoneNumber.isEmpty){
                      UserReplyWindowsApi().showToastMessage(context,"Tafadhali taarifa tatu zinahitajika!!");
                     }else{     
                      if(_profileImage != null){
                        Map<String,dynamic> userInfo={
                         "id": _auth.currentUser!.uid,
                         "firstName":fName.trim(),
                         "lastName":lName.trim(),
                         "profilePhoto":_profileImage,
                         "email":email.trim(),
                         "comments":0,
                         "stars":0.0,
                         "phoneNumber":_countryCode+phoneNumber.trim(),
                         "password":password,
                         "onlineStatus":"Online",
                         "suspended":0,
                         "suspensionReason":"",
                         "bhBlocked":0,
                         "blockReason":"",
                         "myBuildings":0,
                         "myLands":0,
                         "deletedBuildings":0,
                         "deletedLands":0,
                         "soldBuildings":0,
                         "soldLands":0,
                         "date":DateTime.now().millisecondsSinceEpoch,
                         "chattingWith":"",
                         "unseenChats":0,
                         "notificationsCount":0,
                         "nationality":dataProvider.selectedCountry["id"],
                       }; 
                         FocusScopeNode currentScope=FocusScope.of(context);
                       if(!currentScope.hasPrimaryFocus){
                           currentScope.unfocus();
                       }
                      if(email.isNotEmpty){
                        if(EmailValidator.validate(email)){
                          if(password.isNotEmpty && cPassword.isNotEmpty){
                            if(password==cPassword){
                              await addUserDetailsToDb(userInfo);
                            }else{
                              UserReplyWindowsApi().showToastMessage(context,"Tafadhali fananisha nenosiri!!");
                            }
                          }else{
                            UserReplyWindowsApi().showToastMessage(context,"Tafadhali jaza nenosiri sehemu zote!!");
                          }
                        }else{
                          UserReplyWindowsApi().showToastMessage(context,"Muundo wa baruapepe haupo sawa!!");
                        }
                        }else{
                        await addUserDetailsToDb(userInfo);
                        }
                        }else{
                          UserReplyWindowsApi().showToastMessage(context,"Picha yako inahitajika");
                        }
                     }
                     },
                     duration:const Duration(milliseconds: 500),
                     child: Container(
                           margin:const EdgeInsets.only(top: 10),
                          padding:const EdgeInsets.only(top: 4,bottom: 4,right: 4,left: 10),
                           decoration: BoxDecoration(
                             boxShadow:const [
                               BoxShadow(
                                 blurRadius: 10,
                                 //spreadRadius: 1,
                                 //color: Colors.blue
                               )
                             ],
                             borderRadius:const BorderRadius.all(Radius.circular(30)),
                             color: _termsRead==true?kAppColor:Colors.grey
                           ),
                           child: Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             children: const [
                               Text("Sajili",style: TextStyle(color: Colors.white,fontSize: 16, fontWeight: FontWeight.w800),),SizedBox(width: 40,),CircleAvatar(
                                 radius: 15,
                                 backgroundColor: Colors.white,
                                 child: Icon(Icons.create,))
                             ],
                           )
                         ),
                   ),
               )            
                   ],
               ),
                ),), 
                 const SizedBox(
                  height: 10,
                  ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                  const Divider(color: kGreyColor,),
                  Container(color:kWhiteColor, child:const Text("AU",style: TextStyle(fontWeight: FontWeight.bold),))
                  ],
                ),         
               _isFetchingAccount?const LinearProgressIndicator(color: kGreyColor,) :Container()
               ,SignInButton(Buttons.GoogleDark, onPressed: (){
                  if(_termsRead==true){                    
                    _signInWithGoogle(dataProvider);
                  }else{
                    UserReplyWindowsApi().showToastMessage(context,"Kubaliana na sera ya faragha kwanza");
                  }
                },text: "Jisajili kwa Google",),
             ],),
          ),
        ),
         ),
     );

  }
  Future<void> takeRentalImage(String imageSource) async{
    XFile? image= await ImagePicker().pickImage(source:imageSource=="camera"?ImageSource.camera:ImageSource.gallery,imageQuality: 25); 
    if(image!=null){       
      try{     
        CroppedFile? result=await ImageCropper().cropImage(sourcePath: File(image.path).path,
         compressQuality: 25,
         aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
         cropStyle: CropStyle.circle,
         uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Kata picha",
          ),
          IOSUiSettings(
           title: "Kata picha"
         )
         ],
        );
       File imgFile=File(result!.path);
       setState(() {
         _profileImage=imgFile;
       });
      }catch(e){
          print("Tatizoo "+e.toString()); 
      }
    }else{
     UserReplyWindowsApi().showToastMessage(context,"Picha haijachukuliwa");
    }
  }
  

 Future<void> addUserDetailsToDb(Map<String, dynamic> userInfo) async{
     if(_termsRead==true){                  
                    await DatabaseApi().addUser(userInfo,context);
      }else{
           UserReplyWindowsApi().showToastMessage(context,"Kubaliana na sera ya faragha kwanza");        }
 }
 
  Future<void> _signInWithGoogle(AppDataProvider dataProvider)async{
    setState((){
      _isFetchingAccount=true;
    });
    final googleSignIn=GoogleSignIn();
    try{
     GoogleSignInAccount? _signInAccount= await googleSignIn.signIn();
    setState((){
      _isFetchingAccount=false;
    });
     UserReplyWindowsApi().showProgressBottomSheet(context);
    if(_signInAccount!=null){
    try{
    GoogleSignInAuthentication? _signInAuth=await _signInAccount.authentication;
    AuthCredential credential=GoogleAuthProvider.credential(
      accessToken: _signInAuth.accessToken,
      idToken: _signInAuth.idToken
    );
    if(credential != null){
      try{
      UserCredential userCred= await _auth.currentUser!.linkWithCredential(credential);
       UserInfo newUser=userCred.user!.providerData[0];
       List<String> displayName=newUser.displayName!.split(" "); 
         Map<String,dynamic> userInfo={
                "id": _auth.currentUser!.uid,
                "firstName":displayName[0].trim(),
                "lastName":displayName[1].trim(),
                "profilePhoto":newUser.photoURL,
                "phoneNumber":newUser.phoneNumber,
                "email":newUser.email,
                "onlineStatus":"Online",
                "comments":0,
                "stars":0.0,
                "bhBlocked":0,
                "blockReason":"",
                "myBuildings":0,
                "myLands":0,
                "deletedBuildings":0,
                "deletedLands":0,
                "soldBuildings":0,
                "soldLands":0,
                "date":DateTime.now().millisecondsSinceEpoch,
                "chattingWith":"",
                "unseenChats":0,
                "notificationsCount":0,
                "nationality":dataProvider.selectedCountry["id"],
              };  
         await _usersRef.child(_auth.currentUser!.uid).set(userInfo).then((value){
           Navigator.pop(context);
           UserReplyWindowsApi().showToastMessage(context,"Usajili umekamilika..");
            Navigator.pushAndRemoveUntil(
                //jt,zp,wp
                  context,
                  PageTransition(
                      duration:const Duration(milliseconds: 500),
                      child: const ChoiceSelection(),
                      type: PageTransitionType.rightToLeft),
                  (route) => false);      
         }).catchError((e){
         Navigator.pop(context);
         UserReplyWindowsApi().showToastMessage(context,e.toString());
         });
      }catch(e){
      Navigator.pop(context);
      UserReplyWindowsApi().showToastMessage(context,e.toString());
      }
      
    }else{
      Navigator.pop(context);
      UserReplyWindowsApi().showToastMessage(context,"Kunatatizo katika kukusajili, jaribu tena");
    }
    }catch(e){
      Navigator.pop(context);
      UserReplyWindowsApi().showToastMessage(context,e.toString());
    }  
    }else{
      Navigator.pop(context);
      UserReplyWindowsApi().showToastMessage(context,"Akaunti haija chaguliwa");
    }
    }catch(e){
      UserReplyWindowsApi().showToastMessage(context,e.toString());
    }
       
  }
 }