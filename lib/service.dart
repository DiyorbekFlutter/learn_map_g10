import 'dart:convert';
import 'dart:io';

final class ClientService {
  static const _apikey = "e9120412-5563-4b07-a9e8-8e7de743152e";

  static Future<String?> get(String text) async {
    HttpClient httpClient = HttpClient();
    Uri url = Uri.parse("https://geocode-maps.yandex.ru/1.x/?apikey=$_apikey&format=json&lang=uz_UZ&geocode=$text");

    try{
      HttpClientRequest request = await httpClient.getUrl(url);
      HttpClientResponse response = await request.close();
      httpClient.close();

      if(response.statusCode == HttpStatus.ok) return await response.transform(utf8.decoder).join();
    } catch(e) {
      httpClient.close();
    }

    return null;
  }
}
