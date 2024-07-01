import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

var kAppColor=HexColor("#04389E");
const kGreyColor=Colors.grey;
const kBlueGreyColor=Colors.blueGrey;
const kWhiteColor=Colors.white;
const kBlackColor=Colors.black;
const String internetConnMessage="Kifaa hakina internet";

List<District> districts=[];
List<Region> regions=[];
List<Country> countries=[];

class Country{
  var id,continent;
  String name;
  int hRentalCount,hSaleCount,pRentalCount,pSaleCount,fRentalCount,fSaleCount;
  Country(this.id,this.name,this.continent,this.hRentalCount,this.hSaleCount,this.pRentalCount,this.pSaleCount,this.fRentalCount,this.fSaleCount); 
}

class Region{
var id;
String name;
double lat,long;
Region(this.id, this.name,this.lat,this.long);
}

class District{
var id,name;
District(this.id,this.name);
}
