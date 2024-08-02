import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'mqtt_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MqttService mqttService;
  String? timestamp;
  double? voltage;

  @override
  void initState() {
    super.initState();
    mqttService = MqttService('206.189.148.26', 'esp8266/data');
    mqttService.onMessageReceived = (message) {
      final data = jsonDecode(message);
      setState(() {
        timestamp = data['timestamp'].toString();
        voltage = data['voltage'];
      });
    };
    mqttService.connect();
  }

  @override
  void dispose() {
    mqttService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('MQTT Data Display'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Timestamp: ${timestamp ?? "Loading..."}',
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                'Voltage: ${voltage?.toStringAsFixed(6) ?? "Loading..."}',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 50),
              SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 3.0,
                    maximum: 4.2,
                    ranges: <GaugeRange>[
                      GaugeRange(
                          startValue: 3.0, endValue: 3.5, color: Colors.red),
                      GaugeRange(
                          startValue: 3.5, endValue: 4.0, color: Colors.orange),
                      GaugeRange(
                          startValue: 4.0, endValue: 4.2, color: Colors.green)
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: voltage ?? 3.0,
                      )
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Container(
                          child: Text(
                            voltage != null
                                ? voltage!.toStringAsFixed(2)
                                : 'Loading...',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0.5,
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
