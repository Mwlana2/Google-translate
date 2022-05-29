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

  translate_text(String locale){
  translator.translate(final_text,to:locale).then((value){
    setState(() {
      translated_text=value.text;
    });
  });
  }


@override
void initState() {
  getText();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: Scaffold(
          appBar: AppBar(title: Text("Translator App")),
          body: SingleChildScrollView(
            child: Container(
                margin: EdgeInsets.all(20),
                child:Column(
              children: [
                Container(
                  width :double.infinity,
                  height :40,
                  child:TextField(
                    controller: myController,
                    focusNode:FocusNode(canRequestFocus:false),
                    decoration :InputDecoration(
                      border :OutlineInputBorder(),
                      labelText : 'Enter Text',
                    )
                  )
                ),
               Container(
                 margin:EdgeInsets.only(top:20),
                 child:DropdownButton<String>(
                   isExpanded: true,
                   hint:_dropDownvalue==null?Text('Select language'):
                   Text(_dropDownvalue!,
                   style:TextStyle(color:Colors.red)),
                   items:<String>['English','Spanish','Chineese','German','Arabic'].
                   map((String value){
                     return DropdownMenuItem<String>(
                       value: value,
                       child:Container(
                         child:Text(value)
                       ),
                     );
                   }).toList(),
                   onChanged: (newValue){
                     setState(() {
                       _dropDownvalue=newValue;
                     });
          
                     if(_dropDownvalue=='English'){
                       translate_text('en');
                     }else if(_dropDownvalue=='Spanish'){
                       translate_text('es');
                     }
                     else if(_dropDownvalue=='Chineese'){
                       translate_text('zh-cn');
                     }
                     else if(_dropDownvalue=='German'){
                       translate_text('de');
                     }
                     else if(_dropDownvalue=='Arabic'){
                       translate_text('ar');
                     }
                   },
                 )
               ),
                Container(
                  margin:EdgeInsets.only(top:30),
                  child:translated_text!=null?Text(translated_text!,style:
                  TextStyle(fontSize: 25,fontWeight: FontWeight.bold)):Text('')
                ),
            ],)),
          )

        ));
  }

}