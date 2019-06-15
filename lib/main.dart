import 'package:flutter/material.dart';

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

const url = 'https://api.hgbrasil.com/finance?key=c9997124&format=json';

void main() async {
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
      )));
}

Future<Map> getData() async {
  http.Response response = await http.get(url);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text) {

    if(text.isEmpty) {
      _clearAll();
      return;
    }

    double value = double.parse(text);
    dolarController.text = (value/dolar).toStringAsFixed(2);
    euroController.text = (value/euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double value = double.parse(text);
    realController.text = (value*dolar).toStringAsFixed(2);
    euroController.text = (value * dolar /euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if(text.isEmpty) {
      _clearAll();
      return;
    }
    double value = double.parse(text);
    realController.text = (value * euro).toStringAsFixed(2);
    dolarController.text = (value * euro /dolar).toStringAsFixed(2);

  }

  void _clearAll(){
    realController.clear();
    dolarController.clear();
    euroController.clear();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Image.asset(
        "images/moedas.png",
        color: Color.fromRGBO(255, 255, 255, 0.3),
        colorBlendMode: BlendMode.modulate,
        height: 1000.0,
        fit: BoxFit.fill,
      ),
      Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            title: Text("\$ Conversor de moedas \$"),
            backgroundColor: Colors.amber,
            actions: <Widget>[
                  FlatButton(onPressed: _clearAll,
                  child: Icon(Icons.refresh),)
            ],
          ),
          body: FutureBuilder<Map>(
              future: getData(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                        child: Text(
                      "Carregando Dados...",
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ));
                  default:
                    if (snapshot.hasError) {
                      return Center(
                          child: Text(
                        "Erro ao carregando Dados :(",
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center,
                      ));
                    } else {

                      dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                      euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                      return SingleChildScrollView(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Icon(
                              Icons.monetization_on,
                              color: Colors.amber,
                              size: 150.0,
                            ),
                            textWidget(
                                "Reais", "R\$", realController, _realChanged),
                            Divider(),
                            textWidget("Dólares", "US\$", dolarController,
                                _dolarChanged),
                            Divider(),
                            textWidget(
                                "Euro", "€", euroController, _euroChanged),
                          ],
                        ),
                      );
                    }
                }
              })),
    ]);
  }
}

Widget textWidget(String label, String symbol, TextEditingController control,
    Function changedFunction) {
  return TextField(
    controller: control,
    onChanged: changedFunction,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    style: TextStyle(fontSize: 25.0, color: Colors.amber),
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
      prefixText: symbol,
    ),
  );
}
