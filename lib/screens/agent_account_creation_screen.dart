import 'package:avatar_glow/avatar_glow.dart';
import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/screens/choice_selection_screen.dart';
import 'package:betterhouse/screens/house_buildings_uploading_screens/house_building_details.dart';
import 'package:betterhouse/services/database_services.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class AgentAccountCreationScreen extends StatefulWidget {
  Map<dynamic, dynamic> agent;
  AgentAccountCreationScreen(this.agent, {Key? key});

  @override
  State<AgentAccountCreationScreen> createState() =>
      _AgentAccountCreationScreenState();
}

ValueNotifier<bool> locationLoading = ValueNotifier(false);

class _AgentAccountCreationScreenState
    extends State<AgentAccountCreationScreen> {
  final DatabaseReference _districtsRef =
      FirebaseDatabase.instance.reference().child("DISTRICTS");
  final DatabaseReference _regionsRef =
      FirebaseDatabase.instance.reference().child("REGIONS");
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.reference().child("USERS");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late GoogleMapController _googleMapController;
  final _agentNameCntrl = TextEditingController();
  final _agentDescriptionCntrl = TextEditingController();
  final _agentLocalAreaCntrl = TextEditingController();
  final Set<Marker> _mapMarkers = {};
  Map<String, double> _currentLocation = {};
  bool _showingMap = false;
  Region? _selectedRegion;
  District? _selectedDistrict;

  final _formKey = GlobalKey<FormState>();

  animateToCurrentLocation() async {
    AppDataProvider dataProvider =
        Provider.of<AppDataProvider>(context, listen: false);
    LatLng? _devLocation;
    setState(() {
      _devLocation = LatLng(dataProvider.deviceLocation["latitude"]!,
          dataProvider.deviceLocation["longitude"]!);
      _mapMarkers.add(Marker(
        draggable: true,
        onDragEnd: (newLocation) {
          UserReplyWindowsApi().showToastMessage(
              context, "${newLocation.latitude}  ${newLocation.longitude}");
        },
        infoWindow: const InfoWindow(
            title: "Ofisini",
            snippet: "Watu watakupata hapa wakihitaji kuona mali ulizonazo"),
        markerId: const MarkerId("myBuilding"),
        position: _devLocation!,
      ));
    });
    Future.delayed(const Duration(milliseconds: 3000), () {
      _googleMapController.animateCamera(CameraUpdate.newLatLng(_devLocation!));
      Future.delayed(const Duration(milliseconds: 600), () {
        _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(_devLocation!.latitude, _devLocation!.longitude),
                zoom: 15)));
      });
      //_googleMapController.
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getThisDeviceCurrentLocation();
    Future.delayed(const Duration(milliseconds: 2500), () {
      AppDataProvider dataProvider =
          Provider.of<AppDataProvider>(context, listen: false);
      showLocationAlertDialog(dataProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    AppDataProvider dataProvider =
        Provider.of<AppDataProvider>(context, listen: false);
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 1,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        title: const Text(
          "Akaunti ya dalali",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.only(left: 5, right: 5, top: 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: _agentNameCntrl,
                              validator: (val) {
                                if (val!.trim().isEmpty) {
                                  return 'Jaza jina la kikazi';
                                }
                              },
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  labelText: "Jina la kazi",
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            minLines: 3,
                            maxLines: 3,
                            controller: _agentDescriptionCntrl,
                            validator: (val) {
                              if (val!.trim().isEmpty) {
                                return 'Eleza kidogo unachofanya';
                              }
                            },
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                labelText: "Jielezee kidogo",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                          const SizedBox(height: 10),
                          const Text("Ofisi au makazi yako",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: kGreyColor)),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          showRegionsOrDistrictsBottomsheet(
                                              dataProvider, "regions");
                                        },
                                        child: AbsorbPointer(
                                          child: Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: Colors.grey)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                  _selectedRegion == null
                                                      ? "Chagua mkoa"
                                                      : _selectedRegion!.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                                IconButton(
                                                    onPressed: () {
                                                      showRegionsOrDistrictsBottomsheet(
                                                          dataProvider,
                                                          "regions");
                                                    },
                                                    icon: const Icon(
                                                        Icons.arrow_drop_down))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (_selectedRegion != null) {
                                            showRegionsOrDistrictsBottomsheet(
                                                dataProvider, "districts");
                                          } else {
                                            UserReplyWindowsApi()
                                                .showToastMessage(context,
                                                    "Chagua mkoa kwanza");
                                          }
                                        },
                                        child: AbsorbPointer(
                                          child: Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: Colors.grey)),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                  _selectedDistrict == null
                                                      ? "Chagua wilaya"
                                                      : _selectedDistrict!.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                )),
                                                IconButton(
                                                    onPressed:
                                                        _selectedRegion == null
                                                            ? null
                                                            : () {
                                                                showRegionsOrDistrictsBottomsheet(
                                                                    dataProvider,
                                                                    "districts");
                                                              },
                                                    icon: const Icon(
                                                        Icons.arrow_drop_down))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: 40,
                                  child: TextFormField(
                                    controller: _agentLocalAreaCntrl,
                                    validator: (val) {
                                      if (val!.trim().isEmpty) {
                                        return 'Jaza eneo unalopatikana';
                                      }
                                    },
                                    decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                        labelText: "Kata/tarafa/Mtaa/kitongoji",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 250,
                                  width: screenSize.width,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 3)),
                                  child: _showingMap == false
                                      ? const Center(
                                          child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child:
                                                  CircularProgressIndicator()))
                                      : GoogleMap(
                                          initialCameraPosition:
                                              const CameraPosition(
                                                  target: LatLng(-6.8, 39.2833),
                                                  zoom: 15),
                                          mapType: MapType.satellite,
                                          markers: _mapMarkers,
                                          onMapCreated:
                                              (GoogleMapController controller) {
                                            _googleMapController = controller;
                                            animateToCurrentLocation();
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ]),
                  ),
                ),
                ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() &&
                          _selectedRegion != null &&
                          _selectedDistrict != null) {
                        Map<String, dynamic> agentInfo = {
                          "userId": _auth.currentUser!.uid,
                          "name": _agentNameCntrl.text.trim(),
                          "description": _agentDescriptionCntrl.text.trim(),
                          "region": _selectedRegion!.name,
                          "district": _selectedDistrict!.name,
                          "localArea": _agentLocalAreaCntrl.text.trim(),
                          "location": dataProvider.deviceLocation
                        };
                        if (dataProvider.deviceLocation.isNotEmpty) {
                          UserReplyWindowsApi()
                              .showProgressBottomSheet(context);
                          String res =
                              await DatabaseApi().createAgentProfile(agentInfo);
                          if (res == "success") {
                            await _usersRef
                                .child(_auth.currentUser!.uid)
                                .once()
                                .then((value) {
                              var user = value.value;
                              Navigator.pop(context);
                              if (user != null) {
                                dataProvider.currentUser = user;
                                Navigator.push(
                                  context,
                                  PageTransition(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      child: const RentalHouseDetailsScreen(),
                                      type: PageTransitionType.rightToLeft),
                                );
                              } else {
                                Navigator.pushAndRemoveUntil(
                                    //jt,zp,wp
                                    context,
                                    PageTransition(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        child: const ChoiceSelection(),
                                        type: PageTransitionType.rightToLeft),
                                    (route) => false);
                              }
                            }).catchError((e) {
                              Navigator.pop(context);
                              Navigator.pushAndRemoveUntil(
                                  //jt,zp,wp
                                  context,
                                  PageTransition(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      child: const ChoiceSelection(),
                                      type: PageTransitionType.rightToLeft),
                                  (route) => false);
                            });
                          } else {
                            UserReplyWindowsApi().showToastMessage(
                                context, "Jaza taarifa zote.");
                          }
                        } else {
                          showLocationAlertDialog(dataProvider);
                        }
                      } else {
                        UserReplyWindowsApi()
                            .showToastMessage(context, "Jaza taarifa zote.");
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => kAppColor)),
                    child: const Text("Tuma"))
              ],
            ),
          )),
    );
  }

  void showLocationAlertDialog(AppDataProvider provider) {
    locationLoading.value = false;
    showGeneralDialog(
        barrierDismissible: false,
        barrierLabel: "location",
        context: context,
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, anim1, anim2) {
          Animation<Offset> offAnim = Tween<Offset>(
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ).animate(anim1);
          return SlideTransition(
            position: offAnim,
            child: StatefulBuilder(builder: (context, stateSetter) {
              return AlertDialog(
                title: Row(
                  children: const [
                    Icon(Icons.location_pin),
                    SizedBox(width: 10),
                    Text("Eneo unalopatikana"),
                  ],
                ),
                content: ValueListenableBuilder(
                    valueListenable: locationLoading,
                    builder: (context, locLoad, child) {
                      return (locLoad == true)
                          ? Column(mainAxisSize: MainAxisSize.min, children: [
                              const Text("Tunachukua eneo ulipo.."),
                              AvatarGlow(
                                glowColor: kAppColor,
                                //endRadius: 60,
                                duration: const Duration(milliseconds: 1000),
                                child: const Icon(Icons.location_pin),
                              ),
                              const Text("Tafadhali subiri"),
                            ])
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                  const Text(
                                      "Watu watahitaji kujua sehemu unapopatikana(ofisi/makazi) kupitia ramani.\n Hivyo hakikisha upo kwenye eneo lako kisha bonyeza kitufe hapa chini"),
                                  ElevatedButton(
                                      onPressed: () async {
                                        locationLoading.value = true;
                                        await getDevicelocation(provider);
                                      },
                                      child: const Text("Nipo eneo husika",
                                          style: TextStyle(color: kWhiteColor)))
                                ]);
                    }),
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

          await _usersRef
              .child(_auth.currentUser!.uid)
              .child("location")
              .update(_currentLocation)
              .then((value) {
            provider.deviceLocation = _currentLocation;
            Navigator.pop(context);
            locationLoading.value = false;
            setState(() {
              _showingMap = true;
            });
          });
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

  void showRegionsOrDistrictsBottomsheet(
      AppDataProvider provider, String choice) {
    Size screenSize = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        )),
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            )),
            height: screenSize.height * 0.7,
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      color: kGreyColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      )),
                  height: 40,
                  child: Center(
                      child: Text(
                    choice == "districts"
                        ? "Wilaya za ${_selectedRegion!.name.toString()}"
                        : "Mikoa ya ${provider.selectedCountry['name']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )),
                ),
                Expanded(
                  child: StreamBuilder(
                      stream: choice == "districts"
                          ? _districtsRef
                              .child(provider.selectedCountry["id"].toString())
                              .child(_selectedRegion!.id.toString())
                              .onValue
                          : _regionsRef
                              .child(provider.selectedCountry["id"].toString())
                              .onValue,
                      builder: (context, AsyncSnapshot<Event> snap) {
                        if (snap.connectionState == ConnectionState.done ||
                            snap.connectionState == ConnectionState.active) {
                          if (snap.data != null) {
                            if (choice == "regions") {
                              regions.clear();
                            }
                            if (choice == "districts") {
                              districts.clear();
                            }
                            if (choice == "regions") {
                              for (int i = 0;
                                  i < snap.data!.snapshot.value.length;
                                  i++) {
                                var val = snap.data!.snapshot.value[i];
                                regions.add(Region(val["id"], val["name"],
                                    val["latitude"], val["longitude"]));
                              }
                              // snap.data!.snapshot.value.forEach((val){

                              // });
                            }
                            if (choice == "districts") {
                              print(snap.data!.snapshot.value);
                              snap.data!.snapshot.value.forEach((val) {
                                districts.add(District(val["id"], val["name"]));
                              });
                            }
                            return ListView.builder(
                                itemCount: choice == "districts"
                                    ? districts.length
                                    : regions.length,
                                itemBuilder: (context, index) {
                                  Region? thisRegion;
                                  District? thisDistrict;
                                  if (choice == "regions") {
                                    thisRegion = regions[index];
                                  }
                                  if (choice == "districts") {
                                    thisDistrict = districts[index];
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(top: 3),
                                    decoration: BoxDecoration(
                                        border: Border(
                                            left: BorderSide(
                                                color: kAppColor, width: 5),
                                            right: BorderSide(
                                                color: kAppColor, width: 5))),
                                    child: ListTile(
                                      onTap: () {
                                        if (choice == "regions") {
                                          setState(() {
                                            _selectedDistrict = null;
                                            _selectedRegion = thisRegion;
                                          });
                                          Navigator.pop(context);
                                          showRegionsOrDistrictsBottomsheet(
                                              provider, "districts");
                                        }
                                        if (choice == "districts") {
                                          setState(() {
                                            _selectedDistrict = thisDistrict;
                                          });
                                          Navigator.pop(context);
                                        }
                                      },
                                      dense: true,
                                      visualDensity:
                                          const VisualDensity(vertical: -3),
                                      title: Text(choice == "districts"
                                          ? thisDistrict!.name
                                          : thisRegion!.name),
                                    ),
                                  );
                                });
                          } else {
                            return UserReplyWindowsApi().showLoadingIndicator();
                          }
                        } else {
                          return Center(
                            child: UserReplyWindowsApi().showLoadingIndicator(),
                          );
                        }
                      }),
                ),
              ],
            ),
          );
        });
  }
}
