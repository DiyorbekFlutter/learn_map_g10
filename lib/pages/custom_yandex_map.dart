import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:learn_map_g10/model.dart';
import 'package:learn_map_g10/pages/serching.dart';
import 'package:learn_map_g10/service.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();
  late YandexMapController yandexMapController;
  late Position currentPosition;
  List<MapObject> mapObjects = [];
  List<Model> models = [];
  bool isLoadingFloatingActionButton = false;
  bool isSearching = false;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 80),
        child: Container(
          color: Colors.blue,
          alignment: const Alignment(0, 0.5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onTap: () => setState(() => isSearching = true),
              onChanged: (_) async {
                String? result = await ClientService.get(_);

                if(result != null){
                  AllResult allResult = AllResult.fromJson(json.decode(result));
                  models = allResult.models;
                  setState(() {});

                  for(Model element in allResult.models) {
                    log("\n\n\n");
                    log(element.name);
                    log(element.latitude.toString());
                    log(element.latitude.toString());
                  }
                }
              },
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xffF4F4F4),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  hintText: 'Searching...',
                  prefixIcon: const Icon(CupertinoIcons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none
                  )
              ),
            ),
          ),
        ),
      ),
      body: isSearching ? Searching(
        models: models,
        back: () => setState(() => isSearching = false),
        searching: searching
      ) : !isLoading ? YandexMap(
        mapObjects: mapObjects,
        onMapTap: (Point point) async {
          mapObjects.removeRange(2, mapObjects.length);

          mapObjects.add(
            PlacemarkMapObject(
                  opacity: 1,
                  point: point,
                  mapId: const MapObjectId("selected_location"),
                  icon: PlacemarkIcon.single(
                      PlacemarkIconStyle(
                          scale: 0.18,
                          image: BitmapDescriptor.fromAssetImage("assets/placemark.png")
                      )
                  )
              )
          );

          await _onMapTap(point);
          setState((){});
          customBottomSheet();
        },
        onMapCreated: (YandexMapController controller){
          yandexMapController = controller;

          yandexMapController.moveCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: Point(
                  latitude: currentPosition.latitude,
                  longitude: currentPosition.longitude
                ),
                zoom: 15.5
              )
            )
          );

          mapObjects.addAll([
            PlacemarkMapObject(
                opacity: 1,
                mapId: const MapObjectId("firstPoint2"),
                point: Point(
                    latitude: currentPosition.latitude,
                    longitude: currentPosition.longitude
                ),
                icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(
                        scale: 0.4,
                        image: BitmapDescriptor.fromAssetImage("assets/dot.png")
                    )
                )
            ),
            PlacemarkMapObject(
              opacity: 0.2,
              mapId: const MapObjectId("firstPoint1"),
              point: Point(
                latitude: currentPosition.latitude,
                longitude: currentPosition.longitude
              ),
              icon: PlacemarkIcon.single(
                PlacemarkIconStyle(
                  scale: 1,
                  image: BitmapDescriptor.fromAssetImage("assets/dot.png")
                )
              )
            ),
          ]);

          setState((){});
        },
      ) : const Center(
        child: CircularProgressIndicator(
          color: Colors.blue,
          strokeCap: StrokeCap.round,
        ),
      ),
      floatingActionButton: isSearching ? const SizedBox.shrink() : !isLoading ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if(mapObjects.length >= 4) Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black)
            ),
            child: IconButton(
              onPressed: customBottomSheet,
              icon: const Icon(Icons.arrow_drop_up),
            ),
          ),
          FloatingActionButton(
            onPressed: () async {
              if(isLoadingFloatingActionButton) return;
              isLoadingFloatingActionButton = true;
              setState((){});
              await _determinePosition();
              isLoadingFloatingActionButton = false;
              setState((){});

              await yandexMapController.moveCamera(
                  CameraUpdate.newCameraPosition(
                      CameraPosition(
                          target: Point(
                              latitude: currentPosition.latitude,
                              longitude: currentPosition.longitude
                          ),
                          zoom: 18,
                          tilt: 800,
                          azimuth: 180
                      )
                  ),
                  animation: const MapAnimation(duration: 2)
              );

              yandexMapController.moveCamera(
                  CameraUpdate.newCameraPosition(
                      CameraPosition(
                          target: Point(
                              latitude: currentPosition.latitude,
                              longitude: currentPosition.longitude
                          ),
                          zoom: 18,
                          tilt: 800,
                          azimuth: 180
                      )
                  ),
                  animation: const MapAnimation(duration: 2)
              );

              mapObjects.removeRange(2, mapObjects.length);
              setState(() {});
            },
            backgroundColor: Colors.black,
            child: isLoadingFloatingActionButton
                ? const Padding(
                  padding: EdgeInsets.all(15),
                  child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeCap: StrokeCap.round,
              ),
            )
                : const Icon(CupertinoIcons.location_solid, color: Colors.red),
          ),
        ],
      ) : null,
    );
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> searching(point) async {
    isSearching = false;
    isLoading = true;
    focusNode.unfocus();
    mapObjects.removeRange(2, mapObjects.length);
    setState((){});
    await _determinePosition();
    isLoading = false;
    setState((){});

    mapObjects.add(
      PlacemarkMapObject(
            opacity: 1,
            point: point,
            mapId: const MapObjectId("selected_location"),
            icon: PlacemarkIcon.single(
                PlacemarkIconStyle(
                    scale: 0.18,
                    image: BitmapDescriptor.fromAssetImage("assets/placemark.png")
                )
            )
        )
    );

    setState((){});

    await _onMapTap(point);
    setState(() {});
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;

    if(!await Geolocator.isLocationServiceEnabled()) {
      return Future.error("Location services are disabled.");
    }

    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        return Future.error("Location permissions are denied.");
      }
    }

    if(permission == LocationPermission.deniedForever){
      return Future.error("Location permissions are permanently denied, we cannot request permissions.");
    }

    currentPosition = await Geolocator.getCurrentPosition();
    isLoading = false;
    setState((){});

    return currentPosition;
  }

  Future<void> _onMapTap(Point point) async {
    var route = YandexBicycle.requestRoutes(
      bicycleVehicleType: BicycleVehicleType.bicycle,
      points: [
        RequestPoint(
          point: Point(
            latitude:  currentPosition.latitude,
            longitude: currentPosition.longitude,
          ),
          requestPointType: RequestPointType.wayPoint
        ),
        RequestPoint(point: point, requestPointType: RequestPointType.wayPoint),
      ],
    );

    var result = await route.result;

    if(result.routes!.isNotEmpty){
      for (var element in result.routes ?? []) {
        mapObjects.add(
          PolylineMapObject(
            mapId: const MapObjectId("way"),
            polyline: Polyline(
              points: element.geometry,
            ),
            strokeColor: Colors.blue,
            strokeWidth: 4,
          ),
        );
      }
    }
  }

  Future<void> customBottomSheet() async {
    await Future.delayed(const Duration(milliseconds: 500));
    bool selectedCar = true;

    if(!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text("Masofa: 500 metr",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: (){
                          selectedCar = true;
                          setState((){});
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selectedCar ? Colors.amber : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text("Mashina yo'li"),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: (){
                          selectedCar = false;
                          setState((){});
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: !selectedCar ? Colors.amber : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text("Piyoda"),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    await _determinePosition();
                    goLive();
                    if(!context.mounted) return;
                    Navigator.pop(context);
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text("Boshalash"),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      }
    );
  }

  Future<void> goLive() async {
    yandexMapController.moveCamera(
      CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 20,
            target: Point(
              latitude: currentPosition.latitude,
              longitude: currentPosition.longitude
            ),
          ),
        ),
      animation: const MapAnimation(type: MapAnimationType.smooth)
    );

    mapObjects.add(
      PlacemarkMapObject(
          opacity: 1,
          mapId: const MapObjectId("navigator"),
          point: Point(
              latitude: currentPosition.latitude,
              longitude: currentPosition.longitude
          ),
          icon: PlacemarkIcon.single(
              PlacemarkIconStyle(
                  scale: 0.1,
                  image: BitmapDescriptor.fromAssetImage("assets/navigator.png")
              )
          )
      ),
    );

    setState((){});

    Geolocator.getPositionStream(
        locationSettings: const LocationSettings()
    ).listen((event) {
      yandexMapController.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(latitude: event.latitude, longitude: event.longitude),
            zoom: 20,
          ),
        ),
        animation: const MapAnimation(type: MapAnimationType.smooth)
      );


      mapObjects.removeLast();
      mapObjects.add(
        PlacemarkMapObject(
            opacity: 1,
            mapId: const MapObjectId("navigator"),
            point: Point(
                latitude: event.latitude,
                longitude: event.longitude
            ),
            icon: PlacemarkIcon.single(
                PlacemarkIconStyle(
                    scale: 0.1,
                    image: BitmapDescriptor.fromAssetImage("assets/navigator.png")
                )
            )
        ),
      );

      setState(() {});
    });
  }
}
