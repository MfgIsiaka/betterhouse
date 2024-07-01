
import 'package:betterhouse/screens/house_buildings_uploading_screens/initial_building_details_screen.dart';
import 'package:betterhouse/services/location_services.dart';
import 'package:betterhouse/services/modal_services.dart';
import 'package:flutter/cupertino.dart';

class AppDataProvider extends ChangeNotifier{
Map<String,double> _deviceLocation={};
Map<dynamic,dynamic> _currentUser={};
Widget _currentBuildingRegPage= AllDetailsScreen();
int _selectedProductType=0;
late Region _selectedRegion;
late PropertyInfo _selectedHouse;
late int _rentOrSell;
bool _isDark=false;
Map<String,dynamic> _selectedCountry={};
late int _userUploadRole;
Map<String,dynamic> _propertyFilters={
  "AllFilters":{}
};


Map<String,dynamic> get propertyFilters=>_propertyFilters;

set propertyFilters(Map<String,dynamic> _propertyFilters){
  this._propertyFilters=_propertyFilters;
  notifyListeners();
}

PropertyInfo get selectedHouse=>_selectedHouse;

set selectedHouse(PropertyInfo _selectedHouse){
  this._selectedHouse=_selectedHouse;
  notifyListeners();
}

//_selectedProductType
Map<dynamic,dynamic> get currentUser=>_currentUser;

set currentUser(Map<dynamic,dynamic> _currentUser){
  this._currentUser=_currentUser;
  notifyListeners();
}

int get rentOrSell=>_rentOrSell;

set rentOrSell(int _rentOrSell){
  this._rentOrSell=_rentOrSell;
  notifyListeners();
}

Map<String,double> get deviceLocation=>_deviceLocation;

set deviceLocation(Map<String,double> _deviceLocation){
  this._deviceLocation=_deviceLocation;
  notifyListeners();
}

int get userUploadRole=>_userUploadRole;

set userUploadRole(int _userUploadRole){
  this._userUploadRole=_userUploadRole;
  notifyListeners();
}

int get selectedProductType=>_selectedProductType;

set selectedProductType(int _selectedProductType){
  this._selectedProductType=_selectedProductType;
  notifyListeners();
}

Map<String,dynamic> get selectedCountry=>_selectedCountry;

set selectedCountry(Map<String,dynamic> _selectedCountry){
  this._selectedCountry=_selectedCountry;
  notifyListeners();
}


Region get selectedRegion=>_selectedRegion;

set selectedRegion(Region _selectedRegion){
  this._selectedRegion=_selectedRegion;
  notifyListeners();
}

bool get isDark=>_isDark;

set isDark(bool mode){
  _isDark=mode;
  notifyListeners();
}

Widget get currentBuildingRegPage=>_currentBuildingRegPage; 

set currentBuildingRegPage(Widget _currentBuildingRegPage){
  this._currentBuildingRegPage=_currentBuildingRegPage;
  notifyListeners();
}
}