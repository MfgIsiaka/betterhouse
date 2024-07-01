import 'package:betterhouse/services/database_services.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';

class PasswordResetBottomSheet extends StatefulWidget {
  const PasswordResetBottomSheet({ Key? key }) : super(key: key);

  @override
  _PasswordResetBottomSheetState createState() => _PasswordResetBottomSheetState();
}

class _PasswordResetBottomSheetState extends State<PasswordResetBottomSheet> {
  final _emailTxtCntrl=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
          Text("Badili nenosiri",style: TextStyle(color: kAppColor, fontSize: 16, fontWeight: FontWeight.bold),),
           Form(child: ListView(
             shrinkWrap: true,
             children: [
               const SizedBox(height: 10,),
               Container(
                 margin:const EdgeInsets.only(top: 10),
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
             ],
           ),),
               UnconstrainedBox(
                 child: Bounce(
                   onPressed:()async{
                   var email=_emailTxtCntrl.text;
                  if( email.isEmpty){
                    UserReplyWindowsApi().showToastMessage(context,"Tafadhali ingiza paruapepe(Email) uliosajilia kubadili nenosiri!!");
                   }else if(!EmailValidator.validate(email)){
                    UserReplyWindowsApi().showToastMessage(context,"Muundo wa paruapepe(email) haupo sawa!!"); 
                   }else{
                     FocusScopeNode currentScope=FocusScope.of(context);
                    if(!currentScope.hasPrimaryFocus){
                         currentScope.unfocus();
                     }
                    UserReplyWindowsApi().showProgressBottomSheet(context);
                      
                   String res=await DatabaseApi().changeUserPassword(email);
                     Navigator.pop(context);
                  if(res=="success"){
                      UserReplyWindowsApi().showToastMessage(context,"Link imetumetumwa kwenye baruapepe(Email) yako. Fungua uitumie kubadili nenosiri");                      
                      //Navigator.pushAndRemoveUntil(context,PageTransition(child: ChoiceSelection(), type: PageTransitionType.fade), (route) => false);
                  }else{
                     UserReplyWindowsApi().showToastMessage(context,res);
                  }
                  
                   }
                   },
                   duration:const Duration(milliseconds: 500),
                   child: Container(
                         margin:const EdgeInsets.only(top: 10),
                        padding:const EdgeInsets.only(top: 4,bottom: 4,right: 4,left: 10),
                         decoration:BoxDecoration(
                           boxShadow:const [
                             BoxShadow(
                               blurRadius: 10,
                             )
                           ],
                           borderRadius:const BorderRadius.all(Radius.circular(30)),
                           color: kAppColor
                         ),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: const [
                             Text("Pokea link",style: TextStyle(color: Colors.white,fontSize: 16, fontWeight: FontWeight.w800),),SizedBox(width: 40,),CircleAvatar(
                               radius: 15,
                               backgroundColor: Colors.white,
                               child: Icon(Icons.link,))
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