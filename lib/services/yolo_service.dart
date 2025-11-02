import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class YoloService {
  final String _apiUrl = "https://detect.roboflow.com/college-floor-plan-detection-uy5rg/2";
  final String _apiKey = "tIF0H8cLwMwVAentg1FN";

  Future<String> detectObject(String imagePath) async {
    var request = http.MultipartRequest('POST', Uri.parse("$_apiUrl?api_key=$_apiKey"));
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));

    var response = await request.send();
    var res = await http.Response.fromStream(response);
    var data = json.decode(res.body);

    if (data["predictions"] != null && data["predictions"].isNotEmpty) {
      return data["predictions"][0]["class"];
    } else {
      return "unknown object";
    }
  }
}
