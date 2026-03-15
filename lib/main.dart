import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  void openBluetoothSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BluetoothDeviceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0b6e63),
        title: Text("Arduino Bluetooth Control"),
      ),

      body: Center(
        child: ElevatedButton(
          child: Text("Connect Bluetooth"),
          onPressed: () => openBluetoothSheet(context),
        ),
      ),
    );
  }
}

class BluetoothDeviceSheet extends StatefulWidget {
  @override
  _BluetoothDeviceSheetState createState() => _BluetoothDeviceSheetState();
}

class _BluetoothDeviceSheetState extends State<BluetoothDeviceSheet> {
  List<BluetoothDevice> pairedDevices = [];
  List<BluetoothDiscoveryResult> availableDevices = [];
  bool scanning = false;

  @override
  void initState() {
    super.initState();
    getPaired();
  }

  void getPaired() async {
    List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance
        .getBondedDevices();

    setState(() {
      pairedDevices = devices;
    });
  }

  void startScan() {
    availableDevices.clear();

    setState(() {
      scanning = true;
    });

    FlutterBluetoothSerial.instance
        .startDiscovery()
        .listen((result) {
          setState(() {
            availableDevices.add(result);
          });
        })
        .onDone(() {
          setState(() {
            scanning = false;
          });
        });
  }

  Widget deviceTile(String name, String address, IconData icon) {
    return ListTile(
      leading: Icon(icon, size: 30),

      title: Text(name),

      subtitle: Text(address),

      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),

      height: 500,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          SizedBox(height: 20),

          Text(
            "Paired Devices",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          ...pairedDevices.map(
            (d) => deviceTile(d.name ?? "Unknown", d.address, Icons.headphones),
          ),

          SizedBox(height: 10),

          Text(
            "Available Devices",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          Expanded(
            child: ListView(
              children: availableDevices
                  .map(
                    (d) => deviceTile(
                      d.device.name ?? "Unknown",
                      d.device.address,
                      Icons.bluetooth,
                    ),
                  )
                  .toList(),
            ),
          ),

          SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff0b9a8a),
                padding: EdgeInsets.all(15),
              ),
              child: Text("START SCANNING"),
              onPressed: startScan,
            ),
          ),
        ],
      ),
    );
  }
}
