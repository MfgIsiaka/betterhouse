import 'dart:math';
import 'dart:ui';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:betterhouse/screens/house_buildings_uploading_screens/building_images_screen.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/server_variable_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:number_selection/number_selection.dart';
import 'package:provider/src/provider.dart';
import 'package:show_up_animation/show_up_animation.dart';
import 'package:sms_autofill/sms_autofill.dart';

class AllDetailsScreen extends StatefulWidget {
   AllDetailsScreen({ Key? key }) : super(key: key);

  @override
  _AllDetailsScreenState createState() => _AllDetailsScreenState();
}

class _AllDetailsScreenState extends State<AllDetailsScreen> {
final DatabaseReference _usersRef=FirebaseDatabase.instance.reference().child("USERS");
final FirebaseAuth _auth=FirebaseAuth.instance;
String selectedRentelCompletionStatus="";
String electricityShareValue="1";
String _selectedDistanceFrmRoadStatus="";
String _selectedElectricityStatus="";
String _selectedWaterStatus="";
String _selectedBuildingType="";
String _selectedAssetStatus="";
List<String> _assets=[];
ExpandableController _expController=ExpandableController();
String _selectedRentalCategory="";
final _singlePeriodAmountCntrl=TextEditingController();
final _rentalDescriptionCntrl=TextEditingController();
List<Color> _assetColors=[];
final control=TextEditingController();
bool _hasStore=false;
bool _hasKitchen=false;
String _selectedParkingStatus="";

late AppDataProvider dataProvider;
bool sendingOtp=false; 
final _phoneNumberTxtCntrl=TextEditingController();
String smsCode="";
Map<dynamic,dynamic> _phoneCredential={};
String _countryCode="";
String _selectedPayPeriod="";
late int _noOfPaymentPeriods;
int? _totalRentalBill;
String _selectedPayCurrency="TSH";
String _selectedBrokerPocketCurrency="TSH";
String _selectedAreaDimension="sq ft";
final _brokersPocketCntr=TextEditingController();
final _areaSizeCntr=TextEditingController();
final _titleCntr=TextEditingController();
String _selectedHouseOrLand="";
String _selectedPropertyPurpose="";
String _selectedPropertyType="";
String _selectedRentalSize="";
String _selectedSubCreType="";
String _selectedCreBuildingClass="";
double _paddingTop=0.0;
late Size screenSize;
bool _hasFens=false;
bool _hasParking=false;
String _bedRoomCount="1";
String _storeRoomCount="0";
String _bathRoomCount="0";
String _kitchenRoomCount="0";
String _selfContBedRoomCount="0";
String _livingRoomCount="0";
String _diningRoomCount="0";
String _selectedResidentStatus="";
List<int> _selectedSocialServices=[];
List<int> _selectedInsideServices=[];
Map<String,dynamic> _buildingData={};
  
  @override
  Widget build(BuildContext context) {
    int _currentAsset=0;
    dataProvider=Provider.of<AppDataProvider>(context);
    screenSize=MediaQuery.of(context).size;
    _countryCode=dataProvider.selectedCountry["countryCode"];
    _paddingTop=MediaQueryData.fromWindow(window).padding.top;
    _expController.expanded=false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:[
     Row(
       children: [
        const CircleAvatar(
           radius: 13,
           child: Text("1"),
         ),
        const SizedBox(
           width: 20,
         ),
       const Text("Taarifa za mali yako",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 15)),
         CustomPopupMenu(child:const Icon(Icons.help_outline,color:Colors.blueGrey),
         verticalMargin: 0.0,
          menuBuilder: (){
            return ShowUpAnimation(
              child: Container(
                padding:const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(20)
                ),
                width: 200,
                child: Text("Taarifa hizi zitawezesha wateja wanaotaka pango lenye sifa hizi kukupata kwa haraka zaidi"),),
            );
          }, pressType: PressType.singleClick),
           SizedBox(width: 20,),
          Row(
            children:const [
              Icon(Icons.arrow_forward),
              CircleAvatar(
              radius: 15,
              backgroundColor: kGreyColor,
              child: Text("3",style: TextStyle(color: kWhiteColor),),
             ),
            ]
          )
       ],
     ),   
     Expanded(
       child: SingleChildScrollView(
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children:[
           const SizedBox(
            height:10,
            ),
           const Text("Aina ya mali yako",style:TextStyle(fontWeight:FontWeight.bold)), 
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
                // activeColor: kDominantColor,
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
                                     _selectedCreBuildingClass=creBuildingClasses[ind];
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
                                    _selectedResidentStatus=thisStatus;
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
            const SizedBox(
            height:10,
            ),
            const Text("Kichwa cha mali yako",style:TextStyle(fontWeight:FontWeight.bold)),
            SizedBox(
              height: 45,
              child: TextFormField(
                controller:_titleCntr,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  hintText: "Andika (mfano: Apatment ya vyumba 6)",
                  border:OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                    )
                  ),
                  ),
            ),
          _selectedHouseOrLand!=houseOrLand[0]?Container(): const SizedBox(
            height:10,
            ),
          _selectedHouseOrLand!=houseOrLand[0]?Container():const Text("Eneo linalohusika",style:TextStyle(fontWeight:FontWeight.bold)), 
          _selectedHouseOrLand!=houseOrLand[0]?Container():Container(
              decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(10),
             border: Border.all(
               color: Colors.grey
             )
           ),
              child:  RadioGroup<String>.builder(
                 spacebetween: 35,
                 groupValue: _selectedRentalSize,
                // activeColor: kDominantColor,
                  onChanged:(val){
                     setState(() {
                        _selectedRentalSize=val.toString();
                     });
                  },
                  items: rentalSize, 
                  itemBuilder: (item)=>RadioButtonBuilder(item))
                 ),                
          _selectedHouseOrLand.isEmpty || _selectedHouseOrLand=="Eneo la ardhi" || _selectedPropertyPurpose.isEmpty?Container():Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              SizedBox(height:10,),
              Text("Aina ya jengo la ${_selectedPropertyPurpose.toLowerCase()}",style:TextStyle(fontWeight:FontWeight.bold)),
             Container(
             width:screenSize.width,
             padding:EdgeInsets.all(10),
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
                     const Text("Daraja la jengo - ",style:TextStyle(fontWeight:FontWeight.w400)),Text(_selectedCreBuildingClass,style:TextStyle(color: kAppColor,fontWeight:FontWeight.bold)),
                    ],
                  )),
                 Padding(
                  padding:const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                     const Text("Aina ya jengo - ",style:TextStyle(fontWeight:FontWeight.w400)),Expanded(child: Text(_selectedPropertyType+" - "+_selectedSubCreType,maxLines: 1,overflow: TextOverflow.ellipsis, style:TextStyle(color: kAppColor,fontWeight:FontWeight.bold))),
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
                     const Text("Aina ya jengo - ",style:TextStyle(fontWeight:FontWeight.w400)),const Spacer(),Text(_selectedPropertyType,style:TextStyle(color: kAppColor,fontWeight:FontWeight.bold)),
                    ],
                  )),
                                  Padding( 
                  padding:const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                     const Text("Hali ya jengo - ",style:TextStyle(fontWeight:FontWeight.w400)),const Spacer(),Text(_selectedResidentStatus,style:TextStyle(color: kAppColor,fontWeight:FontWeight.bold)),
                    ],
                  )),
                 Padding( 
                  padding:const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    children: [
                     const Text("Vyumba vya kulala(bedroom) - ",style:TextStyle(fontWeight:FontWeight.w400)),
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
                     const Text("Sebure ya chakula(dining) - ",style:TextStyle(fontWeight:FontWeight.w400)),
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
                     const Text("Vyumba vyenye choo/bafu(self) - ",style:TextStyle(fontWeight:FontWeight.w400)),
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
            Padding( 
            padding:const EdgeInsets.symmetric(vertical: 1),
            child: SizedBox(
              height: 30,
              child: CheckboxListTile(
                contentPadding:EdgeInsets.all(0),
                title:const Text("Ndani ya fensi"),
                value: _hasFens, onChanged: (newVal){
                setState(() {
                  _hasFens=newVal!;
                });
              }),
            )),
            const SizedBox(
             height: 10,),
            Padding( 
            padding:const EdgeInsets.symmetric(vertical: 1),
            child: SizedBox(
              height: 30,
              child: CheckboxListTile(
                contentPadding:EdgeInsets.all(0),
                title:const Text("Kuna paking ya gari"),
                value: _hasParking, onChanged: (newVal){
                  setState(() {
                    _hasParking=newVal!;
                  });
              }),
            )),
           const SizedBox(
             height: 20,),
          Text("Ukubwa wa eneo ${_selectedHouseOrLand==houseOrLand[0]?'(sio lazima)':''}",style: TextStyle(fontWeight:FontWeight.bold)), 
          Container(
          padding:const EdgeInsets.all(5),
          decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(10),
             border: Border.all(
               color: Colors.grey
             )
           ),
         child: Row(
               children: [
                 Container(
                                width: 85,
                                height:40,
                               decoration: BoxDecoration(
                                    borderRadius:const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                   border: Border.all(
                                      color: Colors.grey
                                    )
                                  ),
                                  padding:const EdgeInsets.symmetric(horizontal: 5),
                              child: DropdownButtonHideUnderline(
                                      child: DropdownButton2 (                                        
                                        onChanged: (val){
                                          FocusScopeNode currentScope=FocusScope.of(context);
                                                if(!currentScope.hasPrimaryFocus){
                                                    currentScope.unfocus();
                                                }
                                                setState(() {
                                                  _selectedAreaDimension=val.toString();
                                                });
                                        },
                                       hint: Text(_selectedAreaDimension),             
                                        items: areaDimensions.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList()),
                                    ),
                            ),
                  Expanded(
                    child: SizedBox(
                           height:40,
                           child: TextFormField(
                             keyboardType:TextInputType.number,
                             inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              ],
                             controller:_areaSizeCntr,
                            decoration: InputDecoration(
                              enabledBorder:const OutlineInputBorder(
                                //borderSide: BorderSide(color: Colors.black)
                              ),
                              contentPadding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                              hintText: "Ukubwa katika ${_selectedAreaDimension=="sq ft"?"futi za mraba":_selectedAreaDimension=="sq m"?"mita za mraba":"kilomita za mraba"}",
                              border:const OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(-1),
                                        bottomLeft: Radius.circular(-1),
                                      ),
                              )
                            ),
                             ),
                           ),
                  )
             ],)      
           ),
            _selectedHouseOrLand==houseOrLand[1] || _selectedHouseOrLand.isEmpty?Container():
            Column(
              children: [
                  const SizedBox(
              height:10
            ),
             Container(
              padding:const EdgeInsets.only(left: 5,bottom: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey
                  )
                ),
               child: ExpandablePanel(
                controller:_expController,
                header: Container(margin:const EdgeInsets.only(top: 10), child:const Text("Aseti zilizopo ndani mfano viti n.k",style:TextStyle(fontWeight:FontWeight.bold))),
                collapsed: Container(),
                expanded: Column(
                  children: [
                 _assets.isEmpty?Container(
                  ):SizedBox(
                    height:_assets.length*40,
                    child: ListView.builder(
                      controller:ScrollController(),
                     itemCount:_assets.length,
                     itemBuilder: (context,index){
                        return Container(
                         margin: EdgeInsets.only(top: 3),
                          child: ListTile(
                            dense: true,
                            visualDensity: VisualDensity(vertical: -3),
                            //leading:Text("${(index+1).toString()}"),
                            title: Row(
                              children: [
                                 Icon(Icons.circle,size:12,color:kAppColor),const SizedBox(width:5),
                                Text(_assets[index]),
                                const Spacer(),GestureDetector(onTap: (){
                                  setState(() {
                                    _assets.remove(_assets[index]);
                                  });
                                },child:const Icon(Icons.cancel))
                              ],
                            ),
                            ),
                        ); 
                    }),                  
                  ),
                    FloatingActionButton(
                      mini:true,
                      elevation:0,
                      backgroundColor: Colors.amber,
                      child:const Icon(Icons.add,color:kBlackColor),
                      onPressed: (){
                        showAssetAdditionDialog();
                      }),
                  ],
                ),),
             ),
             const SizedBox(
              height:10
            ),
             Container(
              padding:const EdgeInsets.only(left: 5,bottom: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey
                  )
                ),
               child: ExpandablePanel(
                controller:_expController,
                header: Container(margin:const EdgeInsets.only(top: 10), child:const Text("Huduma zilizopo ndani",style:TextStyle(fontWeight:FontWeight.bold))),
                collapsed: Container(),
                expanded: Column(
                  children: [
                 _selectedInsideServices.isEmpty?Container(
                  ):SizedBox(
                    height:_selectedInsideServices.length*40,
                    child: ListView.builder(
                      controller:ScrollController(),
                     itemCount:_selectedInsideServices.length,
                     itemBuilder: (context,index){
                        return Container(
                         margin: EdgeInsets.only(top: 3),
                          child: ListTile(
                            dense: true,
                            visualDensity: VisualDensity(vertical: -3),
                            //leading:Text("${(index+1).toString()}"),
                            title: Row(
                              children: [
                                 Icon(Icons.circle,size:12,color:kAppColor),const SizedBox(width:5),
                                Text(insideSocialServices[_selectedInsideServices[index]]),
                                const Spacer(),GestureDetector(onTap: (){
                                  setState(() {
                                    _selectedInsideServices.remove(_selectedInsideServices[index]);
                                  });
                                },child:const Icon(Icons.cancel))
                              ],
                            ),
                            ),
                        ); 
                    }),
                  
                  ),
                    FloatingActionButton(
                      mini:true,
                      elevation:0,
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.add,color:kBlackColor),
                      onPressed: (){
                         showModalBottomSheet(context: context,
     isScrollControlled: true,
     shape:const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      )
     ),
     builder: (context){
        return FractionallySizedBox(
          heightFactor: 0.95,
          child: Container(
            decoration:const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
              )
            ),
            height:screenSize.height-_paddingTop,
            child: Column(
              children: [
                    Container(
                      decoration:const BoxDecoration(
                      color: kGreyColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        )
                      ),
                      height: 40,
                      child:Row(
                        children: [
                          Expanded(child: Container()),
                          const Text("Chagua huduma za ndani",style:TextStyle(fontWeight: FontWeight.bold),),
                          Expanded(child: 
                          Align(
                            alignment:Alignment.centerRight,
                            child: IconButton(onPressed: (){
                              Navigator.pop(context);
                            }, icon:const Icon(Icons.done,color:kWhiteColor,size:30)),
                          )),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StatefulBuilder (
                        builder: (context, stateSetter) {
                          return ListView.builder(
                            controller:ScrollController(),
                           itemCount:insideSocialServices.length,
                           itemBuilder: (context,index){
                              return Container(
                               margin: EdgeInsets.only(top: 3),
                               decoration: BoxDecoration(
                                 border: Border(
                                   left:BorderSide(
                                   color:kAppColor,
                                   width:5
                                 ),right:BorderSide(
                                   color:kAppColor,
                                   width:5
                                 )
                                  )
                               ),
                                child: ListTile(
                                  onTap: (){
                                      stateSetter((){
                                        if(_selectedInsideServices.contains(index)){
                                         _selectedInsideServices.remove(index);   
                                        }else{
                                          _selectedInsideServices.add(index);
                                        }
                                      });
                                      setState(() {
                                        
                                      });
                                  },
                                  dense: true,
                                  visualDensity: VisualDensity(vertical: -3),
                                  title: Row(
                                    children: [
                                      Expanded(child: Text(insideSocialServices[index])),
                                      _selectedInsideServices.any((el) => el==index) ?  Icon(Icons.done,color:kAppColor):Container()
                                    ],
                                  ),
                                  ),
                              ); 
                          });
                        }
                      )
         ),
                    
              ],
            ),
          ),
        );
     });  
                    }),
                  ],
                ),),
             ),              
            ],
            ),
            const SizedBox(
              height:10
            ),
             Container(
              padding:const EdgeInsets.only(left: 5,bottom: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey
                  )
                ),
               child: ExpandablePanel(
                controller:_expController,
                header: Container(margin:const EdgeInsets.only(top: 10), child:const Text("Huduma za kijami zilizopo karibu",style:TextStyle(fontWeight:FontWeight.bold))),
                collapsed: Container(),
                expanded: Column(
                  children: [
                 _selectedSocialServices.isEmpty?Container(

                  ):SizedBox(
                    height:_selectedSocialServices.length*40,
                    child: ListView.builder(
                      controller:ScrollController(),
                     itemCount:_selectedSocialServices.length,
                     itemBuilder: (context,index){
                        return Container(
                          margin: EdgeInsets.only(top: 3),
                          child: ListTile(
                            onTap: (){
                            },
                            dense: true,
                            visualDensity: VisualDensity(vertical: -3),
                            title: Row(
                              children: [
                                 Icon(Icons.circle,size:12,color:kAppColor),SizedBox(width:5),
                                Text(nearbySocialServices[_selectedSocialServices[index]]),
                                Spacer(),GestureDetector(onTap: (){
                                  setState(() {
                                    _selectedSocialServices.remove(_selectedSocialServices[index]);
                                  });
                                },child:const Icon(Icons.cancel))
                              ],
                            ),
                            ),
                        ); 
                    }),
                  ),
                    FloatingActionButton(
                      mini:true,
                      elevation:0,
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.add,color:kBlackColor),
                      onPressed: (){
                         showModalBottomSheet(context: context,
     isScrollControlled: true,
     shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      )
     ),
     builder: (context){
        return FractionallySizedBox(
          heightFactor: 0.95,
          child: Container(
            decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
              )
            ),
            height:screenSize.height*0.7,
            child: Column(
              children: [
                    Container(
                      decoration: BoxDecoration(
                      color: kGreyColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        )
                      ),
                      height: 40,
                      child:Row(
                        children: [
                          Expanded(child: Container()),
                           Text("Chagua huduma za kijamii",style:TextStyle(fontWeight: FontWeight.bold),),
                          Expanded(child: 
                          Align(
                            alignment:Alignment.centerRight,
                            child: IconButton(onPressed: (){
                              Navigator.pop(context);
                            }, icon: Icon(Icons.done,color:kWhiteColor,size:30)),
                          )),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StatefulBuilder (
                        builder: (context, stateSetter) {
                          return ListView.builder(
                            controller:ScrollController(),
                           itemCount:nearbySocialServices.length,
                           itemBuilder: (context,index){
                              return Container(
                               margin: EdgeInsets.only(top: 3),
                               decoration: BoxDecoration(
                                 border: Border(
                                   left:BorderSide(
                                   color:kAppColor,
                                   width:5
                                 ),right:BorderSide(
                                   color:kAppColor,
                                   width:5
                                 )
                                  )
                               ),
                                child: ListTile(
                                  onTap: (){
                                      stateSetter((){
                                        if(_selectedSocialServices.contains(index)){
                                         _selectedSocialServices.remove(index);   
                                        }else{
                                          _selectedSocialServices.add(index);
                                        }
                                      });
                                      setState(() {
                                        
                                      });
                                  },
                                  dense: true,
                                  visualDensity: VisualDensity(vertical: -3),
                                  title: Row(
                                    children: [
                                      Expanded(child: Text(nearbySocialServices[index])),
                                      _selectedSocialServices.any((el) => el==index) ?  Icon(Icons.done,color:kAppColor):Container()
                                    ],
                                  ),
                                  ),
                              ); 
                          });
                        }
                      )
         ),
                    
              ],
            ),
          ),
        );
     });  
                    }),
                  ],
                ),),
             ),
            SizedBox(
              height:10,
            ),
          Text("Maelezo ya ziada(sio lazima)",style:TextStyle(fontWeight:FontWeight.bold)),
           Container(                
                child: TextFormField(
                  minLines:3,
                  maxLines: 3,
                  controller:_rentalDescriptionCntrl,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  hintText: "Elezea hapa",
                  border:OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                  )
                ),
                  ),
                ),
             dataProvider.userUploadRole==1?Container():const SizedBox(
                   height:10,
                ),
         dataProvider.userUploadRole==1?Container():const Text("Kamisheni yako ya udalali",style: TextStyle(fontWeight:FontWeight.bold)), 
          dataProvider.userUploadRole==1?Container():Container(
          padding:const EdgeInsets.all(5),
          decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(10),
             border: Border.all(
               color: Colors.grey
             )
           ),
         child: Row(
               children: [
                              Container(
                                width: 77,
                                height:40,
                               decoration: BoxDecoration(
                                    borderRadius:const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                   border: Border.all(
                                      color: Colors.grey
                                    )
                                  ),
                                  padding:const EdgeInsets.symmetric(horizontal: 5),
                              child: DropdownButtonHideUnderline(
                                      child: DropdownButton2 (                                        
                                        onChanged: (val){
                                          FocusScopeNode currentScope=FocusScope.of(context);
                                                if(!currentScope.hasPrimaryFocus){
                                                    currentScope.unfocus();
                                                }
                                                setState(() {
                                                  _selectedBrokerPocketCurrency=val.toString();
                                                });
                                        },
                                       hint: Text(_selectedBrokerPocketCurrency),
                                       //value: _selectedPayCurrency,                 
                                       // value: _selectedRentalCategory,               
                                        items: payCurrencyChoices.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList()),
                                    ),
                            ),
                  Expanded(
                    child: SizedBox(
                           height:40,
                           child: TextFormField(
                             keyboardType:TextInputType.number,
                             inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              ],
                             controller:_brokersPocketCntr,
                            decoration:const InputDecoration(
                              enabledBorder:OutlineInputBorder(
                                //borderSide: BorderSide(color: Colors.black)
                              ),
                              contentPadding:EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                              hintText: "Kiasi cha pesa",
                              border:OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(-1),
                                        bottomLeft: Radius.circular(-1),
                                      ),
                              )
                            ),
                             ),
                           ),
                  )
             ],)      
           ),
       const SizedBox(
           height:10,
        ),
          Text(dataProvider.rentOrSell==1?"Kodi unayotaka":"Bei unayouzia",style: TextStyle(fontWeight:FontWeight.bold)), 
          Container(
          padding:const EdgeInsets.all(5),
          decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(10),
             border: Border.all(
               color: Colors.grey
             )
           ),
         child:dataProvider.rentOrSell==0?
         Row(
               children: [
                  Container(
                    width: 77,height:40,
                              decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                   border: Border.all(
                                      color: Colors.grey
                                    )
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                              child: DropdownButtonHideUnderline(
                                      child: DropdownButton2 (                                        
                                        onChanged: (val){
                                          FocusScopeNode currentScope=FocusScope.of(context);
                                                if(!currentScope.hasPrimaryFocus){
                                                    currentScope.unfocus();
                                                }
                                                setState(() {
                                                  _selectedPayCurrency=val.toString();
                                                });
                                        },
                                       hint: Text(_selectedPayCurrency),
                                       //value: _selectedPayCurrency,                 
                                       // value: _selectedRentalCategory,               
                                        items: payCurrencyChoices.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList()),
                                    ),
                            ),
                  Expanded(
                    child: SizedBox(
                           height:40,
                           child: TextFormField(
                             keyboardType:TextInputType.number,
                             inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              ],
                             controller: _singlePeriodAmountCntrl,
                            decoration: InputDecoration(
                              enabledBorder:OutlineInputBorder(
                                //borderSide: BorderSide(color: Colors.black)
                              ),
                              contentPadding:EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                              hintText: "Kiasi cha pesa",
                              border:OutlineInputBorder(
                                borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(-1),
                                        bottomLeft: Radius.circular(-1),
                                      ),
                              )
                            ),
                             ),
                           ),
                  )
             ],)
         :Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisSize: MainAxisSize.min,
           children: [
             Row(
               children: [
                  Container(
                    width: 77,height:40,
                               decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                   border: Border.all(
                                      color: Colors.grey
                                    )
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                              child: DropdownButtonHideUnderline(
                                      child: DropdownButton2 (
                                        //alignment: AlignmentDirectional.center,
                                        
                                        onChanged: (val){
                                          FocusScopeNode currentScope=FocusScope.of(context);
                                                if(!currentScope.hasPrimaryFocus){
                                                    currentScope.unfocus();
                                                }
                                                setState(() {
                                                  _selectedPayCurrency=val.toString();
                                                });
                                        },
                                       hint: Text(_selectedPayCurrency),
                                       //value: _selectedPayCurrency,                 
                                       // value: _selectedRentalCategory,               
                                        items: payCurrencyChoices.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList()),
                                    ),
                            ),
                  SizedBox(
                         height:40,
                         width: screenSize.width*0.67-80,
                         child: TextFormField(
                           keyboardType:TextInputType.number,
                           inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ],
                           controller: _singlePeriodAmountCntrl,
                          decoration: InputDecoration(
                            enabledBorder:OutlineInputBorder(
                           //borderSide: BorderSide(color: Colors.black) 
                            ),
                            contentPadding:EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            hintText: "Kiasi cha pesa",
                            border:OutlineInputBorder(
                              borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(-1),
                                      bottomLeft: Radius.circular(-1),
                                    ),
                            )
                          ),
                           ),
                         ),Expanded(
                          child: Container(
                                  height:40,
                                  decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: Colors.grey
                                    )
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButtonFormField(
                                      //alignment: AlignmentDirectional.center,                                      
                                      onChanged: (val){
                                        FocusScopeNode currentScope=FocusScope.of(context);
                                             if(!currentScope.hasPrimaryFocus){
                                                  currentScope.unfocus();
                                              }
                                        if(_singlePeriodAmountCntrl.text.trim().isEmpty){
                                            UserReplyWindowsApi().showToastMessage(context,"Ingiza kiasi cha kodi kwanza");
                                        }else{
                                            _selectedPayPeriod=val.toString();
                                           showMinimumPaymentPeeriodDialog(payPeriodChoicesPrural[payPeriodChoices.indexWhere((item) => item==val.toString())]);
                                        }
                                      },
                                     hint: Text("Muda"),
                                     //value: _selectedPayPeriod,                 
                                    // value: _selectedRentalCategory,               
                                      items: payPeriodChoices.map((e) => DropdownMenuItem(value: e, child: Text(e.toString()))).toList()),
                                  ),
                                ),
                       ),
             ],),
              SizedBox(height: 5,),
            (_totalRentalBill==null)?Container():Container(
              child: Text("$_selectedPayCurrency  ${_totalRentalBill.toString()}/= kila baada ya  ${payPeriodChoicesPrural[payPeriodChoices.indexWhere((item) =>item==_selectedPayPeriod)]}  ${control.text}",
              style: TextStyle(fontWeight:FontWeight.w500,fontSize:13)
              ))
           ],
         )
           ),
          SizedBox(
           height:10,
         ),          
           ]
         ),
       ),
     ),
     Container(
       height:40,
       margin: EdgeInsets.only(bottom: 5),
       child:ElevatedButton(
           onPressed: (){
             FocusScopeNode currentScope=FocusScope.of(context);
                  if(!currentScope.hasPrimaryFocus){
                       currentScope.unfocus();
                   }
                  if((_titleCntr.text.trim().isEmpty || _selectedHouseOrLand.isEmpty || _selectedPropertyPurpose.isEmpty || _totalRentalBill==null) && dataProvider.rentOrSell==1){
                    UserReplyWindowsApi().showToastMessage(context,"Tafadhali ingiza machaguo yanayohitajika");
                  }else if((_titleCntr.text.trim().isEmpty || _selectedHouseOrLand.isEmpty || _selectedPropertyPurpose.isEmpty || _singlePeriodAmountCntrl.text.trim().isEmpty ) && dataProvider.rentOrSell==0){
                    UserReplyWindowsApi().showToastMessage(context,"Tafadhali ingiza machaguo yanayohitajika");
                  }else {
                    Map<String,dynamic> buildingData={
                    "operation":dataProvider.rentOrSell,
                    "userRole":dataProvider.userUploadRole,
                    
                    "houseOrLand":houseOrLand.indexWhere((e) => e==_selectedHouseOrLand),
                    "purpose":propertyPurpose.indexWhere((e) => e==_selectedPropertyPurpose), 
                    "title":_titleCntr.text.trim().substring(0,1).toUpperCase()+_titleCntr.text.trim().substring(1), 
                    "hasFens":_hasFens?1:0,
                    "hasParking":_hasParking?1:0,
                    "areaDimension":areaDimensions.indexWhere((e) => e==_selectedAreaDimension),
                    "areaSize":_areaSizeCntr.text,
                    "socialServices":_selectedSocialServices,
                    "description":_rentalDescriptionCntrl.text,
                    "brokerPayCurrency":payCurrencyChoices.indexWhere((el) => el== _selectedBrokerPocketCurrency),                
                    "brokerSalary":_brokersPocketCntr.text,       
                    "userId":FirebaseAuth.instance.currentUser!.uid,
                    "externalViews":0,
                    "internalViews":0,
                    "sold":0,
                    "suspended":0,
                    "suspensionReason":"",
                    "likes":[],
                    "assets":_assets,
                    "payCurrency":payCurrencyChoices.indexWhere((el) => el==_selectedPayCurrency),
                    "ownerInfo":{
                      "name":dataProvider.currentUser['agentInfo'] !=null?dataProvider.currentUser['agentInfo']['name']:dataProvider.currentUser["firstName"]+" "+dataProvider.currentUser["lastName"],
                      "phone":dataProvider.currentUser["phoneNumber"],
                      "email":dataProvider.currentUser["email"],
                      "photo":dataProvider.currentUser["profilePhoto"],
                      },
                    };
                    if(dataProvider.rentOrSell==1){
                    buildingData["buildingBillAmount"]=_singlePeriodAmountCntrl.text; 
                    buildingData["minBillPeriod"]= payPeriodChoices.indexWhere((el) => el==_selectedPayPeriod);
                    buildingData["billPeriodsNumber"]= control.text;
                    }else{
                      buildingData["propertyPriceAmount"]=_singlePeriodAmountCntrl.text; 
                    }
                    //
                    if(buildingData["houseOrLand"]==0){
                      if(_selectedPropertyType.isNotEmpty){
                        if(_selectedRentalSize.isNotEmpty){
                          buildingData["rentalSize"]= rentalSize.indexWhere((el) => el==_selectedRentalSize);
                        if(_selectedPropertyPurpose==propertyPurpose[0]){
                          buildingData["buildingType"]= commercialBuildingTypes.indexWhere((el) => el==_selectedPropertyType);  
                          buildingData["subBuildingType"]= commercialSubBuilding[buildingData["buildingType"].toString()].indexWhere((e)=> e==_selectedSubCreType);
                          buildingData["buildingClass"]= creBuildingClasses.indexWhere((el) => el==_selectedCreBuildingClass);
                          buildingData["insideServices"]=_selectedInsideServices;
                          shiftPage(buildingData);
                        }else{
                          buildingData["insideServices"]=_selectedInsideServices;
                        buildingData["buildingType"]= residentBuildingTypes.indexWhere((el) => el==_selectedPropertyType);
                        buildingData["buildingStatus"]= residentBuildingStatus.indexWhere((el) => el==_selectedResidentStatus);
                        buildingData["bedRooms"]= int.parse(_bedRoomCount);
                        buildingData["livingRooms"]= int.parse(_livingRoomCount);
                        buildingData["diningRooms"]= int.parse(_diningRoomCount);
                        buildingData["kitchenRooms"]= int.parse(_kitchenRoomCount);
                        buildingData["storeRooms"]= int.parse(_storeRoomCount);
                        buildingData["selfRooms"]= int.parse(_selfContBedRoomCount);
                        buildingData["bathRooms"]= int.parse(_bathRoomCount);
                         shiftPage(buildingData);
                        }
                        }else{
                        UserReplyWindowsApi().showToastMessage(context,"Chagua ukubwa wa eneo linalohusika");
                        }
                      }else{
                        UserReplyWindowsApi().showToastMessage(context,"Tafadhali chagua aina ya ${_selectedPropertyType}");
                      }
                    }else{
                      if(_areaSizeCntr.text.trim().isEmpty){
                      UserReplyWindowsApi().showToastMessage(context,"Ingiza ukubwa wa eneo");
                      }else{
                      shiftPage(buildingData);
                      }
                    }
                  }
           },
           child: Container(
             padding:const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
            child:const Text("Endelea",style: TextStyle(fontWeight: FontWeight.w500,color:kWhiteColor),)
           ),
         ),
     )   
    ],);
  }

  void showElectricityShareCountDialog(String? val){
       showDialog(context: context, builder: (context){
         return AlertDialog(
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               Text("Familia/wapangaji/watu wangapi wanaoshea umeme?"), SizedBox(height:10),
                SizedBox(
                     height:40,
                     width: MediaQuery.of(context).size.width*0.6,
                     child: NumberSelection(
                       initialValue: 1,
                       minValue: 1,
                       onChanged: (val){
                          electricityShareValue=val.toString();   
                       },
                     )
                     ), SizedBox(height:10),
                     TextButton(
                       onPressed: (){             
                         print(electricityShareValue);
                        if(electricityShareValue=="1"){
                          UserReplyWindowsApi().showToastMessage(context,"Ingiza idadi ya watakaoshea umeme na atakaechukua pango hili");
                        }else{ 
                         _selectedElectricityStatus=val.toString();
                          setState(() {
                             
                           });
                           Navigator.pop(context);
                        }
                     },child:const Text("Endelea"),)
             ],
           ),
         );
       });
  }

  void showMinimumPaymentPeeriodDialog(String string) {
       showDialog(context: context, builder: (context){
         return AlertDialog(
           content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               Text("Unapokea kodi hiyo kila baada ya $string ngapi?"), SizedBox(height:10),
                SizedBox(
                     height:40,
                     width: MediaQuery.of(context).size.width*0.6,
                     child: TextFormField( 
                       keyboardType:TextInputType.number, 
                       inputFormatters: [ 
                        FilteringTextInputFormatter.digitsOnly,
                       ],
                       //0716272723
                       controller: control,
                      decoration: InputDecoration(
                        enabledBorder:const OutlineInputBorder(
                          //borderSide: BorderSide(color: Colors.black)
                        ),
                        contentPadding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                        hintText: "Idadi ya $string ",
                        border:OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                        )
                      ),
                       ),
                     ),const SizedBox(height:10),
                     TextButton(
                       onPressed: (){
                       int number;
                       FocusScopeNode currentScope=FocusScope.of(context);
                          if(!currentScope.hasPrimaryFocus){
                              currentScope.unfocus();
                          }                    
                        if(control.text.isEmpty){
                          UserReplyWindowsApi().showToastMessage(context,"Ingiza idadi ya $string ");
                        }else{
                           setState(() {
                             number=int.parse(control.text.trim());
                             _totalRentalBill=number*int.parse(_singlePeriodAmountCntrl.text.trim());
                           });
                        }
                        Navigator.pop(context);
                     },child: Text("Endelea"),)
             ],
           ),
         );
       });
  }
  
  void showAssetAdditionDialog() {
                 TextEditingController _assetsController=TextEditingController();   
                          showDialog(context: context, builder: (context){
                            return AlertDialog(
                              title: Text(_assets.isEmpty?"Weka aseti":"Ongeza aseti"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                   Text("Jaza kitu kilichopo kwenye jengo"), SizedBox(height:10),
                                 SizedBox(
                                  height:40,
                                  width: MediaQuery.of(context).size.width*0.6,
                                  child: TextFormField(
                                    controller: _assetsController,
                                    decoration: InputDecoration(                                    
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                  hintText: "Vitu vya ndani",
                                  //G account manager 9.0 apk , frp bypass apk
                                  border:OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)
                                  )
                                ),
                                ),
                              ), SizedBox(height:10),
                                        TextButton(
                                          onPressed: (){         
                                            if(_assetsController.text.trim().isEmpty){
                                              UserReplyWindowsApi().showToastMessage(context,"Ingiza moja ya vitu vya ndani");
                                            }else{ 
                                              Navigator.pop(context);
                                              setState((){
                                                _assetColors.add(Colors.primaries[Random().nextInt(Colors.primaries.length)]);
                                               _assets.add(_assetsController.text);
                                              });
                                            }
                                        },child:Text(_assets.isEmpty?"Weka":"Ongeza"),)
                                ],
                              ),
                            );
                          }); 
  }
  
  void showBuildingsRealEstates(int purpose, int houseOrLand) {
    showModalBottomSheet(context: context,
     isScrollControlled: true,
     builder:(context){
       return Container(
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
                    contentPadding:EdgeInsets.all(10),
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
       return Container(
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
                    contentPadding:EdgeInsets.all(10),
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
  
  ValueNotifier<bool> verifyingNumber = ValueNotifier(false);
    void showPhoneNumberUpdateDialog(AppDataProvider provider) { 
    verifyingNumber.value = false;
    showGeneralDialog(barrierDismissible: true,barrierLabel: "phone", context: context,
    transitionDuration: Duration(milliseconds: 400),
    pageBuilder: (context,anim1,anim2){
      Animation<Offset> offAnim=Tween<Offset>(begin: Offset(0,-1),end: Offset(0,0),).animate(anim1);
     return SlideTransition(
       position:offAnim,
       child: StatefulBuilder(
         builder: (context,stateSetter) {
           return AlertDialog(
            title: Row(
              children:const [
                Icon(Icons.phone_in_talk),
                SizedBox(width: 10),
                Text("Namba ya simu"),
              ],
            ),
             content: ValueListenableBuilder(
                valueListenable: verifyingNumber,
                builder: (context, locLoad, child) {
                  return (locLoad == true)
                      ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min, children: [
                          Text("Jaza tarakimu tulizokutumia kwa meseji kwenda ${"0" + _phoneNumberTxtCntrl.text}"),
                        PinFieldAutoFill(
                          onCodeChanged: (code)async{
                           smsCode=code!;       
                          },
                        ),
                         ElevatedButton(
                         onPressed:sendingOtp?(){
                           UserReplyWindowsApi().showToastMessage(context,"Subiri");
                         }: ()async{
                          if(smsCode.length==6){
                            stateSetter((){
                              sendingOtp=true;
                            });
                            PhoneAuthCredential credential=PhoneAuthProvider.credential(verificationId: _phoneCredential['verificationId'], smsCode: smsCode.toString());
                            UserCredential? userCred;
                           try{
                            userCred= await _auth.currentUser!.linkWithCredential(credential);
                            //Navigator.pop(context);
                            if(userCred !=null){ 
                                await _addToRealtimeDatabase({'phoneNumber':_countryCode+_phoneNumberTxtCntrl.text.trim()});
                              }else{
                                //print("Kunatatizo limetokea tafadhali jaribu tena");
                                UserReplyWindowsApi().showToastMessage(context,"Kunatatizo limetokea tafadhali jaribu tena");
                              }
                          } on FirebaseAuthException catch(e){
                                 setState(() {
                                  sendingOtp=false;
                                });
                             UserReplyWindowsApi().showToastMessage(context,e.toString());
                          }
                        }else{
                            UserReplyWindowsApi().showToastMessage(context,"Jaza tarakimu tulizokutumia");
                          }
                      },
                       style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith((states) => sendingOtp?kWhiteColor:kAppColor)
                        ),
                       child:sendingOtp?UserReplyWindowsApi().showLoadingIndicator():const Text("Tuma",style: TextStyle(color: kWhiteColor),))
         
                        ])
                        :Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Text(
                          "Google haijatupatia namba yako ${provider.currentUser['firstName']}, Jaza namba yako ili tukukutanishe kirahisi na wateja."),                        
                          Container(
                          margin:const EdgeInsets.only(top: 10),
                          height: 40,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: _phoneNumberTxtCntrl,
                            decoration: InputDecoration(
                            prefixIcon: FittedBox(
                            fit: BoxFit.contain,
                            child: CountryCodePicker(
                            initialSelection:provider.selectedCountry["name"].toString().toLowerCase(),                          onChanged: (CountryCode code){
                             _countryCode=code.toString();
                            },
                            ),
                          ),
                          labelText: "Usianze na 0 au ${provider.selectedCountry['countryCode']}",
                          border:OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)
                          )
                        ),
                       ),
                     ),           
                      ElevatedButton(
                        onPressed:sendingOtp?(){
                           UserReplyWindowsApi().showToastMessage(context,"Subiri");
                         }: () async {
                          if(_phoneNumberTxtCntrl.text.trim().isNotEmpty){
                             stateSetter(() {
                              sendingOtp = true;
                             });
                            await registerPhoneNumber( _countryCode+ _phoneNumberTxtCntrl.text.trim());
                          }else{
                            UserReplyWindowsApi().showToastMessage(context,"Jaza namba ya simu kwanza");
                          }                         
                          //verifyingNumber.value = true;
                        //await registerPhoneNumber(_countryCode+_phoneNumberTxtCntrl.text.trim());
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith((states) => sendingOtp?kWhiteColor:kAppColor)
                        ),
                        child:sendingOtp == true? UserReplyWindowsApi().showLoadingIndicator() :const Text(
                        "Endelea",style:TextStyle(color: kWhiteColor)))
                      ]);
                    }),
          );
        
         }
       ),
     );
    });
  }

Future<void> registerPhoneNumber(String phone)async{
   await _auth.verifyPhoneNumber(
    phoneNumber: phone,
    verificationCompleted: (PhoneAuthCredential credential)async{
      verifyingNumber.value=false;
      Navigator.pop(context);
      UserReplyWindowsApi().showProgressBottomSheet(context);
      UserCredential userCred;
      try{         
        userCred= await _auth.currentUser!.linkWithCredential(credential);
          if(_auth.currentUser !=null){ 

            await _addToRealtimeDatabase({"phoneNumber": phone});
            }else{
              Navigator.pop(context);
              UserReplyWindowsApi().showToastMessage(context,"Kunatatizo limetokea tafadhali jaribu tena");
            }
        } on FirebaseAuthException catch(e){
            setState(() {
              sendingOtp=false;
            });
          verifyingNumber.value=false;  
          Navigator.pop(context);
          UserReplyWindowsApi().showToastMessage(context,e.toString());
        }
   },verificationFailed: (FirebaseAuthException ex){
     setState(() {
       sendingOtp=false;
     });
       verifyingNumber.value=false;
       UserReplyWindowsApi().showToastMessage(context,ex.toString());
   }, codeSent: (String verificationId,int? resendToken){
     _phoneCredential={
      "verificationId":verificationId,"resendToken":resendToken,
     };
     setState(() {
       sendingOtp=false;
     });
     verifyingNumber.value=true;
   }, codeAutoRetrievalTimeout: (String verificationId){

   });

}

Future<void> _addToRealtimeDatabase(Map<String,dynamic> phoneMap)async{
    
    await _usersRef.child(_auth.currentUser!.uid).update(phoneMap).then((value){
        Navigator.pop(context);
        dataProvider.currentUser['phoneNumber']=phoneMap['phoneNumber'];
        Map<String,dynamic> ownerInfo=_buildingData['ownerInfo'];
        ownerInfo['phone']=phoneMap['phoneNumber'];
        _buildingData['ownerInfo']= ownerInfo;        
      setState(() {
        dataProvider.currentBuildingRegPage=RentalImagesScreen(_buildingData);
       });     
    }).catchError((e){
      Navigator.pop(context);
      UserReplyWindowsApi().showToastMessage(context,"Kunatatizo limetokea, Jaribu tena");
    }); 
}

void shiftPage(Map<String,dynamic> buildingData){
   if(dataProvider.currentUser['phoneNumber'] != null){
      setState(() {
        dataProvider.currentBuildingRegPage=RentalImagesScreen(buildingData);
      });
   }else{
    _buildingData=buildingData;
    showPhoneNumberUpdateDialog(dataProvider);
   }
}

}
