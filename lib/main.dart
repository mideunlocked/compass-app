import 'dart:math' as math;

import 'package:compass_app/neu_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool hasPermissions = false;

  @override
  void initState() {
    super.initState();

    _fetchPermissionStatus();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          hasPermissions = (status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[600],
      body: Builder(
        builder: ((context) {
          if (hasPermissions) {
            return buildCompass();
          } else {
            return buildPermissionSheet();
          }
        }),
      ),
    );
  }

  Widget buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error reading heading: ${snapshot.error}.");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;

        if (direction == null) {
          return const Center(
            child: Text("Device does not support sensors"),
          );
        }

        return NeuCircle(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(25),
              child: Transform.rotate(
                angle: direction * (math.pi / 180) * -1,
                child: Image.asset(
                  "assets/compass.png",
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget buildPermissionSheet() {
    return Center(
      child: FloatingActionButton.extended(
          backgroundColor: Colors.green[900],
          onPressed: () {
            Permission.locationWhenInUse.request().then((value) {
              _fetchPermissionStatus();
            });
          },
          label: const Text("Request Permission")),
    );
  }
}
