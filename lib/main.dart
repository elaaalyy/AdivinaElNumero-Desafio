import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(JuegoAdivinaNumero());
}

class JuegoAdivinaNumero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  @override
  _PantallaPrincipalState createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int numeroSecreto = 0;
  int intentosRestantes = 0;
  String nivelSeleccionado = "Fácil";
  List<String> historialMayor = [];
  List<String> historialMenor = [];
  List<String> historialResultados = [];

  final TextEditingController _controladorEntrada = TextEditingController();

  final ScrollController _scrollControllerMayor = ScrollController();
  final ScrollController _scrollControllerMenor = ScrollController();
  final ScrollController _scrollControllerResultados = ScrollController();

  @override
  void initState() {
    super.initState();
    iniciarJuego(nivelSeleccionado);
  }

  @override
  void dispose() {
    _scrollControllerMayor.dispose();
    _scrollControllerMenor.dispose();
    _scrollControllerResultados.dispose();
    super.dispose();
  }

  void iniciarJuego(String nivel) {
    setState(() {
      nivelSeleccionado = nivel;
      historialMayor.clear();
      historialMenor.clear();
      historialResultados.clear();

      switch (nivel) {
        case "Fácil":
          numeroSecreto = Random().nextInt(10) + 1;
          intentosRestantes = 5;
          break;
        case "Medio":
          numeroSecreto = Random().nextInt(20) + 1;
          intentosRestantes = 8;
          break;
        case "Avanzado":
          numeroSecreto = Random().nextInt(100) + 1;
          intentosRestantes = 15;
          break;
        case "Extremo":
          numeroSecreto = Random().nextInt(1000) + 1;
          intentosRestantes = 25;
          break;
      }
    });
  }

  void verificarNumero(int numeroIngresado) {
    if (intentosRestantes <= 0) {
      mostrarDialogo("¡Lo siento!",
          "Te quedaste sin intentos. El número era $numeroSecreto.");
      return;
    }

    setState(() {
      intentosRestantes--;

      if (numeroIngresado == numeroSecreto) {
        historialResultados.add("¡Correcto! Número: $numeroIngresado");
        mostrarDialogo("¡Felicidades!", "¡Adivinaste el número correctamente!");
      } else if (numeroIngresado > numeroSecreto) {
        historialMayor.add("$numeroIngresado");
        historialResultados.add("Intento: $numeroIngresado (Menor)");
      } else {
        historialMenor.add("$numeroIngresado");
        historialResultados.add("Intento: $numeroIngresado (Mayor)");
      }

      if (intentosRestantes <= 0 && numeroIngresado != numeroSecreto) {
        mostrarDialogo("¡Lo siento!",
            "Te quedaste sin intentos. El número era $numeroSecreto.");
      }
    });
  }

  void mostrarDialogo(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                iniciarJuego(nivelSeleccionado);
              },
              child: Text("Reiniciar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adivina el Número"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
              value: nivelSeleccionado,
              items: ["Fácil", "Medio", "Avanzado", "Extremo"]
                  .map((nivel) => DropdownMenuItem(
                        value: nivel,
                        child: Text(nivel),
                      ))
                  .toList(),
              onChanged: (nuevoNivel) {
                if (nuevoNivel != null) {
                  iniciarJuego(nuevoNivel);
                }
              },
            ),
            SizedBox(height: 10),
            Text(
              "¡Bienvenido al nivel $nivelSeleccionado! Adivina un número entre 1 y ${rangoMaximo()}.\n" +
                  "📌 Recuerda: ¡Tienes $intentosRestantes intentos!",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _controladorEntrada,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Ingresa tu número",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                final input = int.tryParse(_controladorEntrada.text);
                if (input == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("Por favor, ingresa un número válido")),
                  );
                } else if (input < 1 || input > rangoMaximo()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            "El número debe estar entre 1 y ${rangoMaximo()}")),
                  );
                } else {
                  verificarNumero(input);
                  _controladorEntrada.clear();
                }
              },
              child: Text("Verificar"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Menor que:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Scrollbar(
                            controller: _scrollControllerMayor,
                            thumbVisibility: true,
                            child: ListView(
                              controller: _scrollControllerMayor,
                              children: historialMayor
                                  .map((numero) => Text(
                                        numero,
                                        style: TextStyle(color: Colors.red),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mayor que:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Scrollbar(
                            controller: _scrollControllerMenor,
                            thumbVisibility: true,
                            child: ListView(
                              controller: _scrollControllerMenor,
                              children: historialMenor
                                  .map((numero) => Text(
                                        numero,
                                        style: TextStyle(color: Colors.blue),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Resultados:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Scrollbar(
                controller: _scrollControllerResultados,
                thumbVisibility: true,
                child: ListView(
                  controller: _scrollControllerResultados,
                  children: historialResultados
                      .map((resultado) => Text(
                            resultado,
                            style: TextStyle(
                              color: resultado.contains("¡Correcto!")
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int rangoMaximo() {
    switch (nivelSeleccionado) {
      case "Fácil":
        return 10;
      case "Medio":
        return 20;
      case "Avanzado":
        return 100;
      case "Extremo":
        return 1000;
      default:
        return 10;
    }
  }
}
