import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carte de Localisation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LatLng _currentPosition = LatLng(43.600000, 1.433333); 
  late MapController mapController;
  double _currentZoom = 12.0;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _requestPermission();
    _startLocationUpdates();
  }

  Future<void> _requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      mapController.move(_currentPosition, _currentZoom); 
    });
  }

  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
    });
    mapController.move(_currentPosition, _currentZoom);
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
    });
    mapController.move(_currentPosition, _currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carte de Localisation'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: _currentPosition, 
              initialZoom: _currentZoom, 
              maxZoom: 18.0,
              minZoom: 5.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 80,
                    height: 80,
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.blue, 
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 15,
            top: MediaQuery.of(context).size.height / 2 - 60,
            child: Column(
              children: [
                _buildZoomButton(Icons.add, _zoomIn),
                SizedBox(height: 10),
                _buildZoomButton(Icons.remove, _zoomOut),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.my_location),
        onPressed: () async {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
          });
          mapController.move(_currentPosition, _currentZoom);
        },
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, Function() onPressed) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onPressed,
      ),
    );
  }
}



class FibresPage extends StatefulWidget {
  @override
  _FibresPageState createState() => _FibresPageState();
}

class _FibresPageState extends State<FibresPage> {
  DateTime? startDate;
  DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fibres Options'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(color: Colors.black, thickness: 1), 
            Text('Choisissez une option :', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            _buildRadioOption('Entreprise'),
            _buildRadioOption('Sport'),
            _buildRadioOption('Association'),
            SizedBox(height: 20),
            Divider(color: Colors.black, thickness: 1), 
            Text('Sélectionnez une période :', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            _buildDatePicker('Début', startDate, (date) {
              setState(() => startDate = date);
            }),
            _buildDatePicker('Fin', endDate, (date) {
              setState(() => endDate = date);
            }),
            Divider(color: Colors.black, thickness: 1), 
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0), 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {}, 
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), 
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('Valider'),
                  ),
                  SizedBox(width: 20), 
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        startDate = null;
                        endDate = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), 
                      textStyle: TextStyle(fontSize: 18),
                    ),
                    child: Text('Tout Effacer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String title) {
    return ListTile(
      title: Text(title),
      leading: Radio(
        value: title,
        groupValue: null,
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onDateSelected) {
    return Row(
      children: [
        Text('$label :'),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () async {
            DateTime? selectedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) {
              onDateSelected(selectedDate);
            }
          },
          child: Text(date == null
              ? 'Choisir'
              : '${date.toLocal()}'.split(' ')[0]),
        ),
      ],
    );
  }
}
