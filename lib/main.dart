import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firestore_queries_exp/firebase_options.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // State
  List<Map<String, dynamic>> contacts = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.greenAccent, brightness: Brightness.dark)),
      home: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                  child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ListTile(
                    title: Text(contact["name"]),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contact["number"]),
                        Text(contact["age"].toString()),
                      ],
                    ),
                  );
                },
              )),
              FilledButton(
                onPressed: () async {
                  final contactsFuture = await FirebaseFirestore.instance
                      .collection('contacts')
                      .orderBy('age')
                      .get();

                  setState(() {
                    contacts =
                        contactsFuture.docs.map((e) => e.data()).toList();
                  });
                },
                child: const Text("Hole Kontakte"),
              ),
              FilledButton(
                onPressed: () async {
                  // COLLECTION PFAD - Doc adden
                  // await FirebaseFirestore.instance.collection("contacts").add({
                  //   "age": 30,
                  //   "lat": 1.113,
                  //   "lon": 65.24,
                  //   "name": "Thomas",
                  //   "number": "+49 24353463463456"
                  // });

                  // DOCUMENT PFAD - Doc adden
                  await FirebaseFirestore.instance
                      .collection("contacts")
                      .doc('nikolai')
                      .set({
                    "age": 22,
                    "lat": 1.113,
                    "lon": 65.24,
                    "name": "Nikolai",
                    "number": "+49 24542353543463456"
                  });
                },
                child: const Text("Erstelle Kontakt"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
