import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/controller/fridge.controller.dart';
import 'package:fridgify/view/widgets/forms/add_content_form.dart';
import 'package:fridgify/view/widgets/forms/add_fridge_form.dart';

class FridgeContentAddButton extends StatefulWidget {
  Fridge fridge;

  FridgeContentAddButton(this.fridge);


  @override
  FridgeContentAddButtonState createState() {
    return FridgeContentAddButtonState(this.fridge);
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class FridgeContentAddButtonState extends State<FridgeContentAddButton> {
  final _formKey = GlobalKey<FormState>();
  Fridge fridge;

  FridgeContentAddButtonState(this.fridge);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AddContentForm(),
                    ],
                  ),
                ),
              );
            });
      },
      child: Icon(Icons.add),
    );
  }
}