import 'dart:io';
import 'dart:convert' show json, utf8;
import 'dart:async';

 const apiCategory = {
  'name': 'Currency',
  'route': 'currency',
};


class api {
  

  HttpClient httpClient = new HttpClient();
  final url = 'flutter.udacity.com';

  Future<List> getUnit(String category) async{
   final uri = Uri.https(url, '/$category');
   final jsonResponse =await  _getJson(uri);
   if(jsonResponse['units'] ==null || jsonResponse == null){
  print('Error retrieving units');
  return null;
   }
   return jsonResponse['units'];
  }

  Future<double> convert(
      String category, String amount, String fromUnit, String toUnit) async {
    final uri = Uri.https(url, '/$category/convert',
        {'amount': amount, 'from': fromUnit, 'to': toUnit});
        final jsonResponse = await _getJson(uri);
        if(jsonResponse['status']==null || jsonResponse==null){
          print('error while retrieving data');
          return null;
        }else if(jsonResponse['status']=='error'){
          print(jsonResponse['message']);
          return null;
        }
        return jsonResponse['conversion'].toDouble();
  }

   /// Fetches and decodes a JSON object represented as a Dart [Map].
  ///
  /// Returns null if the API server is down, or the response is not JSON.
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final httpRequest = await httpClient.getUrl(uri);
      final httpResponse = await httpRequest.close();
      if (httpResponse.statusCode != HttpStatus.OK) {
        return null;
      }
      // The response is sent as a Stream of bytes that we need to convert to a
      // `String`.
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      // Finally, the string is parsed into a JSON object.
      return json.decode(responseBody);
    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }
}

