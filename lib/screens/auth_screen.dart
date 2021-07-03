import 'package:cemfrontend/providers/auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
	static const routeName = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  Map _data = {'username': '', 'fullName': '', 'email': '', 'password': '', 'loginUsername': ''};

  void _updateValue(value, field) {
    _data[field] = value;
  }

  var _register = false;
  void methodChanger(n) {
    setState(() {
      _register = n;
    });
  }

  var _logInUsernameController = TextEditingController();
  var _logInPasswordController = TextEditingController();

  var _usernameController = TextEditingController();
  var _fullNameController = TextEditingController();
  var _passwordController = TextEditingController();
  var _emailController = TextEditingController();
  var _confirmPasswordController = TextEditingController();

  @override
  void clearFields() {
		_logInUsernameController.clear();
		_logInPasswordController.clear();

    _usernameController.clear();
    _fullNameController.clear();
    _passwordController.clear();
    _emailController.clear();
		_confirmPasswordController.clear();
  }

  // void test() {
  //   if (!_formKey.currentState!.validate()) {
  //     return;
  //   }

  //   _formKey.currentState!.save();

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   void seti() {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }

  //   Timer(Duration(seconds: 3), () => seti());
  // }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_register == false) {

        await Provider.of<Auth>(context, listen: false)
            .signIn(_data['loginUsername'], _data['password']);

      } else {
        
        await Provider.of<Auth>(context, listen: false)
            .signUp(_data['fullName'].split(' ')[0], _data['fullName'].split(' ')[1], _data['username'].toLowerCase(), _data['password'], _data['email']);

      }
    } catch (error) {
        showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('OOPS',
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontWeight: FontWeight.bold)),
                  content: Text(
										error.toString().contains('SocketException')
                    ? 'Network problem, please try again.'
										:error.toString(),
                    style: TextStyle(
                        color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  actions: <Widget>[
                    Row(
                      children: <Widget>[
                        RaisedButton(
                          padding: EdgeInsets.all(10),
                          color: Theme.of(context).primaryColor,
                          child: Text('GO BACK',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          onPressed: () =>
                              Navigator.of(context).pop(),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ],
                    )
                  ],
                ));
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _logInUsernameController.dispose();
		_logInPasswordController.dispose();

    _usernameController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
		_confirmPasswordController.dispose();
  }
  @override
  Widget build(BuildContext context) {
		if (_data['fullName'].length != 0) {
      _fullNameController.text = _data['fullName'];
    }
    if (_data['email'].length != 0) {
      _emailController.text = _data['email'];
    }
    if (_data['username'].length != 0) {
      _usernameController.text = _data['username'];
    }
		if (_data['loginUsername'].length != 0) {
      _logInUsernameController.text = _data['loginUsername'];
    }
    
    final deviceSize = MediaQuery.of(context).size;
    final fontSize = MediaQuery.of(context).textScaleFactor;
    return Scaffold(
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: _isLoading
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
											height: deviceSize.width * .2,
											width: deviceSize.width * .2,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: fontSize * 10,
                      ),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 3)),
                    Text(
                      _register == true
                          ? 'Creating your account...'
                          : 'Logging you into your account...',
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: fontSize * 20,
                          fontWeight: FontWeight.w900),
                    )
                  ],
                ))
              : SingleChildScrollView(
                  child: Container(
                      padding: EdgeInsets.only(
                          top: 20,
                          bottom:
                              MediaQuery.of(context).viewInsets.bottom + 10),
                      child: Column(
                        children: [
                          Container(
                              height: deviceSize.height * .16,
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                  left: 40, right: 40, bottom: 10, top: 60),
                              child: Image.asset(
                                "assets/images/JesseShare.png",
                                fit: BoxFit.contain,
                              )),
                          Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: FlatButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        color: _register == true
                                            ? Colors.white24
                                            : Theme.of(context)
                                                .primaryColorDark,
                                        onPressed: () {
                                          methodChanger(false);
                                        },
                                        child: Text(
                                          'SIGN IN',
                                          style: TextStyle(
                                              color: _register == true
                                                  ? Theme.of(context)
                                                      .primaryColor
                                                  : Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: fontSize * 17),
                                        )),
                                  ),
                                  Expanded(
                                    child: FlatButton(
                                        color: _register == false
                                            ? Colors.white
                                            : Theme.of(context)
                                                .primaryColorDark,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        onPressed: () {
                                          methodChanger(true);
                                        },
                                        child: Text('REGISTER',
                                            style: TextStyle(
                                                color: _register == true
                                                    ? Colors.white
                                                    : Theme.of(context)
                                                        .primaryColorDark,
                                                fontWeight: FontWeight.w900,
                                                fontSize: fontSize * 17))),
                                  )
                                ],
                              )),
                          Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  _register == false
                                      ? Container(
                                          margin: EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: Column(
                                            children: [
                                              Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 10),
                                                child: TextFormField(
                                                  controller:
                                                      _logInUsernameController,
                                                  onTap: () async {},
                                                  style: TextStyle(
                                                      fontSize: fontSize * 18),
                                                  decoration: InputDecoration(
                                                    prefixIcon: Icon(
                                                      Icons.person,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                    labelText: 'Username',
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Colors.red),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Colors.red),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark)),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                  ),
                                                  validator: (v) {
                                                    if (v!.isEmpty) {
                                                      return "Username can't be empty";
                                                    } else if (v.length < 4) {
                                                      return "Username can't be lesser than 4";
                                                    }
                                                  },
                                                  onSaved: (v) {
                                                    _data['loginUsername'] = v;
                                                  },
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 10),
                                                child: TextFormField(
                                                  enableSuggestions: false,
                                                  autocorrect: false,
                                                  obscureText: true,
                                                  controller:
                                                      _logInPasswordController,
                                                  onTap: () async {},
                                                  style: TextStyle(
                                                      fontSize: fontSize * 18),
                                                  decoration: InputDecoration(
                                                    prefixIcon: Icon(
                                                      Icons.lock,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                    labelText: 'Password',
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Colors.red),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Colors.red),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark)),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark),
                                                    ),
                                                  ),
                                                  validator: (v) {
                                                    if (v!.isEmpty) {
                                                      return "Please input your password";
                                                    } else if (v.length < 5) {
                                                      return "An address can't be lesser than 5 characters";
                                                    }
                                                  },
                                                  onSaved: (v) {
                                                    _data['password'] = v;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          margin: EdgeInsets.only(
                                              left: 20, right: 20),
                                          child: Column(
                                            children: [
                                              Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 10),
                                                child: TextFormField(
                                                  controller:
                                                      _fullNameController,
                                                  onTap: () async {},
                                                  style: TextStyle(
                                                      fontSize: fontSize * 18),
                                                  decoration: InputDecoration(
                                                    prefixIcon: Icon(
                                                      Icons.person,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                    labelText: 'Full Name',
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Colors.red),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Colors.red),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark)),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                  ),
                                                  validator: (v) {
                                                    if (v!.isEmpty) {
                                                      return "Name can't be empty";
                                                    } else if (v.length < 4) {
                                                      return "Username can't be lesser than 4";
                                                    } else if (v.contains(
                                                        new RegExp(r'[0-9]'))) {
                                                      return "Names don't have numbers";
                                                    }else if (v.split(' ').length < 2){
																											return 'Please enter your Last name';
																										}
                                                  },
                                                  onSaved: (v) {
                                                    _data['fullName'] = v;
                                                  },
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 10),
                                                child: TextFormField(
                                                  controller:
                                                      _usernameController,
                                                  onTap: () async {},
                                                  style: TextStyle(
                                                      fontSize: fontSize * 18),
                                                  decoration: InputDecoration(
                                                    prefixIcon: Icon(
                                                      Icons.person,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                    labelText: 'Username',
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Colors.red),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Colors.red),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark)),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                  ),
                                                  validator: (v) {
                                                    if (v!.isEmpty) {
                                                      return "Username can't be empty";
                                                    } else if (v.length < 4) {
                                                      return "Username can't be lesser than 4";
                                                    }
                                                  },
                                                  onSaved: (v) {
                                                    _data['username'] = v;
                                                  },
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 10),
                                                child: TextFormField(
                                                  controller: _emailController,
                                                  onTap: () async {},
                                                  style: TextStyle(
                                                      fontSize: fontSize * 18),
                                                  decoration: InputDecoration(
                                                    prefixIcon: Icon(
                                                      Icons.person,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                    labelText: 'Email address',
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Colors.red),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Colors.red),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark)),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                    ),
                                                  ),
                                                  validator: (v) {
                                                    if (v!.isEmpty) {
                                                      return "Email can't be empty";
                                                    } else if (!v
                                                        .contains('@')) {
                                                      return "Please enter a valid email";
                                                    }
                                                  },
                                                  onSaved: (v) {
                                                    _data['email'] = v;
                                                  },
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 10),
                                                child: TextFormField(
                                                  enableSuggestions: false,
                                                  autocorrect: false,
                                                  obscureText: true,
                                                  controller:
                                                      _passwordController,
                                                  onTap: () async {},
                                                  style: TextStyle(
                                                      fontSize: fontSize * 18),
                                                  decoration: InputDecoration(
                                                    prefixIcon: Icon(
                                                      Icons.lock,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                    labelText: 'Password',
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Colors.red),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Colors.red),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark)),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark),
                                                    ),
                                                  ),
                                                  validator: (v) {
                                                    if (v!.isEmpty) {
                                                      return "Please input your password";
                                                    } else if (v.length < 6) {
                                                      return "Please choose a password with atleast 6 digits";
                                                    }
                                                  },
                                                  onSaved: (v) {
                                                    _data['password'] = v;
                                                  },
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 10),
                                                child: TextFormField(
                                                  controller:
                                                      _confirmPasswordController,
                                                  enableSuggestions: false,
                                                  autocorrect: false,
                                                  obscureText: true,
                                                  onTap: () async {},
                                                  style: TextStyle(
                                                      fontSize: fontSize * 18),
                                                  decoration: InputDecoration(
                                                    prefixIcon: Icon(
                                                      Icons.lock,
                                                      color: Theme.of(context)
                                                          .primaryColorDark,
                                                    ),
                                                    labelText:
                                                        'Confirm password',
                                                    errorBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Colors.red),
                                                    ),
                                                    focusedErrorBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Colors.red),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10)),
                                                        borderSide: BorderSide(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColorDark)),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      borderSide: BorderSide(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColorDark),
                                                    ),
                                                  ),
                                                  validator: (v) {
                                                    if (v!.isEmpty) {
                                                      return "Please confirm your password";
                                                    } else if (v.length < 6) {
                                                      return "Password can't be lesser than 6 digits";
                                                    } else if (v !=
                                                        _passwordController
                                                            .text) {
                                                      return "Passwords don't match";
                                                    }
                                                  },
                                                  onSaved: (v) {
                                                    _data['password'] = v;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 10, left: 20, right: 20),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: RaisedButton(
                                              padding: EdgeInsets.all(10),
                                              elevation: 3,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30)),
                                              color: Theme.of(context)
                                                  .primaryColorDark,
                                              child: Text(
                                                _register == true
                                                    ? 'REGISTER'
                                                    : 'SIGN IN',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: fontSize * 20),
                                              ),
                                              onPressed: _submit),
                                          flex: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ))
                        ],
                      )),
                )),
    );
  }
}
