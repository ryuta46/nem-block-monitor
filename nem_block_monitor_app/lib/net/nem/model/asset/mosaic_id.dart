

class MosaicId {
  final String namespaceId;
  final String name;

  String get fullName => "$namespaceId:$name";

  MosaicId(this.namespaceId, this.name);
}