import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
  List<BluetoothDevice> systemDevices = [];
  List<ScanResult> scanResults = [];
  bool scanning = false;

  @override
  void initState() {
    super.initState();
    getSystemDevices();
  }

  void getSystemDevices() async {
    List<BluetoothDevice> devices = await FlutterBluePlus.systemDevices([]);

    setState(() {
      systemDevices = devices;
    });
  }

  void startScan() async {
    scanResults.clear();

    setState(() {
      scanning = true;
    });

    await FlutterBluePlus.startScan(timeout: Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });

    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        scanning = false;
      });
    });
  }

  Widget deviceTile(
    String name,
    String id,
    IconData icon,
    BluetoothDevice device,
  ) {
    return ListTile(
      leading: Icon(icon, size: 30),

      title: Text(name),

      subtitle: Text(id),

      onTap: () async {
        try {
          await device.connect();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Connected to $name")));

          Navigator.pop(context);
        } catch (e) {
          print("Connection error");
        }
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
            "System Devices",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          ...systemDevices.map(
            (d) => deviceTile(
              d.platformName.isEmpty ? "Unknown" : d.platformName,
              d.remoteId.toString(),
              Icons.bluetooth_connected,
              d,
            ),
          ),

          SizedBox(height: 10),

          Text(
            "Available Devices",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          Expanded(
            child: ListView(
              children: scanResults.map((r) {
                final device = r.device;

                return deviceTile(
                  device.platformName.isEmpty
                      ? "Unknown Device"
                      : device.platformName,
                  device.remoteId.toString(),
                  Icons.bluetooth,
                  device,
                );
              }).toList(),
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

              child: Text(scanning ? "SCANNING..." : "START SCANNING"),

              onPressed: scanning ? null : startScan,
            ),
          ),
        ],
      ),
    );
  }
}
