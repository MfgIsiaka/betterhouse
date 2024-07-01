import 'package:betterhouse/services/modal_services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FullScreenMapScreen extends StatefulWidget {
  LatLng currentLocation;
  PropertyInfo rentalInfo;
  Set<Marker> mapMarkers;
  double zoom;
  MapType mapType;
  FullScreenMapScreen(this.currentLocation,this.rentalInfo,this.mapMarkers,this.zoom,this.mapType,{ Key? key }) : super(key: key);

  @override
  _FullScreenMapScreenState createState() => _FullScreenMapScreenState();
}

class _FullScreenMapScreenState extends State<FullScreenMapScreen> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
        body: Hero(
          tag:"map",
          child: GoogleMap(
                      mapType:widget.mapType,
                      initialCameraPosition:CameraPosition(target:LatLng(widget.currentLocation.latitude,widget.currentLocation.longitude),zoom: widget.zoom),
                       markers: widget.mapMarkers,
                       onMapCreated:(GoogleMapController controller){
                        // _googleMapController=controller;
                        // getCustomeMapMarkers().then((value){
                        //      getThisDeviceCurrentLocation(region);
                        // });
                      },
                      ),
        ),
    );
  }
}