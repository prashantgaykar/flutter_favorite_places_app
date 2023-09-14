import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:favorite_places_app/models/place.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite/sqlite_api.dart';

Future<Database> _getDatabase() async {
  final dbPath = await sqflite.getDatabasesPath();
  final db = await sqflite.openDatabase(path.join(dbPath, 'places.db'),
      onCreate: (db, version) {
    db.execute('CREATE TABLE user_places' +
        '(id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL,lng REAL,address TEXT)');
  }, version: 1);
  return db;
}

class UserPlacesNotifier extends StateNotifier<List<Place>> {
  UserPlacesNotifier() : super(const []);

  void addPlace(String title, File image, PlaceLocation location) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final copiedImage = await image.copy('${appDir.path}/$fileName');
    print('Image old path - ${image.path}');
    print('Image new path - ${copiedImage.path}');
    final newPlace =
        Place(title: title, image: copiedImage, location: location);

    _savePlace(newPlace);

    state = [newPlace, ...state];
  }

  void _savePlace(Place newPlace) async {
    final db = await _getDatabase();

    db.insert('user_places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'lat': newPlace.location.latitude,
      'lng': newPlace.location.longitude,
      'address': newPlace.location.address
    });
  }

  Future<void> loadPlaces() async {
    final db = await _getDatabase();

    final data = await db.query('user_places');
    final places = data
        .map((row) => Place(
            id: row['id'] as String,
            title: row['title'] as String,
            image: File(row['image'] as String),
            location: PlaceLocation(
              latitude: row['lat'] as double,
              longitude: row['lng'] as double,
              address: row['address'] as String,
            )))
        .toList();

    state = places;
  }
}

final userPlacesProvider =
    StateNotifierProvider<UserPlacesNotifier, List<Place>>(
  (ref) => UserPlacesNotifier(),
);
