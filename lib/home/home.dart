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

  final Map<String, int> _numberWords = {
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
    'six': 6,
    'seven': 7,
    'eight': 8,
    'nine': 9,
    'ten': 10,
    'eleven': 11,
    'twelve': 12,
    'thirteen': 13,
    'fourteen': 14,
    'fifteen': 15,
    'sixteen': 16,
    'seventeen': 17,
    'eighteen': 18,
    'nineteen': 19,
    'twenty': 20,
    'thirty': 30,
    'forty': 40,
    'fifty': 50,
    'sixty': 60,
    'seventy': 70,
    'eighty': 80,
    'ninety': 90,
    'hundred': 100,
    'thousand': 1000,
    'lakh': 100000,
    'crore': 10000000,
  };

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
      },
    );
    if (available) {
      setState(() {
        _isListening = true;
      });
      _startListening();
    } else {
      setState(() {
        _isListening = false;
      });
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
      listenFor: Duration(seconds: 10),
      onSoundLevelChange: (level) => print('Sound level: $level'),
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  void _stopListening() {
    _speech?.stop();
    setState(() {
      _isListening = false;
    });
  }

  int _convertWordToNumber(String word) {
    if (_numberWords.containsKey(word)) {
      return _numberWords[word]!;
    }
    return 0;
  }

  int _convertWordsToNumber(String input) {
    List<String> words = input.split(' ');
    int number = 0;
    int currentNumber = 0;
    int multiplier = 1;

    for (String word in words) {
      if (_numberWords.containsKey(word)) {
        int value = _numberWords[word]!;
        if (value >= 100) {
          multiplier = value;
          currentNumber = (currentNumber == 0 ? 1 : currentNumber) * multiplier;
        } else {
          currentNumber += value;
        }
      } else if (currentNumber > 0) {
        number += currentNumber * multiplier;
        currentNumber = 0;
        multiplier = 1;
      }
    }
    number += currentNumber * multiplier;
    return number;
  }

  String _processText(String text) {
    String convertedText = text;
    RegExp numberWordsPattern = RegExp(r'\b(?:one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|sixteen|seventeen|eighteen|nineteen|twenty|thirty|forty|fifty|sixty|seventy|eighty|ninety|hundred|thousand|lakh|crore)\b');

    if (numberWordsPattern.hasMatch(text)) {
      convertedText = text.replaceAllMapped(
          numberWordsPattern, (match) => _convertWordsToNumber(match.group(0)!).toString());
    }
    return convertedText;
  }

  Widget _buildParsedText() {
    String processedText = _processText(_text);
    RegExp regex = RegExp(r'(\w+(?:\s+\w+)*)\s+quantity\s+(\d+)\s*(\w+)?');
    Match? match = regex.firstMatch(processedText);

    if (match != null) {
      String name = match.group(1) ?? "";
      String quantity = match.group(2) ?? "";
      String unit = match.group(3) ?? "";

      if (name.isNotEmpty && quantity.isNotEmpty && unit != null && unit.isNotEmpty) {
        return Column(
          children: [
            _productWidget('Product', name),
            _productWidget('Quantity', quantity),
            _productWidget('Unit', unit),
          ],
        );
      }

      if (quantity.isEmpty) {
        return _productErrorWidget('Quantity is missing.');
      }

      if (unit == null || unit.isEmpty) {
        return _productErrorWidget('Unit is missing.');
      }

      if (int.tryParse(quantity) == null) {
        return _productErrorWidget('Invalid quantity.');
      }
    }

    if (_text.contains('quantity') && !_text.contains(RegExp(r'\d+'))) {
      return _productErrorWidget('Quantity is missing.');
    }

    if (_text.contains(RegExp(r'\d+')) && !_text.contains('quantity')) {
      return _productErrorWidget('Quantity word is missing.');
    }

    if (_text.startsWith('Quantity')) {
      return _productErrorWidget('Product is missing.');
    }

    return _productErrorWidget('Invalid input.');
  }

  Widget _productWidget(String key, String value) {
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

  Widget _productErrorWidget(String error) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        'Error: $error',
        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
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
