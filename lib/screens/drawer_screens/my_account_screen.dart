import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
//import 'awesom';
import 'package:flutter/material.dart';

class MyAccountScreen extends StatefulWidget {
 var currentUserData;
 MyAccountScreen(this.currentUserData,{ Key? key }) : super(key: key);

  @override
  _MyAccountScreenState createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
AwesomeDialog? passwordInfoDialog;
AwesomeDialog? emailInfoDialog;

  @override
  Widget build(BuildContext context) {
     passwordInfoDialog = AwesomeDialog(context: context,
                    dialogType: DialogType.WARNING,
                      title: "Angalizo",
                      desc: "Kubadili nenosiri ni kitendo nyeti, hivyo tutakutoa nje ya akaunti hii na kisha uingie kwa nenosiri jipya",
                      btnOkText: "Sawa",
                      btnCancelText:"Sitisha",
                      btnOkOnPress:(){
                         UserReplyWindowsApi().showToastMessage(context,"Part hii inashughulikiwa");
                      },
                      btnCancelOnPress:(){
                      
                      },
                     );
                    emailInfoDialog = AwesomeDialog(context: context,
                    dialogType: DialogType.WARNING,
                      title: "Angalizo",
                      desc: "Kubadili email ni kitendo nyeti, hivyo tutakutoa nje ya akaunti hii na kisha uingie kwa email jipya",
                      btnOkText: "Sawa",
                      btnCancelText:"Sitisha",
                      btnOkOnPress:(){
                         UserReplyWindowsApi().showToastMessage(context,"Part hii inashughulikiwa");
                      },
                      btnCancelOnPress:(){
                      
                      },
                     );                 

    Size screenSize=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text("Akaunti"),
        centerTitle: true,
      ), 
      body: Stack(
        children: [
          Container(
            width: screenSize.width,
            height: screenSize.height,
           padding: const EdgeInsets.symmetric(horizontal: 3,),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height:155),
                  Container(
                     alignment: Alignment.topLeft,
                     padding: const EdgeInsets.symmetric(horizontal: 4),
                     decoration:BoxDecoration(
                       color:Colors.white,
                       boxShadow:const [
                        BoxShadow(
                           color: Colors.black,
                           blurRadius: 4
                         )
                       ],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:kAppColor
                        )
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Column(
                          crossAxisAlignment:CrossAxisAlignment.start,
                         children: [
                            Text("Jina la mwanzo: ",style: TextStyle(fontWeight:FontWeight.bold,color: kAppColor)),Text(widget.currentUserData["firstName"])
                          ],
                         ),
                    Container()     
                  //  IconButton(
                  //    onPressed: (){
                  //     UserReplyWindowsApi().showToastMessage(context,"Part hii inashughulikiwa");
                  //    }, icon: Icon(Icons.edit,color: Colors.grey,))
                       ],
                     )),
                     const SizedBox(height: 5,),
                     Container(
                     alignment: Alignment.topLeft,
                     padding: const EdgeInsets.symmetric(horizontal: 4),
                     decoration:BoxDecoration(
                       color:Colors.white,
                       boxShadow:const [
                        BoxShadow(
                           color: Colors.black,
                           blurRadius: 4
                         )
                       ],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:kAppColor
                        )
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Column(
                          crossAxisAlignment:CrossAxisAlignment.start,
                         children: [
                            Text("Jina la mwisho: ",style: TextStyle(fontWeight:FontWeight.bold,color: kAppColor)),Text(widget.currentUserData["lastName"])
                          ],
                         ),Container(),
                  //  IconButton(
                  //    onPressed: (){
                  //     UserReplyWindowsApi().showToastMessage(context,"Part hii inashughulikiwa");
                  //    }, icon: Icon(Icons.edit,color: Colors.grey,))
                       ],
                     )), const SizedBox(height: 5,), 
                     Container(
                     alignment: Alignment.topLeft,
                     padding: const EdgeInsets.symmetric(horizontal: 4),
                     decoration:BoxDecoration(
                       color:Colors.white,
                       boxShadow: const [
                        BoxShadow(
                           color: Colors.black,
                           blurRadius: 4
                         )
                       ],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:kAppColor
                        )
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Column(
                          crossAxisAlignment:CrossAxisAlignment.start,
                         children: [
                            Text("Namba ya simu: ",style: TextStyle(fontWeight:FontWeight.bold,color: kAppColor)),Text(widget.currentUserData["phoneNumber"])
                          ],
                         ),
                  //  IconButton(
                  //    onPressed: (){
                  //     UserReplyWindowsApi().showToastMessage(context,"Part hii inashughulikiwa");
                  //    }, icon: Icon(Icons.edit,color: Colors.grey,))
                       ],
                     )),
                    const SizedBox(height: 5,),
                widget.currentUserData["email"].toString().isEmpty?Container():Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      Container(
                     alignment: Alignment.topLeft,
                     padding: const EdgeInsets.symmetric(horizontal: 4),
                     decoration:BoxDecoration(
                       color:Colors.white,
                       boxShadow: const [
                        BoxShadow(
                           color: Colors.black,
                           blurRadius: 4
                         )
                       ],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:kAppColor
                        )
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Column(
                          crossAxisAlignment:CrossAxisAlignment.start,
                         children: [
                            Text("Barua pepe(email): ",style: TextStyle(fontWeight:FontWeight.bold,color: kAppColor)),Text(widget.currentUserData["email"])
                          ],
                         ),
                  //  IconButton(
                  //    onPressed: (){
                  //    UserReplyWindowsApi().showToastMessage(context,"Part hii inashughulikiwa");
                  //    emailInfoDialog!.show();
                  //    }, icon: Icon(Icons.edit,color: Colors.grey,))
                       ],
                     )), const SizedBox(height:5),
                     Container(
                     alignment: Alignment.topLeft,
                     padding: const EdgeInsets.symmetric(horizontal: 4),
                     decoration:BoxDecoration(
                       color:Colors.white,
                       boxShadow: const [
                        BoxShadow(
                           color: Colors.black,
                           blurRadius: 4
                         )
                       ],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:kAppColor
                        )
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Column(
                          crossAxisAlignment:CrossAxisAlignment.start,
                         children: [
                            Text("Nenosiri: ",style: TextStyle(fontWeight:FontWeight.bold,color: kAppColor)),const Text("......",style: TextStyle(fontSize:20,fontWeight:FontWeight.bold))
                          ],
                         ),
                  //  IconButton(
                  //    onPressed: (){                  
                  //    passwordInfoDialog!.show();
                  //    }, icon: Icon(Icons.edit,color: Colors.grey,))
                       ],
                     )),
                    ])  
                ],
              )),
          ),
          Container(
            height: 150,
            width: screenSize.width,
            decoration: BoxDecoration(
              color: kAppColor,
              borderRadius:const BorderRadius.only(
                bottomLeft: Radius.circular(200),
                bottomRight: Radius.circular(200),
              ),
              
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("",style: TextStyle(fontSize: 20,)),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                    backgroundColor: Colors.red,
                    child: Text(widget.currentUserData["firstName"].toString().substring(0,1).toUpperCase(),style: const TextStyle(fontWeight: FontWeight.bold,),),
           ),Container()
          //  Positioned(
          //    bottom: 0,right: -10,
          //    child: IconButton(onPressed: (){
          //      UserReplyWindowsApi().showToastMessage(context,"Part hii inashughulikiwa");
          //    }, icon: Icon(Icons.photo_camera,size: 30,color: Colors.white,)),
          //  )
                  ],
                ),
              ],
            ),
          )
        ],
      ),     
    );
  }
}