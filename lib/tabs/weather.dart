import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import 'package:provider/provider.dart';
import 'package:weathery/application_state.dart';
import 'package:weathery/services/weather_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherTab extends StatefulWidget {
  const WeatherTab({super.key});

  @override
  State<WeatherTab> createState() => _WeatherTabState();
}

class _WeatherTabState extends State<WeatherTab> {

  final String degreeSymbol = '°';
  final String bulletSymbol = '•';

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
            collapsedHeight: 390,
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
                 Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.5),
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(20),
                    child: SizedBox(
                      height: 50,
                      child: Container(
                        color: Colors.black.withAlpha(30),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Feels Like 20$degreeSymbol",
                                style: TextStyle(
                                  fontSize: 17.5 
                                ),
                              ),
                              Text(
                                "High: 30$degreeSymbol $bulletSymbol Low: 23$degreeSymbol",
                                style: TextStyle(
                                  fontSize: 16.5
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(padding: EdgeInsetsGeometry.symmetric(vertical: 7.5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // lowest = 950 highest = 1080 
                    iconTextContainerBasic(175, 175, "Pressure", "", "hPa", state.pressure, (state.pressure - 950) / (1080 - 950), true, Colors.orange),
                    iconTextContainerBasic(175, 175, "Humidity", "%", getHumidityStatus(state.humidity), state.humidity, state.humidity / 100.0, false, Colors.lightBlue)
                  ],
                ),
                Padding(padding: EdgeInsetsGeometry.symmetric(vertical: 7.5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // lowest = 950 highest = 1080 
                    iconTextContainerDirection(175, 175, "Wind", "", "km/h", state.windSpeed.round(), state.windDirection.round(), Colors.orange),
                    iconTextContainerBasic(175, 175, "Cloudiness", "%", getCloudinessStatus(state.cloudiness), state.cloudiness, state.cloudiness / 100.0, false, Color.fromARGB(255, 128, 128, 128))
                  ],
                ),
              ],
            ),
          ),

          SliverPadding(padding: EdgeInsetsGeometry.only(top: 300)),

        ],
      ),
    );
  }

  Widget iconTextContainerCustom(
    double width, 
    double height, 
    String title, 
    String unit, 
    String footer, 
    int value,
    Widget? customWidget) {
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
                    customWidget ?? SizedBox(width: 0, height: 0)
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget iconTextContainerBasic(
    double width, 
    double height, 
    String title, 
    String unit, 
    String footer, 
    int value, 
    double progressValue, 
    bool circular, 
    Color accent) {
    return iconTextContainerCustom(width, height, title, unit, footer, value, 
      circular ? 
        CircularProgressIndicator(
          value: progressValue,
          strokeCap: StrokeCap.round,
          color: accent,
          strokeWidth: 8,
          backgroundColor: Colors.black.withAlpha(35),
          
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
              backgroundColor: Colors.black.withAlpha(35),
            ),
          ),
        ) 
    ); 
  }

  Widget iconTextContainerDirection(
    double width, 
    double height, 
    String title, 
    String unit, 
    String footer, 
    int value, 
    int angle,
    Color accent) {
    return iconTextContainerCustom(width, height, title, unit, footer, value,
      Column(
        children: [
          Text("N"),
          SizedBox(
            width: 50,
            height: 50,
            child: Transform.rotate(
              angle: angle * 3.14 / 180,
              child: Icon(Icons.arrow_circle_up_rounded, size: 50, color: Colors.red)
            ),
          ),
        ],
      )
    ); 
  }

  

  // Location related functions: -------------------------------------------------------------------------------------------
  void _getLocationInfo(BuildContext context, ApplicationState state) async {
    PermissionStatus status = await Permission.location.request();
    if(status.isGranted) {
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

      state.setWindSpeed(resp['wind']['speed']);
      state.setWindDirection(resp['wind']['deg']);

      state.setCloudiness(resp['clouds']['all'].round());
    }
    else {
      // TODO: Proper handling?
    }
  }

  // Misc Helper functions: ------------------------------------------------------------------------------------------------------
  String capitalizeEachWord(String input) {
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String getCloudinessStatus(int percent) {
    if (percent < 20) {
      return 'Clear';
    } else if (percent < 50) {
      return 'Partly Cloudy';
    } else if (percent < 80) {
      return 'Mostly Cloudy';
    } else {
      return 'Overcast';
    }
  }

  String getHumidityStatus(int percent) {
    if (percent < 30) {
      return 'Very Dry';
    } else if (percent < 60) {
      return 'Comfortable';
    } else if (percent < 80) {
      return 'Humid';
    } else {
      return 'Extremely Humid';
    }
  }
}