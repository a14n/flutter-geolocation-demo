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
    final json = JSON.decode(message) as Map<String, dynamic>;
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
        .map((latLng) => '${latLng.lat},${latLng.lng}')
        .join('|');
  }

  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle descriptionStyle = theme.textTheme.subhead;
    return new Card(child: new Column(children: [
      new AspectRatio(
          aspectRatio: 16.0 / 9.0,
          child: new LayoutBuilder(builder: (context, size) {
            final width = min(400, size.width).toInt();
            final height = width * size.height ~/ size.width;
            return new NetworkImage(
                src: 'https://maps.googleapis.com/maps/api/staticmap'
                    '?size=${width}x$height'
                    '&path=color:0x00000000|weight:5|fillcolor:0xFFFF0033|$_path');
          })),
      new Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(
                    'Date: ' +
                        new DateTime.fromMillisecondsSinceEpoch(location.time)
                            .toString(),
                    style: descriptionStyle),
                new Text('LatLng: ${location.latitude},${location.longitude}',
                    style: descriptionStyle),
                new Text('Provider: ${location.provider}',
                    style: descriptionStyle),
                new Text('Accuracy: ${location.accuracy}',
                    style: descriptionStyle),
              ]))
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
