import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a record of a completed transaction (a "receipt").
/// A copy of this is created for both the buyer and the seller.
class TransactionModel {
  final String transactionId;
  final String listingId;
  final String productName;
  final String imageUrl;
  final double price;

  // --- Participant Information ---
  final String sellerId;
  final String sellerName;
  final String buyerId;
  final String buyerName;

  // --- Timestamp ---
  final Timestamp timestamp;

  TransactionModel({
    required this.transactionId,
    required this.listingId,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.sellerId,
    required this.sellerName,
    required this.buyerId,
    required this.buyerName,
    required this.timestamp,
  });

  /// Converts a Firestore DocumentSnapshot into a TransactionModel object.
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      transactionId: map['transactionId'] ?? '',
      listingId: map['listingId'] ?? '',
      productName: map['productName'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      buyerId: map['buyerId'] ?? '',
      buyerName: map['buyerName'] ?? '',
      timestamp: map['timestamp'] ?? Timestamp.now(),
    );
  }

  /// Converts a TransactionModel object into a Map for storing in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'listingId': listingId,
      'productName': productName,
      'imageUrl': imageUrl,
      'price': price,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'timestamp': timestamp,
    };
  }
}
