import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/screens/authentication_screens/login_bottom_sheet.dart';
import 'package:betterhouse/screens/choice_selection_screen.dart';
import 'package:betterhouse/services/database_services.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class PhoneLoginBottomSheet extends StatefulWidget {
   const PhoneLoginBottomSheet({ Key? key }) : super(key: key);

  @override
  _PhoneLoginBottomSheetState createState() => _PhoneLoginBottomSheetState();
}

class _PhoneLoginBottomSheetState extends State<PhoneLoginBottomSheet> {
final DatabaseReference _usersRef=FirebaseDatabase.instance.reference().child("USERS");  
final _auth=FirebaseAuth.instance;  
final _phoneNumberTxtCntrl=TextEditingController();
String _countryCode="+255";
bool _isFetchingAccount=false;

  @override
  Widget build(BuildContext context) {
      AppDataProvider dataProvider=Provider.of<AppDataProvider>(context,listen: false);
    _countryCode=dataProvider.selectedCountry["countryCode"];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.only(top: 8,left: 10,right: 10,bottom: 10),
        margin: const EdgeInsets.only(left: 5,right: 5,bottom: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:BorderRadius.all(Radius.circular(20))
        ),
        child:Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           Text("Ingia BetterHouse",style: TextStyle(color: kAppColor, fontSize: 16, fontWeight: FontWeight.bold),),
           Form(child: Container(
            padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: kGreyColor
              )
            ),
             child: Column(
               children: [
                  const SizedBox(height: 10,),
                 Container(
                       margin: const EdgeInsets.only(top: 10),
                       height: 40,
                       child: TextFormField(
                         keyboardType: TextInputType.number,
                         controller: _phoneNumberTxtCntrl,
                        decoration: InputDecoration(
                          prefixIcon: FittedBox(
                            fit: BoxFit.contain,
                            child: CountryCodePicker(
                            initialSelection:"tanzania",
                            onChanged: (CountryCode code){
                             _countryCode=code.toString();
                            },
                            ),
                          ),
                         // contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                          labelText: "Namba ya simu(usianze na 0)",
                          border:OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40)
                          )
                        ),
                        inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              ],
                       ),
                     ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [ const Text("Umesahau namba ya simu? "), TextButton(onPressed: (){
                     Navigator.pop(context);
                     showModalBottomSheet(context: context,
                   isScrollControlled: true,
                   backgroundColor: Colors.transparent,
                    builder: (context)=> const LoginBottomSheet());
                 }, child: const Text("tumia email"))],)
                ,UnconstrainedBox(
                 child: Bounce(
                   onPressed:()async{
                   var phone=_phoneNumberTxtCntrl.text.trim();
                  if(phone.isEmpty){
                    UserReplyWindowsApi().showToastMessage(context,"Tafadhali jaza namba ya simu!!");
                   }else{
                    FocusScopeNode currentScope=FocusScope.of(context);
                    if(!currentScope.hasPrimaryFocus){
                         currentScope.unfocus();
                     }
                     await DatabaseApi().phoneNumberSignIn(context,_countryCode+phone);
                   }
                   },
                   duration: const Duration(milliseconds: 500),
                   child: Container(
                         margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.only(top: 4,bottom: 4,right: 4,left: 10),
                         decoration: BoxDecoration(
                           boxShadow:const [
                             BoxShadow(
                               blurRadius: 10,
                               //spreadRadius: 1,
                               //color: Colors.blue
                             )
                           ],
                           borderRadius: const BorderRadius.all(Radius.circular(30)),
                           color: kAppColor
                         ),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children:const [
                             Text("Ingia",style: TextStyle(color: Colors.white,fontSize: 16, fontWeight: FontWeight.w800),),SizedBox(width: 40,),CircleAvatar(
                               radius: 15,
                               backgroundColor: Colors.white,
                               child: Icon(Icons.login,))
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
           _isFetchingAccount==true?const LinearProgressIndicator(color: kGreyColor,):Container(),
            SignInButton(Buttons.GoogleDark, onPressed: ()async{
                  await _signInWithGoogle(dataProvider);
                },text: "Ingia kwa Google",),
         ],),
      ),
    );
  }
   Future<void> _signInWithGoogle(AppDataProvider dataProvider)async{
    setState(() {
      _isFetchingAccount=true;
    });
    final googleSignIn=GoogleSignIn();
    try{
     GoogleSignInAccount? _signInAccount= await googleSignIn.signIn();
     setState(() {
      _isFetchingAccount=true;
     });
    if(_signInAccount!=null){
    UserReplyWindowsApi().showProgressBottomSheet(context);
    try{
    GoogleSignInAuthentication? _signInAuth=await _signInAccount.authentication;
    AuthCredential credential=GoogleAuthProvider.credential(
      accessToken: _signInAuth.accessToken,
      idToken: _signInAuth.idToken
    );
    if(credential != null){
      try{
      UserCredential userCred= await _auth.signInWithCredential(credential);
      if(userCred.additionalUserInfo!.isNewUser){
       UserInfo newUser=userCred.user!.providerData[0];
       List<String> displayName=newUser.displayName!.split(" ");
         Map<String,dynamic> userInfo={
                       "id":_auth.currentUser!.uid,
                       "firstName":displayName[0].trim(),
                       "lastName":displayName[1].trim(),
                       "profilePhoto":newUser.photoURL,
                       "phoneNumber":newUser.phoneNumber,
                       "email":newUser.email,
                       "onlineStatus":"Online",
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
      }else{
      Navigator.pop(context);
       Navigator.pushAndRemoveUntil(
                              //jt,zp,wp
                                context,
                                PageTransition(
                                    duration:const Duration(milliseconds: 500),
                                    child: const ChoiceSelection(),
                                    type: PageTransitionType.rightToLeft),
                                (route) => false);                  
      }
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