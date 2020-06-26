import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'order.dart' ;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WSB zti',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'Flutter WSB'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> users = [];
  //List<Order> orders = [];
  bool _smallDevice = false;
  int _counter = 0;
  FirebaseUser _user;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = Firestore.instance;
  var _textController = TextEditingController(text: "Write here");
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  void _loginWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);

    databaseReference.collection('chat').snapshots().listen((event) {
      print("GOT RESPONSE FROM DATABASE ${event.runtimeType}");
      users.clear();
      event.documents.forEach((element) {
        users.add("${element['message']}");
      });
      setState(() {
        users = users.toSet().toList();
      });
    });

    setState(() {
      _user = user;
     // _counter = 1000;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
              Text(
                'liczba polubień:',
              ),

              RaisedButton(
                child: _buildUserWidget(_user),
                onPressed: () {
                  _loginWithGoogle();
                },
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: Icon(Icons.adjust),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
        ),
        body: ListView.builder(
            itemCount: users.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return ListTile(title: Text(users[index]));
            }),
      );
    }
  }

  Widget _buildUserWidget(FirebaseUser user) {
    if (user == null) {
      return Text("Zaloguj się przez Google");
    } else {
      return Row(
        children: [Text(user.displayName), Image.network(user.photoUrl)],
      );

    }
  }
}
