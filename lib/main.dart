import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=e1b814b2";

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.parse(request));
  return jsonDecode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;
  FocusNode focusNode;
  void realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void dolarChanged(String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void euroChanged(String text) {
    double euro = double.parse(text);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
    realController.text = (euro * this.euro).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("\$\$\$ Conversor de moedas \$\$\$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              ConnectionState.waiting;
              return const Center(
                child: Text(
                  "Carregando dados",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Erro ao Carregar dados",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      color: Colors.amber,
                      size: 150,
                    ),
                    SizedBox(
                        width: width * 0.9,
                        child: buildTextField(
                            "Real", "R\$", realController, realChanged)),
                    SizedBox(
                        width: width * 0.9,
                        child: buildTextField(
                            "Dólar", "US\$", dolarController, dolarChanged)),
                    SizedBox(
                      width: width * 0.9,
                      child: buildTextField(
                          "Euro", "€", euroController, euroChanged),
                    )
                  ],
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function function) {
  return TextField(
    decoration: InputDecoration(
        prefix: Text(prefix, style: const TextStyle(
          color: Colors.amber, fontSize: 25
        ),),
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.amber,
          fontSize: 20,
        ),
        border: const OutlineInputBorder()),
    controller: controller,
    onChanged: function as void Function(String)?,
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
  );
}
