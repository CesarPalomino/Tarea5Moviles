import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeMap extends StatefulWidget {
  HomeMap({Key key}) : super(key: key);

  @override
  _HomeMapState createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeMap> {
  final _buscarController = TextEditingController();
  
  Set<Marker> _mapMarkers = Set();
  GoogleMapController _mapController;
  Position _currentPosition;
  Position _defaultPosition = Position(
    longitude: 20.608148,
    latitude: -103.417576,
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getCurrentPosition(),
      builder: (context, result) {
        if (result.error == null) {
          if (_currentPosition == null) _currentPosition = _defaultPosition;
          return Scaffold(
            body: Stack(
              children: <Widget>[
                GoogleMap(
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  onMapCreated: _onMapCreated,
                  markers: _mapMarkers,
                  onLongPress: _setMarker,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition.latitude,
                      _currentPosition.longitude,
                    ),
                  ),
                ),
                Positioned(child: TextField(
        controller: _buscarController,
        onSubmitted: (String value) async {
          await showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Buscando'),
                content: Text ('Esta buscando..."$value".'),
                actions: <Widget>[
                  FlatButton(

                    onPressed: () { 
                      searchandNavigate(value);
                      
                      Navigator.pop(context); },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
        },
      ),)
              ],
            ),
          );
        } else {
          Scaffold(
            body: Center(child: Text("Error!")),
          );
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  void _onMapCreated(controller) {
    setState(() {
      _mapController = controller;
    });
  }

  void _setMarker(LatLng coord) async {
    // get address
    String _markerAddress = await _getGeolocationAddress(
      Position(latitude: coord.latitude, longitude: coord.longitude),
    );

    // add marker
    setState(() {
      _mapMarkers.add(
        Marker(
            markerId: MarkerId(coord.toString()),
            position: coord,
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet),
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return _bSheet(coord.toString(), _markerAddress);
                  });
            }
            /* infoWindow: InfoWindow(
            title: coord.toString(),
            snippet: _markerAddress,
          ),*/
            ),
      );
    });
  }

  Future<void> _getCurrentPosition() async {
    // get current position
    _currentPosition = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // get address
    String _currentAddress = await _getGeolocationAddress(_currentPosition);

    // add marker
    _mapMarkers.add(
      Marker(
          markerId: MarkerId(_currentPosition.toString()),
          position: LatLng(
            _currentPosition.latitude,
            _currentPosition.longitude,
          ),
          onTap: () {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return _bSheet(_currentPosition.toString(), _currentAddress);
                });
          }
          /*infoWindow: InfoWindow(
          title: _currentPosition.toString(),
          snippet: _currentAddress,
        ),*/
          ),
    );

    // move camera
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            _currentPosition.latitude,
            _currentPosition.longitude,
          ),
          zoom: 15.0,
        ),
      ),
    );
  }

  Future<String> _getGeolocationAddress(Position position) async {
    var places = await Geolocator().placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (places != null && places.isNotEmpty) {
      final Placemark place = places.first;
      return "${place.thoroughfare}, ${place.locality}";
    }
    return "No address availabe";
  }

  Widget _bSheet(String dato1, String dato2) {
    /*showModalBottomSheet(
      context: context,
      builder: (context) {
        return 
      },
    );*/
    return Container(
      child: Column(
        children: <Widget>[
          Text("$dato1"),
          Text("$dato2"),
        ],
      ),
    );
  }


  searchandNavigate(String add) {
    Geolocator().placemarkFromAddress(add).then((result) {
      _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target:
              LatLng(result[0].position.latitude, result[0].position.longitude),
          zoom: 10.0)));
    });
  }
}
