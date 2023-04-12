import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mapa extends StatefulWidget {
  String idViagem = "";

  Mapa({idViagem});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final Set<Marker> _marcadores = {};

  CameraPosition _posicaoCamera =
      const CameraPosition(target: LatLng(-23.562436, -46.655005), zoom: 18);

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  _adicionarMarcador(LatLng latLng) async {
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

        Map<String, dynamic> viagem = {};

        viagem["titulo"] = rua;
        viagem["latitude"] = latLng.latitude;
        viagem["longitude"] = latLng.longitude;

        //salva no firebase
        _db.collection("viagens").add(viagem);
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

  _recuperaViagemParaID(String idViagem) async {
    if (idViagem != null) {
      DocumentSnapshot documentSnapshot =
          await _db.collection("viagens").doc(idViagem).get();

      Map<String, dynamic>? dados =
          documentSnapshot.data as Map<String, dynamic>?;

      //var dados = documentSnapshot.data;

      String titulo = dados?["titulo"];
      LatLng latLng = LatLng(dados?["latitude"], dados?["longitude"]);

      setState(() {
        Marker marcador = Marker(
            markerId:
                MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
            position: latLng,
            infoWindow: InfoWindow(title: titulo));

        _marcadores.add(marcador);
        _posicaoCamera = CameraPosition(target: latLng, zoom: 18);

        _movimentarCamera();
      });
    } else {
      _adicionarListenerLocalizacao();
    }
  }

  @override
  void initState() {
    super.initState();

    // _adicionarListenerLocalizacao();
    _recuperaViagemParaID(widget.idViagem);
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
        onLongPress: _adicionarMarcador,
        myLocationEnabled: true,
      ),
    );
  }
}
