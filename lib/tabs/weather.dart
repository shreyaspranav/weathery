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
            expandedHeight: 500,
            collapsedHeight: 500,
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
                ),
                Image.network(
                  state.getCurrentIconUrl(),
                  width: 200,
                  height: 200,
                ),
                Text(
                  state.weatherDescription,
                  style: TextStyle(
                    fontSize: 22
                  ),
                )
              ],
            )
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // lowest = 950 highest = 1080 
                    iconTextContainer(175, 175, "Pressure", "", "mPa", state.pressure, (state.pressure - 950) / (1080 - 950), true, Colors.orange),
                    iconTextContainer(175, 175, "Humidity", "%", "Lorem", state.humidity, state.humidity / 100.0, false, Colors.lightBlue)
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget iconTextContainer(double width, double height, String title, String unit, String footer, int value, double progressValue, bool circular, Color accent) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(20),
      child: SizedBox(
        width: width,
        height: height,
        child: Container(
          color: Colors.black.withAlpha(25),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            Text(
                              value.toString(),
                              style: TextStyle(
                                fontSize: 30
                              ),
                            ),
                            Column(
                              children: [
                                Padding(padding: EdgeInsetsGeometry.only(top: 10)),
                                Text(unit),
                              ],
                            )
                          ],
                        ),
                        Text(footer)
                      ],
                    ),
                    circular ? CircularProgressIndicator(
                      value: progressValue,
                      strokeCap: StrokeCap.round,
                      color: accent,
                      strokeWidth: 8,
                      backgroundColor: Colors.black.withAlpha(30),
                    ) : 
                    SizedBox(
                      width: 15,
                      height: 50,
                      child: RotatedBox(
                        quarterTurns: -1,
                        child: LinearProgressIndicator(        
                          value: progressValue,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: accent,
                          backgroundColor: Colors.black.withAlpha(30),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
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
    }

    Position pos = await Geolocator.getCurrentPosition();
    state.setPosition(pos);

    List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      state.setPositionString('${place.locality}, ${place.administrativeArea}');
    }
    Map<String, dynamic> resp = await state.weatherService.getCurrentData(pos.latitude, pos.longitude, Units.metric);

    // Set the responded data to the Application State
    state.setWeather(resp['weather'][0]['main']);
    state.setWeatherDescription(capitalizeEachWord(resp['weather'][0]['description']));
    state.setWeatherIconId(resp['weather'][0]['icon']);

    state.setTemperature(resp['main']['temp'].round());
    state.setPressure(resp['main']['pressure'].round());
    state.setHumidity(resp['main']['humidity'].round());
  }

  String capitalizeEachWord(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}