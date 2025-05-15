import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:simplytranslate/simplytranslate.dart';

void main() {
  runApp(MaterialApp(
    home: WhatsAppReader(),
  ));
} 

class WhatsAppReader extends StatefulWidget {
  @override
  _WhatsAppReaderState createState() => _WhatsAppReaderState();
}

class _WhatsAppReaderState extends State<WhatsAppReader> {
  final String defaultLanguage = 'en-US';
  TextToSpeech tts = TextToSpeech();
  String text = '';
  String displayedText = '';
  double volume = 1; // Range: 0-1
  double rate = 1.0; // Range: 0-2
  double pitch = 1.0; // Range: 0-2
  String selectedLanguage = 'en'; // Default to English

  TextEditingController textEditingController = TextEditingController();
  SimplyTranslator translator = SimplyTranslator(EngineType.google);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green,
        hintColor: Colors.black,
        scaffoldBackgroundColor: Colors.green[50],
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.chat, size: 25, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'WhatsApp Reader',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          actions: [
            IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('About WhatsApp Reader'),
                      content: Text(
                          'This app is designed to read out WhatsApp messages. Simply paste your WhatsApp chat into the text box and the app will read it out loud.'),
                      actions: [
                        ElevatedButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        TextField(
                          controller: textEditingController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Paste your WhatsApp messages here...',
                          ),
                          onChanged: (String newText) {
                            setState(() {
                              text = newText;
                            });
                          },
                        ),
                        Positioned(
                          bottom: 2.0,
                          right: 2.0,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(80),
                            onTap: () {
                              setState(() {
                                resetApp();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close,
                                size: 25.0,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    DropdownButton<String>(
                      value: selectedLanguage,
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'hi',
                          child: Text('Hindi'),
                        ),
                        DropdownMenuItem(
                          value: 'te',
                          child: Text('Telugu'),
                        ),
                        DropdownMenuItem(
                          value: 'ta',
                          child: Text('Tamil'),
                        ),
                        DropdownMenuItem(
                          value: 'kn',
                          child: Text('Kannada'),
                        ),
                        DropdownMenuItem(
                          value: 'ml',
                          child: Text('Malayalam'),
                        ),
                        DropdownMenuItem(
                          value: 'mr',
                          child: Text('Marathi'),
                        ),
                        DropdownMenuItem(
                          value: 'gu',
                          child: Text('Gujarati'),
                        ),
                        DropdownMenuItem(
                          value: 'pa',
                          child: Text('Punjabi'),
                        ),
                        DropdownMenuItem(
                          value: 'bn',
                          child: Text('Bengali'),
                        ),
                        DropdownMenuItem(
                          value: 'or',
                          child: Text('Odia'),
                        ),
                        DropdownMenuItem(
                          value: 'as',
                          child: Text('Assamese'),
                        ),
                        DropdownMenuItem(
                          value: 'ur',
                          child: Text('Urdu'),
                        ),
                      ],
                      onChanged: (Value) {
                        setState(() {
                          selectedLanguage = Value!;
                          _translateText();
                        });
                      },
                    ),
                    AnimatedElevatedButton(
                      onPressed: _translateText,
                      text: 'Translate',
                    ),
                    AnimatedElevatedButton(
                      onPressed: () async {
                        await _translateText();
                        speak();
                      },
                      text: 'Read All',
                    ),
                    AnimatedElevatedButton(
                      onPressed: () {
                        tts.stop();
                      },
                      text: 'Stop',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                    image: DecorationImage(
                      image: AssetImage('assets/images/watssappbaground.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0), BlendMode.darken),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _getMessageCount(),
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                              onTap: () {
                                final messageText = _getMessageText(index);
                                tts.setVolume(volume);
                                tts.setRate(rate);
                                tts.setPitch(pitch);
                                tts.speak(messageText);
                              },
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: EdgeInsets.only(top: 10.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Container(
                                      color: Colors.green[100]?.withOpacity(1.0),
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(
                                        _getMessageText(index),
                                        style: TextStyle(fontSize: 16.0),
                                        maxLines: null,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void resetApp() {
    textEditingController.clear();
    text = '';
    displayedText = '';
    selectedLanguage = 'en';
  }

  String _getMessageText(int index) {
    List<String> messages = displayedText.split('\n');
    if (index >= messages.length) return '';
    String message = messages[index];
    if (message.startsWith('[')) {
      return message.split(':').sublist(2).join(':').trim();
    }
    return message;
  }

  int _getMessageCount() {
    if (displayedText.isEmpty) return 0;
    return displayedText.split('\n').length;
  }

  void speak() {
    List<String> messages = displayedText.split('\n');
    String combinedText = messages.join('. ');

    if (combinedText.isNotEmpty) {
      tts.setVolume(volume);
      tts.setRate(rate);
      tts.setPitch(pitch);
      tts.speak(combinedText);
    }
  }

  Future<void> _translateText() async {
    if (text.isEmpty) return;

    List<String> messages = text.split('\n');
    List<String> filteredMessages = [];

    for (String message in messages) {
      if (!message.startsWith('[')) {
        filteredMessages.add(message.trim());
      } else {
        int secondColonIndex = message.indexOf(':', message.indexOf(':') + 1);
        if (secondColonIndex != -1) {
          String filteredText = message.substring(secondColonIndex + 1).trim();
          if (filteredText.isNotEmpty) {
            filteredMessages.add(filteredText);
          }
        }
      }
    }

    if (filteredMessages.isNotEmpty) {
      String filteredText = filteredMessages.join('\n');
      String translatedText = '';
      int retryCount = 0;
      const int maxRetries = 4;
      const Duration retryDelay = Duration(seconds: 2);

      while (retryCount < maxRetries) {
        try {
          translatedText = await translator.trSimply(
            filteredText,
            'auto',
            selectedLanguage,
          );
          if (translatedText.isNotEmpty) {
            setState(() {
              displayedText = translatedText;
            });
            break;
          }
        } catch (e) {
          print('Translation attempt ${retryCount + 1} failed: $e');
        }
        await Future.delayed(retryDelay);
        retryCount++;
      }

      if (translatedText.isEmpty) {
        print('Translation failed after $maxRetries attempts.');
      }
    }
  }
}

class AnimatedElevatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const AnimatedElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  _AnimatedElevatedButtonState createState() => _AnimatedElevatedButtonState();
}

class _AnimatedElevatedButtonState extends State<AnimatedElevatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.green : Colors.green,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: _isPressed
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10.0,
              spreadRadius: 2.0,
            ),
          ]
              : null,
        ),
        child: Text(
          widget.text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
