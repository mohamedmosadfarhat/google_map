import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Marker> markers = [
    Marker(markerId: MarkerId("1"), position: LatLng(25.351894, 30.1448782)),
  ];
  GoogleMapController? googleMapController;

  getLocation() async {
    bool serviceEnable;
    LocationPermission permission;

    serviceEnable = await Geolocator.isLocationServiceEnabled();
    print(serviceEnable);
    print("++++++++++++++++++");

    if (serviceEnable) {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print("_________________________");
      }
      if (permission == LocationPermission.deniedForever) {
        return;
      }
      if (permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition();
        StreamSubscription<Position> positionStream =
            Geolocator.getPositionStream().listen((Position? position) {
          markers.add(Marker(
              markerId: MarkerId("6"),
              position: LatLng(position!.latitude, position.longitude)));
          googleMapController!.animateCamera(CameraUpdate.newLatLng(
              LatLng(position.latitude, position.longitude)));
          setState(() {});
        });
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text("google map"),
        ),
        body: GoogleMap(
          onTap: (latlong) async {
            markers.add(Marker(
                markerId: MarkerId("3"),
                position: LatLng(latlong.latitude, latlong.longitude)));
            setState(() {});

            double distanceInMeters = Geolocator.distanceBetween(
                52.2165157, 6.9437819, 52.3546274, 4.8285838);
            print("+++++++++++++++++++++++++++++++");
            print(distanceInMeters / 1000);
            print("+++++++++++++++++++++++++++++++");
            List<Placemark> placemarks = await placemarkFromCoordinates(
                latlong.latitude, latlong.longitude);
            print(placemarks[0].name);
          },
          markers: markers.toSet(),
          initialCameraPosition: CameraPosition(
            target: LatLng(25.351894, 30.1448782),
          ),
          onMapCreated: (controller) {
            googleMapController = controller;
          },
        ),
      ),
    );
  }
}
