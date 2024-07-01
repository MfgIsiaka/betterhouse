// SHA1: BB:F2:30:D5:E5:58:FC:12:62:10:E2:98:AD:5F:8A:1F:48:C7:FD:95
// SHA-256: 55:CC:7A:4D:03:37:23:D1:36:DF:67:DB:59:8F:76:AC:F9:0E:B3:1C:55:A9:2C:43:FE:D8:FC:ED:F4:BA:10:75

import 'dart:async';
import 'dart:convert';
import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/screens/choice_selection_screen.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:upgrader/upgrader.dart';

class SplashScreen extends StatefulWidget {
   const SplashScreen({ Key? key }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>{
final DatabaseReference _usersRef=FirebaseDatabase.instance.reference().child("USERS");
final DatabaseReference _countriesRef=FirebaseDatabase.instance.reference().child("COUNTRIES");
final CollectionReference<Map<String, dynamic>> _itemsViewsAndCartRef=FirebaseFirestore.instance.collection("ITEMS VIEWS AND CART");
late AppLifecycleState _appLifeState;  
final GlobalKey<ScaffoldState> _scaffoldKey=GlobalKey<ScaffoldState>();
SharedPreferences? _sharedPreferences;
Country? _country;
late Widget _currentHeader;
late int currentTime;
Timer? _timer;
String _greetings="";
int buildTimes=1;
final FirebaseAuth _auth= FirebaseAuth.instance;

Future<void> checkForCurrentUser()async{                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
 _sharedPreferences=await SharedPreferences.getInstance();
  AppDataProvider dataProvider=Provider.of<AppDataProvider>(context,listen: false);
  if(_auth.currentUser==null){
     await _auth.signInAnonymously().then((value)async{
      Map<String,dynamic> interacted={"commented":[" "],"cartItems":[],"viewedItems":[]};
      await _itemsViewsAndCartRef.doc(_auth.currentUser!.uid).set(interacted).then((value)async{
         await _sharedPreferences!.setBool("guestUser",true);
      });
    });
  }else{
    if(_sharedPreferences!.getBool("guestUser")==null || _sharedPreferences!.getBool("guestUser")==false){
               await _usersRef.child(_auth.currentUser!.uid).once().then((value)async{
                if(value.value!=null){
                  dataProvider.currentUser=value.value as Map<dynamic,dynamic>;
                  await _sharedPreferences!.setBool("guestUser",false);     
                }
              });
    }
  }
}

@override
  void initState() {
  // TODO: implement initState
   super.initState();
   checkForCurrentUser();
   Future.delayed(const Duration(seconds:5),(){
   _timer=Timer.periodic(const Duration(milliseconds:1000), (timer) async{
      if(_sharedPreferences != null){
         print(_sharedPreferences!.getString("country").toString()+"  "+_sharedPreferences!.getBool("guestUser").toString());
         if(_sharedPreferences!.getString("country")!=null && _sharedPreferences!.getBool("guestUser")!=null){
            Navigator.pushReplacement(context, PageTransition(
            duration: const Duration(milliseconds: 1000),
            child: const ChoiceSelection(), type: PageTransitionType.rightToLeft));
            _timer!.cancel();    
          }
      }      
    });});
   currentTime=DateTime.now().hour;    
      setState(() {
         if(currentTime<12 && currentTime>5){
            _greetings="Habari za asubuhi";
         }else if(currentTime<15 && currentTime>=12){
            _greetings="Habari za mchana";
         }else if(currentTime<19 && currentTime>=15){
            _greetings="Habari za jioni";
         }else if(currentTime<=23 && currentTime>=19){
            _greetings="Habari za leo";
         }else if(currentTime>=0 && currentTime<=4){
            _greetings="Habari za leo";
         }      
      });

     _currentHeader= ShowUpAnimation(
       key:UniqueKey(),
      animationDuration:const Duration(milliseconds:200),     
      child: Text(_greetings,style:const TextStyle(fontSize: 25,color: Colors.white,fontWeight: FontWeight.w800),));   
     Future.delayed(const Duration(seconds: 6),(){
         setState(() {
           _currentHeader= ShowUpAnimation(
              key:UniqueKey(),
              animationDuration: const Duration(milliseconds:500),
             child: const Text("Karibu",style: TextStyle(fontSize: 25,color: Colors.white,fontWeight: FontWeight.w800),));
         });
    });
  }

  Future<void> _getCurrentLocation()async{
      try{
    //  loc.LocationData locData= await loc.Location.instance.getLocation();
    print("fetching location");
     Position? position= await Geolocator.getCurrentPosition(
        //forceAndroidLocationManager: true,
        timeLimit: const Duration(seconds:8),
      //desiredAccuracy: LocationAccuracy.low
      );
      if(position !=null){
        print("loc found");
       try{
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude,position.longitude);
         print(placemarks[0].locality);
        await _countriesRef.orderByChild("name").equalTo(placemarks[0].country.toString().toUpperCase()).once().then((value)async{
          if(value.value!=null){
            AppDataProvider dataProvider=Provider.of<AppDataProvider>(context,listen:false); 
            value.value.forEach((key,country){
              setState(() {
                dataProvider.selectedCountry={
                  "countryCode": country["countryCode"],
                  "id":country["id"].toString(),
                  "continent":country["continent"],
                  "name": country["name"]
                };
              });
            });  
            await _sharedPreferences!.setString("country", json.encode(dataProvider.selectedCountry));     
          }else{
             UserReplyWindowsApi().showToastMessage(context,"Hatuna huduma kwa sasa nchini ${placemarks[0].country.toString()}");
          }
        });
       }catch(e){
       UserReplyWindowsApi().showToastMessage(context,e.toString());
       await _getCurrentLocation();
       }                               
      }else{
        print("Errrorrr nof found");
        await _getCurrentLocation();       
      }
    }catch(err){
        print("Errrrrrrrrr "+err.toString());
         await _countriesRef.orderByChild("name").equalTo("TANZANIA").once().then((value)async{
          if(value.value!=null){
            AppDataProvider dataProvider=Provider.of<AppDataProvider>(context,listen:false); 
            value.value.forEach((key,country){
              setState(() {
                dataProvider.selectedCountry={
                  "countryCode": country["countryCode"],
                  "id":country["id"].toString(),
                  "continent":country["continent"],
                  "name": country["name"]
                };
              });
            });  
            await _sharedPreferences!.setString("country", json.encode(dataProvider.selectedCountry));     
          }else{
            print("Country not found");
          }
        }).catchError((e){
          print(e.toString());
        });  
    }
      print("Finish checking");
  }

  Future<void> _checkLocationPermission() async {
    print("PERMISSION");
    String permissionFeedback="";
  AppDataProvider dataProvider=Provider.of<AppDataProvider>(context,listen:false);
  bool serviceEnabled;
  LocationPermission permission;
  bool _gpsEnabled=false;
  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    //UserReplyWindowsApi().showToastMessage(context,"Huduma ya Gps imezuiliwa kwenye kifaa hiki, Tafadhali tazama settings zako");
   permissionFeedback="deniedForever";
  }

  
  permission = await Geolocator.checkPermission();
  if(permission == LocationPermission.always || permission == LocationPermission.whileInUse){
    if(_sharedPreferences!.getString("country")==null){
      print("no location before");
      permissionFeedback="granted";
      //await _getCurrentLocation();
      //_checkLocationPermission();                     u 
    }else{
      print("yes location before");
      permissionFeedback="exist";
       //dataProvider.selectedCountry= json.decode(_sharedPreferences!.getString("country").toString());
    }
  }

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    //_checkLocationPermission();
    if (permission == LocationPermission.denied) {
       await _checkLocationPermission();
    }else if(permission == LocationPermission.always || permission == LocationPermission.whileInUse){
      if(_sharedPreferences!.getString("country")==null){
       permissionFeedback="granted";
       //await _getCurrentLocation();  
    }else{
      permissionFeedback="exist";
       //dataProvider.selectedCountry= json.decode(_sharedPreferences!.getString("country").toString());
    }
  }  
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    permissionFeedback="deniedForever";
   // UserReplyWindowsApi().showToastMessage(context,"Huduma ya Gps imezuiliwa kwenye kifaa hiki, Tafadhali tazama settings zako");
  }
  print(permissionFeedback);
  if(permissionFeedback=="deniedForever"){
    UserReplyWindowsApi().showToastMessage(context,"Huduma ya Gps imezuiliwa kwenye kifaa hiki, Tafadhali tazama settings zako");
  }else if(permissionFeedback=="granted"){
    await _getCurrentLocation();
  }else if(permissionFeedback=="exist"){
    dataProvider.selectedCountry= json.decode(_sharedPreferences!.getString("country").toString());
  }else{
    await _checkLocationPermission();
  }   
}


  @override
  Widget build(BuildContext context) {
        Future.delayed(Duration.zero,(){
          //UserReplyWindowsApi().showToastMessage(context,_sharedPreferences!.getString("country").toString());
          if(_sharedPreferences!=null){
             if(_sharedPreferences!.getString("country")==null && mounted && buildTimes==1){
              buildTimes++;
              print("inside");
              showLocationPermissionDialog();
          }else{
            print(_sharedPreferences!.getString("country"));
          }   
          }
        });

   Size screenSize=MediaQuery.of(context).size; 
    //message:internetConnMessage,
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        color:kWhiteColor,
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            SizedBox(width:120,height:120, child: Image.asset("assets/images/betterhouse_logo.png")),
            SpinKitThreeBounce(
            duration:const Duration(milliseconds: 900),
            itemBuilder: (context,ind){
               return Icon(Icons.circle,color:ind==0?Colors.red:ind==1?Colors.green: Colors.amber,);
            },
          ),
            const SizedBox(height: 10,),
            Text("Betterhouse",style: TextStyle(fontWeight: FontWeight.w700,color: kAppColor,fontSize: 20)),
            ],
          )),                
         const SizedBox(height: 10) 
          ],
        ),
      ) 
    );
  }
  
  void showLocationPermissionDialog() {
    showGeneralDialog(context: context,
    barrierDismissible: false,
    barrierLabel: "location permission",
     pageBuilder:(context,anim1,anim2){
       return AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.location_on_outlined,size:30),  
            SizedBox(width: 10,),
            Text("Ruhusu Gps")
          ],
        ),
        content:Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
             const Text("Tunahitaji kujua nchi uliyopo ili tukuletee taarifa husika, tafadhali ruhusu betterhouse itambue nchi uliyopo"),
            const SizedBox(height:8),
            OutlinedButton(onPressed: ()async{
            Navigator.pop(context);
           await _checkLocationPermission();
          }, child: const Text("Sawa"))
          ],
        ),
        
       );
     });
  }
}
