import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final Set<Marker> _marcadores = {};

  CameraPosition _posicaoCamera =
      const CameraPosition(target: LatLng(-23.562436, -46.655005), zoom: 18);

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _exibirMarcador(LatLng latLng) async {
    List<Placemark> listEnderecos =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    // ignore: prefer_is_empty, unnecessary_null_comparison
    if (listEnderecos != null && listEnderecos.length > 0) {
      Placemark endereco = listEnderecos[0];

      String? rua = endereco.thoroughfare;

      Marker marcador = Marker(
          markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
          position: latLng,
          infoWindow: InfoWindow(title: rua));

      setState(() {
        _marcadores.add(marcador);
      });
    }
  }

  _movimentarCamera() async {
    GoogleMapController googleMapController = await _controller.future;

    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(_posicaoCamera));
  }

  _adicionarListenerLocalizacao() {
    var locationOptions =
        const LocationSettings(accuracy: LocationAccuracy.high);

    Geolocator.getPositionStream(locationSettings: locationOptions)
        .listen((Position position) {
      setState(() {
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 18);
        _movimentarCamera();
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _adicionarListenerLocalizacao();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa"),
      ),
      body: GoogleMap(
        markers: _marcadores,
        mapType: MapType.normal,
        initialCameraPosition: _posicaoCamera,
        onMapCreated: _onMapCreated,
        onLongPress: _exibirMarcador,
        myLocationEnabled: true,
      ),
    );
  }
}
