
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:betterhouse/screens/authentication_screens/phone_login_bottomsheet.dart';
import 'package:betterhouse/screens/authentication_screens/registration_bottom_sheet.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:show_up_animation/show_up_animation.dart';

class UserReplyWindowsApi{
final CollectionReference<Map<String, dynamic>> _itemsViewsAndCartRef=FirebaseFirestore.instance.collection("ITEMS VIEWS AND CART");
static final _localNotifications=FlutterLocalNotificationsPlugin();

void showNotification(int id,String title,String body)async{
  await _localNotifications.show(id, title, body,const NotificationDetails(
    android:AndroidNotificationDetails("channel_id","channel_name",importance: Importance.max)
    ,iOS: DarwinNotificationDetails()
  ),payload: "abc");
}

showToastMessage(BuildContext context,String message){
final fToast=FToast();
fToast.init(context);
 fToast.init(context);
    final toast=Container(
    padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
    decoration: BoxDecoration(
      color: Colors.grey,
      borderRadius:BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
       const Icon(Icons.error),  
       const SizedBox(width: 10,),Flexible(child: Text(message))
    ],),); 

 fToast.showToast(
  child: toast,
  toastDuration: const Duration(seconds: 5),
  gravity: ToastGravity.TOP
  );     
}

void showProgressBottomSheet(BuildContext context){
  showModalBottomSheet(context: context,
                            isScrollControlled: true,
                            isDismissible:false,
                            backgroundColor: Colors.transparent,
                              builder: (context)=> Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                child: Container(
                                   padding: const EdgeInsets.only(top: 8,left: 10,right: 10,bottom: 10),
                                  margin: const EdgeInsets.only(left: 5,right: 5,bottom: 10),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:BorderRadius.all(Radius.circular(20))
                                  ),
                                  child: Row(
                                  children:const [
                                    CircularProgressIndicator(),SizedBox(width: 20,),Text("Tafadhali subiri")
                                  ]
                                )
                                ),
                              ));
}

void showLoadingDialog(BuildContext context){
            showGeneralDialog(context: context,
              barrierDismissible: true,
              barrierLabel:"loadingDialog",
             //transitionDuration: Duration(seconds: 1),[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
             pageBuilder: (context,anim1,anim2){
              return ShowUpAnimation(
                key: UniqueKey(),
                animationDuration: const Duration(milliseconds: 600),
                child:  SizedBox(
                  height: 30,
                child:SpinKitThreeBounce(
                  duration: const Duration(milliseconds: 1000),
                  //borderWidth: 30,
                  //size:100,
                  color:kAppColor
                ),
                ),
              ); 
            });
}

cartItemsRemovalInfo(BuildContext context){
    AwesomeDialog(
      context: context,
      dialogType: DialogType.INFO,
      title: "Taarifa",
      desc:
          "Mali hii tayari ipo kwenye kapu, Je unataka kuitoa kapuni?",
      dialogBorderRadius: BorderRadius.circular(20),
      btnOk: OutlinedButton(
          child:const Text("Ndio, toa"),
          style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))),
          onPressed: () {
            Navigator.pop(context,true);
             }),
      btnCancel: OutlinedButton(
          child:const Text("Hapana"),
          style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))),
          onPressed: () {
            Navigator.pop(context,false);
           }),
    ).show();
}

Widget showLoadingIndicator(){
  return ShowUpAnimation(
            key: UniqueKey(),
            animationDuration: const Duration(milliseconds: 700),
            child:  SizedBox(
              height: 30,
            child:SpinKitThreeBounce(
              duration: const Duration(milliseconds: 700),
              size: 30,
              color:kAppColor
            ),
            ),
          );
}

 Future showAuthInfoDialog(String messageBody,BuildContext context)async {
  return await AwesomeDialog(
      context: context,
      dialogType: DialogType.INFO,
      title: "Taarifa",
      desc:
          messageBody,
      // body: Text(
      //   "Kutangaza mali yako kunahitaji uwe umeingia kwenye akaunti yako ya BetterHouse",
      //   style:TextStyle(fontWeight: FontWeight.bold)
      //   ) ,
      dialogBorderRadius: BorderRadius.circular(20),
      btnOk: Column(
        children: [
          OutlinedButton(
              child: const Text("Ingia"),
              style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const PhoneLoginBottomSheet());
              }),
          FittedBox(
              child: Text(
            "Unayo akaunti?",
            style: TextStyle(
                color: kAppColor, fontSize: 11, fontWeight: FontWeight.bold),
          )),
        ],
      ),
      btnCancel: Column(
        children: [
          OutlinedButton(
              child: const Text("Jisajili"),
              style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const RegistrationBottomSheet());
              }),
          FittedBox(
              child: Text(
            "Hauna akaunti?",
            style: TextStyle(
                color: kAppColor, fontSize: 11, fontWeight: FontWeight.bold),
          )),
        ],
      ),
    ).show();
  }
 

}