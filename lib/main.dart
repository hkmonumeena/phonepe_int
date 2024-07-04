import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

//https://api.phonepe.com/apis/hermes
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String environmentValue = "SANDBOX";
  String appId = "";
  String merchantId = "PGTESTPAYUAT86";
  String callback = "https://webhook.site/127dba5d-ee2c-4e28-b71f-7633edb4f21b";
  bool enableLogging = true;
  String apiEndPoint = "/pg/v1/pay";

  //String salt = "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399";
  String salt = "96434309-7796-489d-8924-ab56988a6076";
  String saltIndex = "1";
  String base64Body = "";

  @override
  void initState() {
    super.initState();
    initPhonePe();
    getPackageSignatureForAndroid();
  }

  void getPackageSignatureForAndroid() {
    PhonePePaymentSdk.getPackageSignatureForAndroid()
        .then((packageSignature) => {
              setState(() {
                appId = packageSignature!;
              })
            })
        .catchError((error) {
      return <dynamic>{};
    });
  }

  void initPhonePe() {
    PhonePePaymentSdk.init(environmentValue, appId, merchantId, enableLogging)
        .then((val) => {
              setState(() {
                var result = 'PhonePe SDK Initialized - $val';
              })
            })
        .catchError((error) {
      return <dynamic>{};
    });
  }

 String getChecksum3() {
    final requestData = {
      "merchantId": merchantId,
      "merchantTransactionId": "MT7850590068188104",
      "merchantUserId": "MUID123",
      "amount": 1000,
      "callbackUrl": "https://webhook.site/callback-url",
      "mobileNumber": "9999999999",
      "paymentInstrument": {
        "type": "PAY_PAGE"
      }
    };

    base64Body = base64.encode(utf8.encode(json.encode(requestData)));

    return '${sha256.convert(utf8.encode(base64Body + apiEndPoint + salt)).toString()}###$saltIndex';
  }

  String getSalt() {
    String apiEndPoint = "/pg/v1/pay";
    var salt = "96434309-7796-489d-8924-ab56988a6076";
    var index = 1;
    return sha256
            .convert(utf8.encode(getBody() + apiEndPoint + salt))
            .toString() +
        "###" +
        index.toString();
  }

  String getBody() {
    var body = {
      "merchantId": "PGTESTPAYUAT86",
      "merchantTransactionId": "transaction_123",
      "merchantUserId": "902254543250",
      "amount": 10,
      "mobileNumber": "9999999999",
      "callbackUrl": callback,
      "paymentInstrument": {"type": "PAY_PAGE"}
    }; // Encode the request body to JSON
    String jsonBody = jsonEncode(body);
    String base64EncodedBody = base64Encode(utf8.encode(jsonBody));
    return base64EncodedBody;
  }

  String getCheckSum() {
    String base64Body = base64.encode(utf8.encode(json.encode(getBody())));
    //   String apiEndPoint = "/v3/charge"; // Ensure this is the correct endpoint
    String salt2 = salt;
    String saltIndex = "1";

    String checksum =
        generateChecksum(base64Body, apiEndPoint, salt2, saltIndex);
    print('Checksum: $checksum');
    print('Base64 Body: $base64Body');
    return checksum;
  }

  // Function to generate checksum
  String generateChecksum(
      String base64Body, String apiEndPoint, String salt, String saltIndex) {
    // Concatenate base64Body, apiEndPoint, and salt
    String dataToHash = base64Body + apiEndPoint + salt;
    print(dataToHash);
    // Generate SHA-256 hash
    var bytes = utf8.encode(dataToHash);
    var digest = sha256.convert(bytes);

    // Concatenate hash, '###', and saltIndex
    String checksum = digest.toString() + '###' + saltIndex;

    return checksum;
  }

  String getCheckSum2() {
    String base64Body = base64.encode(utf8.encode(json.encode(getBody())));
    String apiEndPoint = "/v3/charge"; // Ensure this is the correct endpoint
    String salt = "yourSalt";
    String saltIndex = "yourSaltIndex";

    String checksum =
        generateChecksum(base64Body, apiEndPoint, salt, saltIndex);
    print('Checksum: $checksum');
    print('Base64 Body: $base64Body');
    return checksum;
  }


  String getSalt3() {
    String apiEndPoint = "/pg/v1/pay";
    var index = 1;
    return sha256
        .convert(utf8.encode(getBody() + apiEndPoint + salt))
        .toString() +
        "###" +
        index.toString();
  }

  void startTransaction() {
    try {
      print("Sneha");
      print(base64Body);
      var response = PhonePePaymentSdk.startTransaction(
          base64Body, callback, getChecksum3(), "");
      response
          .then((val) => {
                setState(() {
                  var result = val;
                })
              })
          .catchError((error) {
        return <dynamic>{};
      });
    } catch (error) {}
  }

  void _incrementCounter() {
    startTransaction();
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
        child: Column(
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
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
