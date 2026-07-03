import 'dart:convert' show jsonEncode;
import 'package:http/http.dart' as http;

class ApiService {

  static Future<void> startMission({

    required String gender,
    required String ageRange,
    required String daysMissing,
    required String vehicle,
    required String clothingColor,
    required String clothingType,
    required String lastSeenLocation,

  }) async {

    try {

      print("sending request...");

      final url = Uri.parse(
          "http://10.0.2.2:5001/start_mission"
      );

      final response = await http.post(

        url,

        headers: {
          "Content-Type": "application/json",
        },

        body: jsonEncode({

          "gender": gender,

          "age_range": ageRange,

          "days_missing": daysMissing,

          "vehicle": vehicle,

          "clothing_color": clothingColor,

          "clothing_type": clothingType,

          "last_seen_location": lastSeenLocation,
        }),
      );

      print(response.statusCode);
      print(response.body);

    } catch (e) {

      print("ERROR:");
      print(e);
    }
  }
}