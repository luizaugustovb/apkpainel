import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PanelApp(),
  ));
}

class PanelApp extends StatefulWidget {
  const PanelApp({super.key});

  @override
  State<PanelApp> createState() => _PanelAppState();
}

class _PanelAppState extends State<PanelApp> {
  late final WebViewController controller;
  final FlutterTts flutterTts = FlutterTts();
  
  final String panelUrl = 'http://10.1.8.13/painellab/public/painel?token=0d3b32bcfabbb9bebd005a9c91a48898'; 

  @override
  void initState() {
    super.initState();
    _setupTts();
    _setupWebViewController();
  }

  void _setupTts() async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    
    // TESTE 1: Tenta falar logo no início
    Future.delayed(const Duration(seconds: 5), () {
      flutterTts.speak("Aplicativo conectado com sucesso");
    });
  }

  void _setupWebViewController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'AndroidTerminal',
        onMessageReceived: (JavaScriptMessage message) {
          // TESTE 2: Tenta falar o que recebeu
          _speak(message.message);
        },
      )
      ..loadRequest(Uri.parse(panelUrl));
  }

  Future<void> _speak(String text) async {
    print("Mensagem recebida do PHP: $text");
    if (text.isNotEmpty) {
      // Tenta falar
      await flutterTts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WebViewWidget(controller: controller),
    );
  }
}
