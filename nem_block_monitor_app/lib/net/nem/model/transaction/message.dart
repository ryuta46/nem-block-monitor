
import 'package:nem_block_monitor_app/net/nem/model/transaction/message_type.dart';

class Message {
  final MessageType type;
  final String payload;

  Message(this.type, this.payload);
}