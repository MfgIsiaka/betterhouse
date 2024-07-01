//0627245415 itel
import 'dart:io';
import 'package:betterhouse/provider_services.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:betterhouse/screens/choice_selection_screen.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/modal_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geo_firestore_flutter/geo_firestore_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

class DatabaseApi{
final _geoFire=GeoFlutterFire();
final FirebaseAuth _auth=FirebaseAuth.instance;
final CollectionReference<Map<String, dynamic>> _propertiesRef=FirebaseFirestore.instance.collection("PROPERTIES");
final CollectionReference<Map<String, dynamic>> _itemsViewsAndCartRef=FirebaseFirestore.instance.collection("ITEMS VIEWS AND CART");
final CollectionReference<Map<String, dynamic>> _userComments=FirebaseFirestore.instance.collection("USER COMMENTS");
final DatabaseReference _countriesRef=FirebaseDatabase.instance.reference().child("COUNTRIES");
final DatabaseReference _regionsRef=FirebaseDatabase.instance.reference().child("REGIONS");
final DatabaseReference _districtsRef=FirebaseDatabase.instance.reference().child("DISTRICTS");
final DatabaseReference _chatRoomsRef=FirebaseDatabase.instance.reference().child("CHATROOMS");
final DatabaseReference _usersRef=FirebaseDatabase.instance.reference().child("USERS");
final DatabaseReference _smsRef=FirebaseDatabase.instance.reference().child("MESSAGES");
final DatabaseReference _remainingPropertyInfoRef=FirebaseDatabase.instance.reference().child("REMAINING PROPERTY INFO");
final DatabaseReference _userPropertiesRef=FirebaseDatabase.instance.reference().child("USER PROPERTIES");
final DatabaseReference _plotsRef=FirebaseDatabase.instance.reference().child("PLOTS");
final DatabaseReference _farmsRef=FirebaseDatabase.instance.reference().child("FARMS");
final DatabaseReference _notificationsRef=FirebaseDatabase.instance.reference().child("NOTIFICATIONS");
final DatabaseReference _requestedRentalsRef=FirebaseDatabase.instance.reference().child("REQUESTED RENTALS");
final _buildingImagesRef=FirebaseStorage.instance.ref().child("PROPERTY IMAGES");
final _profilePhotosRef=FirebaseStorage.instance.ref().child("PROFILE IMAGES");


Future<void> phoneNumberSignIn(BuildContext context,var phoneNumber)async{
 UserReplyWindowsApi().showProgressBottomSheet(context);
 SharedPreferences _sharedPreferences=await SharedPreferences.getInstance();
 await _usersRef.orderByChild("phoneNumber").equalTo(phoneNumber).once().then((value)async{
    var user=value.value;
    if(user !=null){
     await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential)async{
            Navigator.pop(context);
            UserReplyWindowsApi().showProgressBottomSheet(context);
            UserCredential? userCred;
                try{
                          userCred= await _auth.signInWithCredential(credential);
                          Navigator.pop(context);
                          if(_auth.currentUser !=null){ 
                            if(userCred.additionalUserInfo!.isNewUser){
                              await _auth.currentUser!.delete().then((value){
                                    UserReplyWindowsApi().showToastMessage(context,"Samahani namba ya simu ulojaza haijasajiliwa, tafadhali tazama vizuri||");  
                              });
                            }else{
                            await _sharedPreferences.setBool("guestUser", false).then((value){
                               Navigator.pushAndRemoveUntil(context,PageTransition(child:  const ChoiceSelection(), type: PageTransitionType.fade), (route) => false);
                            });
                                                               
                            } 
                            }else{
                              //print("Kunatatizo limetokea tafadhali jaribu tena");
                              UserReplyWindowsApi().showToastMessage(context,"Kunatatizo limetokea tafadhali jaribu tena");
                            }
                        } on FirebaseAuthException catch(e){
                          Navigator.pop(context);
                          UserReplyWindowsApi().showToastMessage(context,e.toString());
                        }
                  }, 
          verificationFailed:(FirebaseAuthException ex){
            Navigator.pop(context);
            UserReplyWindowsApi().showToastMessage(context,ex.toString());
        },codeSent:(String verificationId,int? resendToken){
          Navigator.pop(context);
          String? smsCode;
            //Navigator.pop(context);
              showDialog(
                context: context,
                builder: (BuildContext ctxInsideDialog){
                  final _controller=TextEditingController();
                  return AlertDialog(
                    title:  const Text("Uthibitisho"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         const Text("Thibitisha umiliki wa namba ya simu kwa kujaza tarakimu sita tulizokutumia kwenye simu yako"),
                        Container(child: PinFieldAutoFill(
                          onCodeChanged: (code)async{
                           smsCode=code;       
                          },
                        ),),
                         ElevatedButton(
                         onPressed: ()async{
                        if(smsCode!.length==6){
                            Navigator.pop(ctxInsideDialog);
                            UserReplyWindowsApi().showProgressBottomSheet(ctxInsideDialog);
                            PhoneAuthCredential credential=PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode.toString());
                            UserCredential? userCred;
                          try{
                            userCred= await _auth.signInWithCredential(credential);
                            Navigator.pop(context);
                            if(_auth.currentUser !=null){ 
                              if(userCred.additionalUserInfo!.isNewUser){
                                await _auth.currentUser!.delete().then((value){
                                      UserReplyWindowsApi().showToastMessage(context,"Samahani namba ya simu ulojaza haijasajiliwa, tafadhali tazama vizuri||");  
                                });
                              }else{
                                await _sharedPreferences.setBool("guestUser",false).then((value){
                                  Navigator.pushAndRemoveUntil(context,PageTransition(child:  const ChoiceSelection(), type: PageTransitionType.fade), (route) => false);    
                                });                                               
                              }
                              }else{
                                //print("Kunatatizo limetokea tafadhali jaribu tena");
                                UserReplyWindowsApi().showToastMessage(context,"Kunatatizo limetokea tafadhali jaribu tena");
                              }
                          } on FirebaseAuthException catch(e){
                            Navigator.pop(context);
                            UserReplyWindowsApi().showToastMessage(context,e.toString());
                          }
                          //Navigator.pop(context); fl pub cache repair,fl clean
                          // await saveUser(userInfo,context);           
                        }else{
                            UserReplyWindowsApi().showToastMessage(context,"Jaza tarakimu tulizokutumia");
                          }
                }, child:const SizedBox(
                  width:320,
                  child:Center(child: Text("Tuma",style: TextStyle(color: kWhiteColor),))
                ))
         
                      ],
                    ),
                  );
                });
          }, codeAutoRetrievalTimeout:(String resendToken){
              
          });
    }else{
     Navigator.pop(context);
     UserReplyWindowsApi().showToastMessage(context,"Samahani namba imekosewa au haijasajiliwa||");   
    }
 }).catchError((e){
   Navigator.pop(context);
   UserReplyWindowsApi().showToastMessage(context,e.toString());
 });
}

Future<void> addUser(Map<String,dynamic> userInfo,BuildContext context)async{
 String res="";    
 bool verifyingPhone=false;     
  UserReplyWindowsApi().showProgressBottomSheet(context);
  await _usersRef.orderByChild("phoneNumber").equalTo(userInfo["phoneNumber"]).once().then((value)async{
  var user=value.value;    
   if(user==null){
      if(userInfo["email"].toString().trim().isNotEmpty){
        await _usersRef.orderByChild("email").equalTo(userInfo["email"]).once().then((value){
       var user=value.value;
       if(user==null){
          verifyingPhone=true;  
       }else{
         Navigator.pop(context);
        UserReplyWindowsApi().showToastMessage(context,"Baruapepe inatumika na akaunti nyingine!!");
       }
    }).catchError((e){
      Navigator.pop(context);
      UserReplyWindowsApi().showToastMessage(context,e.toString());
    });
      }else{
        verifyingPhone=true;
      }
    }else{
      Navigator.pop(context);
      UserReplyWindowsApi().showToastMessage(context,"Namba ya simu inatumiwa na akaunti nyingine!!");
    }
  }).catchError((e){
    Navigator.pop(context);
    UserReplyWindowsApi().showToastMessage(context,e.toString());
  });
if(verifyingPhone==true){
  bool verified=false;
  print("Verifying number");
  await _auth.verifyPhoneNumber(
  phoneNumber: userInfo["phoneNumber"],
   verificationCompleted: (PhoneAuthCredential credential)async{
      Navigator.pop(context);
      //Navigator.pop(context);
       UserReplyWindowsApi().showProgressBottomSheet(choiceScreenContext!);
          UserCredential userCred;
          try{         
                  userCred= await _auth.currentUser!.linkWithCredential(credential);
                   //userCred= await _auth.signInWithCredential(credential);
                    // Navigator.pop(context);
                    if(_auth.currentUser !=null){ 
                      await saveUser(userInfo,context);
                     //print("DONE");
                     //Navigator.pushAndRemoveUntil(context,PageTransition(child: ChoiceSelection(), type: PageTransitionType.fade), (route) => false);
                      }else{
                        Navigator.pop(choiceScreenContext!);
                        //print("Kunatatizo limetokea tafadhali jaribu tena");
                        UserReplyWindowsApi().showToastMessage(choiceScreenContext!,"Kunatatizo limetokea tafadhali jaribu tena");
                      }
                  } on FirebaseAuthException catch(e){
                    Navigator.pop(choiceScreenContext!);
                    UserReplyWindowsApi().showToastMessage(choiceScreenContext!,e.toString());
                  }     
   }, verificationFailed: (FirebaseAuthException ex){
       Navigator.pop(context);
       UserReplyWindowsApi().showToastMessage(context,ex.toString());
   }, codeSent:(String verificationId,int? resendToken){
       Navigator.pop(context);
       //Navigator.pop(context);
       String smsCode="";
       showDialog(
         context: context,
         builder: (BuildContext ctxInsideDialog){
           final _controller=TextEditingController();
          return AlertDialog(
            title: const Text("Uthibitisho"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                 const Text("Thibitisha umiliki wa namba ya simu kwa kujaza tarakimu sita tulizokutumia kwenye simu yako"),
                Container(
                child: PinFieldAutoFill(
                  onCodeChanged: (code)async{
                      smsCode=code!;  
                  },               
                ),),
                ElevatedButton(
                  onPressed: ()async{
                   if(smsCode.length==6){
                    Navigator.pop(ctxInsideDialog);
                    UserReplyWindowsApi().showProgressBottomSheet(context);
                    PhoneAuthCredential credential=PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode.toString());
                    //Navigator.pop(context);
                    
                    // UserReplyWindowsApi().showProgressBottomSheet(context);
                  UserCredential? userCred;
                //  EmailAuthProvider.credential(email: email, password: password)
                  try{
                   userCred =await _auth.currentUser!.linkWithCredential(credential);
                    //userCred= await _auth.signInWithCredential(credential);
                     //Navigator.pop(context);
                    if(_auth.currentUser !=null){
                         await saveUser(userInfo,context);
                     //print("DONE");
                     //Navigator.pushAndRemoveUntil(context,PageTransition(child: ChoiceSelection(), type: PageTransitionType.fade), (route) => false);
                      }else{
                        Navigator.pop(context);
                        //print("Kunatatizo limetokea tafadhali jaribu tena");
                        UserReplyWindowsApi().showToastMessage(context,"Kunatatizo limetokea tafadhali jaribu tena");
                      }
                  } on FirebaseAuthException catch(e){
                    Navigator.pop(context);
                    UserReplyWindowsApi().showToastMessage(context,e.toString());
                  }
                  //Navigator.pop(context); fl pub cache repair,fl clean
                  // await saveUser(userInfo,context);           
                 }else{
                    UserReplyWindowsApi().showToastMessage(context,"Jaza tarakimu tulizokutumia");
                  }
                }, child:const SizedBox(
                  width:320,
                  child:Center(child: Text("Tuma",style: TextStyle(color: kWhiteColor)))
                ))
              ],
            ),
          );
         });

   },
   timeout: const Duration(seconds:20),
   codeAutoRetrievalTimeout: (String verificationId){
       
   });
}
}

Future<void> saveUser(Map<String,dynamic> userInfo,BuildContext context)async{ 
 SharedPreferences  _sharedPreferences=await SharedPreferences.getInstance();
  String profilePhotoUrl=await addProfilePhotoToStorage(userInfo["profilePhoto"],context);          
 userInfo["profilePhoto"]=profilePhotoUrl;
 if(userInfo["email"].toString().trim().isEmpty){
     var uId=_auth.currentUser!.uid;
     userInfo.remove("password");
     userInfo["id"]=uId;
     SharedPreferences  _sharedPreferences=await SharedPreferences.getInstance();
     await _usersRef.child(uId).set(userInfo).then((value)async{
      await _sharedPreferences.setBool("guestUser",false).then((value){
      Navigator.pop(context); 
      Navigator.pushAndRemoveUntil(context,PageTransition(child:  const ChoiceSelection(), type: PageTransitionType.fade), (route) => false);
      UserReplyWindowsApi().showToastMessage(context,"Hongera, usajili umekamilika");
     }).catchError((e){
        if(_auth.currentUser!=null){
        _auth.currentUser!.delete();
       }
       UserReplyWindowsApi().showToastMessage(context,e.toString());
       Navigator.pop(context);
     });
     
     }).catchError((e)async{
       if(_auth.currentUser!=null){
        _auth.currentUser!.delete();
       }
       UserReplyWindowsApi().showToastMessage(context,e.toString());
       Navigator.pop(context);
     });
 }else{ 
  AuthCredential authCred=EmailAuthProvider.credential(email: userInfo["email"], password: userInfo["password"]);
  await _auth.currentUser!.linkWithCredential(authCred).then((value)async{
   var uId=_auth.currentUser!.uid;
     userInfo.remove("password");
     userInfo["id"]=uId;
     await _usersRef.child(uId).set(userInfo).then((value)async{
      await _sharedPreferences.setBool("guestUser",false).then((value){
      Navigator.pop(context); 
      Navigator.pushAndRemoveUntil(context,PageTransition(child:  const ChoiceSelection(), type: PageTransitionType.fade), (route) => false);
      UserReplyWindowsApi().showToastMessage(context,"Hongera, usajili umekamilika");
     }).catchError((e){
        if(_auth.currentUser!=null){
        _auth.currentUser!.delete();
       }
       print(e.toString());
       UserReplyWindowsApi().showToastMessage(context,e.toString());
       Navigator.pop(context);
     });
     }).catchError((e)async{
       await _auth.currentUser!.delete().then((value){
          UserReplyWindowsApi().showToastMessage(context,e.toString());
          Navigator.pop(context);
       });
     });
  }).catchError((e)async{
    print("Errorr "+e.toString());
    if(_auth.currentUser !=null){
        await _auth.currentUser!.delete();
    }
       UserReplyWindowsApi().showToastMessage(context,e.toString());
          Navigator.pop(context);
  });
  }   
}

Future<String> addProfilePhotoToStorage(File hisProfile,BuildContext cont)async{
 String url="";
  await _profilePhotosRef.child(_auth.currentUser!.uid).putFile(hisProfile).then((snap)async{
    url=await snap.ref.getDownloadURL();
  }).catchError((err){
  UserReplyWindowsApi().showToastMessage(cont,err.toString());
  });
 return url;
}

Future<String> signInUser(Map<String,dynamic> userInfo)async{
SharedPreferences _sharedPreferences=await SharedPreferences.getInstance();
  String res="";
await _auth.signInWithEmailAndPassword(email: userInfo["email"], password: userInfo["password"]).then((value)async{
 await _sharedPreferences.setBool("guestUser", false).then((value){
     res="success";
  });
     
}).catchError((e){
   res=e.toString();
});   
  return res;
}
 
Future<String> uploadBuildingDetails(Map<String,dynamic> buildingData,BuildContext context) async{
AppDataProvider dataProvider=Provider.of<AppDataProvider>(context,listen: false);
final geoPoint=_geoFire.point(latitude:buildingData["latlong"]["latitude"], longitude:buildingData["latlong"]["longitude"]);
String res="";
List<String> urls=[];
String buildingId=_propertiesRef.doc().id;
try{
  await Future.forEach(buildingData["images"], (File image)async{
    String imageId=_propertiesRef.doc().id;
    try{
      UploadTask task= _buildingImagesRef.child(buildingId).child(imageId).putFile(image);
      TaskSnapshot taskSnapshot=await task.whenComplete((){});
      String url=await taskSnapshot.ref.getDownloadURL();
      urls.add(url);
    }catch(e){
       print("Error01 ");
       res=e.toString();
    }
});
//5-3

buildingData["id"]=buildingId;
buildingData["latlong"]=geoPoint.data;
buildingData["coverImage"]=urls[0];
buildingData["uploadTime"]=DateTime.now();
 //rental["id"], rental["coverImage"], rental["productPrice"], rental["localArea"],rental["rentalCharge"], rental["imageCount"]
 urls.removeAt(0);
 Map<String,dynamic> finalRemainingData={
   "description":buildingData["description"],
   "images":urls,
   "photoLocation":buildingData["photoLocation"],
   "assets":buildingData["assets"],
   "countryName":buildingData["countryName"],
   "externalViews":buildingData["externalViews"]
 };
 buildingData.remove("countryName");
 buildingData.remove("assets");
 buildingData.remove("photoLocation");
 buildingData.remove("description");
 buildingData.remove("images");
 buildingData.remove("externalViews");
      await _propertiesRef.doc(buildingId).set(buildingData).then((value)async{              
       if(buildingData["houseOrLand"]==0){
        await _remainingPropertyInfoRef.child("BUILDINGS/$buildingId").set(finalRemainingData).then((value)async{
          await _usersRef.child(buildingData["userId"]).update({"myBuildings":ServerValue.increment(1)});
        });
       }else{
         await _remainingPropertyInfoRef.child("LANDS/$buildingId").set(finalRemainingData).then((value)async{
          await _usersRef.child(buildingData["userId"]).update({"myLands":ServerValue.increment(1)});
        });
       }
        res="success";
        }).catchError((e){
          print("Error2 ");
          res=e.toString(); 
        });
  }catch(e){
    print("Error0 ");
    res=e.toString();
  }
  return res;
  }

 Future<String> sendMessage(Map<String,dynamic> smsInfo,var userNames)async{
  String result="";
    var smsId=_smsRef.push().key;
    smsInfo["id"]=smsId;
   await _smsRef.child(smsInfo["propertyId"]).child(smsId).set(smsInfo).then((value)async{
    await _chatRoomsRef.child(smsInfo["sender"]).child(smsInfo["propertyId"]+"_"+smsInfo["receiver"]).once().then((value)async{
        var chatRoom=value.value;
        DatabaseReference thisChatroomRef=_chatRoomsRef.child(smsInfo["sender"]).child(smsInfo["propertyId"]+"_"+smsInfo["receiver"]);
        smsInfo["smsId"]=smsId;
        smsInfo["personName"]=userNames["receiverName"];
        smsInfo["personPhoto"]=userNames["receiverPhoto"];
        smsInfo.remove("id");
        if(chatRoom==null){   
        smsInfo["chatRoomId"]=smsInfo["propertyId"]+"_"+smsInfo["receiver"];   
        smsInfo["unseenSms"]=0;
        await thisChatroomRef.set(smsInfo).then((value){
        });
         }else{
          await thisChatroomRef.update({            
            "message":smsInfo["message"],
            "time":smsInfo["time"],
            "seenStatus":smsInfo["seenStatus"],
            });
         }
     });

     await _chatRoomsRef.child(smsInfo["receiver"]).child(smsInfo["propertyId"]+"_"+smsInfo["sender"]).once().then((value)async{
        var chatRoom=value.value;
        DatabaseReference thisChatroomRef=_chatRoomsRef.child(smsInfo["receiver"]).child(smsInfo["propertyId"]+"_"+smsInfo["sender"]);
        smsInfo["smsId"]=smsId;
        smsInfo["personName"]=userNames["senderName"];
        smsInfo["personPhoto"]=userNames["senderPhoto"];
        smsInfo.remove("id");
        if(chatRoom==null){   
        smsInfo["chatRoomId"]=smsInfo["propertyId"]+"_"+smsInfo["sender"];   
        smsInfo["unseenSms"]=1;
        await thisChatroomRef.set(smsInfo).then((value){
          print("increme2");
        }).then((value)async{
          await _usersRef.child(smsInfo["receiver"]).child("unseenChats").runTransaction((MutableData mutableData){
          mutableData.value=(mutableData.value ?? 0)+1;
          return mutableData;
      });
        }); 
         }else{
             if(chatRoom["seenStatus"]=="seen"){
               await _usersRef.child(smsInfo["receiver"]).child("unseenChats").runTransaction((MutableData mutableData){
                  mutableData.value=(mutableData.value ?? 0)+1;
                  return mutableData;
              });   
             }
          await thisChatroomRef.update({
            "message":smsInfo["message"],
            "time":smsInfo["time"],
            "seenStatus":smsInfo["seenStatus"],
            }).then((value)async{
               await thisChatroomRef.child("unseenSms").runTransaction((mutableData){
                 mutableData.value=(mutableData.value ?? 0)+1;
                 return mutableData;
               });
            });
         }
     });
      result="Ujumbe umetumwa";
    }).catchError((e){
      result="Ujumbe haujatumwa ${e.toString()}";
    });
    return result;      
}
  
 Future<String> sendRequestedRentalInfo(Map<String,dynamic> reqRentalInfo)async{
   String result="";
  var id=_requestedRentalsRef.push().key;
  reqRentalInfo["id"]=id;
  await _requestedRentalsRef.child(id).set(reqRentalInfo).then((value)async{
   // await checkRentalAndSendNotification(reqRentalInfo);
    result="Taarifa zimetumwa kikamilifu..";
  }).catchError((e){
    result=e.toString();
  });
   return result;
 }

 Future<String> changeSoldPropertyStatus(PropertyInfo propertyInfo)async{
  String res="";
  await _propertiesRef.doc(propertyInfo.id).update({"sold":1}).then((value)async{
    if(propertyInfo.houseOrLand==0){
      await _usersRef.child(propertyInfo.userId).update({
       "soldBuildings":ServerValue.increment(1),
       "myBuildings":ServerValue.increment(-1),
      }).then((value){
        res="success";
      }).catchError((err){
        res=err.toString();
      });
    }else{
      await _usersRef.child(propertyInfo.userId).update({
       "soldLands":ServerValue.increment(1),
       "myLands":ServerValue.increment(-1),
      }).then((value){
        res="success";
      }).catchError((err){
        res=err.toString();
      });
    }
    
  }).catchError((err){
    res=err.toString();
  });
  return res; 
 }       

Future<String> changeUserPassword(String email)async{
  String result ="";
  await _auth.sendPasswordResetEmail(email: email).then((value){
    result="success";
  }).catchError((e){
    result=e.toString();
  });
  return result;
}

Future<List<District>> getRegionDistricts(Map<String,dynamic> data)async{
  
  List<District> regionalDistricts=[];
  print(data);
  await _districtsRef.child(data["countryId"].toString()).child(data["regionId"].toString()).once().then((value){
    
    if(value.value !=null){
      value.value.forEach((val){
        District district=District(val["id"].toString(),val["name"]);
        regionalDistricts.add(district);
      });
     }         
  });
  return regionalDistricts;
}
 
 Future<List<DocumentSnapshot>> getBuildingsFormDb(Map<String,dynamic> filter,AppDataProvider dataProvider)async{
   List<DocumentSnapshot> docsFromDb=[];
   Map<String,dynamic> propertyFilters=dataProvider.propertyFilters;
   var query=_propertiesRef.where("country",isEqualTo: filter["country"]).where("sold",isEqualTo: 0).where("suspended",isEqualTo: 0);
        if(propertyFilters["operation"]!=null){
         query=query.where("operation",isEqualTo: propertyFilters["operation"]);  
        }
        if(propertyFilters["region"]!=null){
         query=query.where("region",isEqualTo: propertyFilters["region"]);  
        }
        if(propertyFilters["district"]!=null){
         query=query.where("district",isEqualTo: propertyFilters["district"]);  
        }

    if(propertyFilters["AllFilters"]!=null){
      //  query=query.where("subBuildingType",isEqualTo: 1);
      //  query=query.where("buildingClass",isEqualTo: 0); 
       if(propertyFilters["AllFilters"]["houseOrLand"]!=null){
        query=query.where("houseOrLand",isEqualTo: propertyFilters["AllFilters"]["houseOrLand"]);
       }
       if(propertyFilters["AllFilters"]["purpose"]!=null){
        query=query.where("purpose",isEqualTo: propertyFilters["AllFilters"]["purpose"]);
       }
       if(propertyFilters["AllFilters"]["purpose"]==0 && propertyFilters["AllFilters"]["houseOrLand"]==0){
          if(propertyFilters["AllFilters"]["buildingType"]!=null){
            query=query.where("buildingType",isEqualTo: propertyFilters["AllFilters"]["buildingType"]);
          }
          if(propertyFilters["AllFilters"]["subBuildingType"]!=null){
            query=query.where("subBuildingType",isEqualTo: propertyFilters["AllFilters"]["subBuildingType"]);
          }
          if(propertyFilters["AllFilters"]["buildingClass"]!=null){
            query=query.where("buildingClass",isEqualTo: propertyFilters["AllFilters"]["buildingClass"]);
          }             
       }

       if(propertyFilters["AllFilters"]["purpose"]==1 && propertyFilters["AllFilters"]["houseOrLand"]==0){
           if(propertyFilters["AllFilters"]["buildingType"]!=null){
            query=query.where("buildingType",isEqualTo: propertyFilters["AllFilters"]["buildingType"]);
          }
          if(propertyFilters["AllFilters"]["buildingStatus"]!=null){
            query=query.where("buildingStatus",isEqualTo: propertyFilters["AllFilters"]["buildingStatus"]);
          }

          if(propertyFilters["AllFilters"]["bedRooms"]!=null && propertyFilters["AllFilters"]["bedRooms"]!=0){
            query=query.where("bedRooms",isEqualTo: propertyFilters["AllFilters"]["bedRooms"]);
          }
          if(propertyFilters["AllFilters"]["livingRooms"]!=null && propertyFilters["AllFilters"]["livingRooms"]!=0){
            query=query.where("livingRooms",isEqualTo: propertyFilters["AllFilters"]["livingRooms"]);
          }
          if(propertyFilters["AllFilters"]["diningRooms"]!=null && propertyFilters["AllFilters"]["diningRooms"]!=0){
            query=query.where("diningRooms",isEqualTo: propertyFilters["AllFilters"]["diningRooms"]);
          }
          if(propertyFilters["AllFilters"]["kitchenRooms"]!=null && propertyFilters["AllFilters"]["kitchenRooms"]!=0){
            query=query.where("kitchenRooms",isEqualTo: propertyFilters["AllFilters"]["kitchenRooms"]);
          }
          if(propertyFilters["AllFilters"]["storeRooms"]!=null && propertyFilters["AllFilters"]["storeRooms"]!=0){
            query=query.where("storeRooms",isEqualTo: propertyFilters["AllFilters"]["storeRooms"]);
          }
          if(propertyFilters["AllFilters"]["selfRooms"]!=null && propertyFilters["AllFilters"]["selfRooms"]!=0){
            query=query.where("selfRooms",isEqualTo: propertyFilters["AllFilters"]["selfRooms"]);
          }
          if(propertyFilters["AllFilters"]["bathRooms"]!=null && propertyFilters["AllFilters"]["bathRooms"]!=0){
            query=query.where("bathRooms",isEqualTo: propertyFilters["AllFilters"]["bathRooms"]);
          }  
       }
    }    

    
    if(filter["lastDocument"]!=null){             
      await query.orderBy("uploadTime",descending: true).startAfterDocument(filter["lastDocument"]).limit(7).get().then((value){
        docsFromDb=value.docs;
      });
    }else{
     await query.orderBy("uploadTime",descending: true).limit(20).get().then((value){
        docsFromDb=value.docs;
    });
  }
  return docsFromDb;
 }

Future<List<DocumentSnapshot>> getMyFavouriteProperties(var propertyIds)async{
List<DocumentSnapshot> docsFromDb=[];

   await _propertiesRef.where("id",whereIn: propertyIds).limit(20).get().then((value){
    docsFromDb=value.docs;
  });

  return docsFromDb;
}

Future<List<DocumentSnapshot>> getCurrentUserProperties(Map<String,dynamic> filter,AppDataProvider dataProvider)async{
  List<DocumentSnapshot> docsFromDb=[];
  var query=_propertiesRef.where("userId",isEqualTo: dataProvider.currentUser["id"]).orderBy("uploadTime",descending: true);
    if(filter["lastDocument"]!=null){             
      await query.startAfterDocument(filter["lastDocument"]).limit(20).get().then((value){
        docsFromDb=value.docs;
    });
    }else{
     await query.limit(10).get().then((value){
        docsFromDb=value.docs;
    });
  }
  return docsFromDb;
}

Future<List<DocumentSnapshot>> getOwnerProperties(Map<String,dynamic> filter)async{
  List<DocumentSnapshot> docsFromDb=[];
  var query=_propertiesRef.where("userId",isEqualTo: filter["userId"]).where("sold",isEqualTo: 0).where("suspended",isEqualTo: 0).orderBy("uploadTime",descending: true);
   if(filter["lastDocument"]!=null){             
    await query.startAfterDocument(filter["lastDocument"]).limit(7).get().then((value){
        docsFromDb=value.docs;
    });
    }else{
     await query.limit(20).get().then((value){
        docsFromDb=value.docs;
    });
  } 
  return docsFromDb;
}

Stream<List<DocumentSnapshot>> getNearbyBuildingsFromDatabae(GeoFirePoint geoPoint){
  List<DocumentSnapshot> docsFromDb=[];
   final geoFire= GeoFirestore(_propertiesRef);
   return _geoFire.collection(collectionRef: _propertiesRef).within(center: geoPoint,
    radius: 0.5, field: "latlong");
  //  await geoFire.getAtLocation(geoPoint,400).then((value){
  //   docsFromDb=value;
  //   //print("Done "+docsFromDb.length.toString());
  //  });
}

 Future<Map<dynamic,dynamic>> getParticularUserInfo(String userId)async{
  Map<dynamic,dynamic> userInfo={};
  await _usersRef.child(userId).get().then((value){
    userInfo=value.value as Map<dynamic,dynamic>;
  });  
  return userInfo;
 }
 
 Future<String> addUserComment(Map<String,dynamic> commentData)async{
  String result='';
  await _usersRef.child(commentData['ownerId']).get().then((value)async{
    var user=value.value;
    if(user != null){
    print(user['stars'].toString() +" "+ commentData['star'].toString());
    double totalStars=user['stars']+commentData['star'];
    int totalComments=user['comments']+1;
    double averageStars=totalStars/totalComments ;
     averageStars=double.parse(double.parse(averageStars.toString()).toStringAsFixed(1));
        String commentId=_userComments.doc().id;
        //{id,userId,stars,comment,name,photo,time}
        commentData['id']=commentId;
        await _userComments.doc(commentData['ownerId']).collection("comments").doc(commentId).set(commentData).then((value) async{
          await _usersRef.child(commentData['ownerId']).update({
          "comments":totalComments,"stars":averageStars
          }).then((value)async{
          await _itemsViewsAndCartRef.doc(commentData['commenterId']).update({'commented':FieldValue.arrayUnion([commentData['ownerId']])}).then((value){
            result="success";
          }).catchError((e){
              result=e.toString();
          });
          }).catchError((e){
              result=e.toString();
          });
        }).catchError((e){
              result=e.toString();
       });
    }else{
      result="Tatizo limetokea tukikamilisha kitendo hiki, jaribu tena";
    }
  }).catchError((e){
      result=e.toString();
  });
  return result; 
 }

 Future<String> createAgentProfile(Map<String,dynamic> agentInfo)async{
  String result='';
  String userId=agentInfo['userId'];
  var location=agentInfo['location'];
  agentInfo.remove('userId');    //0715 251100
  agentInfo.remove('location');
   await _usersRef.child(userId).update({'agentInfo':agentInfo,"location":location}).then((value){    
    result='success';
   }).catchError((e){
    result=e.toString();
   });
  return result;
 }
//
 Future<List<DocumentSnapshot>> getUserCommentsFormDb(String userId)async{
  List<DocumentSnapshot> commentDocSnaps=[];

  await _userComments.doc(userId).collection("comments").orderBy("time",descending: true).get().then((value){
      commentDocSnaps=value.docs;
  });
  return commentDocSnaps;
 }

}