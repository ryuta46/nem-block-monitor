import 'package:json_annotation/json_annotation.dart';
import 'package:nem_block_monitor_app/net/nem/model/node/node.dart';

part 'node_dto.g.dart';

@JsonSerializable(createToJson: false)
class NodeEndPointDTO {
  final String protocol;
  final int port;
  final String host;


  NodeEndPointDTO({this.protocol, this.port, this.host});
  static final Function factory = _$NodeEndPointDTOFromJson;
  factory NodeEndPointDTO.fromJson(Map<String, dynamic> json) => factory(json);
}


@JsonSerializable(createToJson: false)
class NodeDTO {
  final NodeEndPointDTO endpoint;

  NodeDTO({this.endpoint});
  static final Function factory = _$NodeDTOFromJson;
  factory NodeDTO.fromJson(Map<String, dynamic> json) => factory(json);

  Node toModel() {
    return Node(endpoint: NodeEndPoint(
        protocol: endpoint.protocol,
        port: endpoint.port,
        host: endpoint.host));
  }
}

@JsonSerializable(createToJson: false)
class NodeCollectionDTO {
  final List<NodeDTO> data;

  NodeCollectionDTO({this.data});

  static final Function factory = _$NodeCollectionDTOFromJson;
  factory NodeCollectionDTO.fromJson(Map<String, dynamic> json) => factory(json);

  List<Node> toModel() {
    return data.map((dto) => dto.toModel()).toList();
  }
}
