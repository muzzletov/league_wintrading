
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wintrading/services/fcm.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FCMService.init();
  FCMService.scheduleValidityCheck();
  runApp(const WintradingApp());
}

class WintradingApp extends StatelessWidget {

  const WintradingApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: FCMService.messengerKey,
      title: 'wintrading',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white10),
        useMaterial3: true,
      ),
      home: const WintradingPage(title: 'wintrading'),
    );
  }


}

class WintradingPage extends StatefulWidget {
  const WintradingPage({super.key, required this.title});

  final String title;

  @override
  State<WintradingPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<WintradingPage> {
  String? _name;
  bool _initialized = false;
  final controller = TextEditingController(text: "");
  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs)=> {
      setState(() {
      _name = prefs.getString(FCMService.IDENTIFIER_NAME);
      _initialized = true;
      })
    });
  }

  requestWin () async {
    setState(() {
      _initialized = false;
    });
    await FCMService.issueRequest();
    setState(() {
      _initialized = true;
    });
  }

  clearName () {
    setState(() {
      _name = null;
    });
  }

  syncName() async {
    if(!await FCMService.setName(controller.text)) {
      FCMService.showSnackbar("failed to sync the name", duration: 3);
    } else {
      setState(() {
        _name = controller.text;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(

        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: !_initialized ? const CircularProgressIndicator() : Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,

          children: <Widget>[

            if (_name == null)
              ...[
                const Text("Enter the summoner name"),
                TextField(controller: controller,),
                MaterialButton(
              onPressed: syncName,
              child: const Text("save"),
            )] else ...[
              Text(_name!),
              MaterialButton(
                color: Colors.grey,
              visualDensity: const VisualDensity(horizontal: 4,vertical: 0),
              elevation: 5,
              onPressed: requestWin,
              child: const Text("request win")
              ),
              MaterialButton(
              onPressed: clearName,
                visualDensity: const VisualDensity(horizontal: 1,vertical: 0),
              color: Colors.redAccent,
              child: const Icon(Icons.delete_forever_sharp),
              )
            ]

          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
