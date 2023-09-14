import 'package:favorite_places_app/models/place.dart';
import 'package:favorite_places_app/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:favorite_places_app/models/constants.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectedLocation});

  final void Function(PlaceLocation location) onSelectedLocation;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;
  //final _googleMapApiKey = "AIzaSyDLcwxUggpPZo8lcbH0TB4Crq5SJjtj4ag";

  String get locationImage {
    if (_pickedLocation == null) return '';
    final lat = _pickedLocation!.latitude;
    final lng = _pickedLocation!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=${GOOGLE_MAP_API_KEY}';
  }

  Future<String> _getLocationAddress(lat, long) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=${GOOGLE_MAP_API_KEY}'));
    final resData = json.decode(response.body);
    return resData['results'][0]['formatted_address'];
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    print(locationData.latitude);
    print(locationData.longitude);

    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      print("_getCurrentLocation() - locationData is null");
      return;
    }

    _saveLocation(lat, lng);
  }

  void _saveLocation(lat, lng) async {
    final address = await _getLocationAddress(lat, lng);
    print('address : $address');

    setState(() {
      _pickedLocation =
          PlaceLocation(latitude: lat, longitude: lng, address: address);
      _isGettingLocation = false;
    });

    widget.onSelectedLocation(_pickedLocation!);
  }

  void _selectOnMap() async {
    final position = await Navigator.of(context)
        .push<LatLng>(MaterialPageRoute(builder: (ctx) => const MapScreen()));

    if (position == null) return;

    setState(() {
      _isGettingLocation = true;
    });

    _saveLocation(position.latitude, position.longitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location selected',
      style: Theme.of(context)
          .textTheme
          .bodyLarge!
          .copyWith(color: Theme.of(context).colorScheme.primary),
    );

    if (_pickedLocation != null) {
      previewContent = Image.network(
        locationImage,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 170,
          decoration: BoxDecoration(
            border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.20),
                width: 1),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
                onPressed: _getCurrentLocation,
                icon: Icon(
                  Icons.location_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: const Text(
                  'Get Current Location',
                )),
            const SizedBox(
              width: 20,
            ),
            TextButton.icon(
                onPressed: _selectOnMap,
                icon: Icon(
                  Icons.map,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: const Text('Select on Map')),
          ],
        )
      ],
    );
  }
}
