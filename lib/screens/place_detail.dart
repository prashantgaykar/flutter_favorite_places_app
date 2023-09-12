import 'package:flutter/material.dart';

import 'package:favorite_places_app/models/place.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.file(
            place.image,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fitWidth,
          ),
          Text(
            place.title,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
