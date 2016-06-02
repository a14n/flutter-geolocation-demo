import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

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
      locations.insert(0, new Location(
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
            children: locations.map((m) => new LocationListItem(m)).toList()));
  }
}

class LocationListItem extends StatelessWidget {
  LocationListItem(this.location);

  final Location location;

  Widget build(BuildContext context) {
    return new ListItem(
        dense: true,
        title: new Text('Lat:${location.latitude} Lng:${location.longitude}'),
        subtitle: new Text(
            'Provider: ${location.provider}, Accuracy: ${location.accuracy}\n'
            'Time: ${new DateTime.fromMillisecondsSinceEpoch(location.time).toString()}'));
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
