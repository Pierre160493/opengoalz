import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:opengoalz/constants.dart';
import 'package:opengoalz/models/club/class/club.dart';
import 'package:opengoalz/postgresql_requests.dart';

class EditCoordinatesPage extends StatefulWidget {
  final Club club;

  const EditCoordinatesPage({Key? key, required this.club}) : super(key: key);

  @override
  State<EditCoordinatesPage> createState() => _EditCoordinatesPageState();
}

class _EditCoordinatesPageState extends State<EditCoordinatesPage> {
  late TextEditingController latController;
  late TextEditingController lngController;
  late LatLng markerPosition;
  late double? originalLat;
  late double? originalLng;

  @override
  void initState() {
    super.initState();
    originalLat = widget.club.latitude;
    originalLng = widget.club.longitude;
    latController = TextEditingController(
      text: originalLat?.toString() ?? '',
    );
    lngController = TextEditingController(
      text: originalLng?.toString() ?? '',
    );
    markerPosition = LatLng(
      originalLat ?? 0,
      originalLng ?? 0,
    );
  }

  bool get hasChanged {
    final currentLat = double.tryParse(latController.text.trim());
    final currentLng = double.tryParse(lngController.text.trim());
    return currentLat != originalLat || currentLng != originalLng;
  }

  void _reset() {
    setState(() {
      latController.text = originalLat?.toStringAsFixed(6) ?? '';
      lngController.text = originalLng?.toStringAsFixed(6) ?? '';
      markerPosition = LatLng(originalLat ?? 0, originalLng ?? 0);
    });
  }

  @override
  void dispose() {
    latController.dispose();
    lngController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final lat = double.tryParse(latController.text.trim());
    final lng = double.tryParse(lngController.text.trim());

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid latitude and longitude'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Invalid coordinate range (lat: -90 to 90, lng: -180 to 180)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final pointString = 'POINT($lng $lat)';

    await operationInDB(
      context,
      'UPDATE',
      'clubs',
      data: {'location': pointString},
      matchCriteria: {'id': widget.club.id},
      messageSuccess: 'GPS coordinates updated successfully',
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit GPS Coordinates',
            style: TextStyle(fontSize: fontSizeLarge)),
        actions: [
          TextButton(
            onPressed: hasChanged ? _reset : null,
            child: Row(
              children: [
                Icon(Icons.refresh,
                    color: hasChanged ? Colors.blue : Colors.grey,
                    size: iconSizeMedium),
                formSpacer3,
                Text('Reset',
                    style: TextStyle(
                        fontSize: fontSizeMedium,
                        color: hasChanged ? null : Colors.grey)),
              ],
            ),
          ),
          TextButton(
            onPressed: hasChanged ? _save : null,
            child: Row(
              children: [
                Icon(iconSuccessfulOperation,
                    color: hasChanged ? Colors.green : Colors.grey,
                    size: iconSizeMedium),
                formSpacer3,
                Text('Save',
                    style: TextStyle(
                        fontSize: fontSizeMedium,
                        color: hasChanged ? null : Colors.grey)),
              ],
            ),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: markerPosition,
                initialZoom: 10.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    markerPosition = point;
                    latController.text = point.latitude.toStringAsFixed(6);
                    lngController.text = point.longitude.toStringAsFixed(6);
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: markerPosition,
                      child: Icon(iconClub,
                          color: Colors.red, size: iconSizeLarge),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              top: iconSizeSmall / 2,
              left: iconSizeSmall / 2,
              child: Container(
                width: iconSizeLarge * 4,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: latController,
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        hintText: 'e.g., 40.7128',
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: fontSizeMedium,
                            fontWeight: FontWeight.bold),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      style: TextStyle(
                        fontSize: fontSizeSmall,
                        color: Colors.black,
                      ),
                      onChanged: (value) {
                        final lat = double.tryParse(value);
                        final lng = double.tryParse(lngController.text);
                        if (lat != null && lng != null) {
                          setState(() {
                            markerPosition = LatLng(lat, lng);
                          });
                        }
                      },
                    ),
                    formSpacer12,
                    TextField(
                      controller: lngController,
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        hintText: 'e.g., -74.0060',
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontSize: fontSizeMedium,
                            fontWeight: FontWeight.bold),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      style: TextStyle(
                        fontSize: fontSizeSmall,
                        color: Colors.black,
                      ),
                      onChanged: (value) {
                        final lat = double.tryParse(latController.text);
                        final lng = double.tryParse(value);
                        if (lat != null && lng != null) {
                          setState(() {
                            markerPosition = LatLng(lat, lng);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
