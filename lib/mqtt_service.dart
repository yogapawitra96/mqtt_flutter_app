import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  final MqttServerClient client;
  final String server;
  final String topic;
  Function(String)? onMessageReceived;

  MqttService(this.server, this.topic)
      : client = MqttServerClient.withPort(server, '', 1883) {
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
  }

  Future<void> connect() async {
    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier('mqtt_client')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      disconnect();
    }

    client.subscribe(topic, MqttQos.atMostOnce);

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      if (onMessageReceived != null) {
        onMessageReceived!(pt);
      }
    });
  }

  void disconnect() {
    client.disconnect();
  }

  void onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void onDisconnected() {
    print('Disconnected');
  }

  void onConnected() {
    print('Connected');
  }
}
