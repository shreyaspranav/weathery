import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';
import 'package:provider/provider.dart';
import 'package:weathery/application_state.dart';
import 'package:weathery/services/weather_service.dart';
import 'package:geocoding/geocoding.dart';

class WeatherTab extends StatefulWidget {
  const WeatherTab({super.key});

  @override
  State<WeatherTab> createState() => _WeatherTabState();
}

class _WeatherTabState extends State<WeatherTab> {

  final String degreeSymbol = '°';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ApplicationState state = Provider.of<ApplicationState>(context, listen: true);

    // Check to see if the location service is enabled.
    if(!state.positionInitalized) {
      _getLocationInfo(context, state);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 600,
            collapsedHeight: 200,
            centerTitle: true,

            floating: false,
            pinned: false,
            snap: false,

            flexibleSpace: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Display the city
                Text(
                  state.positionString,
                  style: TextStyle(
                    fontSize: 28
                  ),
                ),
                Text(
                  state.temperature.toString() + degreeSymbol,
                  style: TextStyle(
                    fontSize: 70
                  ),
                )
              ],
            )
          ),


          SliverToBoxAdapter(
            child: Column(
              children: [
              ],
            ),
          )
        ],
      ),
    );
  }

  // Location related functions: -------------------------------------------------------------------------------------------
  void _getLocationInfo(BuildContext context, ApplicationState state) async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if(!enabled) {
      showDialog(
        context: context, 
        barrierDismissible: false,
        
        builder: (_) => AlertDialog(
          title: Text("Location"),
          content: Text("Enable location services to determine your location"),
          
          actions: [
            TextButton(
              onPressed: () {
                AppSettings.openAppSettings(type: AppSettingsType.location);
                Navigator.of(context).pop();
              },
              child: Text("Enable Location")
            )
          ],
        )
      );
      return;
    }

    Position pos = await Geolocator.getCurrentPosition();
    state.setPosition(pos);

    List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      state.setPositionString('${place.locality}, ${place.administrativeArea}');
    }
    Map<String, dynamic> resp = await state.weatherService.getCurrentData(pos.latitude, pos.longitude, Units.metric);
    state.setTemperature(resp['main']['temp'].toInt());
  }
}