import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minhas_viagens/mapa.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final List _listaViagens = [
  //   "Cristo Redentor",
  //   "Grande Muralha da China",
  //   "Taj Mahal",
  //   "Machu Picchu",
  //   "Coliseu"
  // ];

  final _controller = StreamController<QuerySnapshot>.broadcast();
  // ignore: prefer_final_fields
  FirebaseFirestore _db = FirebaseFirestore.instance;

  _abrirMapa(String idViagem) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => Mapa(
                  idViagem: idViagem,
                )));
  }

  _excluirViagem(String idViagem) {
    _db.collection("viagens").doc(idViagem).delete();
  }

  _adicionarLocal() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Mapa()));
  }

  _adicionarListenerViagens() async {
    final stream = _db.collection("viagens").snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  @override
  void initState() {
    super.initState();

    _adicionarListenerViagens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Minhas viagens")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff0066cc),
        onPressed: () {
          _adicionarLocal();
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
            case ConnectionState.active:
            case ConnectionState.done:
              // ignore: avoid_print
              print("registro: ConnectionState.done");

              List<DocumentSnapshot>? viagens = [];

              if (snapshot.hasData) {
                QuerySnapshot? querySnapshot = snapshot.data;
                viagens = querySnapshot?.docs.toList();
                // ignore: avoid_print
                print("registro: snapshot.hasData");
              } else {
                // ignore: avoid_print
                print("registro: snapshot.hasData vazio");
              }

              return Column(
                children: [
                  Expanded(
                      child: ListView.builder(
                          itemCount: viagens!.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot item = viagens![index];
                            String titulo = item["titulo"];
                            String idViagem = item.id;

                            return GestureDetector(
                              onTap: () {
                                _abrirMapa(idViagem);
                              },
                              child: Card(
                                child: ListTile(
                                  title: Text(titulo),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _excluirViagem(idViagem);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.remove_circle,
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }))
                ],
              );
          }
        },
      ),
    );
  }
}
