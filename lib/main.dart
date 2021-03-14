import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const url = 'https://api.hgbrasil.com/finance?key=c9997124&format=json';

main(List<String> args) {
  runApp(MaterialApp(
    title: "Projeto 3 - Conversor de Moedas",
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(url));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

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
    if (text.isEmpty) {
      _clearAll();
    }
    double value = double.parse(text);
    dolarController.text = (value / dolar).toStringAsFixed(2);
    euroController.text = (value / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
    }
    double value = double.parse(text);
    realController.text = (value * this.dolar).toStringAsFixed(2);
    euroController.text = (value * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
    }
    double value = double.parse(text);
    realController.text = (value * this.euro).toStringAsFixed(2);
    dolarController.text = (value * this.euro / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.clear();
    dolarController.clear();
    euroController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "images/moedas.png",
          height: 1000.0,
          fit: BoxFit.fill,
        ),
        Scaffold(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.7),
          appBar: AppBar(
            title: Text("\$ Conversor de Moedas \$"),
            backgroundColor: Colors.amber,
            centerTitle: true,
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
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Erro ao carregar dados :(",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      ),
                    );
                  } else {
                    dolar =
                        snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.monetization_on,
                            size: 150.0,
                            color: Colors.amber,
                          ),
                          Divider(),
                          buildTextField(
                              "Reais", "R\$", realController, _realChanged),
                          Divider(),
                          buildTextField("Dólares", "US\$", dolarController,
                              _dolarChanged),
                          Divider(),
                          buildTextField(
                              "Euros", "€", euroController, _euroChanged)
                        ],
                      ),
                    );
                  }
              }
            },
          ),
        )
      ],
    );
  }
}

Widget buildTextField(String label, String symbol,
    TextEditingController controller, Function onChange) {
  return TextField(
    controller: controller,
    onChanged: onChange,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    decoration: InputDecoration(
        fillColor: Colors.black,
        filled: true,
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: symbol),
  );
}
