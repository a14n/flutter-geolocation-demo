import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geo/geo.dart';

void main() {
  runApp(new MaterialApp(
      title: 'Geolocation sample',
      theme: new ThemeData(
          primarySwatch: Colors.purple, accentColor: Colors.orangeAccent[400]),
      home: new GeolocScreen()));
}

class GeolocScreen extends StatefulWidget {
  @override
  State createState() => new GeolocScreenState();
}

class GeolocScreenState extends State<GeolocScreen> {
  final locations = <Location>[];

  @override
  void initState() {
    super.initState();
    HostMessages.addMessageHandler('locations', _handleLocation);
  }

  Future<String> _handleLocation(String message) async {
    Map<String, dynamic> json = JSON.decode(message);
    setState(() {
      locations.insert(
          0,
          new Location(
              accuracy: json['accuracy'],
              provider: json['provider'],
              latitude: json['latitude'],
              longitude: json['longitude'],
              time: json['time']));
    });
    return null;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text('Geolocation sample')),
        body: new Block(
            padding: new EdgeInsets.symmetric(horizontal: 8.0),
            children: locations.map((m) => new LocationCard(m)).toList()));
  }
}

class LocationCard extends StatelessWidget {
  LocationCard(Location location)
      : location = location,
        _path = _makeCirclePath(location, 12);

  final Location location;
  final String _path;

  static String _makeCirclePath(Location location, int nbPoints) {
    final center = new LatLng(location.latitude, location.longitude);
    return new List.generate(nbPoints, (i) => i * 360 / nbPoints)
        .map((heading) => computeOffset(center, location.accuracy, heading))
        .map((LatLng latLng) => '${latLng.lat},${latLng.lng}')
        .join('|');
  }

  Widget build(BuildContext context) {
    int height = 200;
    int width = 400;
    return new Card(child: new Column(children: [
      new NetworkImage(src: 'https://maps.googleapis.com/maps/api/staticmap'
          '?size=${width}x$height'
          '&path=color:0x00000000|weight:5|fillcolor:0xFFFF0033|$_path'),
      new Text('Lat:${location.latitude} Lng:${location.longitude}\n'
          'Provider: ${location.provider}, Accuracy: ${location.accuracy}\n'
          'Time: ${new DateTime.fromMillisecondsSinceEpoch(location.time).toString()}')
    ]));
  }
}

class Location {
  Location(
      {this.accuracy, this.provider, this.latitude, this.longitude, this.time});
  final num accuracy;
  final String provider;
  final num latitude;
  final num longitude;
  final int time;
}
