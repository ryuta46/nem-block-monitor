
enum MessageType {
  plain,
  encrypted
}

class MessageTypeValues {
  static final Map<MessageType, int> values = {
    MessageType.plain: 1,
    MessageType.encrypted: 2,
  };

  static final Map<int, MessageType> types = values.map((k, v) => MapEntry(v, k));
}
