import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechRecognitionExample extends StatefulWidget {
  @override
  _SpeechRecognitionExampleState createState() =>
      _SpeechRecognitionExampleState();
}

class _SpeechRecognitionExampleState extends State<SpeechRecognitionExample> {
  stt.SpeechToText? _speech;
  bool _isListening = false;
  String _text = "Press the button to start speaking";
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _initSpeech() async {
    bool available = await _speech!.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) {
        print('onError: $val');

        setState(() => _isListening = false);
      },
    );
    if (available) {
      setState(() => _isListening = true);
      _startListening();
    } else {
      setState(() => _isListening = false);
    }
  }

  void _startListening() {
    _speech?.listen(
      onResult: (val) => setState(() {
        _text = val.recognizedWords;
        if (val.hasConfidenceRating && val.confidence > 0) {
          _confidence = val.confidence;
        }
        if (_speech?.isNotListening ?? true) {
          _isListening = false;
        }
      }),
    );
  }

  void _stopListening() {
    _speech?.stop();
    setState(() => _isListening = false);
  }

  Widget _buildParsedText() {
    RegExp regex = RegExp(r'(\w+(?:\s+\w+)*)\s+quantity\s+(\d+)\s*(\w+)?');
    Match? match = regex.firstMatch(_text);

    if (match != null) {
      String name = match.group(1) ?? "";
      String quantity = match.group(2) ?? "";
      String unit = match.group(3) ?? "";

      if (name.isNotEmpty &&
          quantity.isNotEmpty &&
          unit != null &&
          unit.isNotEmpty) {
        return Column(
          children: [
            _productWidget('Product', name),
            _productWidget('Quantity', quantity),
            _productWidget('Unit', unit),
          ],
        );
      } else if (unit == null || unit.isEmpty) {
        return _productErrorWidget('Unit is missing.');
      }
    }

    if (!_text.contains('quantity')) {
      return _productErrorWidget('Quantity word is missing.');
    }

    if (_text.contains('quantity') && !_text.contains(RegExp(r'\d+'))) {
      return _productErrorWidget('Quantity is missing.');
    }

    if (_text.contains(RegExp(r'quantity\s+\d+')) &&
        !_text.contains(RegExp(r'\w+$'))) {
      return _productErrorWidget('Unit is missing.');
    }

    if (_text.contains(RegExp(r'\d+\s*\w+$')) && !_text.contains('quantity')) {
      return _productErrorWidget('Quantity word is missing.');
    }

    if (_text.startsWith('quantity')) {
      return _productErrorWidget('Product is missing.');
    }

    return _productErrorWidget('Invalid input.');
  }

  Widget _productWidget(key, value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$key: ',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: const TextStyle(
                color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _productErrorWidget(error) {
    return Align(
        alignment: Alignment.center,
        child: Text(
          'Error: $error',
          style:
              const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Speech2Text',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              _text,
              style: const TextStyle(
                fontSize: 32.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Accuracy: ${(_confidence * 100.0).toStringAsFixed(1)}%',
              style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          if (_text != 'Press the button to start speaking') _buildParsedText(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: _isListening ? Colors.green : Colors.red,
        onPressed: _isListening ? _stopListening : _initSpeech,
        tooltip: 'Listen',
        child: Icon(_isListening ? Icons.mic : Icons.mic_off),
      ),
    );
  }
}
