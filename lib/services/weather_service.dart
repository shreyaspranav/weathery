import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

enum Units {
  imperial, metric
}

String unitsToString(Units units) {
  switch (units) {
    case Units.metric:    return 'metric';
    case Units.imperial:  return 'imperial';
  }
}

class WeatherService {
  late String apiKey;
  final Dio dio = Dio();

  // URLs to request for weather data:
  final String openWeatherURL = 'https://api.openweathermap.org/data/2.5/weather';

  WeatherService() {
    apiKey = dotenv.env['OPENWEATHERMAP_API_KEY'] ?? "";
    
    if(apiKey.isEmpty) {
      print("API Key not found! Set the API key in the .env file");
    }
  }

  Future<Map<String, dynamic>> getCurrentData(double latitude, double longitude, Units units) async {
    String requestURL = openWeatherURL;
    requestURL += "?appid=$apiKey&lat=$latitude&lon=$longitude&units=${unitsToString(units)}";
    
    Response response = await dio.get(requestURL, options: Options(responseType: ResponseType.json));
    if(response.statusCode == 200) {
      return Map<String, dynamic>.from(response.data);
    } else {
      // Do some error handling.
    }

    return <String, dynamic>{};
  }
}