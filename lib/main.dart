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
  
  // URL do seu sistema
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
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);
    
    // Teste de som inicial (opcional)
    // await flutterTts.speak("Sistema Iniciado");
  }

  void _setupWebViewController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            // Injeta um log para debug (visível no terminal do Android)
            controller.runJavaScript("console.log('Painel carregado no APK');");
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..addJavaScriptChannel(
        'AndroidTerminal',
        onMessageReceived: (JavaScriptMessage message) {
          _speak(message.message);
        },
      )
      ..loadRequest(Uri.parse(panelUrl));
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      try {
        await flutterTts.stop();
        await flutterTts.awaitSpeakCompletion(true);
        await flutterTts.speak(text);
      } catch (e) {
        debugPrint("Erro ao falar: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
