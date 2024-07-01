import 'package:betterhouse/screens/authentication_screens/password_reset_bottom_sheet.dart';
import 'package:betterhouse/screens/choice_selection_screen.dart';
import 'package:betterhouse/services/database_services.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:page_transition/page_transition.dart';

class LoginBottomSheet extends StatefulWidget {
   const LoginBottomSheet({ Key? key }) : super(key: key);

  @override
  _LoginBottomSheetState createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {
 final _emailTxtCntrl=TextEditingController();
 final _passwordTxtCntrl=TextEditingController();
 final bool _isInBackground=false;

  @override
  Widget build(BuildContext context) {
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
           Form(child: ListView(
             shrinkWrap: true,
             children: [
                const SizedBox(height: 10,),
               Container(
                 margin: const EdgeInsets.only(top: 10),
                 height: 40,
                 child: TextFormField(
                   controller: _emailTxtCntrl,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    labelText: "Barua pepe(email)",
                    border:OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40)
                    )
                  ),
                 ),
               ),
               Container(
                 margin: const EdgeInsets.only(top: 10),
                 height: 40,
                 child: TextFormField(
                 obscureText: true,
                   controller: _passwordTxtCntrl,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    labelText: "nenosiri",
                    border:OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40)
                    )
                  ),
                 ),
               ),
               Row(
                 mainAxisAlignment: MainAxisAlignment.end,
                 children: [ const Text("Umesahau nenosiri? "), TextButton(onPressed: (){
                   Navigator.pop(context);
                   showModalBottomSheet(context: context,
                 isScrollControlled: true,
                 backgroundColor: Colors.transparent,
                  builder: (context)=> const PasswordResetBottomSheet());
               }, child: const Text("Badili"))],)
             ],
           ),),
               UnconstrainedBox(
                 child: Bounce(
                   onPressed:()async{
                   var email=_emailTxtCntrl.text.trim();
                   var password=_passwordTxtCntrl.text.trim();
                  if( email.isEmpty || password.isEmpty){
                    UserReplyWindowsApi().showToastMessage(context,"Tafadhali jaza taarifa zote!!");
                   }else if(!EmailValidator.validate(email)){
                    UserReplyWindowsApi().showToastMessage(context,"Muundo wa paruapepe(email) haupo sawa!!"); 
                   }else{
                     UserReplyWindowsApi().showProgressBottomSheet(context);
                    Map<String,dynamic> userInfo={
                      "email":email,
                      "password":password
                    };
                    FocusScopeNode currentScope=FocusScope.of(context);
                    if(!currentScope.hasPrimaryFocus){
                         currentScope.unfocus();
                     }
                   String res=await DatabaseApi().signInUser(userInfo);
                     Navigator.pop(context);
                  if(res=="success"){
                      Navigator.pushAndRemoveUntil(context,PageTransition(child:  const ChoiceSelection(), type: PageTransitionType.fade), (route) => false);
                  }else{
                    UserReplyWindowsApi().showToastMessage(context,res);
                  }
                  
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
                             )
                           ],
                           borderRadius: const BorderRadius.all(Radius.circular(30)),
                           color: kAppColor
                         ),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children:  const [
                             Text("Ingia",style: TextStyle(color: Colors.white,fontSize: 16, fontWeight: FontWeight.w800),),SizedBox(width: 40,),CircleAvatar(
                               radius: 15,
                               backgroundColor: Colors.white,
                               child: Icon(Icons.login,))
                           ],
                         )
                       ),
                 ),
               )
         ],),
      ),
    );
  }
}