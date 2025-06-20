
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weathery/services/weather_service.dart';

class ApplicationState with ChangeNotifier{ 
  
  // Weather application state: -----------------------------------------------
  late Position position;
  bool positionInitalized = false;
  WeatherService weatherService = WeatherService();

  // Default location parameters
  String positionString = "New Delhi, Delhi";

  // Weather data:
  String weather = "Clouds";
  String weatherDescription = "Few Clouds";
  String iconId = "02d";
  
  int temperature = 20;        // Celcius
  int pressure = 1000;         // hPa
  int humidity = 80;           // Relative humidity

  double windSpeed = 2.0;      // kmph
  int windDirection = 0;  // degrees from N

  int cloudiness = 10;         // %

  void setPosition(Position p) {
    position = p;
    positionInitalized = true;
    notifyListeners();
  }

  void setPositionString(String p) {
    positionString = p;
    notifyListeners();
  }


  void setWeather(String w) {
    weather = w;
    notifyListeners();
  }

  void setWeatherDescription(String w) {
    weatherDescription = w;
    notifyListeners();
  }

  void setWeatherIconId(String id) {
    iconId = id;
    notifyListeners();
  }

  String getCurrentIconUrl() {
    return 'https://openweathermap.org/img/wn/$iconId@4x.png';
  }

  void setTemperature(int temp) {
    temperature = temp;
    notifyListeners();
  }

  void setPressure(int p) {
    pressure = p;
    notifyListeners();
  }

  void setHumidity(int h) {
    humidity = h;
    notifyListeners();
  }

  void setWindSpeed(double s) {
    windSpeed = s;
    notifyListeners();
  }

  void setWindDirection(int d) {
    windDirection = d;
    notifyListeners();
  }

  void setCloudiness(int c) {
    cloudiness = c;
    notifyListeners();
  }

  // News application state: ----------------------------------------------------
}