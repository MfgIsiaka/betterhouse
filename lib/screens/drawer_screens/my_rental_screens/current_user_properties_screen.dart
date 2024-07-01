import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/screens/rental_screens/rental_details_screen_to_client.dart';
import 'package:betterhouse/services/database_services.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/modal_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class CurrentUserProperties extends StatefulWidget {
  const CurrentUserProperties({Key? key}) : super(key: key);

  @override
  State<CurrentUserProperties> createState() => _CurrentUserPropertiesState();
}

class _CurrentUserPropertiesState extends State<CurrentUserProperties> {
final List<DocumentSnapshot> _buildingsDocList = [];
DocumentSnapshot? _lastDocument;  
final ScrollController _gridAutoScrController=ScrollController();
  bool _isLoadingFirstTime = true;
  bool _isFetchingNext = false;
  final List<PropertyInfo> _buildingsList = [];
  final int _buildingsListLength = 0;
  Map<String,dynamic> propertyOwner={};
 
 Future<void> getPropertiesFromDatabase(AppDataProvider dataProvider)async{
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

    _buildingsDocList.addAll(await DatabaseApi().getCurrentUserProperties(filter, dataProvider));
    if (_buildingsDocList.isNotEmpty) {
      for (int i = 0; i < _buildingsDocList.length; i++) {
        Map<String, dynamic> data =
            _buildingsDocList[i].data()! as Map<String, dynamic>;
            PropertyInfo building = PropertyInfo().initializeData(data);
           _buildingsList.add(building);
      }
      _lastDocument = _buildingsDocList.last;
      //_lastDocument.
    }
    setState(() {
      _isFetchingNext = false;
      _isLoadingFirstTime = false;
        _buildingsDocList.clear();
    });
  }
 

@override
  void initState() {
    // TODO: implement initState
    super.initState();
   
    Future.delayed(Duration.zero,()async{
    AppDataProvider dataProvider =Provider.of<AppDataProvider>(context, listen: false);  
    await getPropertiesFromDatabase(dataProvider);
      _gridAutoScrController.addListener(() async {
        if (_gridAutoScrController.hasClients) {
          if (_gridAutoScrController.offset >=
                  _gridAutoScrController.position.maxScrollExtent &&
              !_gridAutoScrController.position.outOfRange) {
            if (_isFetchingNext == false) {
              await getPropertiesFromDatabase(dataProvider);
            }
          }
        }
      }); 
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
        AppDataProvider dataProviderListen =
        Provider.of<AppDataProvider>(context, listen: false);
    AppDataProvider dataProviderNotListen =
        Provider.of<AppDataProvider>(context, listen: false);  
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon:const Icon(Icons.arrow_back,color: Colors.black)),
        title:const Text("Mali zako",style: TextStyle(color: Colors.black),),backgroundColor: kWhiteColor,),
      body: Stack(
        children: [
      Container(
            child: _isLoadingFirstTime == true
                    ? Center(child: UserReplyWindowsApi().showLoadingIndicator())
                    : _buildingsList.isEmpty
                        ?const Center(
                            child: Text("Hauna mali kwa sasa",style:TextStyle(fontWeight: FontWeight.bold)),
                          )
                        :AlignedGridView.count(
                            crossAxisCount: screenSize.width <= 400
                                ? 1
                                : screenSize.width <= 640
                                    ? 2
                                    : screenSize.width <= 960
                                        ? 2
                                        : 4,
                            padding:const EdgeInsets.all(0),
                            physics:const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            mainAxisSpacing: 5,
                            controller: _gridAutoScrController,
                            itemCount: _buildingsList.length,
                            itemBuilder: (context, _currentIndex) {
                              CommercialBuilding? commercial;
                              ResidentBuilding? residential;
                              PropertyInfo building =
                                  _buildingsList[_currentIndex];
                              int soldStatus=building.sold;
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
                                   date="Sasa";  
                                }
                              return StatefulBuilder(
                                builder: (context,stateSetter) {
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
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.stretch ,
                                          children: [
                                          GestureDetector(
                                                          onTap: () {                                              
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        BuildingDetailsToClientScreen(
                                                                            building)));
                                                          },
                                                          onDoubleTap: () {
                                                            dataProviderListen.selectedHouse=building;
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        BuildingDetailsToClientScreen(
                                                                            building)));
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
                                                                       const Center(
                                                                            child: SizedBox(
                                                                                width: 15,
                                                                                height: 15,
                                                                                child:
                                                                                    CircularProgressIndicator())),
                                                                    imageUrl:
                                                                        building.coverImage),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                          Container(
                                            padding: EdgeInsets.only(left: 4,right: 4),
                                            child:building.suspended==1?ElevatedButton(
                                              style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red)),
                                              onPressed:(){
                                             AwesomeDialog(context: context,
                                               showCloseIcon: true,
                                               dialogType: DialogType.INFO,
                                               title: "Taarifa",
                                               desc:"building.suspensionReason.toString()"+"\n Kama unapingamizi lolote wasiliana nasi kwa 'betterhousehelp@gmail.com'.",
                                             ).show();
                                            },child:Text("Imezuiliwa"),):ElevatedButton(onPressed:soldStatus==1?null:(){
                                             AwesomeDialog(context: context,
                                               dialogType: DialogType.INFO,
                                               title: "Taarifa",
                                               desc:"Kama mali hii imeshapata mteja bofya hapa chini ili isiendelee kuonekana\n (wewe utaendelea kuiona hapa)",
                                               btnOkText: "Ondoa kwenye orodha",
                                               showCloseIcon: true,
                                               buttonsTextStyle:const TextStyle(color: Colors.black),
                                               btnOkOnPress: ()async{
                                                 //Navigator.pop(context);
                                                if(building.userId==dataProviderListen.currentUser["id"]){
                                                  UserReplyWindowsApi().showProgressBottomSheet(context);
                                                 String res=await DatabaseApi().changeSoldPropertyStatus(building);
                                                 Navigator.pop(context);
                                                 if(res=="success"){
                                                 UserReplyWindowsApi().showToastMessage(context,"Mali imeondolewa kwenye orodha..");
                                                  stateSetter((){
                                                    soldStatus=1;
                                                  });
                                                 }else{
                                                   UserReplyWindowsApi().showToastMessage(context,"Kunatatizo katika kufuta mali hii");
                                                 }
                                                }else{
                                                 UserReplyWindowsApi().showToastMessage(context,"Huwezi kufanya kitendo hiki");
                                                }
                                               }
                                             ).show();
                                            },child:Text(building.sold==0?"Ipo wazi":building.operation==0?"Imeshauzwa":"Imeshapangishwa"),),
                                          ) 
                                          ],
                                        ),
                                      );
                                }
                              );
                            })
,
          ),
      _isFetchingNext==true && _isLoadingFirstTime==false? const Align(
      alignment: Alignment.bottomCenter,
      child:SizedBox(width: 20,height: 20,
        child: CircularProgressIndicator(),
      ),
    ):Container(),
        ],
      )
    );
  }
}