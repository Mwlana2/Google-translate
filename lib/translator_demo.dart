import 'dart:io';

import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:image_picker/image_picker.dart';

final translator = GoogleTranslator();
String? _dropDownvalue;
String? translated_text;
TextEditingController myController = TextEditingController();

class TranslatorDemo extends StatefulWidget {
  @override
  _TranslatorDemoState createState() => _TranslatorDemoState();
}

class _TranslatorDemoState extends State<TranslatorDemo> {
  late File pickedImage;
  bool isImageLoad = false;
  bool isRecognizerText = false;
  String final_text = "";

  getText() async {
    var tempStor = await ImagePicker().pickImage(source: ImageSource.camera);
    if (tempStor == null) return;
    setState(() {
      pickedImage = File(tempStor.path);
      isImageLoad = true;
    });

    setState(() {
      isRecognizerText = true;
    });
    final GoogleVisionImage visionImage =
        GoogleVisionImage.fromFile(pickedImage);
    final TextRecognizer textRecognizer =
        GoogleVision.instance.textRecognizer();
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);
    final_text = "";
    String? text = visionText.text;
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        final_text = final_text + line.text.toString();
      }
    }
    setState(() {
      final_text;
      isRecognizerText = false;
    });
    print(final_text);
  }

  translate_text(String locale) {
    translator.translate(final_text, to: locale).then((value) {
      setState(() {
        translated_text = value.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Translator App"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 100,
                child: TextField(
                  controller: myController,
                  maxLines: 10,
                  onChanged: (_) {
                    setState(() {
                      final_text = myController.text;
                    });
                  },
                  focusNode: FocusNode(canRequestFocus: false),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.indigo),
                    ),
                    fillColor: Colors.grey[200],
                    filled: true,
                    labelText: 'Enter Text',
                    labelStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: _dropDownvalue == null
                          ? const Text('Select language',
                              style: TextStyle(color: Colors.indigo))
                          : Text(_dropDownvalue!,
                              style: const TextStyle(color: Colors.indigo)),
                      items: <String>[
                        'English',
                        'Spanish',
                        'Chineese',
                        'German',
                        'Arabic'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(child: Text(value)),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _dropDownvalue = newValue;
                        });

                        // if (final_text != null) {
                        //   if (_dropDownvalue == 'English') {
                        //     translate_text('en');
                        //   } else if (_dropDownvalue == 'Spanish') {
                        //     translate_text('es');
                        //   } else if (_dropDownvalue == 'Chineese') {
                        //     translate_text('zh-cn');
                        //   } else if (_dropDownvalue == 'German') {
                        //     translate_text('de');
                        //   } else if (_dropDownvalue == 'Arabic') {
                        //     translate_text('ar');
                        //   }
                        // }
                      },
                    ),
                  ),
                  GestureDetector(
                    child: Container(
                      width: MediaQuery.of(context).size.width / 3,
                      height: 50,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.indigo,
                      ),
                      child: const Center(
                        child: Text(
                          'Translate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      if (_dropDownvalue == null) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Select language'),
                                content: const Text('Select language'),
                                actions: <Widget>[
                                  FlatButton(
                                    child: const Text('Ok'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            });
                      } else {
                        {
                          if (_dropDownvalue == 'English') {
                            translate_text('en');
                          } else if (_dropDownvalue == 'Spanish') {
                            translate_text('es');
                          } else if (_dropDownvalue == 'Chineese') {
                            translate_text('zh-cn');
                          } else if (_dropDownvalue == 'German') {
                            translate_text('de');
                          } else if (_dropDownvalue == 'Arabic') {
                            translate_text('ar');
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.indigo,
                ),
                child: translated_text != null
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          translated_text!,
                          style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          '............',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
              ),
              const SizedBox(height: 30),
              isRecognizerText
                  ? const CircularProgressIndicator()
                  : Container(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => getText(),
        child: const Icon(
          Icons.camera,
          size: 35,
          color: Colors.white,
        ),
      ),
    );
  }
}
