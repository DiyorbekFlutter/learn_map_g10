import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../model.dart';

class Searching extends StatelessWidget {
  final List<Model> models;
  final void Function() back;
  final Future<void> Function(Point point) searching;
  const Searching({
    required this.back,
    required this.models,
    required this.searching,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        back();
        return false;
      },
      child: ListView.separated(
        itemCount: models.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          Model model = models[index];
          return ListTile(
            onTap: () => searching(Point(latitude: model.latitude, longitude: model.longitude)),
            title: Text(model.name),
          );
        },
      ),
    );
  }
}
