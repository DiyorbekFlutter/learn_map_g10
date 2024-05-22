Map map = {
  "response": {
    "GeoObjectCollection": {
      "metaDataProperty": {
        "GeocoderResponseMetaData": {
          "request": "toshkent",
          "results": "10",
          "found": "10"
        }
      },
      "featureMember": [
        {
          "GeoObject": {
            "metaDataProperty": {
              "GeocoderMetaData": {
                "precision": "other",
                "text": "Узбекистан, Ташкент",
                "kind": "locality",
                "Address": {
                  "country_code": "UZ",
                  "formatted": "Узбекистан, Ташкент",
                  "Components": [
                    {
                      "kind": "country",
                      "name": "Узбекистан"
                    },
                    {
                      "kind": "province",
                      "name": "Ташкент"
                    },
                    {
                      "kind": "locality",
                      "name": "Ташкент"
                    }
                  ]
                },
                "AddressDetails": {
                  "Country": {
                    "AddressLine": "Узбекистан, Ташкент",
                    "CountryNameCode": "UZ",
                    "CountryName": "Узбекистан",
                    "AdministrativeArea": {
                      "AdministrativeAreaName": "Ташкент",
                      "Locality": {
                        "LocalityName": "Ташкент"
                      }
                    }
                  }
                }
              }
            },
            "name": "Ташкент",
            "description": "Узбекистан",
            "boundedBy": {
              "Envelope": {
                "lowerCorner": "69.121678 41.157691",
                "upperCorner": "69.525821 41.422501"
              }
            },
            "uri": "ymapsbm1://geo?data=Cgk3NzEyODg4ODUSFk_Ku3piZWtpc3RvbiwgVG9zaGtlbnQiCg06j4pCFaA-JUI,",
            "Point": {
              "pos": "69.279737 41.311158"
            }
          }
        }
      ]
    }
  }
};

class AllResult {
  List<Model> models;

  AllResult({required this.models});

  factory AllResult.fromJson(Map<String, dynamic> json) {
    return AllResult(
        models: List<Model>.from(json["response"]["GeoObjectCollection"]["featureMember"]
            .map((json) => Model.fromJson(json)))
    );
  }
}

class Model {
  String name;
  double latitude;
  double longitude;

  Model({
    required this.name,
    required this.latitude,
    required this.longitude
  });

  factory Model.fromJson(Map<String, dynamic> json){
    return Model(
      name: json["GeoObject"]["metaDataProperty"]["GeocoderMetaData"]["text"] as String,
      latitude: double.parse(json["GeoObject"]["Point"]["pos"].toString().split(' ')[1]),
      longitude: double.parse(json["GeoObject"]["Point"]["pos"].toString().split(' ')[0]),
    );
  }
}
