import 'package:flutter/material.dart';
import 'package:fridgify/controller/content_menu_controller.dart';


class Popups {
  static Future<void> errorPopup(BuildContext context, String msg, {Function callback}) async {
    TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(),
          title: Text('Error', style: style),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              color: Colors.purple,
              child: Text('Okay'),
              onPressed: () {
                callback != null ? callback() : Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> confirmationPopup(BuildContext context, String title, String msg, Function onPressedFunc) async {
    TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(),
          title: Text(title, style: style),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Confirm'),
              onPressed: () async {
                await onPressedFunc();
                Navigator.of(context).pop();
              },
            ),
            RaisedButton(
              color: Colors.purple,
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> infoPopup(BuildContext context, String title, String msg) async {
    TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(),
          title: Text(title, style: style),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(msg),
              ],
            ),
          ),
          actions: <Widget>[
            RaisedButton(
              color: Colors.purple,
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> addFridge(BuildContext context, ContentMenuController _controller, Function onChange) async {
    TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
    GlobalKey<FormState> key = GlobalKey();

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(),
          title: Text('Add Fridge', style: style),
          content: SingleChildScrollView(
            child: Form(
              key: key,
              child:
              ListBody(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _controller.nameController,
                    decoration: InputDecoration(hintText: "Fridge Name"),
                    validator: (value) {
                      if (value.isEmpty) return "Please enter a fridge name";
                      return null;
                    },
                  ),
                ),
              ])
              ,
            ),
          ),
          actions: <Widget>[
            Padding(

        padding: EdgeInsets.only(left: 10),
        child:
            RaisedButton(
              color: Colors.purple,
              child: Text('Create'),
              onPressed: () async => await _controller.createFridge(key, context, onChange)
              ,
            )),
            /*FlatButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0)),
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  alignment: Alignment.center,
                  child: Text(
                    "Or join a fridge via QR-Code", //"DON'T HAVE AN ACCOUNT?",
                    style: TextStyle(color: Colors.purple),
                  ),
                ),
                onPressed: () {}//() =>
                //Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => RegisterPage())),
                ),*/
          ],
        );
      },
    );
  }
}
