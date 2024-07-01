import 'package:betterhouse/provider_services.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RequiredRentalDetailsScreen extends StatefulWidget {
  const RequiredRentalDetailsScreen({ Key? key }) : super(key: key);

  @override
  _RequiredRentalDetailsScreenState createState() => _RequiredRentalDetailsScreenState();
}

class _RequiredRentalDetailsScreenState extends State<RequiredRentalDetailsScreen> {
  final FirebaseAuth _auth=FirebaseAuth.instance;
final String _selectedDistanceFrmRoad="";
final String _selectedElectricityStatus="";
final String _selectedWaterStatus="";
final String _selectedBuildingType="";
final List<DropdownMenuItem<String>> _rentalCategoryDrodownItems=[];
final String _selectedRentalCategory="";
final _singlePeriodAmountCntrl=TextEditingController();
final _rentalDescriptionCntrl=TextEditingController();
final control=TextEditingController();
final String _selectedPayPeriod="";
late int _noOfPaymentPeriods;
int? _totalRentalBill;
Region? _selectedRegion;
District? _selectedDistrict;
final String _selectedRentalSize="";
final List<DropdownMenuItem<String>> _regionsDropdownItems=[];
 
  @override
  Widget build(BuildContext context) {
     AppDataProvider dataProvider=Provider.of<AppDataProvider>(context);
    Size screenSize=MediaQuery.of(context).size;
    return Scaffold(
       appBar:AppBar(
           title:const Text("Sifa za pango"), 
         ),
      // body: Container(
      //   padding:const EdgeInsets.symmetric(horizontal: 3),
      //   child: SingleChildScrollView(
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [          
      //       const SizedBox(
      //          height: 10,
      //        ),
      //        const Text("Aina ya pango(inahitajika)",style:TextStyle(fontWeight:FontWeight.bold)), 
      //        Container(
      //          decoration: BoxDecoration(
      //            borderRadius: BorderRadius.circular(10),
      //            border: Border.all(
      //              color: Colors.grey
      //            )
      //          ),
      //          padding:const EdgeInsets.symmetric(horizontal: 5),
      //          child: DropdownButtonFormField(
      //            onChanged: (val){
      //               _selectedRentalCategory=rentalType.indexWhere((el) => el==val!.toString()).toString();  
      //                if(_selectedRentalCategory=="1"){
      //                  showModalBottomSheet(context: context,
      //                   builder:(context){
      //                     return Container(
      //                      // height: screenSize.height,
      //                       child: Column(
      //                         mainAxisSize: MainAxisSize.min,
      //                         children:[
      //                         const Text("Ukubwa wa pango",style:TextStyle(fontWeight:FontWeight.bold,fontSize: 17)),
      //                         const Text("(Pango liwe na ukubwa gani?)"),
      //                         ListView.builder(
      //                                                    shrinkWrap: true,
      //                                                    controller: ScrollController(),
      //                                                    itemCount: houseSizeCategory.length,
      //                                                    itemBuilder: (context,ind){
      //                          return ListTile(
      //                            onTap:(){
      //                              setState(() {
      //                                _selectedRentalSize=houseSizeCategory[ind];
      //                              });
      //                              Navigator.pop(context);
      //                            },
      //                            title: Text(houseSizeCategory[ind]),
      //                          );} )
      //                       ]),
      //                     );
      //                   });
      //                }else{
      //                  setState(() {
      //                    _selectedRentalSize="";
      //                  });
      //                }
      //            },
      //           hint:const Text("Aina ya pango"),                 
      //            //value: _selectedRentalCategory,               
      //            items: rentalType.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList()),
      //        ),
      //        const SizedBox(height: 10,),
      //            const Text("Mkoa unaohitaji kupanga(inahitajika)",style:TextStyle(fontWeight:FontWeight.bold)),
      //            Container(
      //              decoration: BoxDecoration(
      //                borderRadius: BorderRadius.circular(10),
      //                border: Border.all(
      //                  color: Colors.grey
      //                )
      //              ),
      //              padding:const EdgeInsets.symmetric(horizontal: 5),
      //              child: DropdownButtonFormField(
      //                onChanged: (val){
      //                  print((val as Region).name);
      //                  int i=regions.indexWhere((e) => (e.id==(val).id));
      //                  Region currentRegion=regions[i];
      //                              setState(() {
      //                                _selectedRegion=val;
      //                                  _selectedDistrict=null;
      //                                }); 
      //                  showModalBottomSheet(context: context,
      //                   builder:(context){
      //                     return SizedBox(
      //                       height: screenSize.height,
      //                       child: Column(children:[
      //                         Text("Wilaya za "+_selectedRegion!.name,style:const TextStyle(fontWeight:FontWeight.bold,fontSize: 15)),
      //                         const Text("(Pango liwe wilaya gani)"),
      //                         Expanded(
      //                           child: Container(),
      //                           // child: ListView.builder(
      //                           //                            shrinkWrap: true,
      //                           //                            controller: ScrollController(),
      //                           //                            itemCount: currentRegion.districts.length,
      //                           //                            itemBuilder: (context,ind){
      //                           //  District district=currentRegion.districts[ind];
      //                           //  return ListTile(
      //                           //    onTap:(){
      //                           //      setState(() {
      //                           //        _selectedDistrict=district;
      //                           //      });
      //                           //      Navigator.pop(context);
      //                           //    },
      //                           //    title: Text(district.name),
      //                           //  );} ),
      //                         )
      //                       ]),
      //                     );
      //                   });
      //                },
      //               hint:const Text("Mikoa"),                              
      //                items: regions.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList()),
      //            ),
      //           const SizedBox(height: 10,),
      //          _selectedDistrict==null?Container():Column(
      //             crossAxisAlignment:CrossAxisAlignment.start,
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               const Text("Wilaya",style:TextStyle(fontWeight:FontWeight.bold)),
      //               Text(_selectedDistrict!.name),
      //               const SizedBox(height: 10),
      //             ] 
      //          ),
      //          _selectedRentalSize.isEmpty?Container():Column(
      //             crossAxisAlignment:CrossAxisAlignment.start,
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               const Text("Ukubwa wa pango",style:TextStyle(fontWeight:FontWeight.bold)),
      //               Text(_selectedRentalSize),
      //               const SizedBox(height: 10),
      //             ] 
      //          ),
      //     //      const SizedBox(
      //     //      height:2,
      //     //    ),
      //     //      const Text("Umbali toka barabarani",style:TextStyle(fontWeight:FontWeight.bold)), 
      //     //         Container(
      //     //    decoration: BoxDecoration(
      //     //        borderRadius: BorderRadius.circular(10),
      //     //        border: Border.all(
      //     //          color: Colors.grey
      //     //        )
      //     //      ),
      //     //    child:  RadioGroup<String>.builder(
      //     //            spacebetween: 35,
      //     //            groupValue: _selectedDistanceFrmRoad,
      //     //           // activeColor: kDominantColor,
      //     //             onChanged:(val){
      //     //                setState(() {
      //     //                   _selectedDistanceFrmRoad=val.toString();
      //     //                });
      //     //             },
      //     //             items: distanceFrmRoadChoices, 
      //     //             itemBuilder: (item)=>RadioButtonBuilder(item))
      //     //      ),
      //     //    const SizedBox(
      //     //      height:10,
      //     //    ),
      //     //         const Text("Hali ya umeme",style:TextStyle(fontWeight:FontWeight.bold)),
      //     //         Container(
      //     //    decoration: BoxDecoration(
      //     //        borderRadius: BorderRadius.circular(10),
      //     //        border: Border.all(
      //     //          color: Colors.grey
      //     //        )
      //     //      ),
      //     //    child:  RadioGroup<String>.builder(
      //     //            spacebetween: 35,
      //     //            groupValue: _selectedElectricityStatus,
      //     //           // activeColor: kDominantColor,
      //     //             onChanged:(val){
      //     //                setState(() {
      //     //                   _selectedElectricityStatus=val.toString();
      //     //                });
      //     //             },
      //     //             items: rentelElectricity, 
      //     //             itemBuilder: (item)=>RadioButtonBuilder(item))
      //     //     ),
      //     //    const SizedBox(
      //     //      height:10,
      //     //    ),
      //     //     const Text("Aina ya jengo",style:TextStyle(fontWeight:FontWeight.bold)), 
      //     // Container(
      //     //    decoration: BoxDecoration(
      //     //        borderRadius: BorderRadius.circular(10),
      //     //        border: Border.all(
      //     //          color: Colors.grey
      //     //        )
      //     //      ),
      //     //    child: RadioGroup<String>.builder(
      //     //            spacebetween: 35,
      //     //            groupValue: _selectedBuildingType,
      //     //           // activeColor: kDominantColor,
      //     //             onChanged:(val){
      //     //                setState(() {
      //     //                   _selectedBuildingType=val.toString();
      //     //                });
      //     //             },
      //     //             items: buildingTypeChoices, 
      //     //             itemBuilder: (item)=>RadioButtonBuilder(item))
      //     //      ),

      //     //         const SizedBox(
      //     //              height:10,
      //     //           ),
      //     //              const Text("Kodi utayoweza kulipa",style:TextStyle(fontWeight:FontWeight.bold)), 
      //     // Container(
      //     //   padding:const EdgeInsets.all(5),
      //     //    decoration: BoxDecoration(
      //     //        borderRadius: BorderRadius.circular(10),
      //     //        border: Border.all(
      //     //          color: Colors.grey
      //     //        )
      //     //      ),
      //     //    child: Column(
      //     //      crossAxisAlignment: CrossAxisAlignment.start,
      //     //      mainAxisSize: MainAxisSize.min,
      //     //      children: [
      //     //        Row(children: [
      //     //             Container(
      //     //                    height:40,
      //     //                    width: screenSize.width*0.6,
      //     //                    child: TextFormField(
      //     //                      keyboardType:TextInputType.number,
      //     //                      inputFormatters: [
      //     //                       FilteringTextInputFormatter.digitsOnly,
      //     //                       ],
      //     //                      controller: _singlePeriodAmountCntrl,
      //     //                     decoration: InputDecoration(
      //     //                       enabledBorder:const OutlineInputBorder(
      //     //                         //borderSide: BorderSide(color: Colors.black)
      //     //                       ),
      //     //                       contentPadding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      //     //                       hintText: "Kiasi katika shilingi",
      //     //                       border:OutlineInputBorder(
      //     //                         borderRadius: BorderRadius.circular(10)
      //     //                       )
      //     //                     ),
      //     //                      ),
      //     //                    ),Expanded(
      //     //                     child: Container(
      //     //                       height:40,
      //     //                             decoration: BoxDecoration(
      //     //                               borderRadius: BorderRadius.circular(5),
      //     //                              border: Border.all(
      //     //                                 color: Colors.grey
      //     //                               )
      //     //                             ),
      //     //                             padding:const EdgeInsets.symmetric(horizontal: 5),
      //     //                             child: DropdownButtonFormField(                                       
      //     //                               onChanged: (val){
      //     //                                 if(_singlePeriodAmountCntrl.text.isEmpty){
      //     //                                     UserReplyWindowsApi().showToastMessage(context,"Ingiza kiasi cha kodi kwanza");
      //     //                                 }else{
      //     //                                    _selectedPayPeriod=val.toString();
      //     //                                 }
      //     //                               },
      //     //                              hint:const Text("Muda"),                 
      //     //                             // value: _selectedRentalCategory,               
      //     //                               items: payPeriodChoices.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList()),
      //     //                           ),
      //     //                  ),
      //     //        ],),
      //     //        const SizedBox(height: 5,),
      //     //       (_totalRentalBill==null)?Container():Container(
      //     //         child: Text("Tsh ${_totalRentalBill.toString()}/= kila baada ya  $_selectedPayPeriod  ${control.text}",
      //     //         style:const TextStyle(fontWeight:FontWeight.w500,fontSize:13)
      //     //         ))
      //     //      ],
      //     //    )
      //     //      ),
      //        const SizedBox(
      //          height:10,
      //        ),  
      //        Center(
      //          child: Bounce(
      //            onPressed: ()async{
      //             if(_selectedRentalCategory.isEmpty){
      //                UserReplyWindowsApi().showToastMessage(context,"Tafadhali chagua aina ya pango unalohitaji!!");
      //             }else if(_selectedRegion==null){
      //                UserReplyWindowsApi().showToastMessage(context,"Tafadhali chagua mkoa unaotaka kupanga!!");
      //             }else{
      //                 Map<String,dynamic> reqRentalInfo={ 
      //                 "userId":_auth.currentUser!.uid,
      //                 "country_region_rentalType":dataProvider.selectedCountry["id"].toString()+"_"+_selectedRegion!.id.toString()+"_"+_selectedRentalCategory.toString(),
      //                 "district":_selectedDistrict==null?"":_selectedDistrict!.id,
      //                 "rentalSize":houseSizeCategory.indexWhere((el) =>el==_selectedRentalSize).toString(),
      //                 "uploadTime":DateTime.now().toString()
      //                };
      //                UserReplyWindowsApi().showProgressBottomSheet(context); 
      //                String res=await DatabaseApi().sendRequestedRentalInfo(reqRentalInfo);
      //                Navigator.pop(context);
      //                UserReplyWindowsApi().showToastMessage(context,res);
      //                if(res=="Taarifa zimetumwa kikamilifu.."){
      //                  Navigator.pop(context);
      //                }
      //               }
      //            },
      //            duration:const Duration(milliseconds:500),
      //            child: Container(
      //              padding:const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
      //              margin:const EdgeInsets.only(right: 10),
      //              decoration: BoxDecoration(
      //                color: Colors.blue,
      //                boxShadow:const [
      //                   BoxShadow(
      //                     blurRadius: 5,
      //                     color: Colors.white
      //                   )
      //                ],
      //                border: Border.all(
      //                  color: Colors.white,
      //                ),
      //                borderRadius: BorderRadius.circular(10)
      //              ),
      //             child: const Text("Tuma taarifa",style: TextStyle(fontWeight: FontWeight.w500),)
      //            ),
      //          ),
      //        ),const SizedBox(
      //          height:10,
      //        ),
      //       ],
      //     ),
      //   ),
      // )
    );
  }
}