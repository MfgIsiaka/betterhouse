
import 'dart:ui';
import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:betterhouse/services/server_variable_services.dart';
import 'package:number_selection/number_selection.dart';
import 'package:provider/provider.dart';
import 'package:show_up_animation/show_up_animation.dart';

class BuildingsFilterScreen extends StatefulWidget {
   const BuildingsFilterScreen({Key? key}) : super(key: key);

  @override
  State<BuildingsFilterScreen> createState() => _BuildingsFilterScreenState();
}

class _BuildingsFilterScreenState extends State<BuildingsFilterScreen> {
final DatabaseReference _districtsRef=FirebaseDatabase.instance.reference().child("DISTRICTS");
final DatabaseReference _regionsRef=FirebaseDatabase.instance.reference().child("REGIONS");
Region? _selectedRegion;
District? _selectedDistrict;
String _selectedHouseOrLand="";
String _selectedPropertyPurpose="";
String _selectedPropertyType="";
String _selectedSubCreType="";
String _selectedCreBuildingClass="";
String _selectedResidentStatus="";
double _paddingTop=0.0;
late Size screenSize;
final bool _hasFens=false;
final bool _hasParking=false;

String _bedRoomCount="1";
String _storeRoomCount="0";
String _bathRoomCount="0";
String _kitchenRoomCount="0";
String _selfContBedRoomCount="0";
String _livingRoomCount="0";
String _diningRoomCount="0";
List<int> _selectedSocialServices=[];
final List<int> _selectedInsideServices=[];
final ExpandableController _expController=ExpandableController();


  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration.zero,(){
      AppDataProvider dataProvider=Provider.of<AppDataProvider>(context,listen: false);
       setState(() {
          if(dataProvider.propertyFilters["AllFilters"]!=null){
        if(dataProvider.propertyFilters["AllFilters"]["houseOrLand"]!=null){
         _selectedHouseOrLand=houseOrLand[dataProvider.propertyFilters["AllFilters"]["houseOrLand"]];  
       }
       if(dataProvider.propertyFilters["AllFilters"]["purpose"]!=null){
         _selectedPropertyPurpose=propertyPurpose[dataProvider.propertyFilters["AllFilters"]["purpose"]];  
       }
       if(dataProvider.propertyFilters["AllFilters"]["houseOrLand"]==0 && dataProvider.propertyFilters["AllFilters"]["purpose"]==0){
         if(dataProvider.propertyFilters["AllFilters"]["buildingType"]!=null){
            _selectedPropertyType=commercialBuildingTypes[dataProvider.propertyFilters["AllFilters"]["buildingType"]];            
         }
         if(dataProvider.propertyFilters["AllFilters"]["buildingClass"]!=null){
            _selectedCreBuildingClass=creBuildingClasses[dataProvider.propertyFilters["AllFilters"]["buildingClass"]];            
         }
         if(dataProvider.propertyFilters["AllFilters"]["subBuildingType"]!=null){
            _selectedSubCreType=commercialSubBuilding[dataProvider.propertyFilters["AllFilters"]["buildingType"].toString()][dataProvider.propertyFilters["AllFilters"]["subBuildingType"]];            
         }  
       }
        
       if(dataProvider.propertyFilters["AllFilters"]["houseOrLand"]==0 && dataProvider.propertyFilters["AllFilters"]["purpose"]==1){
          if(dataProvider.propertyFilters["AllFilters"]["buildingType"]!=null){
            _selectedPropertyType=residentBuildingTypes[dataProvider.propertyFilters["AllFilters"]["buildingType"]];            
         }
         if(dataProvider.propertyFilters["AllFilters"]["buildingStatus"]!=null){
            _selectedResidentStatus=residentBuildingStatus[dataProvider.propertyFilters["AllFilters"]["buildingStatus"]];            
         }
       }
          if(dataProvider.propertyFilters["AllFilters"]["socialServices"]!=null){
             _selectedSocialServices=dataProvider.propertyFilters["AllFilters"]["socialServices"];
          }

       }
       });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppDataProvider dataProvider=Provider.of<AppDataProvider>(context,listen: false);
     screenSize=MediaQuery.of(context).size;
    _paddingTop=MediaQueryData.fromWindow(window).padding.top;
    _expController.expanded=true;
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
             Container(
              decoration:const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black
                  )
                )
              ),
              child: Row(
                children: [
                  Expanded(child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(onPressed: (){
                      Navigator.pop(context);
                    },
                     icon: Icon(Icons.arrow_back,color: kAppColor,)),
                  )),
                  const Text("Chuja data",style: TextStyle(fontSize: 19,fontWeight:FontWeight.bold,)),
                  Expanded(child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(onPressed: (){
                          setState(() {
                            dataProvider.propertyFilters["AllFilters"]={};
                            });
                            Navigator.pop(context,"refresh");
                        }, icon:const Icon(Icons.refresh)),
                      )),
                ],
              ),
             )    
            ,Expanded(child: Container(
              padding:const EdgeInsets.only(
                left: 5,right: 5,top: 5
              ),
              child: ListView(
              children: [
              const Text("Aina ya mali",style:TextStyle(fontWeight:FontWeight.bold)), 
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey
                      )
                    ),
                  child:  RadioGroup<String>.builder(
                 spacebetween: 35,
                 groupValue: _selectedHouseOrLand,
                  onChanged:(val){
                     setState(() {
                        _selectedPropertyPurpose="";
                        _selectedPropertyType="";
                        _selectedHouseOrLand=val.toString();
                     });
                  },
                  items: houseOrLand, 
                  itemBuilder: (item)=>RadioButtonBuilder(item))
              ),
              const SizedBox(
                height:10,
                ),
              const Text("Matumizi/malengo",style:TextStyle(fontWeight:FontWeight.bold)), 
              Container(
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey
                )
              ),
                child:  RadioGroup<String>.builder(
                    spacebetween: 35,
                    groupValue: _selectedPropertyPurpose,
                      onChanged:(val){
                        if(_selectedHouseOrLand.isNotEmpty){
                          setState(() {
                            _selectedPropertyPurpose=val.toString();
                            _selectedPropertyType="";
                            _selectedSubCreType="";
                            _selectedCreBuildingClass="";
                          });
                          
                          if(houseOrLand.indexWhere((e) => e==_selectedHouseOrLand)==0){
                            if(propertyPurpose.indexWhere((el) => el==val)==0){
                              showDialog(context: context, builder: (context){
                                return AlertDialog(
                                  title:const Center(child: Text("DARAJA LA JENGO")),
                                  content: ListView.builder(
                                    itemCount: creBuildingClasses.length,
                                    shrinkWrap:true,
                                    itemBuilder: (ctx,ind){
                                    String classDescription=ind==0?"Jengo jipya, location nzuri,Miundombinu bora":ind==1?"Jengo sio jipya, location yoyote,Miundombinu ya kawaida":"Miaka 20+,location yoyote, Linahitaji marekebisho ";
                                    return Container(
                                      decoration:const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.black,
                                          )
                                        )
                                      ),
                                      child: ListTile(
                                        onTap: (){
                                        setState(() {
                                          _selectedCreBuildingClass=creBuildingClasses[ind];
                                        });
                                        Navigator.pop(context);
                                        showBuildingsRealEstates(propertyPurpose.indexWhere((el) => el==val),houseOrLand.indexWhere((element) => element==_selectedHouseOrLand));
                                        },
                                        title:Text(creBuildingClasses[ind],style:const TextStyle(fontWeight: FontWeight.bold)),
                                        subtitle: Text(classDescription),
                                      ),
                                    );
                                    }),
                                );  
                              });
                            }else{
                            showDialog(context: context, builder: (context){
                                return AlertDialog(
                                  title:const Center(child: Text("HALI YA JENGO")),
                                  content: ListView.builder(
                                    itemCount: residentBuildingStatus.length,
                                    shrinkWrap:true,
                                    itemBuilder: (ctx,ind){
                                    String thisStatus=residentBuildingStatus[ind];
                                    return Container(
                                      decoration:const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.black,
                                          )
                                        )
                                      ),
                                      child: ListTile(
                                        onTap: (){
                                        setState(() {
                                          _selectedResidentStatus=thisStatus;
                                        });
                                        Navigator.pop(context);
                                        showBuildingsRealEstates(propertyPurpose.indexWhere((el) => el==val),houseOrLand.indexWhere((element) => element==_selectedHouseOrLand));
                                        },
                                        title:Text(thisStatus,style:const TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    );
                                    }),
                                );  
                              });
                          
                            }
                          }else if(houseOrLand.indexWhere((e) => e==_selectedHouseOrLand)==1){
                            setState(() {
                              _selectedPropertyPurpose=val!;
                            }); 
                          }
                        }else{
                          UserReplyWindowsApi().showToastMessage(context,"Chagua aina ya mali yako kwanza");
                        }
                      },
                      items: propertyPurpose, 
                      itemBuilder: (item)=>RadioButtonBuilder(item))
              ),  
              _selectedHouseOrLand.isEmpty || _selectedHouseOrLand=="Eneo la ardhi" || _selectedPropertyPurpose.isEmpty?Container():
              Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
            const SizedBox(height:10,),
            Text("Aina ya jengo la ${_selectedPropertyPurpose.toLowerCase()}",style:const TextStyle(fontWeight:FontWeight.bold)),
             Container(
             width:screenSize.width,
             padding:const EdgeInsets.all(10),
             decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(10),
             border: Border.all(
               color: Colors.grey
             )
           ),
             child:_selectedPropertyPurpose=="Biashara"?Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                  Padding( 
                  padding:const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                     const Text("Daraja la jengo - ",style:TextStyle(fontWeight:FontWeight.w400)),Text(_selectedCreBuildingClass.isEmpty?"Yoyote":_selectedCreBuildingClass,style:TextStyle(color: kAppColor,fontWeight:FontWeight.bold)),
                    ],
                  )),
                 Padding(
                  padding:const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                     const Text("Aina ya jengo - ",style:TextStyle(fontWeight:FontWeight.w400)),Expanded(child: Text(_selectedPropertyType.isEmpty?"Yoyote": _selectedPropertyType+" - "+_selectedSubCreType,maxLines: 1,overflow: TextOverflow.ellipsis, style:TextStyle(color:kAppColor,fontWeight:FontWeight.bold))),
                    ],
                  )),   
              ]
             ):Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Padding( 
                  padding:const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                     const Text("Aina ya jengo - ",style:TextStyle(fontWeight:FontWeight.w400)),const Spacer(),Text(_selectedPropertyType.isEmpty?"Yoyote":_selectedPropertyType,style:TextStyle(color: kAppColor,fontWeight:FontWeight.bold)),
                    ],
                  )),
                                  Padding( 
                  padding:const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                     const Text("Hali ya jengo - ",style:TextStyle(fontWeight:FontWeight.w400)),const Spacer(),Text(_selectedResidentStatus.isEmpty?"Yoyote":_selectedResidentStatus,style:TextStyle(color: kAppColor,fontWeight:FontWeight.bold)),
                    ],
                  )),
                 Padding( 
                  padding:const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                     const Text("Vyumba vya kulala - ",style:TextStyle(fontWeight:FontWeight.w400)),
                    const Spacer(),SizedBox(                      
                       height:35,
                       child: NumberSelection(
                         initialValue:int.parse(_bedRoomCount),
                         minValue:1,
                         onChanged:(newVal){
                           _bedRoomCount=newVal.toString();
                         }
                       ),
                     ),
                    ],
                  )),  
                  Padding( 
                  padding:const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                     const Text("Sebure ya kukaa(sitting) - ",style:TextStyle(fontWeight:FontWeight.w400)),
                   const Spacer(),SizedBox(
                      height:35,
                       child: NumberSelection(
                         initialValue:int.parse(_livingRoomCount),
                         minValue:0,
                         onChanged:(newVal){
                           _livingRoomCount=newVal.toString();
                         }
                       ),
                     ),
                    ],
                  )),  
                   Padding( 
                  padding:const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                     const Text("Sebure ya chakula(sitting) - ",style:TextStyle(fontWeight:FontWeight.w400)),
                   const Spacer(),SizedBox(
                      height:35,
                       child: NumberSelection(
                         initialValue:int.parse(_diningRoomCount),
                         minValue:0,
                         onChanged:(newVal){
                           _diningRoomCount=newVal.toString();
                         }
                       ),
                     ),
                    ],
                  )),  
                  Padding( 
                  padding:const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                     const Text("Vyumba vya jiko- ",style:TextStyle(fontWeight:FontWeight.w400)),
                   const Spacer(),SizedBox(
                      height:35,
                       child: NumberSelection(
                         initialValue:int.parse(_kitchenRoomCount),
                         minValue:0,
                         onChanged:(newVal){
                           _kitchenRoomCount=newVal.toString();
                         }
                       ),
                     ),
                    ],
                  )),  
                  Padding( 
                  padding:const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                     const Text("Vyumba vya stoo - ",style:TextStyle(fontWeight:FontWeight.w400)),
                   const Spacer(),SizedBox(
                      height:35,
                       child: NumberSelection(
                         initialValue:int.parse(_storeRoomCount),
                         minValue:0,
                         onChanged:(newVal){
                           _storeRoomCount=newVal.toString();
                         }
                       ),
                     ),
                    ],
                  )),                 
                  Padding( 
                  padding:const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                     const Text("Vyumba vyenye choo/bafu - ",style:TextStyle(fontWeight:FontWeight.w400)),
                   const Spacer(),SizedBox(
                      height:35,
                       child: NumberSelection(
                         initialValue:int.parse(_selfContBedRoomCount),
                         minValue:0,
                         onChanged:(newVal){
                           _selfContBedRoomCount=newVal.toString();
                         }
                       ),
                     ),
                    ],
                  )),                 
                               
                  Padding( 
                  padding:const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                     const Text("Idadi ya vyoo/bafu - ",style:TextStyle(fontWeight:FontWeight.w400)),
                   const Spacer(),SizedBox(
                      height:35,
                       child: NumberSelection(
                         initialValue:int.parse(_bathRoomCount),
                         minValue:0,
                         onChanged:(newVal){
                           _bathRoomCount=newVal.toString();
                         }
                       ),
                     ),
                    ],
                  )),                 
                
              ]
             ) 
              ),
            ],
           ),  
              const SizedBox(
              height:10,
              ),
               ],),
            )
            ),
            Container(
              margin:const EdgeInsets.only(left: 5,right: 5,bottom:5),
              child: ElevatedButton(onPressed: (){
                    if(dataProvider.propertyFilters["AllFilters"].isNotEmpty || dataProvider.propertyFilters["AllFilters"]!=null){
                      dataProvider.propertyFilters["AllFilters"]={};
                    if(_selectedPropertyPurpose.isNotEmpty){
                      dataProvider.propertyFilters["AllFilters"].addAll({"purpose":propertyPurpose.indexWhere((el) => el==_selectedPropertyPurpose)});
                    }
                    if(_selectedHouseOrLand.isNotEmpty){
                      dataProvider.propertyFilters["AllFilters"].addAll({"houseOrLand":houseOrLand.indexWhere((el) => el==_selectedHouseOrLand)});
                    }
                    
                    dataProvider.propertyFilters["AllFilters"].addAll({"socialServices":_selectedSocialServices});
                    
                    if(_selectedPropertyPurpose==propertyPurpose[0] && _selectedHouseOrLand==houseOrLand[0]){
                      if(_selectedPropertyType.isNotEmpty){
                          dataProvider.propertyFilters["AllFilters"].addAll({"buildingType":commercialBuildingTypes.indexWhere((el) => el==_selectedPropertyType)});
                      }
                      if(_selectedSubCreType.isNotEmpty){
                        dataProvider.propertyFilters["AllFilters"].addAll({"subBuildingType":commercialSubBuilding[commercialBuildingTypes.indexWhere((el) => el==_selectedPropertyType).toString()].indexWhere((e)=> e==_selectedSubCreType)});
                      }
                      if(_selectedCreBuildingClass.isNotEmpty){
                        dataProvider.propertyFilters["AllFilters"].addAll({"buildingClass":creBuildingClasses.indexWhere((el) => el==_selectedCreBuildingClass)});
                      }
                      dataProvider.propertyFilters["AllFilters"].addAll({"insideServices":_selectedInsideServices});
                     }

                     if(_selectedPropertyPurpose==propertyPurpose[1] && _selectedHouseOrLand==houseOrLand[0]){
                      if(_selectedPropertyType.isNotEmpty){
                        dataProvider.propertyFilters["AllFilters"].addAll({"buildingType":residentBuildingTypes.indexWhere((el) => el==_selectedPropertyType)});
                      }
                      if(_selectedResidentStatus.isNotEmpty){
                        dataProvider.propertyFilters["AllFilters"].addAll({"buildingStatus":residentBuildingStatus.indexWhere((el) => el==_selectedResidentStatus)});
                      }
                         
                      dataProvider.propertyFilters["AllFilters"].addAll({"bedRooms":int.parse(_bedRoomCount)});
                      dataProvider.propertyFilters["AllFilters"].addAll({"livingRooms":int.parse(_livingRoomCount)});
                      dataProvider.propertyFilters["AllFilters"].addAll({"diningRooms":int.parse(_diningRoomCount)});
                      dataProvider.propertyFilters["AllFilters"].addAll({"kitchenRooms":int.parse(_kitchenRoomCount)});
                      dataProvider.propertyFilters["AllFilters"].addAll({"storeRooms":int.parse(_storeRoomCount)});
                      dataProvider.propertyFilters["AllFilters"].addAll({"selfRooms":int.parse(_selfContBedRoomCount)});
                      dataProvider.propertyFilters["AllFilters"].addAll({"bathRooms":int.parse(_bathRoomCount)});
                     }
                    }
                  //UserReplyWindowsApi().showToastMessage(context,dataProvider.propertyFilters["AllFilters"].toString());                     
                  Navigator.pop(context,"refresh");
              },
               child:const Text("Chuja",style:TextStyle(color: kWhiteColor))),
            )
            ],
          ),
        ),
      ),
    );
  }

 void showBuildingsRealEstates(int purpose, int houseOrLand) {
    showModalBottomSheet(context: context,
     isScrollControlled: true,
     builder:(context){
       return SizedBox(
         height:screenSize.height-_paddingTop,
         child: Column(
           children:[
            Container(
             height:45,
             decoration:BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: kAppColor
                )
              )
             ),
             child: Center(child: Text(purpose==0?"Aina ya jengo la biashara":"Aina ya jengo la makazi",style:const TextStyle(fontWeight: FontWeight.bold,fontSize:18))),
            ),
            Expanded(
              child: ListView.builder(
                itemCount:purpose==0?commercialBuildingTypes.length:residentBuildingTypes.length,
                itemBuilder: (context,ind){
                String thisBuilding=purpose==0?commercialBuildingTypes[ind]:residentBuildingTypes[ind];
                String thisMeaning=purpose==0?"Please wait!!":residentBuildingMeaning[ind];
                return ShowUpAnimation(
                  direction:Direction.horizontal,
                  delayStart:const Duration(milliseconds: 700),
                  child: ListTile(
                    onTap:(){
                      _selectedPropertyType=thisBuilding;
                      _selectedPropertyPurpose=propertyPurpose[purpose];                      
                      setState(() {                      
                      });
                      Navigator.pop(context);
                      if(purpose==0){
                        showSubCommercialBuildingsRealEstates(commercialBuildingTypes.indexWhere((el) => el==_selectedPropertyType));
                       }
                    },
                    contentPadding:const EdgeInsets.all(10),
                    title:Text(thisBuilding),
                    trailing: IconButton(onPressed: (){
                      showDialog(context: context, builder: (context){
                        return AlertDialog(
                          title: Text(thisBuilding),
                          content: Text(thisMeaning),
                          actions:[
                            TextButton(onPressed: (){
                              Navigator.pop(context);
                            }, child:const Text("Sawa"))
                          ]
                        );
                      });
                    }, icon:const Icon(Icons.help)),
                    leading:CircleAvatar(
                      child: Text(thisBuilding.substring(0,1)),
                    ),
                  ) );
              }),
            ) 
           ]
         ),
       );
    });
  }
 
 void showSubCommercialBuildingsRealEstates(int propertyTyp) {
     showModalBottomSheet(context: context,
     isScrollControlled: true,
     builder:(context){
       return SizedBox(
         height:screenSize.height-_paddingTop,
         child: Column(
           children:[
            Container(
             height:45,
             decoration:BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: kAppColor
                )
              )
             ),
             child: Center(child: Text("Aina ya jengo la ${commercialBuildingTypes[propertyTyp]}",style:const TextStyle(fontWeight: FontWeight.bold,fontSize:18))),
            ),
            Expanded(
              child: ListView.builder(
                itemCount:commercialSubBuilding[propertyTyp.toString()].length,
                itemBuilder: (context,ind){
                String thisBuilding=commercialSubBuilding[propertyTyp.toString()][ind];
                String thisMeaning="";
                return ShowUpAnimation(
                  direction:Direction.horizontal,
                  delayStart:const Duration(milliseconds: 700),
                  child: ListTile(
                    onTap:(){         
                      _selectedSubCreType= thisBuilding;           
                      setState(() {                      
                      });
                      Navigator.pop(context);
                    },
                    contentPadding:const EdgeInsets.all(10),
                    title:Text(thisBuilding),
                    trailing: IconButton(onPressed: (){
                      showDialog(context: context, builder: (context){
                        return AlertDialog(
                          title: Text(thisBuilding),
                          content: Text(thisMeaning),
                          actions:[
                            TextButton(onPressed: (){
                              Navigator.pop(context);
                            }, child:const Text("Sawa"))
                          ]
                        );
                      });
                    }, icon:const Icon(Icons.help)),
                    leading:CircleAvatar(
                      child: Text(thisBuilding.substring(0,1)),
                    ),
                  ) );
              }),
            ) 
           ]
         ),
       );
    });
  
  }

}