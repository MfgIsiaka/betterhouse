import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:badges/badges.dart';
import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/screens/agent_account_creation_screen.dart';
import 'package:betterhouse/screens/drawer_screens/my_rental_screens/current_user_properties_screen.dart';
import 'package:betterhouse/screens/rental_screens/betterhouse_support_screen.dart';
import 'package:betterhouse/screens/rental_screens/chat_messages_screen.dart';
import 'package:betterhouse/screens/rental_screens/items_in_cart_screens/viewed_and_cart_items.dart';
import 'package:betterhouse/screens/rental_screens/location_filter_screen.dart';
import 'package:betterhouse/screens/rental_screens/owner_info_screen.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:like_button/like_button.dart';
import 'package:betterhouse/screens/authentication_screens/registration_bottom_sheet.dart';
import 'package:betterhouse/screens/drawer_screens/my_account_screen.dart';
import 'package:betterhouse/screens/drawer_screens/my_chats_screen.dart';
import 'package:betterhouse/screens/house_buildings_uploading_screens/house_building_details.dart';
import 'package:betterhouse/screens/notifications_screen.dart';
import 'package:betterhouse/screens/rental_screens/buildings_list_filter_screen.dart';
import 'package:betterhouse/screens/rental_screens/rental_details_screen_to_client.dart';
import 'package:betterhouse/services/database_services.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/modal_services.dart';
import 'package:betterhouse/services/server_variable_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:marquee/marquee.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'authentication_screens/phone_login_bottomsheet.dart';

class ChoiceSelection extends StatefulWidget {
  const ChoiceSelection({Key? key}) : super(key: key);

  @override
  _ChoiceSelectionState createState() => _ChoiceSelectionState();
}

BuildContext? choiceScreenContext;

class _ChoiceSelectionState extends State<ChoiceSelection>
    with WidgetsBindingObserver {
final int _bottomNavIndex = 1;
SharedPreferences? _sharedPreferences;
final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _remainingPropertyInfoRef =
FirebaseDatabase.instance.reference().child("REMAINING PROPERTY INFO");
final CollectionReference<Map<String, dynamic>> _itemsViewsAndCartRef=FirebaseFirestore.instance.collection("ITEMS VIEWS AND CART");
final CollectionReference<Map<String, dynamic>> _propertiesRef=FirebaseFirestore.instance.collection("PROPERTIES");
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.reference().child("USERS");
  final DatabaseReference _countriesRef =
      FirebaseDatabase.instance.reference().child("COUNTRIES");
  final DatabaseReference _regionsRef =
      FirebaseDatabase.instance.reference().child("REGIONS");
  List<Widget> _appbarActions = [
        FloatingActionButton(
          heroTag: "notificationPage0",
          onPressed: () {
          },
          elevation: 0,
          mini: true,
          hoverElevation: 0,
          child:const SizedBox(
            width: 50, height: 50,
            child: Center(
                child: Icon(
                        Icons.notifications,
                        size: 30,
                      ) 
                    ),
          ),
        ),
        FloatingActionButton(
          heroTag: "chatsPage0",
          onPressed: () {
          },
          mini: true,
          elevation: 0,
          hoverElevation: 0,
          child:const SizedBox(
            width: 50, height: 50,
            //color: Colors.red,
            child: Center(
              child:Icon(
                      Icons.message,
                      size: 30,
                    )
            ),
          ),
        ),
       const SizedBox(
          width: 10,
        ),
        FloatingActionButton(
           heroTag: "drawerOpen0",
            onPressed: () {
            },
            mini: true,
            elevation: 0,
            child: Container(
              width: 120,height:120,
              decoration:const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child:const Icon(Icons.person),
            ),
        ),
      ];
  late String? _currentUserId;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey(); 
  Map<dynamic,dynamic> _currentUserData={};
  final List<String> _productTypes = [
    "Nyumba & Majengo",
    "Viwanja",
    "Mashamba"
  ];
  StreamSubscription? _smsNotificationStream;
  bool _isChecking = true;
  final ValueNotifier<double> _uploadBtnPosition = ValueNotifier(-1);
  final ValueNotifier<int> _prodTypeVal = ValueNotifier(0);
  final ValueNotifier<String> _currentProductType =
      ValueNotifier("Nyumba & Majengo");
  final PageController _pageViewController = PageController(initialPage: 1);
  late ScrollController _gridAutoScrController;
  int prompt = 0;

  final List<String> _actions = ["Zote", "Za kununua", "Za kupanga"];
  String _selectedLocation="   ";
  int? _currentActionIndex;
  List<DocumentSnapshot> _buildingsDocList = [];
  DocumentSnapshot? _lastDocument;
  int _buildingsListLength = 0;
  bool _isLoadingFirstTime = true;
  bool _isFetchingNext = false;
  bool _isMovingDown=false;
  List<PropertyInfo> _buildingsList = [];
//Map<String>
  Future<void> getBuildingsFromDatabase(AppDataProvider dataProvider) async {
    Map<String, dynamic> filter = {
      "country": dataProvider.selectedCountry["id"],
      "lastDocument": _lastDocument
    };
    setState(() {
       if(_lastDocument!=null){
        _isFetchingNext = true;
        }else{
          _isLoadingFirstTime = true;
        }
    });

    _buildingsDocList.addAll(await DatabaseApi().getBuildingsFormDb(filter,dataProvider));
    if (_buildingsDocList.isNotEmpty) {
      for (int i = 0; i < _buildingsDocList.length; i++) {
        Map<String, dynamic> data =
            _buildingsDocList[i].data()! as Map<String, dynamic>;
            PropertyInfo building = PropertyInfo().initializeData(data);
          if(building.houseOrLand==0){
             await _remainingPropertyInfoRef
            .child("BUILDINGS")
            .child(building.id)
            .update({"externalViews": ServerValue.increment(1)}).then((value) {
          _buildingsList.add(building);
        });
          }else{
            await _remainingPropertyInfoRef
            .child("LANDS")
            .child(building.id)
            .update({"externalViews": ServerValue.increment(1)}).then((value) {
          _buildingsList.add(building);
        });
          }  
        prompt++;
      }
      _lastDocument = _buildingsDocList.last;
      //_lastDocument.
    }
    setState(() {
      _isFetchingNext = false;
      _isLoadingFirstTime = false;
      if (_buildingsDocList.isNotEmpty) {
        _buildingsListLength = _buildingsList.length + 1;
        int pos = 0;
        if (_buildingsDocList.length == 3) {
          pos = 2;
        } else if (_buildingsDocList.length == 2) {
          pos = 1;
        } else if (_buildingsDocList.length == 1) {
          pos = 0;
        }
        _buildingsDocList.clear();
      }
    });
  }

  void checkConnection() {
    FirebaseDatabase.instance
        .reference()
        .child('.info/connected')
        .onValue
        .listen((data) async {
      String isOnline = data.snapshot.value.toString();
      if (_auth.currentUser != null && _auth.currentUser!.isAnonymous==false){
        if (isOnline == "true") {
          await _usersRef
              .child(_auth.currentUser!.uid)
              .update({"onlineStatus": "Online"}).then((value) {
            //print("true");
          }).catchError((e) {
            print(e.toString());
          });
        } else if (isOnline == "false") {
          // print(_auth.currentUser!.uid);
          await _usersRef
              .child(_auth.currentUser!.uid)
              .onDisconnect()
              .update({"onlineStatus":DateTime.now().toString().substring(0, 16)})
              .then((value) {})
              .catchError((e) {
            print("Error " + e.toString());
          });
        }
      }
    });
  }

  Future<void> checkForCurrentUser() async {
    AppDataProvider dataProvider =
        Provider.of<AppDataProvider>(context, listen: false);

    if (_auth.currentUser == null ||_auth.currentUser!.isAnonymous ) {
      if(dataProvider.currentUser.isNotEmpty){
        _currentUserData=dataProvider.currentUser;
      }
      setState(() {
        _isChecking = false;
      });
    } else {
      _currentUserId = _auth.currentUser!.uid;
      _smsNotificationStream =
        //UserReplyWindowsApi().showToastMessage(context,"user "+dataProvider.currentUser["firstName"]);
        _usersRef.child(_auth.currentUser!.uid).onValue.listen((event) {
     _currentUserData = event.snapshot.value as Map<dynamic,dynamic>;
      setState(() {
          _isChecking = false;
          _sharedPreferences!.setBool("guestUse", false);
         dataProvider.currentUser.addAll(_currentUserData);
         //UserReplyWindowsApi().showToastMessage(context,"Aloooo "+dataProvider.currentUser["catProperties"]);
        });
    });
    }
  }

  Future<void> checker() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    await checkForCurrentUser();
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    Future.delayed(const Duration(milliseconds: 4600), () {
      _uploadBtnPosition.value = 10;
    });
    checkConnection();
    checker();
    Future.delayed(const Duration(milliseconds: 100), () async {
      AppDataProvider dataProvider =
          Provider.of<AppDataProvider>(context, listen: false);
      // print(dataProvider.selectedCountry);
      if (_sharedPreferences != null) {
        if (_sharedPreferences!.getString("country") != null) {
          setState(() {
            dataProvider.selectedCountry =
                json.decode(_sharedPreferences!.getString("country") ?? "");
            //countryId= dataProvider.selectedCountry["id"];
          });
        }
      }
          await getViewsAndCartList();
          await getBuildingsFromDatabase(dataProvider);
      _gridAutoScrController.addListener(() async {
        if (_gridAutoScrController.hasClients) {
          if (_gridAutoScrController.offset >=
                  _gridAutoScrController.position.maxScrollExtent &&
              !_gridAutoScrController.position.outOfRange) {
            if (_isFetchingNext == false || _isLoadingFirstTime==false){
              await getBuildingsFromDatabase(dataProvider);
            }
          }
          if(_gridAutoScrController.position.userScrollDirection==ScrollDirection.reverse && _isMovingDown==false){
            setState((){
              _isMovingDown=true;
            });
          }
          if(_gridAutoScrController.position.userScrollDirection==ScrollDirection.forward && _isMovingDown==true){
             setState(() {
               _isMovingDown=false;
             });
          }

        }

      }); 
 
         });
  }

  Future<void> getViewsAndCartList()async{
      AppDataProvider dataProvider =
        Provider.of<AppDataProvider>(context, listen: false);
    await _itemsViewsAndCartRef.doc(_auth.currentUser!.uid).get().then((value){
      var lists=value.data();
     if(lists != null){
        dataProvider.currentUser.addAll(lists);
     }

    });
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    WidgetsBinding.instance.removeObserver(this);
    if (_smsNotificationStream != null) {
      _smsNotificationStream!.cancel();
    }
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if (_auth.currentUser != null && _auth.currentUser!.isAnonymous==false ) {
      if (state == AppLifecycleState.resumed) {
        await _usersRef
            .child(_auth.currentUser!.uid)
            .update({"onlineStatus": "Online"});
      } else {
        await _usersRef.child(_auth.currentUser!.uid).update(
            {"onlineStatus": DateTime.now().toString().substring(0, 16)});
      }
    }
  }

  Future<void> initializeSharedPreferences(AppDataProvider dataProvider) async {
    _sharedPreferences = await SharedPreferences.getInstance();
    //StaggeredGridTile.count(crossAxisCellCount: crossAxisCellCount, mainAxisCellCount: mainAxisCellCount, child: child)
  }

  @override
  Widget build(BuildContext context) {
    choiceScreenContext = context;
    AppDataProvider dataProviderListen =
        Provider.of<AppDataProvider>(context, listen: false);
    AppDataProvider dataProviderNotListen =
        Provider.of<AppDataProvider>(context, listen: false);     
     
     Future.delayed(Duration.zero,(){
        _selectedLocation="Mikoa yote "+dataProviderListen.selectedCountry["name"];
     });
     if(dataProviderListen.propertyFilters["region"]!=null){
      _selectedLocation=dataProviderListen.propertyFilters["regionName"]+"_"+dataProviderListen.selectedCountry["name"];
     }
     if(dataProviderListen.propertyFilters["district"]!=null){
       _selectedLocation=dataProviderListen.propertyFilters["districtName"]+"_"+_selectedLocation;
     }
     
     if(dataProviderListen.propertyFilters["operation"]!=null){
        _currentActionIndex=dataProviderListen.propertyFilters["operation"]+1;
     }else{
      _currentActionIndex=0;
     }
    _gridAutoScrController = PrimaryScrollController.of(context)!;
    Size screenSize = MediaQuery.of(context).size;
    int animationDelay = 0;
    int currentProdIndex = 0;
    if (_isChecking == false && _auth.currentUser!.isAnonymous){
      _appbarActions = [
        Center(
          child: Bounce(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const RegistrationBottomSheet());
            },
            duration:const Duration(milliseconds: 500),
            child: Container(
                padding:const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                margin:const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                    color: kAppColor,
                    border: Border.all(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(20)),
                child:const Text(
                  "Jisajili",
                  style: TextStyle(fontWeight: FontWeight.w500),
                )),
          ),
        ),
        Center(
          child: Bounce(
            onPressed: () {
              showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const PhoneLoginBottomSheet());
            },
            duration: const Duration(milliseconds: 500),
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                    color: kAppColor,
                    border: Border.all(
                      color: Colors.white,
                    ),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text(
                  "Ingia",
                  style: TextStyle(fontWeight: FontWeight.w500),
                )),
          ),
        )
      ];
    } else if (_isChecking == false && _auth.currentUser!.isAnonymous==false){
      _appbarActions = [
        FloatingActionButton(
          heroTag: "notificationPage",
          onPressed: () {
            Navigator.push(
                context,
                PageTransition(
                    child: NotificationsScreen(_currentUserData),
                    type: PageTransitionType.bottomToTop));
          },
          elevation: 0,
          mini: true,
          hoverElevation: 0,
          child: SizedBox(
            width: 50, height: 50,
            //color: Colors.red,
            child: Center(
                child: _currentUserData["notificationsCount"].toString() == "0"
                    ?const Icon(
                        Icons.notifications,
                        size: 30,
                      )
                    : Badge(
                        position:const BadgePosition(top: -5, end: -1),
                        badgeColor: Colors.redAccent,
                        badgeContent: Text(_currentUserData["notificationsCount"].toString(),
                            style:
                                const TextStyle(fontSize: 10, color: Colors.white)),
                        child:const Icon(
                          Icons.notifications,
                          size: 30,
                        ))),
          ),
        ),
        FloatingActionButton(
          heroTag: "chatsPage",
          onPressed: () {
            Navigator.push(
                context,
                PageTransition(
                    child: MyChatsScreen(),
                    type: PageTransitionType.bottomToTop));
          },
          mini: true,
          elevation: 0,
          hoverElevation: 0,
          child: SizedBox(
            width: 50, height: 50,
            //color: Colors.red,
            child: Center(
              child: _currentUserData["unseenChats"].toString() == "0"
                  ?const Icon(
                      Icons.message,
                      size: 30,
                    )
                  : Badge(
                      position:const BadgePosition(top: -5, end: -3),
                      badgeColor: Colors.redAccent,
                      badgeContent: Text(_currentUserData["unseenChats"].toString(),
                          style:const TextStyle(fontSize: 10, color: Colors.white)),
                      child:const Icon(Icons.message, size: 30)),
            ),
          ),
        ),
       const SizedBox(
          width: 10,
        ),
        FloatingActionButton(
           heroTag: "drawerOpener",
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            mini: true,
            elevation: 0,
          child: Container(
              width: 120,height:120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: NetworkImage(_currentUserData["profilePhoto"]))
              ),
            ),
        ),
      ];
    }

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      backgroundColor: kAppColor,
      drawer: _currentUserData.isEmpty ? Container() : detNavigationDrawer(dataProviderListen),
      body: UpgradeAlert(
        child: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (cntx, isExpanded) {
            return [
              SliverAppBar(
                  pinned: true,
                  floating: true,
                  automaticallyImplyLeading: false,
                  elevation: 0.0,
                  title: SizedBox(
                      height: 40,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText("BetterHouse",
                            maxLines: 1,
                            style:const TextStyle(fontSize: 15),
                            minFontSize: 20,
                            overflowReplacement: Marquee(
                                text: "BetterHouse",
                                blankSpace: 50,
                                pauseAfterRound: const Duration(seconds: 4),
                                startAfter:const Duration(seconds: 4))
                                ),
                      )),
                      bottom: PreferredSize(
                      child: Container(
                        color: kAppColor,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                    width: 150,
                                    height: 30,
                                    margin: const EdgeInsets.only(left: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.black38,
                                        borderRadius: BorderRadius.circular(20)),
                                    padding:const EdgeInsets.all(2),
                                    child: GestureDetector(
                                      onTap: ()async{
                                               String result=await Navigator.push(context,MaterialPageRoute(builder: (context)=>const PropertyLocationFilterScreen()));
                                               if(result=="reload"){                                               
                                                  setState(() {
                                                     _buildingsDocList=[];
                                                      _buildingsList=[];
                                                      _lastDocument=null;
                                                  });
                                                await  getBuildingsFromDatabase(dataProviderListen);
                                               }
                                              },
                                      child: AbsorbPointer(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                           const Icon(Icons.location_on,
                                            color: Colors.amber),
                                            Expanded(
                                                child: Marquee(
                                                    style:const TextStyle(color:kWhiteColor),
                                                    blankSpace: 50,
                                                    pauseAfterRound: const Duration(seconds: 4),
                                                    startAfter:const Duration(seconds: 4),
                                                    text: _selectedLocation)),
                                           const Icon(Icons.keyboard_arrow_down_outlined,color:kWhiteColor),
                                          ],
                                        ),
                                      ),
                                    )),
                                FloatingActionButton(
                                    onPressed: () async{
                                    String result= await Navigator.push(
                                          context,
                                          PageTransition(
                                              child: const BuildingsFilterScreen(),
                                              type: PageTransitionType
                                                  .rightToLeft));
                                       if(result=="refresh"){
                                          setState(() {
                                                     _buildingsDocList=[];
                                                      _buildingsList=[];
                                                      _lastDocument=null;
                                              });
                                           await getBuildingsFromDatabase(dataProviderListen);
                                       }           
                                    },
                                    mini: true,
                                    elevation: 0,
                                    heroTag: "filterPage",
                                    backgroundColor: Colors.transparent,
                                    child:Stack(
                                      children: [
                                        const Icon(Icons.filter_list_alt, size: 30),
                                         dataProviderListen.propertyFilters["AllFilters"].isEmpty?Container():
                                         const Positioned(
                                          right: 3,
                                          child: Icon(Icons.circle,size: 10,color: Colors.green,)),
                                      ],
                                    )),
                              ],
                            ),
                            Container(
                              decoration:const BoxDecoration(
                                  color: kWhiteColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  )),
                              height: 40,
                              width: screenSize.width,
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  //height:40,
                                    margin:const EdgeInsets.only(top: 3, bottom: 3),
                                    padding:const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow:const [
                                        BoxShadow(
                                          blurRadius: 5,
                                          color: Colors.black
                                        )],
                                        color: Colors.grey[300]),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min, 
                                      children: _actions.map((e) {
                                       int ind =_actions.indexWhere((el) => el == e);
                                        return GestureDetector(
                                          onTap: () {
                                            setState((){
                                              _currentActionIndex = ind;
                                              _buildingsDocList=[];
                                              _buildingsList=[];
                                              _lastDocument=null;
                                              if(ind!=0){
                                                dataProviderListen.propertyFilters.addAll({"operation":ind-1});
                                              }else{
                                                dataProviderListen.propertyFilters.addAll({"operation":null});
                                              }
                                            });
                                            getBuildingsFromDatabase(dataProviderListen);
                                   
                                          },
                                          child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      _currentActionIndex == ind
                                                          ? 20
                                                          : 5,
                                                  vertical: 5),
                                              decoration: _currentActionIndex ==
                                                      ind
                                                  ? BoxDecoration(
                                                      color: kAppColor,
                                                      borderRadius: BorderRadius
                                                          .circular(20))
                                                  :const BoxDecoration(
                                                      color: Colors.transparent,
                                                    ),
                                              child: Center(
                                                  child: Text(e,
                                                      style: TextStyle(
                                                          color:
                                                              _currentActionIndex ==
                                                                      ind
                                                                  ? kWhiteColor
                                                                  : Colors
                                                                      .black,fontWeight: FontWeight.bold)))),
                                        );
                                      }).toList(),
                                    )),
                              ),
                            )
                          ],
                        ),
                      ),
                      preferredSize: const Size.fromHeight(89)),
                  actions: _appbarActions)
            ];
          },
          body: Container(
              padding:const EdgeInsets.only(top: 5),
              color: kWhiteColor,
              // decoration: BoxDecoration(
              //   color:kWhiteColor,
              //   borderRadius: BorderRadius.only(
              //     topLeft:Radius.circular(30),
              //     topRight:Radius.circular(30),
              //   )
              // ),
              child: _isLoadingFirstTime == true
                  ? Center(child: UserReplyWindowsApi().showLoadingIndicator())
                  : _buildingsList.isNotEmpty
                      ?const Center(
                          child: Text("Hakuna mali iliyopatikana",style:TextStyle(fontWeight: FontWeight.bold)),
                        ):AlignedGridView.count(
                           crossAxisCount: screenSize.width <= 400
                              ? 1
                              : screenSize.width <= 640
                                  ? 2
                                  : screenSize.width <= 960
                                      ? 2
                                      : 4,
                          padding: const EdgeInsets.all(0),
                          physics: const BouncingScrollPhysics(),
                          primary: true,
                          shrinkWrap: true,
                          mainAxisSpacing: 5,
                          itemCount: _buildingsList.length,
                          itemBuilder: (context, _currentIndex) {
                            CommercialBuilding? commercial;
                            ResidentBuilding? residential;
                            PropertyInfo building =
                                _buildingsList[_currentIndex];
                            if(building.houseOrLand==0 && building.purpose==0){
                              commercial=building.specificInfo as CommercialBuilding;
                            }
                            if(building.houseOrLand==0 && building.purpose==1){
                              residential=building.specificInfo as ResidentBuilding;
                            }
                            bool _isAddingToCart=false;
                            String date= "";
                              Duration difference= DateTime.now().difference(building.uploadTime!);    
                              if(difference.inDays !=0){
                                if(difference.inDays>365){
                                  int years=difference.inDays~/365;
                                   if(years>1){
                                    date="Miaka "+years.toString();
                                   }else{
                                     date="Mwaka";
                                   }
                                }else if(difference.inDays>12){
                                  int months=difference.inDays~/12;
                                   if(months>1){
                                    date="Miezi "+months.toString();
                                   }else{
                                     date="Mwezi";
                                   }
                                  }else{
                                    date="Siku "+difference.inDays.toString();
                                  }
                              }else if(difference.inHours!=0){
                                 if(difference.inHours>1){
                                    date="Masaa "+difference.inHours.toString();
                                 }else{
                                     date="Saa 1";
                                 }  
                              }else if(difference.inMinutes!=0){
                                 date="Dakika "+difference.inMinutes.toString();  
                              }else if(difference.inSeconds!=0){
                                 date="Muda huu ";  
                              } 
                            return Container(
                                  margin:const EdgeInsets.only(left: 3, right: 3),
                                  decoration:const BoxDecoration(
                                      color: kWhiteColor,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black,
                                            blurRadius: 5)
                                      ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                          Stack(
                                            children: [
                                            GestureDetector(
                                                onTap: () {
                                                  dataProviderListen.selectedHouse=building;
                                                  //UserReplyWindowsApi().showNotification(0,"Mali imepandishwa","Hongera mali yako imepandishwa kikamilifu");
                                                     Navigator.push(context, PageTransition(
                                                      duration: const Duration(milliseconds: 300),
                                                      child: BuildingDetailsToClientScreen(building), type: PageTransitionType.rightToLeft));
                                                 },
                                                onDoubleTap: () {
                                                  dataProviderListen.selectedHouse=building;
                                                  Navigator.push(context, PageTransition(
                                                      duration: const Duration(milliseconds: 300),
                                                      child: BuildingDetailsToClientScreen(building), type: PageTransitionType.rightToLeft));
                                                },
                                                child: AbsorbPointer(
                                                  child: AspectRatio(
                                                    aspectRatio: 13/7,
                                                    child: Container(
                                                     color: kBlueGreyColor,
                                                      child: CachedNetworkImage(
                                                          fit: BoxFit.cover,
                                                          width: screenSize.width,
                                                          errorWidget: (context,
                                                                  string, dyna) =>
                                                             const Center(
                                                                  child: Icon(
                                                                Icons.error)),
                                                                placeholder: (context,
                                                                  sms) =>
                                                             Center(
                                                                  child: SpinKitThreeBounce(
                                                                   duration:const Duration(milliseconds: 1000),
                                                                   //borderWidth: 30,
                                                                   size:20,
                                                                   color:kAppColor
                                                                        )),
                                                          imageUrl:
                                                              building.coverImage),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                                Positioned(
                                                    left: 0,bottom:0,
                                                    child: SizedBox(
                                                      width: screenSize.width-48,
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                       Row(
                                                        children:[
                                                          Container(
                                                            padding:const EdgeInsets.only(top:1,right:2),
                                                            color:Colors.black,
                                                            child: Text("1/"+building.imageCount.toString(),style:const TextStyle(color:kWhiteColor,fontSize: 11))
                                                          ),
                                                          StatefulBuilder(
                                                            builder: (context,stateSetter){
                                                              return _isAddingToCart==true? const SizedBox(
                                                                width: 13,height:13,
                                                                child:CircularProgressIndicator()):CircleAvatar(
                                                              radius: 13,
                                                              backgroundColor: Colors.transparent,
                                                               child: IconButton(onPressed: ()async{
                                                                 if(_auth.currentUser!.isAnonymous==false && _auth.currentUser!=null){
                                                                if(dataProviderListen.currentUser["cartItems"].contains(building.id)==false){                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                                                                stateSetter((){
                                                                  _isAddingToCart=true;
                                                                });
                                                                await _itemsViewsAndCartRef.doc(_auth.currentUser!.uid).update({"cartItems":FieldValue.arrayUnion([building.id])}).then((value){
                                                                    List<dynamic> newCarts=(dataProviderListen.currentUser["cartItems"] as List<dynamic>) + ([building.id]);
                                                                    dataProviderListen.currentUser.addAll({"cartItems":newCarts});
                                                                    stateSetter((){
                                                                    _isAddingToCart=false;
                                                                      });
                                                                          UserReplyWindowsApi().showToastMessage(context,"Mali imeingizwa kwenye kapu");
                                                                      });
                                                                  }else{
                                                                    //UserReplyWindowsApi().showToastMessage(context,dataProviderNotListen.currentUser.toString());
                                                                    UserReplyWindowsApi().showToastMessage(context,"Mali tayari ipo kwenye kapu");
                                                                  }
                                                              }else{
                                                              UserReplyWindowsApi().showAuthInfoDialog("Kuweka mali kwenye kapu ingia au sajili akaunti ya better house",context);
                                                              }                                                                                                         
                                                               },padding:const EdgeInsets.all(0), icon:const Icon(Icons.shopping_cart_checkout,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)])),
                                                             );                                               
                                                            })
                                                         
                                                        ]
                                                       ) 
                                                        ,residential ==null?Container():
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                               Row(
                                                                children:[
                                                                  const Icon(Icons.bed_sharp,size:18 ,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)],)
                                                                   ,Text(residential.bedRooms.toString(),style: const TextStyle(fontWeight: FontWeight.bold),)
                                                                ],
                                                              ),const Icon(Icons.circle,size:8,color: Colors.red,),
                                                               Row(
                                                                children:[
                                                                  const Icon(Icons.dining_outlined,size:18,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)],)
                                                                   ,Text(residential.diningRooms.toString(),style: const TextStyle(fontWeight: FontWeight.bold),)
                                                                ],
                                                              ),Icon(Icons.circle,size:8,color:kAppColor,),
                                                               Row(
                                                                children:[
                                                                  const Icon(Icons.chair,size:18 ,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)],)
                                                                   ,Text(residential.livingRooms.toString(),style: const TextStyle(fontWeight: FontWeight.bold),)
                                                                ],
                                                               ),const Icon(Icons.circle,size:8,color: Colors.green,),
                                                               Row(
                                                                children:[
                                                                  const Icon(Icons.bathroom_outlined ,size:18 ,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)],)
                                                                   ,Text(residential.bathRooms.toString(),style:const TextStyle(fontWeight: FontWeight.bold),)
                                                                ],
                                                              ),const Icon(Icons.circle,size:8,color: Colors.amber,),
                                                               Row(
                                                                children:[
                                                                  const Icon(Icons.kitchen ,size:18 ,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)],)
                                                                   ,Text(residential.kitchenRooms.toString(),style:const TextStyle(fontWeight: FontWeight.bold),)
                                                                ],
                                                              ),const Icon(Icons.circle,size:8,color: Colors.red,),
                                                               Row(
                                                                children:[
                                                                  Row(
                                                                    children:const [
                                                                     Icon(Icons.bed_sharp,size:10 ,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)],),
                                                                     Icon(Icons.bathroom_outlined ,size:10 ,color:kWhiteColor,shadows: [Shadow(blurRadius: 10,color: Colors.black)],),
                                                                    ],
                                                                  )
                                                                   ,Text(residential.selfRoomsbathRooms.toString(),style:const TextStyle(fontWeight: FontWeight.bold),)
                                                                ],
                                                              ),
                                                            ],
                                                          )
                                                       
                                                          ],
                                                      ),
                                                    ),
                                                  ),                                         
        
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [     
                                               Container(
                                              padding:const EdgeInsets.only(left:6,right:3,bottom:3),
                                              child:Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                                      building.propertyPriceAmount !=
                                                                              null
                                                                          ? "${payCurrencyChoices[building.payCurrency]} ${building.propertyPriceAmount.toString()}"
                                                                          : "${payCurrencyChoices[building.payCurrency]} ${building.buildingBillAmount.toString()} ${payPeriodChoices[building.minBillPeriod]}",
                                                                      style:const TextStyle(
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .bold,
                                                                          fontSize:
                                                                              15)),
                                                       Text(building.operation==0?" :Inauzwa":" :Inapangishwa",style:TextStyle(color: kAppColor,fontWeight:FontWeight.bold))
                                                      ],
                                                    ),
                                                     Row(
                                                       children: [
                                                         Expanded(
                                                           child: Row(
                                                             children: [
                                                              Icon(Icons.circle,size:12,color:kAppColor),
                                                               Expanded(
                                                                 child: Text("${building.title}",maxLines:1,overflow: TextOverflow.ellipsis, style:TextStyle(color: kAppColor,fontWeight:FontWeight.bold)),
                                                               ),
                                                             ],
                                                           ),
                                                         ),
                                                        building.houseOrLand==0 && building.purpose==1 && residential!.buildingStatus==0?
                                                        Container( 
                                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color:Colors.green,),
                                                          padding:const EdgeInsets.symmetric(horizontal:5),  child:const Text("mpya",style:TextStyle(fontSize: 10,fontWeight:FontWeight.bold))):Container() 
                                                       ],
                                                     ),
                                                      Row(
                                                        children: [
                                                          const Icon(Icons.location_on,size:15,color:Colors.amber),
                                                          Expanded(
                                                            child: Text(
                                                                        "${building.localArea.toString()} ${building.districtName.toString()}, ${building.regionName.toString()}",
                                                                        maxLines:1,overflow: TextOverflow.ellipsis,
                                                                        style:const TextStyle(
                                                                            fontSize:
                                                                                12,fontWeight: FontWeight.w500 )),
                                                          ),
                                                          Text(date,style:const TextStyle(fontSize: 12,color:kGreyColor))
                                                        ],
                                                      ),
                                               
                                                ],
                                              )
                                            ) 
                                             ],
                                          ),
                                        ]),
                                      ),
                                      Container(
                                        padding:const EdgeInsets.all(2),
                                        width: 40,
                                       child: Column(
                                        children:[
                                         Container(
                                          decoration:BoxDecoration(
                                            border: Border.all(
                                              color:kGreyColor
                                            )
                                          ),
                                           child: Column(
                                             children: [
                                            FittedBox(child: Text(building.userRole==0?"Dalali":"Mmiliki",
                                                       maxLines: 1,overflow: TextOverflow.ellipsis,
                                                       style:TextStyle(color:kAppColor,fontSize: 10,fontWeight: FontWeight.bold))), 
                                            Container(
                                              height: 40,
                                              child: FloatingActionButton(
                                              heroTag: UniqueKey(),
                                             onPressed: () {
                                    Navigator.push(context, PageTransition(
                                       duration: const Duration(milliseconds: 200),
                                      child:OwnerInfoScreen(building) , type: PageTransitionType.rightToLeft));
                        },
                        mini: true,
                        elevation: 0,
                      child: Container(
                          decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kAppColor,width: 2),
                        image: DecorationImage(image: NetworkImage(building.ownerInfo!['photo'] ))
                      ),
                    ),
                ),
                                            ),     
                        
                                          const SizedBox(height: 5,),
                                            CircleAvatar(
                                            radius: 13,
                                            backgroundColor: Colors.transparent,
                                              child: IconButton(onPressed: ()async{
                                              
                                              if(_auth.currentUser!=null && _auth.currentUser!.isAnonymous==false){
                                                if(_auth.currentUser!.uid!=building.userId){
                                                  UserReplyWindowsApi().showLoadingDialog(context);
                                                  await _usersRef.child(building.userId).once().then((val)async{
                                                        Map<dynamic,dynamic> receiverInfo = val.value as Map<dynamic,dynamic>;
                                                        Navigator.pop(context);
                                                        if(receiverInfo != null || receiverInfo.isNotEmpty){                                                                      
                                                            Navigator.push(context,PageTransition(child: ChatMessagesScreen(receiverInfo,_auth.currentUser!.uid ,building), type: PageTransitionType.rightToLeft));  
                                                        }else{
                                                          UserReplyWindowsApi().showToastMessage(context,"Hatuna taarifa za mmiliki wa mali hii");
                                                        }
      
                                                });    
                                        
                                                }else{
                                                  UserReplyWindowsApi().showToastMessage(context,"Mali hii inamilikiwa na akaunti yako, huwezi chati"); 
                                                }                                           
                                              }else{
                                                showAuthInfoDialog("Jisajili au ingia kwenye akaunti yako kwanza ili kuchati na wamiliki");
                                              }
                                                                                                                                          
                                              },padding:const EdgeInsets.all(0), icon:const Icon(Icons.message)),
                                            ),
                                            CircleAvatar(
                                            radius: 13,
                                            backgroundColor: Colors.transparent,
                                              child: IconButton(onPressed: ()async{                                
                                                if(_auth.currentUser!.isAnonymous==false){
                                                if(building.ownerInfo!['email'].isNotEmpty){
                                                    String uri="mailto:${building.ownerInfo!['email']}?subject=Habari yako ${building.ownerInfo!['name'].toString().split(" ")[0]}";
                                                      if(await canLaunch(uri)){
                                                      await launch(uri);
                                                      }else{
                                                        UserReplyWindowsApi().showToastMessage(context,"Imeshindikana kufungua gmail kwa sasa!!");
                                                      }            
                                                }else{
                                                  UserReplyWindowsApi().showToastMessage(context,"Mmiliki wa mali hii hajaweka barua pepe yake!!");
                                                }
                                        
                                                }else{
                                                showAuthInfoDialog("Kutuma ujumbe wa barua pepe kunahitaji ungie kwenye akaunti yako ya betterhouse");
                                                }                                                                                         
                                              },padding:const EdgeInsets.all(0), icon:const Icon(Icons.email)),
                                            ),
                                            CircleAvatar(
                                            radius: 13,
                                            backgroundColor: Colors.transparent,
                                              child: IconButton(onPressed: ()async{
                                                if(await canLaunch("tel:"+building.ownerInfo!["phone"].toString())){
                                                  await launch("tel:"+building.ownerInfo!["phone"].toString());
                                                }                                                                                             
                                              },padding:const EdgeInsets.all(0), icon:const Icon(Icons.phone_in_talk)),
                                            ),const SizedBox(height:5),                        
                                           ],),
                                         ),
                                          Builder(
                                                  builder: (context){
                                                    bool _isLiked=building.likes.contains(_auth.currentUser!.uid)?true:false;
                                                    return LikeButton(
                                                      likeCount: building.likes.length,
                                                      isLiked:_isLiked,  
                                                      countPostion:CountPostion.bottom,
                                                      
                                                      onTap:(liked)async{
                                                        bool success=false;
                                                         if(_auth.currentUser!.isAnonymous==false || _auth.currentUser==null){
                                                          if(_isLiked==true){
                                                            await _propertiesRef.doc(building.id).update({"likes":FieldValue.arrayRemove([_auth.currentUser!.uid])}).then((value){
                                                            success=true;
                                                            setState(() {
                                                               _buildingsList[_currentIndex].likes.remove(_auth.currentUser!.uid);
                                                            });
                                                          });
                                                          }else{
                                                           await _propertiesRef.doc(building.id).update({"likes":FieldValue.arrayUnion([_auth.currentUser!.uid])}).then((value){
                                                            success=true;
                                                             setState(() {
                                                               _buildingsList[_currentIndex].likes.add(_auth.currentUser!.uid);
                                                            });
                                                          });
                                                          }
                                                          
                                                        }else{
                                                        showAuthInfoDialog("Jisajili au ingia kwenye akaunti yako ya betterhouse ili ukamilishe kitendo hiki");
                                                        } 
                                                        return success?!_isLiked:_isLiked;
                                                      },
                                                      countBuilder: (count,isLiked,text){
                                                         return Text(text,style:TextStyle(color:isLiked?Colors.purple:Colors.black));
                                                      },
                                                    );
                                                  }
                                                      ),
                                                 CircleAvatar(
                                                  radius: 13,
                                                  backgroundColor: Colors.transparent,
                                                   child: IconButton(onPressed: ()async{
                                                    String url='https://play.google.com/store/apps/details?id=com.tanzanitetz.betterhouse';
                                                    await Share.share("Mali hii(utambulisho:${building.id}) imepostiwa kwenye betterhouse ${url.toString()} \n\n Pakua app na fungua utazame ${building.coverImage}"); 
                                                    },padding:const EdgeInsets.all(0), icon:const Icon(Icons.share)),
                                                 ),const SizedBox(width:5),                                                                                                                                    ]
                                       ),
                                       ),
                                    ],
                                  ),
                                );
                          })
       
              ),
        ),
      ),
        bottomNavigationBar: Stack(
        alignment:Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children:[
          _isFetchingNext == false
          ? Container()
          :_isLoadingFirstTime == true
              ? Container()
              :const Positioned(
                top:-20,
                child: CircleAvatar(
                  radius:10,
                  backgroundColor:Colors.transparent,
                  child: CircularProgressIndicator())
                 ),
                 AnimatedContainer(
                  duration:const Duration(milliseconds: 500),
                  height:_isMovingDown?0:35,
                   child: Row(
                     children: [
                      Container(
                        decoration:const BoxDecoration(
                          color:Colors.green,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15)
                          )
                        ),   
                        alignment:Alignment.centerLeft,
                        child: IconButton(onPressed: (){     
                          print(dataProviderListen.currentUser);
                          //UserReplyWindowsApi().showToastMessage(context,dataProviderListen.currentUser.toString()+" mm");                   
                         Navigator.push(context,MaterialPageRoute(builder: (context)=>const CartAndViewedItemsScreen()));
                        }, icon:const Icon(Icons.shopping_cart,color:kWhiteColor)),
                      ),const Spacer(),
                       ElevatedButton(
                        onPressed: (){
                         showChoiceDialog(dataProviderListen);
                         }, child:const Text("Tangaza sasa",style:TextStyle(color:kWhiteColor))),
                        const Spacer(),Container(
                        decoration:const BoxDecoration(
                          color:Colors.red,
                          borderRadius:BorderRadius.only(
                            topLeft: Radius.circular(15)
                          )
                        ),   
                        alignment:Alignment.centerLeft,
                        child: IconButton(onPressed: (){
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>const BetterhouseSupportScreen()));
                        }, icon:const Icon(Icons.help,color:kWhiteColor)),
                      ),
                     ],
                   ),
                    ) 
        ]
      )      
      
      // bottomNavigationBar: SizedBox(
      //     width:screenSize.width,
      //     height:40,
      //     child:Stack(
      //       clipBehavior: Clip.none,
      //       alignment:Alignment.topCenter,
      //       children: [
      //        _isFetchingNext==false?Container():_isLoadingFirstTime==true?Container(): Positioned(
      //           top: -10,
      //           child: CircularProgressIndicator()),
      //           Container(
      //            child:Row(
      //             children:[
      //               Expanded(
      //                 child:Container(
      //                   decoration: BoxDecoration(
      //                   color: kAppColor,
      //                   borderRadius: BorderRadius.only(
      //                     topRight:Radius.circular(50)
      //                   )
      //                 ),
      //                   child: IconButton(onPressed: (){
      //                     Navigator.push(context,PageTransition(child: NearbyPropertiesScreen(), type: PageTransitionType.leftToRight));
      //                   }, icon: Icon(Icons.location_searching)))
      //               ),
      //               FloatingActionButton(
      //                 heroTag: "uploadBtn",
      //                 onPressed: (){
      //                 showChoiceDialog(dataProviderListen);
      //               },child: Icon(Icons.upload)
      //               ),
      //               Expanded(
      //                 child:Container(
      //                   decoration: BoxDecoration(
      //                   color: kAppColor,
      //                   borderRadius: BorderRadius.only(
      //                     topLeft: Radius.circular(50),
      //                   )
      //                 ),
      //                   child: IconButton(onPressed: (){
      //                     Navigator.push(context,PageTransition(child: BetterhouseHelpScreen() , type: PageTransitionType.rightToLeft));
      //                   }, icon: Icon(Icons.help)))
      //               )
      //             ]
      //            )
      //           )
      //   //       CurvedNavigationBar(
      //   //       height:50,
      //   //       index:_bottomNavIndex,
      //   //       //letIndexChange:(i){},
      //   //       color:kAppColor,
      //   //       buttonBackgroundColor:kBlueGreyColor,
      //   //       backgroundColor:Colors.transparent,
      //   //       animationDuration: Duration(milliseconds: 300),
      //   //       onTap: (index){
      //   //         setState(() {
      //   //           _pageViewController.animateToPage(index, duration: Duration(milliseconds: 400), curve:Curves.ease);
      //   //         });
      //   //       if(index==1){
      //   //         showChoiceDialog(dataProviderListen);
      //   //       }
      //   //       },
      //   //       items: [
      //   //         Icon(Icons.location_searching,color:kWhiteColor),
      //   //         Icon(Icons.upload,color:kWhiteColor),
      //   //         Icon(Icons.help,color:kWhiteColor)
      //   //       ]
      //   // ),
      //       ],
      //     )
      //       ),
    );
  }

  Widget detNavigationDrawer(dataProviderListen) {
    return SizedBox(
      width: 270,
      child: Drawer(
        child: Column(
          children: [
            SizedBox(
                height: 200,
                child: UserAccountsDrawerHeader(
                    margin:const EdgeInsets.only(bottom: 0),
                    currentAccountPicture:  FloatingActionButton(
                    heroTag: "drawerOpen",
                      onPressed: () {
                        _scaffoldKey.currentState!.openDrawer();
                      },
                      mini: true,
                      elevation: 0,
                    child: Container(
                        width: 120,height:120,
                        decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: NetworkImage(_currentUserData["profilePhoto"]))
                    ),
                  ),
              ),
       accountName: Text(_currentUserData["firstName"]+" "+_currentUserData["lastName"]),
                    accountEmail: Text(_currentUserData["email"]))),
            Expanded(
              child: ListView(
              children: [
                Container(
                  decoration:const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                      color: Colors.blueGrey,
                    )),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          PageTransition(
                              child: const CurrentUserProperties (),
                              type: PageTransitionType.rightToLeft));
                    },
                    hoverColor: Colors.blueGrey,
                    leading:const Icon(Icons.house),
                    title:const Text("Mali zako"),
                    // subtitle: Text("Idadi ya jumbe 12"),
                  ),
                ),
                // Container(
                //   decoration:const BoxDecoration(
                //     border: Border(
                //         bottom: BorderSide(
                //       color: Colors.blueGrey,
                //     )),
                //   ),
                //   child: ListTile(
                //     onTap: () {
                //       Navigator.pop(context);
                //       Navigator.push(
                //           context,
                //           PageTransition(
                //               child: MyAccountScreen(_currentUserData),
                //               type: PageTransitionType.rightToLeft));
                //     },
                //     hoverColor: Colors.blueGrey,
                //     leading: const Icon(Icons.person),
                //     title: const Text("Akaunti"),
                //     // subtitle: Text("Idadi ya jumbe 12"),
                //   ),
                // ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                      color: Colors.blueGrey,
                    )),
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          PageTransition(
                              child: MyChatsScreen(),
                              type: PageTransitionType.bottomToTop));
                    },
                    hoverColor: Colors.blueGrey,
                    leading: const Icon(Icons.message),
                    title: const Text("Jumbe zako"),
                    // subtitle: Text("Idadi ya jumbe 12"),
                  ),
                ),
                
              ],
            )),
            Container(
                  decoration:const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                      color: Colors.blueGrey,
                    )),
                  ),
                  child: ListTile(
                    onTap: () async {
                      Navigator.pop(context);
                      UserReplyWindowsApi().showProgressBottomSheet(context);
                      await _usersRef.child(_auth.currentUser!.uid).update({
                        "onlineStatus":
                            DateTime.now().toString().substring(0, 16)
                      }).then((value) async {
                        await _auth.signOut().then((value) async {
                          await _auth.signInAnonymously().then((value)async{
                            await _itemsViewsAndCartRef.doc(_auth.currentUser!.uid).set({"commented":[],"cartItems":[],"viewedItems":[]}).then((value)async{
                                 await _sharedPreferences!
                              .setBool("guestUser", true)
                              .then((value) async{
                            dataProviderListen.currentUser={};                            
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              //jt,zp,wp
                                context,
                                PageTransition(
                                    duration:const Duration(milliseconds: 500),
                                    child: const ChoiceSelection(),
                                    type: PageTransitionType.rightToLeft),
                                (route) => false);                         
                              });
                                });                        
                          });
                          });
                      });
                    },
                    hoverColor: Colors.blueGrey,
                    leading:const Icon(Icons.logout),
                    title:const Text("Logout"),
                    // subtitle: Text("Idadi ya jumbe 12"),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget showHelpScreen() {
    return Container(
      padding: const EdgeInsets.only(bottom: 50, left: 5, right: 5, top: 10),
      child: Column(
        children: [
          const SizedBox(height: 30, child: Text("Kuhusu betterhouse")),
          ExpansionPanelList(children: [
            ExpansionPanel(
                isExpanded: true,
                headerBuilder: (context, isOpen) {
                  return const Text("Jisajili betterhouse");
                },
                body: const Text(
                    """Ni rahisi kujisajili betterhouse,\n 1. Bonyeza kitufe 'jisajili' kisha jaza majina na namba ya simu bila kuanza na sifuri \n
               2. Bonyeza kitufe 'jisajili' na usubiri ujumbe wa meseji kuthibitisha namba ya simu yako \n
               3.Usajili umekamilika na sasa unaweza kufanya vitu kama kutangaza pango lako,kuchati na wamiliki wa mapango,kuomba kujuzwa nasi(betterhouse) kama pango likipatikana mahali unapoitaji""")),
            ExpansionPanel(
                isExpanded: false,
                headerBuilder: (context, isOpen) {
                  return const Text("Jisajili betterhouse");
                },
                body: const Text(
                    """Ni rahisi kujisajili betterhouse,\n 1. Bonyeza kitufe 'jisajili' kisha jaza majina na namba ya simu bila kuanza na sifuri \n
               2. Bonyeza kitufe 'jisajili' na usubiri ujumbe wa meseji kuthibitisha namba ya simu yako \n
               3.Usajili umekamilika na sasa unaweza kufanya vitu kama kutangaza pango lako,kuchati na wamiliki wa mapango,kuomba kujuzwa nasi(betterhouse) kama pango likipatikana mahali unapoitaji"""))
          ]),
          const Spacer(),
          SizedBox(
              height: 30,
              child: TextButton(onPressed: () {}, child: const Text("Wailiana nasi")))
        ],
      ),
    );
  }

  void showChoiceDialog(AppDataProvider provider) {
    ValueNotifier<bool> isRoleSelection = ValueNotifier(false);
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: "actionChoice",
        pageBuilder: (context, anim1, anim2) {
          return AlertDialog(
            title: ShowUpAnimation(
                child: ValueListenableBuilder(
                    valueListenable: isRoleSelection,
                    builder: (context, isRole, child) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: isRole == true
                            ? Row(
                                key: UniqueKey(),
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 30),
                                    child: GestureDetector(
                                        onTap: () {
                                          isRoleSelection.value = false;
                                        },
                                        child: Icon(
                                          Icons.arrow_back,
                                          color: kAppColor,
                                        )),
                                  ),
                                  //TextSpan(text:"Wewe ni nani katika mali unayohitaji kuitangaza?"),
                                  const Text("Uhusika"),
                                ],
                              )
                            : Text("Nini unataka kufanya katika mali yako?",
                                key: UniqueKey()),
                      );
                    })),
            content: ValueListenableBuilder(
                valueListenable: isRoleSelection,
                builder: (context, isRole, child) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: isRole == true
                        ? Column(
                            key: UniqueKey(),
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Wewe ni nani katika mali unayohitaji kuitangaza?",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ElevatedButton(
                                  onPressed: () {
                                   Map<dynamic,dynamic> agent=provider.currentUser;
                                    //print(agent['agentInfo'].toString()+" this ");
                                    provider.userUploadRole = 0;
                                    if(agent['agentInfo']==null || agent['agentInfo'].isEmpty){
                                       Navigator.pop(context);
                                        Navigator.push(context, PageTransition(
                                        duration:const Duration(milliseconds: 700),
                                        child: AgentAccountCreationScreen(agent), type: PageTransitionType.rightToLeft));                                              
                                     }else{
                                       provider.deviceLocation={
                                        "latitude":provider.currentUser['location']['latitude'],
                                        "longitude":provider.currentUser['location']['longitude'],
                                       };
                                        Navigator.pop(context);
                                        Navigator.push(context, PageTransition(
                                        duration:const Duration(milliseconds: 700),
                                        child: const RentalHouseDetailsScreen(), type: PageTransitionType.rightToLeft));
                                     }
                                  },                                  
                                  child:const Text("Dalali",style:TextStyle(color: kWhiteColor))),
                              ElevatedButton(
                                  onPressed: () {
                                    provider.userUploadRole = 1;
                                    Navigator.pop(context);
                                    showLocationAlertDialog(provider);
                                    //Navigator.push(context,PageTransition(child: RentalHouseDetailsScreen() , type: PageTransitionType.leftToRight));
                                  },
                                  
                                  child:const Text("Mmiliki",style:TextStyle(color: kWhiteColor))),
                            ],
                          )
                        : Column(
                            key: UniqueKey(),
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    provider.rentOrSell = 0;
                                    //provider.selectedRegion=regions[0];
                                    if (_auth.currentUser == null || _auth.currentUser!.isAnonymous) {
                                      Navigator.pop(context);
                                      showAuthInfoDialog("Kutangaza mali yako kunahitaji uwe umeingia kwenye akaunti yako ya BetterHouse");
                                    } else {
                                      isRoleSelection.value = true;
                                    }
                                  },
                                  child:const Text("Uza",style:TextStyle(color:kWhiteColor))),
                              ElevatedButton(
                                  onPressed: () {
                                    provider.rentOrSell = 1;
                                    if (_auth.currentUser == null || _auth.currentUser!.isAnonymous){
                                      Navigator.pop(context);
                                      showAuthInfoDialog("Kutangaza mali yako kunahitaji uwe umeingia kwenye akaunti yako ya BetterHouse");
                                    } else {
                                      isRoleSelection.value = true;
                                    }
                                  },
                                  child:const Text("Pangisha/Kodisha",style:TextStyle(color:kWhiteColor))),
                            ],
                          ),
                  );
                }),
          );
        });
  }

  void showAuthInfoDialog(String messageBody) {
    AwesomeDialog(
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
 
  ValueNotifier<bool> locationLoading = ValueNotifier(false);
  ValueNotifier<bool> locationfound = ValueNotifier(false);

  Map<String, double> _currentLocation = {};
  void showLocationAlertDialog(AppDataProvider provider) {
    // print("Location is "+_currentUserData["location"].toString());
    locationLoading.value = false;
    locationfound.value = false;
    showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: "locationChoice",
        pageBuilder: (context, anim1, anim2) {
          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.location_pin),
                const SizedBox(width: 10),
                Text(provider.userUploadRole == 0
                    ? "Eneo unalopatikana"
                    : "Eneo mali ilipo"),
              ],
            ),
            content: ValueListenableBuilder(
                valueListenable: locationLoading,
                builder: (context, locLoad, child) {
                  print(locLoad);
                  return (locLoad == true)
                      ? Column(mainAxisSize: MainAxisSize.min, children: [
                          const Text("Tunachukua eneo ulipo.."),
                          AvatarGlow(
                            glowColor: kAppColor,
                            endRadius: 60,
                            duration: const Duration(milliseconds: 1000),
                            child: const Icon(Icons.location_pin),
                          ),
                          const Text("Tafadhali subiri"),
                        ])
                      : provider.userUploadRole == 0
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  _currentUserData["location"] != null
                                      ? const Text(
                                          "Kama hujabadili eneo unalopatikana chagua 'Tumia lile lile'. \n Kama umebadili hakikisha upo katika eneo husika(ofisi) kisha chagua 'Tumia la sasa'.")
                                      : const Text(
                                          "Watu watahitaji kujua sehemu unapopatikana(ofisi) kupitia ramani.\n Hivyo hakikisha upo kwenye eneo lako kisha bonyeza kitufe hapa chini"),
                                  _currentUserData["location"] == null
                                      ? Container()
                                      : OutlinedButton(
                                          //color: kBlueGreyColor,
                                          onPressed: () async {
                                            provider.deviceLocation = {
                                              "latitude":
                                                  _currentUserData["location"]
                                                      ["latitude"],
                                              "longitude":
                                                  _currentUserData["location"]
                                                      ["longitude"]
                                            };
                                            print(provider.deviceLocation);
                                            Navigator.pop(context);
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    child:
                                                        const RentalHouseDetailsScreen(),
                                                    type: PageTransitionType
                                                        .leftToRight));
                                          },
                                          child: Text("Tumia lile lile",style:TextStyle(color: kAppColor))),
                                  ElevatedButton(
                                      onPressed: () async {
                                        locationLoading.value = true;
                                        await getDevicelocation(provider);
                                      },
                                      child: Text(
                                          _currentUserData["location"] == null
                                              ? "Nipo eneo husika"
                                              : "Tumia la sasa",style:const TextStyle(color: kWhiteColor)))
                                ])
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                    "Watu watahitaji kuona mali yako kwenye ramani ili kufika kirahisi.\n Hivyo hakikisha upo eneo ilipo mali yako kisha bonyeza kitufe hapa chini"),
                                ElevatedButton(
                                    onPressed: () async {
                                      locationLoading.value = true;
                                      await getDevicelocation(provider);
                                    },
                                    child:const Text("Nipo eneo husika",style:TextStyle(color: kWhiteColor)))
                              ],
                            );
                }),
          );
        });
  }

  Future<void> getDevicelocation(AppDataProvider provider) async {
    bool deviceAllowed = false;
    await Geolocator.isLocationServiceEnabled().then((service) async {
      if (service == true) {
        await Geolocator.checkPermission().then((permission) async {
          if (permission == LocationPermission.always ||
              permission == LocationPermission.whileInUse) {
            deviceAllowed = true;
          } else {
            await Geolocator.requestPermission().then((locPermission) {
              if (permission == LocationPermission.always ||
                  permission == LocationPermission.whileInUse) {
                deviceAllowed = true;
              } else {
                locationLoading.value = false;
                UserReplyWindowsApi().showToastMessage(
                    context, "Ruhusu kifaa kichukue muelekeo");
              }
            });
          }
        });
      } else {
        locationLoading.value = false;
        UserReplyWindowsApi()
            .showToastMessage(context, "Washa Gps kwenye kifaa hiki.");
      }
    });
    if (deviceAllowed == true) {
      await Geolocator.getCurrentPosition().then((position) async {
        if (position != null) {
          _currentLocation = {
            "latitude": position.latitude,
            "longitude": position.longitude,
          };
          provider.deviceLocation = _currentLocation;
          if (provider.deviceLocation != null) {
            if (provider.userUploadRole == 0) {
              await _usersRef
                  .child(_auth.currentUser!.uid)
                  .child("location")
                  .update(provider.deviceLocation)
                  .then((value) {
                print(_currentUserData["location"]);
                Navigator.pop(context);
                Navigator.push(
                    context,
                    PageTransition(
                        child: const RentalHouseDetailsScreen(),
                        type: PageTransitionType.leftToRight));
              }).catchError((e) async {
                UserReplyWindowsApi().showToastMessage(context,
                    "Kunatatizo katika kurekodi eneo unalopatikana, tunajaribu tena..");
                await getDevicelocation(provider);
              });
            } else {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  PageTransition(
                      child: const RentalHouseDetailsScreen(),
                      type: PageTransitionType.leftToRight));
            }
            Navigator.pop(context);
            Navigator.push(
                context,
                PageTransition(
                    child: const RentalHouseDetailsScreen(),
                    type: PageTransitionType.leftToRight));
          } else {
            UserReplyWindowsApi().showToastMessage(context,
                "Kunatatizo katika kutambua muelekeo wa kifaa hiki,tunajaribu tena");
            await getDevicelocation(provider);
          }
        } else {
          locationLoading.value = false;
          UserReplyWindowsApi().showToastMessage(context,
              "Kunatatizo katika kutambua muelekeo wa kifaa hiki,tunajaribu tena");
          await getDevicelocation(provider);
        }
      }).catchError((error) async {
        UserReplyWindowsApi().showToastMessage(context,
            "Kunatatizo katika kutambua muelekeo wa kifaa hiki,tunajaribu tena");
        await getDevicelocation(provider);
      });
    }
  }
 }
