
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ApplicationState with ChangeNotifier{ 
  
  // Weather application state: -----------------------------------------------
  late Position position;
  bool positionInitalized = false;

  // Default location parameters
  String positionString = "Bangalore, KA";
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