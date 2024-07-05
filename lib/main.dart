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
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _ageController;
  late Stream<QuerySnapshot<Map<String, dynamic>>> contactsStream;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _ageController = TextEditingController(text: "18");
    contactsStream = FirebaseFirestore.instance
        .collection('contacts')
        .where('isDeleted', isEqualTo: false)
        .orderBy('age')
        .snapshots();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.greenAccent, brightness: Brightness.dark)),
      home: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                    child: StreamBuilder(
                  stream: contactsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                            snapshot.connectionState == ConnectionState.done ||
                        snapshot.connectionState == ConnectionState.active) {
                      // FALL 1: Stream hat Daten!
                      final contacts =
                          snapshot.data?.docs.map((e) => e.data()).toList() ??
                              [];
                      return ListView.builder(
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
                            trailing: IconButton(
                                onPressed: () async {
                                  // Dokument aus Firestore loeschen!
                                  await FirebaseFirestore.instance
                                      .collection('contacts')
                                      .doc(contact['id'])
                                      .update({
                                    'isDeleted': true,
                                  });
                                },
                                icon: const Icon(Icons.delete)),
                          );
                        },
                      );
                    } else if (snapshot.connectionState !=
                        ConnectionState.done) {
                      // FALL 2: Sind noch im Ladezustand
                      return const CircularProgressIndicator();
                    } else {
                      // FALL 3: Es gab nen Fehler
                      return const Icon(Icons.error);
                    }
                  },
                )),
                TextField(
                  decoration: const InputDecoration(
                    hintText: "Name",
                    label: Text("Name"),
                  ),
                  controller: _nameController,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Telefon"),
                  controller: _phoneController,
                ),
                TextField(
                  decoration: const InputDecoration(hintText: "Alter"),
                  controller: _ageController,
                ),
                FilledButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("contacts")
                        .doc('123456')
                        .set({
                      "id": "123456",
                      "age": int.parse(_ageController.text),
                      "lat": 1.113,
                      "lon": 65.24,
                      "name": _nameController.text,
                      "number": _phoneController.text,
                    });
                  },
                  child: const Text("Erstelle Kontakt"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
