class PriceData {
  final DateTime date;
  final int commodityId;
  final int stateId;
  final int? districtId; // nullable
  final int? marketId;   // nullable
  final double minPrice;
  final double maxPrice;
  final double modalPrice;

  PriceData({
    required this.date,
    required this.commodityId,
    required this.stateId,
    this.districtId,
    this.marketId,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
  });

  factory PriceData.fromJson(Map<String, dynamic> json) {
    return PriceData(
      date: DateTime.parse(json['date'] as String),
      commodityId: json['commodity_id'] as int,
      stateId: json['census_state_id'] as int,
      districtId: json['census_district_id'] != null
          ? json['census_district_id'] as int
          : null,
      marketId:
          json['market_id'] != null ? json['market_id'] as int : null,
      minPrice: (json['min_price'] as num).toDouble(),
      maxPrice: (json['max_price'] as num).toDouble(),
      modalPrice: (json['modal_price'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'PriceData(date: $date, modalPrice: $modalPrice)';
  }
}
