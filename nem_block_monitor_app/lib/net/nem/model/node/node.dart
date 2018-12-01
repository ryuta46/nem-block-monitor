

class NodeEndPoint {
  final String protocol;
  final int port;
  final String host;

  String get urlString => "$protocol://$host:$port";

  NodeEndPoint({this.protocol, this.port, this.host});
}

class Node {
  final NodeEndPoint endpoint;

  Node({this.endpoint});



}

