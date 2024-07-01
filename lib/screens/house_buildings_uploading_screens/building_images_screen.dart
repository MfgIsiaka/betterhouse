import 'dart:io';

import 'package:betterhouse/provider_services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'building_location_registry.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/user_info_windows_services.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bounce/flutter_bounce.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:show_up_animation/show_up_animation.dart';

class RentalImagesScreen extends StatefulWidget {
  Map<String,dynamic> buildingData;
  RentalImagesScreen(this.buildingData,{ Key? key }) : super(key: key);

  @override
  _RentalImagesScreenState createState() => _RentalImagesScreenState();
}

class _RentalImagesScreenState extends State<RentalImagesScreen> with SingleTickerProviderStateMixin{
 final _listState=GlobalKey<AnimatedListState>();
  final List<TextEditingController> _txtControllers=[];
   final List<Map<String,dynamic>> _txtPlaceNames=[];
  final ValueNotifier<bool> _isDialOpen=ValueNotifier(false);
 late AnimationController _bubbleFabCtr;
 late Animation<double> _fabAnimation;
 final bool _cropping=false;
  List<File> rentalImages=[];

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bubbleFabCtr=AnimationController(vsync: this,duration: const Duration(microseconds: 700));
    _fabAnimation=Tween<double>(begin: 0,end: 1).animate(_bubbleFabCtr);
  }

  @override
  Widget build(BuildContext context) {
    AppDataProvider dataProvider=Provider.of<AppDataProvider>(context);
     Size screenSize=MediaQuery.of(context).size;
    int index=-1;
    return Column(
      children: [
       SizedBox(
             height: 30,
             child: Row(
               children: [
                 const CircleAvatar(
                   radius: 13,
                   child: Text("2"),
                 ),
                const SizedBox(
                   width: 20,
                 ),
                Text(widget.buildingData["houseOrLand"]==1?"Picha za eneo husika":"Picha za ndani na nje ya jengo",style:const TextStyle(fontWeight: FontWeight.w900,fontSize: 15)),
                 CustomPopupMenu(child:const Icon(Icons.help_outline,color:kBlueGreyColor),
                 verticalMargin: 0.0,
                  menuBuilder: (){
                    return ShowUpAnimation(
                      child: Container(
                        padding:const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(20) ,
                        ),
                        width: 200,
                        child:const Text("Picha zitawezesha wateja kujua muonekano mzima wa mali yako"),),
                    );
                  }, pressType: PressType.singleClick)
               ],
             ),
           ),   
              Container(
               height: 213.3,
               margin:const EdgeInsets.only(top:5,),
               width: 320,
               decoration: BoxDecoration(
                 border: Border.all(
                   color:kAppColor,
                   width: 2
                 )
               ),
               child:Stack(
                 children: [
               Container(
                 alignment: Alignment.center,
                 child: rentalImages.isNotEmpty?Image.file(rentalImages[0],fit: BoxFit.fill,):Row(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 Bounce(
                   onPressed: (){
                       takeRentalImage("gallery");
                   },
                   duration:const Duration(milliseconds:500),
                   child: Container(
                     padding:const EdgeInsets.only(right: 5,top: 4,bottom: 4,left: 10),
                       decoration: BoxDecoration(
                       color:kAppColor,
                       boxShadow:const [
                          BoxShadow(
                            blurRadius: 5,
                            color: Colors.white
                          )
                       ],
                       border: Border.all(
                         color: Colors.white,
                       ),
                       borderRadius: BorderRadius.circular(30)
                     ),
                    child:  Row(
                     mainAxisSize: MainAxisSize.min,
                      children:const [
                         Text("Hifadhi",style: TextStyle(fontWeight: FontWeight.w500,color: kWhiteColor),),
                         SizedBox(width: 10,),
                         CircleAvatar(
                           radius: 13,
                           backgroundColor: Colors.white,
                           child: Icon(Icons.image,size: 20,))
                      ],
                    )
                   ),
                 ),
                const SizedBox(width: 10,),
                 Bounce(
                   onPressed: (){
                       takeRentalImage("camera");
                   },
                   duration:const Duration(milliseconds:500),
                   child: Container(
                     padding:const EdgeInsets.only(right: 5,top: 4,bottom: 4,left: 10),
                     decoration: BoxDecoration(
                       color:kAppColor,
                       boxShadow:const [
                          BoxShadow(
                            blurRadius: 5,
                            color: Colors.white
                          )
                       ],
                       border: Border.all(
                         color: Colors.white,
                       ),
                       borderRadius: BorderRadius.circular(30)
                     ),
                    child: Row(
                     mainAxisSize: MainAxisSize.min,
                      children:const [
                         Text("Kamera",style: TextStyle(fontWeight: FontWeight.w500,color: kWhiteColor),),
                         SizedBox(width: 10,),
                         CircleAvatar(
                           radius: 13,
                           backgroundColor: Colors.white,
                           child: Icon(Icons.camera))
                      ],
                    )
                   ),
                 ),
               ],
         ),
               ),Container(
                 color: Colors.black45,
                 width: screenSize.width,
                 height: 30,
                 padding:const EdgeInsets.only(left: 5,top:3,bottom: 3),
                 child: const Center(child: Text("Picha ya kwanza",style: TextStyle(fontWeight:FontWeight.w500,color: Colors.white))),
                )
                 ],
               ),
             ),
             Container(
                    height: 40,
                     decoration:const BoxDecoration(
                    color:kGreyColor,
                    borderRadius:BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    )
                  ),
                        //padding:const EdgeInsets.only(left: 6,right: 6,bottom: 5),
                        child: Row(
                          children: [
                            IconButton(onPressed: (){
                               if(rentalImages.isEmpty){
                                  UserReplyWindowsApi().showToastMessage(context,"Anza na picha ya kwanza");
                               }else{
                                takeRentalImage("gallery");   
                               } 
                            },
                            padding:const EdgeInsets.all(0),
                            icon:Icon(Icons.image,color:kAppColor,),),
                            const Expanded(
                              child:Center(child: Text("Picha zingine",style: TextStyle(fontWeight:FontWeight.w500,color: Colors.white)))
                            ),
                           IconButton(onPressed: (){
                            if(rentalImages.isEmpty){
                                  UserReplyWindowsApi().showToastMessage(context,"Anza na picha ya kwanza");
                               }else{
                                takeRentalImage("camera");   
                               }
                            },
                            padding:const EdgeInsets.all(0),
                            icon:Icon(Icons.camera,color:kAppColor),),
                 
                          ],
                        ),
                      ),Expanded(
                        child: Container(
                                    decoration: BoxDecoration(
                                      //color: Colors.black26,
                                      border:Border.all(
                                        color: kGreyColor
                                      ),
                                    ),
                                     child:rentalImages.isEmpty?Container(

                                     ):AnimatedList(
                                      key:_listState,
                                      initialItemCount:rentalImages.length,
                                      itemBuilder: (context,index,anim){
                                        print(rentalImages);
                                        return index==0?Container():
                                         SizeTransition(
                                          key: UniqueKey(),
                                          sizeFactor: anim,
                                           child: Align(
                                 alignment: Alignment.center,
                                 child: Container(
                                  height: 263.3,
                                  width:320,
                                 margin:const EdgeInsets.only(bottom: 5),
                                 decoration: BoxDecoration(
                                  color: kBlueGreyColor,
                                  border: Border.all(
                                    color: kGreyColor                               )
                                 ),
                                 child: Column(
                                  children: [
                                    SizedBox(
                                      height: 213.3,
                                      child: Stack(
                                        children: [
                                        Image.file(rentalImages[index]),
                                          Row(
                                            children: [
                                            Container(
                                              color: kGreyColor,
                                              padding:const EdgeInsets.all(5),
                                              child: Text("$index/${rentalImages.length-1}"),
                                              ),
                                             const Spacer(),
                                            IconButton(onPressed: (){
                                              setState(() {
                                                print(index);
                                                rentalImages.removeAt(index);
                                                _listState.currentState!.removeItem(index, (context, animation) => Container()); 
                                                _txtControllers[index].clear();
                                              });
                                               
                                            },padding:const EdgeInsets.all(0), icon:const Icon(Icons.cancel))  
                                            ],
                                          ),
                                        ],
                                      )),
                                    //Container(color: Colors.red,height: 40,)
                                    Expanded(
                                      child: TextFormField(
                                     controller: _txtControllers[index],
                                     decoration: InputDecoration(
                                       enabledBorder:const OutlineInputBorder(
                                         borderSide: BorderSide(color: Colors.black)
                                       ),
                                       contentPadding:const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                       hintText: "Hapa ni wapi?",
                                       border:OutlineInputBorder(
                                         borderRadius: BorderRadius.circular(10)
                                       )
                                     ),
                                    ),
                                    )
                                  ],
                                 ),
                                 ),
                               )
                                          );
                                      })
                                   ),
                      ),
       Align(
          alignment: Alignment.bottomCenter,
          child: Container(
             height:40,
           margin:const EdgeInsets.only(bottom: 5),
           child: Align(
             alignment: Alignment.center,
             child: ElevatedButton(
                onPressed:()async{
                  if(rentalImages.length>=2){
                   for(int x=0;x<rentalImages.length;x++){
                     if(_txtControllers[x].text.trim().isNotEmpty){
                       _txtPlaceNames.add({
                        "index":x,
                        "text":_txtControllers[x].text
                       });
                     }           
                      //_txtPlaceNames.add(_txtControllers[x].text);
                   }
                     Map<String,dynamic> buildingData=widget.buildingData;
                      buildingData["images"]=rentalImages;
                      buildingData["imageCount"]=rentalImages.length;
                      buildingData["photoLocation"]=_txtPlaceNames;
                      
                      print(buildingData);
                      setState(() {
                        _txtPlaceNames.clear();
                        dataProvider.currentBuildingRegPage=RentalLocationRegistryScreen(buildingData);
                      });
                  }else{
                    UserReplyWindowsApi().showToastMessage(context,"Picha angalau mbili zinahitajika");
                  }
                },
              // duration:const Duration(milliseconds:500),
               child: const Center(child: Text("Endelea",style: TextStyle(fontWeight: FontWeight.w500,color: kWhiteColor),)),
             ),
           ),
         ),
        ),
      ],
    );
  }

  Future<void> takeRentalImage(String imageSource) async{
   print("taking picture");
   if(imageSource!="camera"){
    List<XFile> selectedImages= await ImagePicker().pickMultiImage();
     for(int i=0;i<selectedImages.length;i++){
      if(rentalImages.isEmpty){
         CroppedFile? result=await ImageCropper().cropImage(sourcePath: File(selectedImages[0].path).path,
         compressQuality: 25, 
         aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 2),
         uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Kata picha",
          ),
          IOSUiSettings(
           title: "Kata picha"
         )
         ],
        );
       File imgFile=File(result!.path);
       selectedImages[i]=XFile(imgFile.path);
      }
      File thisFile=File(selectedImages[i].path);
       print("Size before "+(thisFile.lengthSync()/1024).toString()+"kb");
      File thisCompressedFile=await FlutterNativeImage.compressImage(thisFile.path,percentage: 50,quality: 50);
      if(thisCompressedFile != null){
        print("Size after "+(thisCompressedFile.lengthSync()/1024).toString()+"kb");
        setState(() {
          rentalImages.add(thisCompressedFile); 
        });
      }
     }
   }else{
    File? imgFile;
    XFile? image= await ImagePicker().pickImage(source:ImageSource.camera,imageQuality: 25); 
    if(image!=null){       
      if(rentalImages.isEmpty){
      try{     
      CroppedFile? result=await ImageCropper().cropImage(sourcePath: File(image.path).path,
         compressQuality: 25, 
         aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 2),
         uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Kata picha",
          ),
          IOSUiSettings(
           title: "Kata picha"
         )
         ],
        );
          imgFile=File(result!.path);
          print("After crop "+(File(imgFile.path).lengthSync()/1024).toString()+" kbs");
         //_txtControllers.add(TextEditingController());                      
      }catch(e){
          print("Tatizoo "+e.toString()); 
      }
      }else{
        imgFile=File(image.path);
      }
      File thisCompressedFile=await FlutterNativeImage.compressImage(imgFile!.path,percentage: 50,quality: 50);
      if(thisCompressedFile != null){
        print("Size after compre "+(thisCompressedFile.lengthSync()/1024).toString()+"kb");
        setState(() {
          rentalImages.add(thisCompressedFile); 
        });
        _listState.currentState!.insertItem(rentalImages.length-1,duration:const Duration(milliseconds: 2000));
      }
    }else{
     UserReplyWindowsApi().showToastMessage(context,"Picha haijachukuliwa");
    }
   }  
  }
 }
