import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:page_transition/page_transition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pigment/pigment.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:random_string/random_string.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flushbar/flushbar.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:flutter_responsive_screen/flutter_responsive_screen.dart';
import 'package:flutter_in_app/flutter_in_app.dart';
import 'package:async/async.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:simple_animations/simple_animations.dart';
import 'AnimatedWave.dart';
import 'WelcomeBackWave.dart';
import 'package:image_ink_well/image_ink_well.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

void main() => runApp(MyApp());

final FirebaseAuth _auth = FirebaseAuth.instance;
var selectedChat;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text',
      theme: ThemeData(
        hintColor: Pigment.fromString("#565F6C"),
        highlightColor: Pigment.fromString("#7BC89B"),
        primaryColor: Colors.white,
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/HomePage':
            return PageTransition(child: HomePage(), type: PageTransitionType.fade, duration: Duration(seconds: 0));
          case '/SignupLoginPage':
            return PageTransition(
                child: SignupLoginPage(), type: PageTransitionType.fade, duration: Duration(seconds: 0));
          case '/PremiumPage':
            return PageTransition(
                child: PremiumPage(), type: PageTransitionType.fade, duration: Duration(milliseconds: 750));
          case '/WelcomePage':
            return PageTransition(
                child: WelcomePage(), type: PageTransitionType.fade, duration: Duration(milliseconds: 750));
          case '/WelcomeBackPage':
            return PageTransition(
                child: WelcomePage(), // Fix to WelcomeBackPage
                type: PageTransitionType.fade,
                duration: Duration(milliseconds: 750));
          case '/GroupChat':
            return PageTransition(
                child: GroupChat(), type: PageTransitionType.fade, duration: Duration(milliseconds: 250));
          default:
            return PageTransition(child: LoadingPage(), type: PageTransitionType.fade, duration: Duration(seconds: 0));
        }
      },
    );
  }
}

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPage createState() => _LoadingPage();
}

class _LoadingPage extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    getUser().then((user) {
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/HomePage');
      } else {
        Navigator.pushReplacementNamed(context, '/SignupLoginPage');
      }
    });
  }

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

class SignupLoginPage extends StatefulWidget {
  SignupLoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SignupLoginPage createState() => _SignupLoginPage();
}

class _SignupLoginPage extends State<SignupLoginPage> {
  FocusNode _focus = FocusNode();
  bool keyboardShowing = false;

  @protected
  void initState() {
    super.initState();

    KeyboardVisibilityNotification().addNewListener(onShow: () {
      if (_focus.hasFocus) {
        setState(() {
          keyboardShowing = true;
        });
      }
    }, onHide: () {
      setState(() {
        keyboardShowing = false;
      });
    });
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {}

  var signupOpened = true;
  var loginOpened = false;

  var sIsLoading = false;

  var sCompleted = false;

  Future purchaseProduct() async {
    setState(() {
      sIsLoading = true;
    });
    final Billing billing = Billing(onError: (e) {});

    final BillingProduct product = await billing.getProduct('android.test.refunded');
    if (product != null) {
      await billing.purchase('android.test.refunded');
      // success

      if (!await billing.isPurchased('android.test.purchased')) {
        setState(() {
          sCompleted = true;
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.pushReplacementNamed(context, '/PremiumPage');
          });
        });
      } else {
        setState(() {
          sIsLoading = false;
        });
      }
    } else {
      // something went wrong
      setState(() {
        sIsLoading = false;
      });
    }
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  void signUpWithEmail() async {
    setState(() {
      sIsLoading = true;
    });
    // marked async
    FirebaseUser user;
    try {
      user = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } catch (e) {
      print(e.toString());
    } finally {
      if (user != null) {
        Firestore.instance.collection('users').document().setData({
          'displayName': usernameController.text,
          'email': user.email,
          'uid': user.uid,
        });
        // sign up successful!
        setState(() {
          sCompleted = true;
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.pushReplacementNamed(context, '/WelcomePage');
          });
        });
      } else {
        setState(() {
          sIsLoading = false;
        });
        // sign up unsuccessful
        // ex: prompt the user to try again
      }
    }
  }

  void logInWithEmail() async {
    setState(() {
      sIsLoading = true;
    });
    // marked async
    FirebaseUser user;
    try {
      user = await _auth.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
    } catch (e) {
      print(e.toString());
    } finally {
      if (user != null) {
        setState(() {
          sCompleted = true;
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.pushReplacementNamed(context, '/WelcomeBackPage');
          });
        });
      } else {
        setState(() {
          sIsLoading = false;
        });
        // log in unsuccessful
        // ex: prompt the user to try again
      }
    }
  }

  bool forgotPasswordTapped = false;

  void forgotPassword() async {
    if (emailController.text.isEmpty ||
        !emailController.text.contains("@") ||
        !emailController.text.contains(".") ||
        !emailController.text.contains("\s")) {
      Flushbar(
        aroundPadding: EdgeInsets.all(8),
        borderRadius: 8,
        message: "Please enter a valid email address in the textfield above",
        icon: Icon(
          Icons.error,
          size: 28.0,
          color: Colors.red,
        ),
        duration: Duration(seconds: 3),
      )..show(context);
    } else {
      await _auth.sendPasswordResetEmail(email: emailController.text);
      Flushbar(
        aroundPadding: EdgeInsets.all(8),
        borderRadius: 8,
        message: "A password reset email has been sent to your email address",
        icon: Icon(
          Icons.info_outline,
          size: 28.0,
          color: Colors.blue,
        ),
        duration: Duration(seconds: 3),
      )..show(context);
    }
  }

  bool hoverColor = false;

  ScrollController _scrollController = ScrollController();

  bool isEnabled1 = true;
  bool isEnabled2 = true;

  double waveColor = 0;
  // waveColor starts with being green(aka 0)

  @override
  Widget build(BuildContext context) {
    final Function wp = Screen(MediaQuery.of(context).size).wp;
    final Function hp = Screen(MediaQuery.of(context).size).hp;
    return Scaffold(
      backgroundColor: Pigment.fromString("#2F3338"),
      body: Center(
        child: Stack(children: <Widget>[
          Column(children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: keyboardShowing ? hp(0) : hp(10)),
              child: SizedBox(
                height: hp(15),
                width: wp(80),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: hp(1)),
              child: Container(
                decoration: ShapeDecoration(
                  color: Pigment.fromString("#2F3338"),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                child: Container(
                  // was 72 ?
                  height: hp(70),
                  child: Padding(
                    padding: EdgeInsets.only(top: hp(2.5)),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            InkWell(
                              onTap: isEnabled1
                                  ? () {
                                      _scrollController.animateTo(_scrollController.position.minScrollExtent,
                                          duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
                                      setState(() {
                                        signupOpened = true;
                                        loginOpened = false;
                                        isEnabled1 = false;
                                        Future.delayed(const Duration(milliseconds: 500), () {
                                          setState(() {
                                            isEnabled1 = true;
                                          });
                                        });
                                      });
                                    }
                                  : null,
                              child: Container(
                                child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 300),
                                  opacity: loginOpened ? 0.5 : 1,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: wp(8.5), right: wp(3.5), top: hp(2.5), bottom: hp(2.5)),
                                    child: Text(
                                      "Log in",
                                      style: TextStyle(
                                          fontFamily: 'Courier',
                                          fontSize: wp(6),
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: isEnabled2
                                  ? () {
                                      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
                                          duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
                                      setState(() {
                                        signupOpened = false;
                                        loginOpened = true;
                                        isEnabled2 = false;
                                        Future.delayed(const Duration(milliseconds: 500), () {
                                          setState(() {
                                            isEnabled2 = true;
                                          });
                                        });
                                      });
                                    }
                                  : null,
                              child: Container(
                                child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 300),
                                  opacity: signupOpened ? 0.5 : 1,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: wp(3.5), right: wp(8.5), top: hp(3.5), bottom: hp(3.5)),
                                    child: Text(
                                      "Sign up",
                                      style: TextStyle(
                                          fontFamily: 'Courier',
                                          fontSize: wp(6),
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.fastOutSlowIn,
                          height: hp(1),
                          width: wp(75),
                          decoration: ShapeDecoration(
                            color: Pigment.fromString("#565F6C"),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          alignment: loginOpened ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            height: hp(1),
                            width: wp(37.5),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: hp(5)),
                          child: SingleChildScrollView(
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            controller: _scrollController,
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.fastOutSlowIn,
                              child: Padding(
                                padding: EdgeInsets.only(right: wp(15.5), left: wp(6.5)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(
                                      width: wp(8.5),
                                    ),
                                    Column(
                                      children: <Widget>[
                                        SizedBox(
                                          width: wp(70),
                                          height: wp(12),
                                          child: TextField(
                                            controller: emailController,
                                            keyboardType: TextInputType.emailAddress,
                                            cursorColor: Colors.white,
                                            style: TextStyle(
                                                fontFamily: 'Courier',
                                                fontSize: wp(5),
                                                color: Pigment.fromString("#2F3338")),
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.only(top: wp(6), left: wp(5)),
                                              fillColor: Pigment.fromString("#565F6C"),
                                              filled: true,
                                              hintText: "Email",
                                              hintStyle: TextStyle(
                                                fontFamily: 'Courier',
                                                fontSize: wp(5),
                                                color: Pigment.fromString("#2F3338"),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(
                                                  const Radius.circular(100),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: wp(6)),
                                          child: SizedBox(
                                            width: wp(70),
                                            height: wp(12),
                                            child: TextField(
                                              controller: passwordController,
                                              obscureText: true,
                                              cursorColor: Colors.white,
                                              style: TextStyle(
                                                  fontFamily: 'Courier',
                                                  fontSize: wp(5),
                                                  color: Pigment.fromString("#2F3338")),
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.only(top: wp(6), left: wp(5)),
                                                fillColor: Pigment.fromString("#565F6C"),
                                                filled: true,
                                                hintText: "Password",
                                                hintStyle: TextStyle(
                                                  fontSize: wp(5),
                                                  color: Pigment.fromString("#2F3338"),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: const BorderRadius.all(
                                                    const Radius.circular(100),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: wp(6), bottom: wp(6)),
                                          child: SizedBox(
                                            width: wp(70),
                                            height: wp(12),
                                            child: RaisedButton(
                                              highlightColor: Pigment.fromString("#ffe34c"),
                                              // On pressed buy premium account
                                              onPressed: () {
                                                waveColor = 1;
                                                purchaseProduct();
                                              },
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                              color: Pigment.fromString("#ffe34c"),
                                              child: Text(
                                                "Buy Premium",
                                                style: TextStyle(
                                                  fontFamily: 'Courier',
                                                  fontSize: wp(5),
                                                  color: Pigment.fromString("#2F3338"),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: wp(15),
                                    ),
                                    Column(
                                      children: <Widget>[
                                        SizedBox(
                                          width: wp(70),
                                          height: wp(12),
                                          child: TextField(
                                            controller: emailController,
                                            keyboardType: TextInputType.emailAddress,
                                            cursorColor: Colors.white,
                                            style: TextStyle(
                                                fontFamily: 'Courier',
                                                fontSize: wp(5),
                                                color: Pigment.fromString("#2F3338")),
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.only(top: wp(6), left: wp(5)),
                                              fillColor: Pigment.fromString("#565F6C"),
                                              filled: true,
                                              hintText: "Email",
                                              hintStyle: TextStyle(
                                                fontFamily: 'Courier',
                                                fontSize: wp(5),
                                                color: Pigment.fromString("#2F3338"),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: const BorderRadius.all(
                                                  const Radius.circular(100),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: wp(6)),
                                          child: SizedBox(
                                            width: wp(70),
                                            height: wp(12),
                                            child: TextField(
                                              controller: usernameController,
                                              cursorColor: Colors.white,
                                              style: TextStyle(
                                                  fontFamily: 'Courier',
                                                  fontSize: wp(5),
                                                  color: Pigment.fromString("#2F3338")),
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.only(top: wp(6), left: wp(5)),
                                                fillColor: Pigment.fromString("#565F6C"),
                                                filled: true,
                                                hintText: "Username",
                                                hintStyle: TextStyle(
                                                  fontSize: wp(5),
                                                  color: Pigment.fromString("#2F3338"),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: const BorderRadius.all(
                                                    const Radius.circular(100),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: wp(6)),
                                          child: SizedBox(
                                            width: wp(70),
                                            height: wp(12),
                                            child: TextField(
                                              focusNode: _focus,
                                              controller: passwordController,
                                              obscureText: true,
                                              cursorColor: Colors.white,
                                              style: TextStyle(
                                                  fontFamily: 'Courier',
                                                  fontSize: wp(5),
                                                  color: Pigment.fromString("#2F3338")),
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.only(top: wp(6), left: wp(5)),
                                                fillColor: Pigment.fromString("#565F6C"),
                                                filled: true,
                                                hintText: "Password",
                                                hintStyle: TextStyle(
                                                  fontSize: wp(5),
                                                  color: Pigment.fromString("#2F3338"),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: const BorderRadius.all(
                                                    const Radius.circular(100),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: wp(5), right: wp(5), top: wp(3.5)),
                          child: SizedBox(
                            width: wp(35),
                            height: wp(12),
                            child: RaisedButton(
                              highlightColor: Pigment.fromString("#7BC89B"),
                              onPressed: () {
                                waveColor = 0;
                                if (loginOpened == true) {
                                  signUpWithEmail();
                                } else {
                                  logInWithEmail();
                                }
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                              color: Pigment.fromString("#7BC89B"),
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: wp(5),
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: wp(5), right: wp(5), top: hp(4.5)),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                forgotPasswordTapped = true;
                              });
                              Future.delayed(const Duration(milliseconds: 750), () {
                                setState(() {
                                  forgotPasswordTapped = false;
                                });
                              });
                              forgotPassword();
                            },
                            child: AnimatedOpacity(
                              opacity: forgotPasswordTapped ? 0.75 : 0.35,
                              duration: Duration(milliseconds: 750),
                              curve: Curves.fastOutSlowIn,
                              child: Text(
                                "Forgot your password?",
                                style: TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: wp(5),
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: <Widget>[
                Positioned(
                  bottom: 0,
                  child: Column(children: <Widget>[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 1500),
                        curve: Curves.fastOutSlowIn,
                        height: sIsLoading ? hp(10) : hp(0),
                        child: SizedBox(
                          height: double.infinity,
                          width: wp(100),
                          child: Stack(
                            children: <Widget>[
                              AnimatedWave(
                                color: waveColor == 0 ? 0 : 1,
                                height: double.infinity,
                                speed: 1.5,
                              ),
                              // These three containers are to remove a line(UI defect) caused by AnimatedWave
                              Positioned(
                                bottom: 0,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 1500),
                                  curve: Curves.fastOutSlowIn,
                                  height: sIsLoading ? hp(1) : hp(0),
                                  width: wp(100),
                                  color: waveColor == 0 ? Pigment.fromString("#7BC89B") : Pigment.fromString("#ffe34c"),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 1500),
                                  curve: Curves.fastOutSlowIn,
                                  height: sIsLoading ? hp(1) : hp(0),
                                  width: wp(100),
                                  color: waveColor == 0 ? Pigment.fromString("#7BC89B") : Pigment.fromString("#ffe34c"),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 1500),
                                  curve: Curves.fastOutSlowIn,
                                  height: sIsLoading ? hp(1) : hp(0),
                                  width: wp(100),
                                  color: waveColor == 0 ? Pigment.fromString("#7BC89B") : Pigment.fromString("#ffe34c"),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        //padding: EdgeInsets.only(top: 30),
                        duration: Duration(milliseconds: 1500),
                        curve: Curves.fastOutSlowIn,
                        height: sCompleted ? hp(100) : hp(0),
                        width: wp(100),
                        color: waveColor == 0 ? Pigment.fromString("#7BC89B") : Pigment.fromString("#ffe34c"),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class WelcomeBack extends StatefulWidget {
  @override
  _WelcomeBackState createState() => _WelcomeBackState();
}

class _WelcomeBackState extends State<WelcomeBack> {
  @override
  Widget build(BuildContext context) {
    final Function wp = Screen(MediaQuery.of(context).size).wp;
    final Function hp = Screen(MediaQuery.of(context).size).hp;
    return Scaffold(
      backgroundColor: Pigment.fromString("7BC89B"),
      body: Center(
        child: Text(
          "Welcome back!",
          style: TextStyle(fontFamily: 'Courier', fontSize: wp(10), color: Colors.black, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  var sIsLoading = false;
  var sCompleted = false;

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        sIsLoading = true;
        sCompleted = true;
      });
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.pushReplacementNamed(context, '/HomePage');
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Function wp = Screen(MediaQuery.of(context).size).wp;
    final Function hp = Screen(MediaQuery.of(context).size).hp;
    return Scaffold(
      backgroundColor: Pigment.fromString("7BC89B"),
      body: Center(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Text(
                "Welcome!",
                style: TextStyle(
                    fontFamily: 'Courier', fontSize: wp(10), color: Colors.black, fontWeight: FontWeight.normal),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    bottom: 0,
                    child: Column(children: <Widget>[
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 1500),
                          curve: Curves.fastOutSlowIn,
                          height: sIsLoading ? hp(10) : hp(0),
                          child: SizedBox(
                            height: double.infinity,
                            width: wp(100),
                            child: Stack(
                              children: <Widget>[
                                WelcomeBackWave(
                                  height: double.infinity,
                                  speed: 1.5,
                                ),
                                // These three containers are to remove a line(UI defect) caused by WelcomeBackWave
                                Positioned(
                                  bottom: 0,
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 1500),
                                    curve: Curves.fastOutSlowIn,
                                    height: sIsLoading ? hp(1) : hp(0),
                                    width: wp(100),
                                    color: Pigment.fromString("2F3338"),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 1500),
                                    curve: Curves.fastOutSlowIn,
                                    height: sIsLoading ? hp(1) : hp(0),
                                    width: wp(100),
                                    color: Pigment.fromString("2F3338"),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 1500),
                                    curve: Curves.fastOutSlowIn,
                                    height: sIsLoading ? hp(1) : hp(0),
                                    width: wp(100),
                                    color: Pigment.fromString("2F3338"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          //padding: EdgeInsets.only(top: 30),
                          duration: Duration(milliseconds: 1500),
                          curve: Curves.fastOutSlowIn,
                          height: sCompleted ? hp(100) : hp(0),
                          width: wp(100),
                          color: Pigment.fromString("2F3338"),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumPage extends StatefulWidget {
  @override
  _PremiumPageState createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  var sIsLoading = false;
  var sCompleted = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();

  void premiumSignup() async {
    setState(() {
      sIsLoading = true;
    });
    // marked async
    FirebaseUser user;
    try {
      user = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } catch (e) {
      print(e.toString());
    } finally {
      if (user != null) {
        await getDownloadUrl(context);

        Firestore.instance.collection('users').document().setData({
          'displayName': usernameController.text,
          'photoUrl': fileUrl.toString(),
          'email': user.email,
          'uid': user.uid,
        });
        // sign up successful!
        setState(() {
          sCompleted = true;
          Future.delayed(const Duration(milliseconds: 1500), () {
            Navigator.pushReplacementNamed(context, '/HomePage');
          });
        });
      } else {
        setState(() {
          sIsLoading = false;
        });
        // sign up unsuccessful
        // ex: prompt the user to try again
      }
    }
  }

  File _file;
  var fileUrl;
  var fileExtension;

  Future getPfp(bool isCamera) async {
    File file;
    if (isCamera == true) {
      file = await ImagePicker.pickImage(source: ImageSource.camera);
    } else {
      file = await ImagePicker.pickImage(source: ImageSource.gallery);
      //file = await FilePicker.getFile(type: FileType.IMAGE);
    }

    setState(() {
      _file = file;
      fileExtension = p.extension(file.toString()).split('?').first.replaceFirst(".", "").replaceFirst("'", "");
    });
  }

  Future getDownloadUrl(BuildContext context) async {
    setState(() {
      // Loading function here?? idk
    });

    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final String userID = user.uid.toString();

    String fileId = userID + " - " + randomAlphaNumeric(5);

    StorageReference reference = FirebaseStorage.instance.ref().child("$fileId");

    StorageUploadTask uploadTask = reference.putFile(
      _file,
      StorageMetadata(
        // Here you need to update the type depending on what the user wants to upload.
        contentType: "image" + '/' + fileExtension,
      ),
    );
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    // Maybe input download url in image.network ??
    fileUrl = downloadUrl;

    setState(() {
      // Loading function ended here.
    });
  }

  @override
  Widget build(BuildContext context) {
    final Function wp = Screen(MediaQuery.of(context).size).wp;
    final Function hp = Screen(MediaQuery.of(context).size).hp;
    return Scaffold(
      backgroundColor: Pigment.fromString("ffe34c"),
      body: Stack(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: Column(
              children: <Widget>[
                Text(
                  "Premium User",
                  style: TextStyle(
                      fontFamily: 'Courier', fontSize: wp(10), color: Colors.black, fontWeight: FontWeight.normal),
                ),
                Padding(
                  padding: EdgeInsets.only(top: hp(5)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      PhysicalModel(
                        borderRadius: BorderRadius.circular(hp(100)),
                        color: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: CircleImageInkWell(
                            size: hp(15),
                            onPressed: () {
                              getPfp(false);
                            },
                            /*
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: Pigment.fromString("ffe34c"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceEvenly,
                                                children: <Widget>[
                                                  IconButton(
                                                    icon: Icon(Icons.camera_alt),
                                                    onPressed: () {
                                                      getPfp(true);
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: Icon(Icons.image),
                                                    onPressed: () {
                                                      getPfp(false);
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ]),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                */
                            image: _file == null
                                ? NetworkImage(
                                    'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Ic_account_circle_48px.svg/1024px-Ic_account_circle_48px.svg.png')
                                : FileImage(_file),
                            splashColor: Colors.white30,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: wp(50),
                        height: wp(15),
                        child: TextField(
                          controller: usernameController,
                          cursorColor: Colors.black,
                          style: TextStyle(fontFamily: 'Courier', fontSize: wp(7.5), color: Colors.black),
                          decoration: InputDecoration(
                            hintText: "Username",
                            hintStyle: TextStyle(
                              fontFamily: 'Courier',
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: hp(5)),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: wp(70),
                        height: wp(12),
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Colors.black,
                          style: TextStyle(fontFamily: 'Courier', fontSize: wp(5), color: Colors.black),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.only(top: wp(6), left: wp(5)),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Email",
                            hintStyle: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: wp(5),
                              color: Colors.black,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                                const Radius.circular(100),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: wp(6)),
                        child: SizedBox(
                          width: wp(70),
                          height: wp(12),
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            cursorColor: Colors.black,
                            style: TextStyle(fontFamily: 'Courier', fontSize: wp(5), color: Colors.black),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(top: wp(6), left: wp(5)),
                              fillColor: Colors.white,
                              filled: true,
                              hintText: "Password",
                              hintStyle: TextStyle(
                                fontSize: wp(5),
                                color: Colors.black,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  const Radius.circular(100),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: wp(6), bottom: wp(6)),
                  child: SizedBox(
                    width: wp(50),
                    height: wp(12),
                    child: RaisedButton(
                      highlightColor: Pigment.fromString("#2F3338"),
                      onPressed: () {
                        if (_file == null) {
                          Flushbar(
                            aroundPadding: EdgeInsets.all(8),
                            borderRadius: 8,
                            message: "Remember to set your profile picture!",
                            icon: Icon(
                              Icons.error,
                              size: 28.0,
                              color: Colors.red,
                            ),
                            duration: Duration(seconds: 3),
                          )..show(context);
                        } else {
                          premiumSignup();
                        }
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      //color: Pigment.fromString("#9BD15F"),
                      color: Pigment.fromString("#2F3338"),
                      child: Text(
                        "Continue",
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: wp(5),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: <Widget>[
                Positioned(
                  bottom: 0,
                  child: Column(children: <Widget>[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 1500),
                        curve: Curves.fastOutSlowIn,
                        height: sIsLoading ? hp(10) : hp(0),
                        child: SizedBox(
                          height: double.infinity,
                          width: wp(100),
                          child: Stack(
                            children: <Widget>[
                              WelcomeBackWave(
                                height: double.infinity,
                                speed: 1.5,
                              ),
                              // These three containers are to remove a line(UI defect) caused by AnimatedWave
                              Positioned(
                                bottom: 0,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 1500),
                                  curve: Curves.fastOutSlowIn,
                                  height: sIsLoading ? hp(1) : hp(0),
                                  width: wp(100),
                                  color: Pigment.fromString("#2F3338"),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 1500),
                                  curve: Curves.fastOutSlowIn,
                                  height: sIsLoading ? hp(1) : hp(0),
                                  width: wp(100),
                                  color: Pigment.fromString("#2F3338"),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 1500),
                                  curve: Curves.fastOutSlowIn,
                                  height: sIsLoading ? hp(1) : hp(0),
                                  width: wp(100),
                                  color: Pigment.fromString("#2F3338"),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        //padding: EdgeInsets.only(top: 30),
                        duration: Duration(milliseconds: 1500),
                        curve: Curves.fastOutSlowIn,
                        height: sCompleted ? hp(100) : hp(0),
                        width: wp(100),
                        color: Pigment.fromString("#2F3338"),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var uid;

  void getChats() async {
    FirebaseUser user = await _auth.currentUser();
    setState(() {
      uid = user.uid;
    });
  }

  @override
  void initState() {
    super.initState();
    getChats();
  }

  @override
  Widget build(BuildContext context) {
    final Function wp = Screen(MediaQuery.of(context).size).wp;
    final Function hp = Screen(MediaQuery.of(context).size).hp;
    return Scaffold(
      backgroundColor: Pigment.fromString("2F3338"),
      appBar: AppBar(
        backgroundColor: Pigment.fromString("2F3338"),
        iconTheme: IconThemeData(color: Pigment.fromString("575f6c")),
      ),
      drawer: Drawer(
        child: Container(
          color: Pigment.fromString("565F6C"),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                duration: Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
                child: Text("User image here."),
                //child: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Ic_account_circle_48px.svg/1024px-Ic_account_circle_48px.svg.png'),
              ),
              ListTile(
                title: Text('Item 1'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Item 2'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('gc').where('members', arrayContains: uid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
            if (!snapshot.hasData) {
              Center(child: Text("Error loading"));
            } else {
              if (snapshot.data == null) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: wp(6), bottom: wp(6)),
                    child: SizedBox(
                      width: wp(50),
                      height: wp(50),
                      child: RaisedButton(
                        elevation: 3,
                        color: Pigment.fromString("#2F3338"),
                        highlightColor: Colors.transparent,
                        onPressed: () {
                          Navigator.pushNamed(context, '/GroupChat');
                        },
                        shape: CircleBorder(),
                        child: Text(
                          "Join Chat",
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: wp(5),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return Center(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topCenter,
                        padding: EdgeInsets.only(bottom: hp(0)),
                        height: hp(100),
                        width: wp(100),
                        child: ScrollConfiguration(
                          behavior: ListViewBehavior(),
                          child: ListView.builder(
                            itemCount: snapshot.data.documents.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot ds = snapshot.data.documents[index];
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.white30,
                                  highlightColor: Colors.white30,
                                  onTap: () {
                                    selectedChat = ds['docID'].toString();
                                    Navigator.pushNamed(context, '/GroupChat');
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(top: hp(2)),
                                    child: Container(
                                      height: hp(6),
                                      width: wp(100),
                                      padding: EdgeInsets.only(left: wp(5), right: wp(5)),
                                      child: Container(
                                        child: Text(
                                          ds['docID'].toString(),
                                          style: TextStyle(
                                            fontFamily: 'Courier',
                                            fontSize: wp(5),
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Pigment.fromString("2F3338"),
                            //color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Pigment.fromString("1a1e21"),
                                blurRadius: 10, // has the effect of softening the shadow
                                spreadRadius: 5, // has the effect of extending the shadow
                                offset: Offset(0, hp(1)),
                              )
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.white30,
                              highlightColor: Colors.white30,
                              onTap: () {
                                Navigator.pushNamed(context, '/GroupChat');
                              },
                              child: Container(
                                height: hp(7.5),
                                width: wp(100),
                                child: Center(
                                  child: Text(
                                    "Join Chat",
                                    style: TextStyle(
                                      fontFamily: 'Courier',
                                      fontSize: wp(5),
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }
          }),
    );
  }
}

class ListViewBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class GroupChat extends StatefulWidget {
  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  Stream<DocumentSnapshot> _stream;
  @override
  void initState() {
    super.initState();
    if (selectedChat != null) {
      getUser();
      setChat();
    } else {
      getUser();
      findChat();
    }
    Future.delayed(const Duration(milliseconds: 1000), () {
      _gcscrollController.jumpTo(_gcscrollController.position.maxScrollExtent);
    });
  }

  void setChat() async {
    currentDoc = selectedChat.toString();
    setState(() {
      _stream = Firestore.instance.collection('gc').document(currentDoc).snapshots();
      selectedChat = null;
    });
  }

  var userInfo;
  var userName;
  var userPfp;
  var userUid;

  void getUser() async {
    try {
      FirebaseUser user = await _auth.currentUser();

      final snapshot = await Firestore.instance.collection('users').where('uid', isEqualTo: user.uid).getDocuments();

      var doc = snapshot.documents.first;

      setState(() {
        userUid = user.uid;
        userName = doc['displayName'];
        userPfp = doc['photoUrl'];
      });
      // sign up successful!
    } catch (e) {
      // getUser();
      //recursive!!!
      // Getting user failed - reload?
    }
  }

  TextEditingController msgController = TextEditingController();
  var keyboardEnabled = true;
  var isSending = false;
  var currentDoc;
  var currentCount;
  var generatedDocName;

  final AsyncMemoizer _asyncMemoizer = AsyncMemoizer();
  findChat() {
    return this._asyncMemoizer.runOnce(() async {
      try {
        FirebaseUser user = await _auth.currentUser();
        final snapshot =
            await Firestore.instance.collection('gc').where('count', isLessThanOrEqualTo: 49).getDocuments();

        var docs = snapshot.documents;
        setState(() {
          docs.removeWhere((item) => item.data['members'].contains(user.uid));
          currentDoc = docs[0].documentID;
          currentCount = docs[0].data['count'];
          _stream = Firestore.instance.collection('gc').document(currentDoc).snapshots();
        });
        addCount();
        return;
        // Not sure if the return statement is necessary. Maybe it serves as break; ?
      } catch (e) {
        // idk if I need setState here
        setState(() {
          generatedDocName = randomAlphaNumeric(20);
          currentDoc = generatedDocName;
          _stream = Firestore.instance.collection('gc').document(currentDoc).snapshots();
        });
        await Firestore.instance.collection('gc').document(generatedDocName).setData({
          'count': 0,
          'docID': generatedDocName,
          'members': null,
          'messages': null,
        }, merge: true);
        addCountGenerated();
      }
    });
  }

  final AsyncMemoizer _aMemoizer = AsyncMemoizer();
  addCountGenerated() {
    return this._aMemoizer.runOnce(() async {
      FirebaseUser user = await _auth.currentUser();
      Firestore.instance.collection('gc').document(currentDoc).updateData(
        {
          'members': FieldValue.arrayUnion([user.uid]),
          'count': 1,
        },
      );
    });
  }

  final AsyncMemoizer _memoizer = AsyncMemoizer();
  addCount() {
    return this._memoizer.runOnce(() async {
      FirebaseUser user = await _auth.currentUser();
      Firestore.instance.collection('gc').document(currentDoc).updateData(
        {
          'members': FieldValue.arrayUnion([user.uid]),
          'count': currentCount + 1,
        },
      );
    });
  }

  void sendMsg() async {
    try {
      if (_file != null) {
        await sendMMS(context);
        FirebaseUser user = await _auth.currentUser();
        Firestore.instance.collection('gc').document(currentDoc).setData({
          'messages': FieldValue.arrayUnion([
            {
              'mms': fileUrl,
              'message': msgController.text,
              'sender': userName,
              'senderimg': userPfp,
              'senderid': user.uid,
              'timeSent': DateTime.now().toUtc(),
            }
          ])
        }, merge: true);

        setState(() {
          fileUrl = null;
          _file = null;
          fileExtension = null;
          msgController.clear();
          keyboardEnabled = true;
          isSending = false;
        });
      } else {
        FirebaseUser user = await _auth.currentUser();
        Firestore.instance.collection('gc').document(currentDoc).setData({
          'messages': FieldValue.arrayUnion([
            {
              'mms': fileUrl,
              'message': msgController.text,
              'sender': userName,
              'senderimg': userPfp,
              'senderid': user.uid,
              'timeSent': DateTime.now().toUtc(),
            }
          ])
        }, merge: true);

        setState(() {
          fileUrl = null;
          _file = null;
          fileExtension = null;
          msgController.clear();
        });
      }
      Future.delayed(const Duration(milliseconds: 100), () {
        _gcscrollController.animateTo(
          _gcscrollController.position.maxScrollExtent,
          curve: Curves.fastLinearToSlowEaseIn,
          duration: const Duration(milliseconds: 500),
        );
      });
    } catch (e) {
      // sending unsuccessful
      // ex: prompt the user to try again?
    }
  }

  File _file;
  var fileUrl;
  var fileExtension;

  Future chooseMMS(bool isCamera) async {
    File file;
    if (isCamera == true) {
      file = await ImagePicker.pickImage(source: ImageSource.camera);
    } else {
      file = await ImagePicker.pickImage(source: ImageSource.gallery);
      //file = await FilePicker.getFile(type: FileType.IMAGE);
    }

    setState(() {
      _file = file;
      fileExtension = p.extension(file.toString()).split('?').first.replaceFirst(".", "").replaceFirst("'", "");
    });
  }

  Future sendMMS(BuildContext context) async {
    /*
    setState(() {
      // Loading function here?? idk
    });
    */

    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final String userID = user.uid.toString();

    String fileId = userID + " - " + randomAlphaNumeric(5);

    StorageReference reference = FirebaseStorage.instance.ref().child("$fileId");

    StorageUploadTask uploadTask = reference.putFile(
      _file,
      StorageMetadata(
        // Here you need to update the type depending on what the user wants to upload.
        contentType: "image" + '/' + fileExtension,
      ),
    );
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    // Maybe input download url in image.network ??
    fileUrl = downloadUrl;

    /*
    setState(() {
      fileUrl = downloadUrl;
      // Loading function ended here.
    });
    */
  }

  ScrollController _gcscrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final Function wp = Screen(MediaQuery.of(context).size).wp;
    final Function hp = Screen(MediaQuery.of(context).size).hp;
    return Scaffold(
      backgroundColor: Pigment.fromString("2F3338"),
      appBar: AppBar(
        backgroundColor: Pigment.fromString("1a1e21"),
        iconTheme: IconThemeData(color: Pigment.fromString("575f6c")),
      ),
      drawer: Drawer(
        child: Container(
          color: Pigment.fromString("565F6C"),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                duration: Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
                child: Text("User image here, maybe?"),
              ),
              ListTile(
                title: Text('Idk whats going to be here'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Idk what is going to be here either.'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: wp(100),
              decoration: BoxDecoration(
                color: Pigment.fromString("2F3338"),
                boxShadow: [
                  BoxShadow(
                    color: Pigment.fromString("1a1e21"),
                    blurRadius: 10, // has the effect of softening the shadow
                    spreadRadius: 5, // has the effect of extending the shadow
                    offset: Offset(0, hp(1)),
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(right: wp(0), bottom: hp(0.5), top: hp(0.5)),
                child: Container(
                  //height: wp(10),
                  height: hp(5.3),
                  width: wp(100),
                  child: SizedBox(
                    child: TextField(
                      enabled: keyboardEnabled,
                      cursorColor: Colors.white,
                      cursorWidth: 1,
                      textInputAction: TextInputAction.newline,
                      maxLines: 100,
                      controller: msgController,
                      style: TextStyle(fontFamily: 'Courier', fontSize: wp(4.5), color: Pigment.fromString("565F6C")),
                      decoration: InputDecoration(
                        prefixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            MaterialButton(
                              elevation: 0,
                              highlightElevation: 0,
                              minWidth: 0,
                              padding: EdgeInsets.all(0),
                              onPressed: () {
                                chooseMMS(false);
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              //color: Pigment.fromString("575f6c"),
                              shape: CircleBorder(),
                              child: Opacity(
                                // opacity: msgController.text.isEmpty ? 0.25 : 1,
                                opacity: 0.75,
                                child: Icon(
                                  Icons.image,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: _file == null ? wp(0) : null,
                              height: _file == null ? hp(0) : null,
                              child: Padding(
                                  padding: EdgeInsets.only(right: wp(2.5), top: hp(1), bottom: hp(1)),
                                  child: _file == null
                                      ? Container()
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: Container(
                                            height: wp(5),
                                            width: wp(5),
                                            child: FittedBox(
                                              fit: BoxFit.cover,
                                              child: Image.file(_file),
                                            ),
                                          ),
                                        )),
                            ),
                          ],
                        ),
                        suffixIcon: MaterialButton(
                          elevation: 0,
                          highlightElevation: 0,
                          minWidth: 0,
                          padding: EdgeInsets.all(0),
                          onPressed: () {
                            if (_file != null) {
                              setState(() {
                                keyboardEnabled = false;
                                isSending = true;
                              });
                              msgController.text = msgController.text.trim();
                              sendMsg();
                            } else {
                              msgController.text = msgController.text.trim();
                              if (msgController.text.isEmpty || msgController.text == ' ') {
                                // Posibility: Promting the user for text in some way.
                              } else {
                                sendMsg();
                              }
                            }
                          },
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          //color: Pigment.fromString("575f6c"),
                          shape: CircleBorder(),
                          child: Opacity(
                            // opacity: msgController.text.isEmpty ? 0.25 : 1,
                            opacity: 0.75,
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        contentPadding: EdgeInsets.only(top: hp(2.5), left: wp(5), right: wp(2.5)),
                        fillColor: Pigment.fromString("#2f3237"),
                        filled: true,
                        hintText: "Type a message...",
                        hintStyle: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: wp(4.5),
                          color: Pigment.fromString("#565F6C"),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(100),
                            ),
                            borderSide: BorderSide(color: Pigment.fromString("2F3338"))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                            borderSide: BorderSide(color: Pigment.fromString("2F3338"))),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                            borderSide: BorderSide(color: Pigment.fromString("2F3338"))),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(100),
                            borderSide: BorderSide(color: Pigment.fromString("2F3338"))),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: hp(6.4)),
            child: StreamBuilder<DocumentSnapshot>(
                stream: _stream,
                builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData) {
                    Text("Error! Please retry again.");
                  } else {
                    if (snapshot.data.data['messages'] == null) {
                      return Center(
                        child: Text(
                          "No messages!",
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: wp(5),
                            color: Colors.white70,
                          ),
                        ),
                      );
                    } else {
                      return ScrollConfiguration(
                          behavior: ListViewBehavior(),
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              reverse: false,
                              controller: _gcscrollController,
                              itemCount: snapshot.data.data['messages'].length,
                              itemBuilder: (context, index) {
                                if (snapshot.data.data['messages'][index]['senderid'].toString() == userUid) {
                                  if (snapshot.data.data['messages'][index]['message'] == "" &&
                                      snapshot.data.data['messages'][index]['mms'] != null) {
                                    return Padding(
                                      padding: EdgeInsets.only(right: hp(2), left: hp(2), top: hp(0), bottom: hp(2)),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(right: wp(2.5)),
                                              child: Column(
                                                children: <Widget>[
                                                  Align(
                                                      alignment: Alignment.centerRight,
                                                      child: Padding(
                                                          padding: EdgeInsets.only(bottom: hp(0.5)),
                                                          child: Text(
                                                            snapshot.data.data['messages'][index]['sender'].toString(),
                                                            style: TextStyle(
                                                                fontSize: wp(4),
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold),
                                                          ))),
                                                  Align(
                                                    alignment: Alignment.centerRight,
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        minWidth: wp(1),
                                                        maxWidth: wp(100),
                                                        minHeight: hp(1),
                                                        maxHeight: hp(50),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(12),
                                                        child: Stack(
                                                          children: <Widget>[
                                                            Image(
                                                              fit: BoxFit.contain,
                                                              image: CachedNetworkImageProvider(snapshot
                                                                  .data.data['messages'][index]['mms']
                                                                  .toString()),
                                                            ),
                                                            Positioned.fill(
                                                                child: Material(
                                                              color: Colors.transparent,
                                                              child: InkWell(
                                                                  highlightColor: Colors.transparent,
                                                                  splashColor: Colors.white30,
                                                                  onTap: () {
                                                                    // Implement image enlargement here
                                                                  }),
                                                            )),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    if (snapshot.data.data['messages'][index]['message'] != "" &&
                                        snapshot.data.data['messages'][index]['mms'] == null) {
                                      return Padding(
                                        padding: EdgeInsets.only(right: hp(2), left: hp(2), top: hp(0), bottom: hp(2)),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(right: wp(2.5)),
                                                child: Column(
                                                  children: <Widget>[
                                                    Align(
                                                        alignment: Alignment.centerRight,
                                                        child: Padding(
                                                            padding: EdgeInsets.only(bottom: hp(0.5)),
                                                            child: Text(
                                                              snapshot.data.data['messages'][index]['sender']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontSize: wp(4),
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.bold),
                                                            ))),
                                                    Flexible(
                                                      fit: FlexFit.tight,
                                                      flex: 0,
                                                      child: Align(
                                                        alignment: Alignment.centerRight,
                                                        child: Container(
                                                          decoration: ShapeDecoration(
                                                            color: Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12.5)),
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets.all(hp(1)),
                                                            child: Text(
                                                              snapshot.data.data['messages'][index]['message']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontSize: wp(3.5),
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.normal),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Padding(
                                        padding: EdgeInsets.only(right: hp(2), left: hp(2), top: hp(0), bottom: hp(2)),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(right: wp(2.5)),
                                                child: Column(
                                                  children: <Widget>[
                                                    Align(
                                                        alignment: Alignment.centerRight,
                                                        child: Padding(
                                                            padding: EdgeInsets.only(bottom: hp(0.5)),
                                                            child: Text(
                                                              snapshot.data.data['messages'][index]['sender']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontSize: wp(4),
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.bold),
                                                            ))),
                                                    Padding(
                                                      padding: EdgeInsets.only(bottom: hp(0.5)),
                                                      child: Align(
                                                        alignment: Alignment.centerRight,
                                                        child: ConstrainedBox(
                                                          constraints: BoxConstraints(
                                                            minWidth: wp(1),
                                                            maxWidth: wp(100),
                                                            minHeight: hp(1),
                                                            maxHeight: hp(50),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(12),
                                                            child: Stack(
                                                              children: <Widget>[
                                                                Image(
                                                                  fit: BoxFit.contain,
                                                                  image: CachedNetworkImageProvider(snapshot
                                                                      .data.data['messages'][index]['mms']
                                                                      .toString()),
                                                                ),
                                                                Positioned.fill(
                                                                    child: Material(
                                                                  color: Colors.transparent,
                                                                  child: InkWell(
                                                                      highlightColor: Colors.transparent,
                                                                      splashColor: Colors.white30,
                                                                      onTap: () {
                                                                        // Implement image enlargement here
                                                                      }),
                                                                )),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      fit: FlexFit.tight,
                                                      flex: 0,
                                                      child: Align(
                                                        alignment: Alignment.centerRight,
                                                        child: Container(
                                                          decoration: ShapeDecoration(
                                                            color: Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12.5)),
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets.all(hp(1)),
                                                            child: Text(
                                                              snapshot.data.data['messages'][index]['message']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontSize: wp(3.5),
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.normal),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  if (snapshot.data.data['messages'][index]['message'] == "" &&
                                      snapshot.data.data['messages'][index]['mms'] != null) {
                                    return Padding(
                                      padding: EdgeInsets.only(right: hp(2), left: hp(2), top: hp(0), bottom: hp(2)),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(right: wp(2)),
                                            child: snapshot.data.data['messages'][index]['senderimg'] != null
                                                ? CircleImageInkWell(
                                                    size: hp(5.5),
                                                    onPressed: () {
                                                      // Maybe implement something here?
                                                    },
                                                    image: CachedNetworkImageProvider(
                                                        snapshot.data.data['messages'][index]['senderimg'].toString()),
                                                    splashColor: Colors.white30,
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor: Colors.white,
                                                    child: Text(
                                                      snapshot.data.data['messages'][index]['sender'][0],
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontFamily: 'Courier',
                                                          fontSize: hp(3),
                                                          color: Pigment.fromString("565F6C")),
                                                    ),
                                                  ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.only(right: wp(2.5)),
                                              child: Column(
                                                children: <Widget>[
                                                  Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Padding(
                                                          padding: EdgeInsets.only(bottom: hp(0.5)),
                                                          child: Text(
                                                            snapshot.data.data['messages'][index]['sender'].toString(),
                                                            style: TextStyle(
                                                                fontSize: wp(4),
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold),
                                                          ))),
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        minWidth: wp(1),
                                                        maxWidth: wp(100),
                                                        minHeight: hp(1),
                                                        maxHeight: hp(50),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(12),
                                                        child: Stack(
                                                          children: <Widget>[
                                                            Image(
                                                              fit: BoxFit.contain,
                                                              image: CachedNetworkImageProvider(snapshot
                                                                  .data.data['messages'][index]['mms']
                                                                  .toString()),
                                                            ),
                                                            Positioned.fill(
                                                                child: Material(
                                                              color: Colors.transparent,
                                                              child: InkWell(
                                                                  highlightColor: Colors.transparent,
                                                                  splashColor: Colors.white30,
                                                                  onTap: () {
                                                                    // Implement image enlargement here
                                                                  }),
                                                            )),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    if (snapshot.data.data['messages'][index]['message'] != "" &&
                                        snapshot.data.data['messages'][index]['mms'] == null) {
                                      return Padding(
                                        padding: EdgeInsets.only(right: hp(2), left: hp(2), top: hp(0), bottom: hp(2)),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(right: wp(2)),
                                              child: snapshot.data.data['messages'][index]['senderimg'] != null
                                                  ? CircleImageInkWell(
                                                      size: hp(5.5),
                                                      onPressed: () {
                                                        // Maybe implement something here?
                                                      },
                                                      image: CachedNetworkImageProvider(snapshot
                                                          .data.data['messages'][index]['senderimg']
                                                          .toString()),
                                                      splashColor: Colors.white30,
                                                    )
                                                  : CircleAvatar(
                                                      backgroundColor: Colors.white,
                                                      child: Text(
                                                        snapshot.data.data['messages'][index]['sender'][0],
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontFamily: 'Courier',
                                                            fontSize: hp(3),
                                                            color: Pigment.fromString("565F6C")),
                                                      ),
                                                    ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(right: wp(2.5)),
                                                child: Column(
                                                  children: <Widget>[
                                                    Align(
                                                      alignment: Alignment.centerLeft,
                                                      child: Padding(
                                                        padding: EdgeInsets.only(bottom: hp(0.5)),
                                                        child: Text(
                                                          snapshot.data.data['messages'][index]['sender'].toString(),
                                                          style: TextStyle(
                                                              fontSize: wp(4),
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      fit: FlexFit.tight,
                                                      flex: 0,
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Container(
                                                          decoration: ShapeDecoration(
                                                            color: Pigment.fromString("565F6C"),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12.5)),
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets.all(hp(1)),
                                                            child: Text(
                                                              snapshot.data.data['messages'][index]['message']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontSize: wp(3.5),
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.normal),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return Padding(
                                        padding: EdgeInsets.only(right: hp(2), left: hp(2), top: hp(0), bottom: hp(2)),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(right: wp(2)),
                                              child: snapshot.data.data['messages'][index]['senderimg'] != null
                                                  ? CircleImageInkWell(
                                                      size: hp(5.5),
                                                      onPressed: () {
                                                        // Maybe implement something here?
                                                      },
                                                      image: CachedNetworkImageProvider(snapshot
                                                          .data.data['messages'][index]['senderimg']
                                                          .toString()),
                                                      splashColor: Colors.white30,
                                                    )
                                                  : CircleAvatar(
                                                      backgroundColor: Colors.white,
                                                      child: Text(
                                                        snapshot.data.data['messages'][index]['sender'][0],
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontFamily: 'Courier',
                                                            fontSize: hp(3),
                                                            color: Pigment.fromString("565F6C")),
                                                      ),
                                                    ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.only(right: wp(2.5)),
                                                child: Column(
                                                  children: <Widget>[
                                                    Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Padding(
                                                            padding: EdgeInsets.only(bottom: hp(0.5)),
                                                            child: Text(
                                                              snapshot.data.data['messages'][index]['sender']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontSize: wp(4),
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.bold),
                                                            ))),
                                                    Padding(
                                                      padding: EdgeInsets.only(bottom: hp(0.5)),
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: ConstrainedBox(
                                                          constraints: BoxConstraints(
                                                            minWidth: wp(1),
                                                            maxWidth: wp(100),
                                                            minHeight: hp(1),
                                                            maxHeight: hp(50),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(12),
                                                            child: Stack(
                                                              children: <Widget>[
                                                                Image(
                                                                  fit: BoxFit.contain,
                                                                  image: CachedNetworkImageProvider(snapshot
                                                                      .data.data['messages'][index]['mms']
                                                                      .toString()),
                                                                ),
                                                                Positioned.fill(
                                                                    child: Material(
                                                                  color: Colors.transparent,
                                                                  child: InkWell(
                                                                      highlightColor: Colors.transparent,
                                                                      splashColor: Colors.white30,
                                                                      onTap: () {
                                                                        // Implement image enlargement here
                                                                      }),
                                                                )),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      fit: FlexFit.tight,
                                                      flex: 0,
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Container(
                                                          decoration: ShapeDecoration(
                                                            color: Pigment.fromString("565F6C"),
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(12.5)),
                                                          ),
                                                          child: Padding(
                                                            padding: EdgeInsets.all(hp(1)),
                                                            child: Text(
                                                              snapshot.data.data['messages'][index]['message']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontSize: wp(3.5),
                                                                  color: Colors.white,
                                                                  fontWeight: FontWeight.normal),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  }
                                }
                              }));
                    }
                  }
                }),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              height: isSending ? hp(0.2) : hp(0),
              width: wp(100),
              child: LinearProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Pigment.fromString("2F3338")),
              ),
            ),
          ),
        ],
      ),
    );
  }
}