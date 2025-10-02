class Commodity {
  final int id;
  final String name;

  Commodity({
    required this.id,
    required this.name,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      // The API returns 'commodity_id' and 'commodity_name'
      id: json['commodity_id'] as int,
      name: json['commodity_name'] as String,
    );
  }

  // A simple toString for debugging
  @override
  String toString() {
    return 'Commodity(id: $id, name: $name)';
  }
}
