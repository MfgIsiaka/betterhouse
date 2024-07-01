import 'package:betterhouse/provider_services.dart';
import 'initial_building_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class RentalHouseDetailsScreen extends StatefulWidget {
   const RentalHouseDetailsScreen({ Key? key }) : super(key: key);

  @override
  _RentalHouseDetailsScreenState createState() => _RentalHouseDetailsScreenState();
}

class _RentalHouseDetailsScreenState extends State<RentalHouseDetailsScreen> {
final List<String> _rentalCategory=["fremu ya biashara","Nyumba ya kuishi","Jengo la ofisi","Godown"];
final List<String> _distanceFrmRoadChoices=["Mkabala na barabara(Hakuna kizuizi)","Ndani ya hatua 50","Ndani ya hatua 100","Nje ya hatua 100"];
final String _selectedDistanceFrmRoadStatus="";
final List<String> _electricityStatusChoices=["Atatumia pekeyake","Atashea na wengine","Haupo"];
final String _selectedElectricityStatus="";
final List<String> _waterStatusChoices=["Yamo ndani ya pango","Yapo ndani ya hatua 50","Yapo ndani ya hatua 100","Yapo nje ya hatua 100"];
final String _selectedWaterStatus="";
final List<String> _buildingTypeChoices=["Jengo la ghorofa","Jengo la kawaida"];
final String _selectedBuildingType="";
final List<DropdownMenuItem<String>> _rentalCategoryDrodownItems=[];
final String _selectedRentalCategory="";

getItems() {
  for(int i=0;i<_rentalCategory.length;i++){
     _rentalCategoryDrodownItems.add(DropdownMenuItem(
       value: _rentalCategory[i],
       child: Text(_rentalCategory[i])));
  }
}

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getItems();
  }

  @override
  Widget build(BuildContext context) {
    AppDataProvider dataProvider=Provider.of<AppDataProvider>(context);
    Size screenSize=MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: (){
          dataProvider.currentBuildingRegPage= AllDetailsScreen();
          // if(dataProvider.currentRentalRegPage==RentalImagesScreen()){
          //      setState(() {
          //        dataProvider.currentRentalRegPage=ResidentSocialServicesDetailsScreen();
          //      });
          // }else if(dataProvider.currentRentalRegPage==ResidentSocialServicesDetailsScreen()){
          //      setState(() {
          //        dataProvider.currentRentalRegPage=AllDetailsScreen();
          //      });
          // }   
        return Future.value(true);
      },
      child: Scaffold(
         appBar:AppBar(
           title:const Text("Tangaza mali yako"), 
         ),
         body: Container(
           height: screenSize.height,
           padding: const EdgeInsets.only(left: 4,right: 4,top: 5),
           child: AnimatedSwitcher(
             duration: const Duration(milliseconds: 400),
             transitionBuilder: (child,anim){
                Animation<Offset> offsetAnim=Tween(begin: const Offset(1,0),end: const Offset(0,0)).animate(anim);
                return SlideTransition(
                  position: offsetAnim,
                  child: child,
                  );
             },
             child: dataProvider.currentBuildingRegPage)
         ),    
      ),
    );
  }
}