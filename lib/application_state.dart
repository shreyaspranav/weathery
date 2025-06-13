
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
  int temperature = 20;

  void setPosition(Position p) {
    position = p;
    positionInitalized = true;
    notifyListeners();
  }

  void setPositionString(String p) {
    positionString = p;
    notifyListeners();
  }

  void setTemperature(int temp) {
    temperature = temp;
    notifyListeners();
  }

  // News application state: ----------------------------------------------------
}