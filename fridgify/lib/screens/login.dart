import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Create a Form widget.
class LoginForm extends StatefulWidget {
  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class LoginFormState extends State<LoginForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Container(
        padding: EdgeInsets.fromLTRB(30, 30, 30, 0),
        child: Form(
          key: _formKey,
          child: Column(
            key: new Key('login'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(hintText: 'Enter your E-Mail'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
                key: new Key('emailfield'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Password',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                  obscureText: true,
                  key: new Key('passfield'),
                  keyboardType: TextInputType.visiblePassword),
              Container(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text('Need an Account?'),
              ),
              GestureDetector(
                key: new Key('register_lbl'),
                onTap: () => Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Processing Data'))),
                child: Container(
                  child: RichText(
                      text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: 'Sign-Up here',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 255),
                            decoration: TextDecoration.underline)),
                  ])),
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              GestureDetector(
                key: new Key('forgot_lbl'),
                onTap: () => Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text('Processing Data'))),
                child: Container(
                  child: RichText(
                      text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: 'Forgot your password?',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 255),
                            decoration: TextDecoration.underline)),
                  ])),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 170, 0, 0),
                child: Center(
                  child: SizedBox(
                    width: 75,
                    height: 75,
                    child: RaisedButton(
                      onPressed: () {
                        // Validate returns true if the form is valid, or false
                        if (_formKey.currentState.validate()) {
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text('Processing Data')));
                        }
                      },
                      key: new Key("login_btn"),
                      child: Icon(
                        Icons.play_arrow,
                        size: 30,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(75)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
