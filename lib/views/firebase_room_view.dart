import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//this view is for diplaying the room/bluetooth id mappings which is connected with google firestore

//Firestore is a no sql database / document based
// collection ~ sql table
// document ~ sql row
// document field ~ sql column
// every document can have different fields/"columns"
// but in file I will only create documents with the same fields... bluetoothId & roomNr

class RoomView extends StatefulWidget {
  const RoomView({Key? key}) : super(key: key);

  @override
  _RoomViewState createState() => _RoomViewState();
}

class _RoomViewState extends State<RoomView> {
// text fields' controllers
  final TextEditingController _bluetoothIdController = TextEditingController();
  final TextEditingController _roomNrController = TextEditingController();

  final CollectionReference BluetoothIdRoomMapping = FirebaseFirestore.instance
      .collection(
          'BluetoothIdRoomMapping'); //name of the used collection = BluetoothIdRoomMapping

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    setState(() {
      _roomNrController.text = "";
    }); //workaround: making values empty, so values will not be taken over from Update field when opened before
    setState(() {
      _bluetoothIdController.text = "";
    });

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  cursorColor: Colors.deepPurple,
                  controller: _bluetoothIdController,
                  decoration: const InputDecoration(
                    labelText: 'bluetoothId',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepPurple)),
                  ),
                ),
                TextField(
                  cursorColor: Colors.deepPurple,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  controller: _roomNrController,
                  decoration: const InputDecoration(
                    labelText: 'roomNr',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .deepPurple)), //changes focused underline color
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Create'),
                  style: ElevatedButton.styleFrom(primary: Colors.deepPurple),
                  onPressed: () async {
                    final String bluetoothId = _bluetoothIdController.text;
                    final int? roomNr = int.tryParse(_roomNrController.text);
                    if (roomNr != null) {
                      await BluetoothIdRoomMapping.add(
                          {"bluetoothId": bluetoothId, "roomNr": roomNr});

                      _bluetoothIdController.text = '';
                      _roomNrController.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _bluetoothIdController.text = documentSnapshot['bluetoothId'];
      _roomNrController.text = documentSnapshot['roomNr'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  cursorColor: Colors.deepPurple,
                  controller: _bluetoothIdController,
                  decoration: const InputDecoration(
                    labelText: 'Bluetooth ID',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .deepPurple)), //changes focused underline color
                  ),
                ),
                TextFormField(
                  cursorColor: Colors.deepPurple,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  controller: _roomNrController,
                  decoration: const InputDecoration(
                    labelText: 'Room Nr',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .deepPurple)), //changes focused underline color
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.deepPurple),
                  child: const Text('Update'),
                  onPressed: () async {
                    final String bluetoothId = _bluetoothIdController.text;
                    final int? roomNr = int.tryParse(_roomNrController.text);
                    if (roomNr != null) {
                      await BluetoothIdRoomMapping.doc(documentSnapshot!.id)
                          .update(
                              {"bluetoothId": bluetoothId, "roomNr": roomNr});
                      _bluetoothIdController.text = '';
                      _roomNrController.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _delete(String documentId) async {
    await BluetoothIdRoomMapping.doc(documentId).delete();
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted an Entry')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0, //removes shadow
        automaticallyImplyLeading: false, //removes left back button from AppBar
        title: const Text(
          "Room/Bluetooth Mapping",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
      ),

      body: StreamBuilder(
        //streambuilder is used to listen to changes in the database / changes will be displayed live
        stream: BluetoothIdRoomMapping.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                        "Bluetooth ID: ${documentSnapshot['bluetoothId']}"),
                    subtitle: Text("Room Nr: ${documentSnapshot['roomNr']}"),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _update(documentSnapshot)),
                          IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _delete(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // Add new Room BluetoothId Mapping
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(),
        elevation: 0, //removing shadow of the floating action button
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Colors.black),
            borderRadius: BorderRadius.circular(
                100)), //creating black border for floating action button
        foregroundColor: Colors.black, //plus symbol color
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
