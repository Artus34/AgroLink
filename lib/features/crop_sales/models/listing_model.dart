import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single item listed for sale in the marketplace.
/// This class provides a structured way to handle data to and from Firestore.
class ListingModel {
  final String listingId;
  final String productName;
  final String description;
  final double price;
  final int quantity;
  final String unit; // e.g., "kg", "dozen", "piece"
  final String imageUrl;

  // --- Seller Information ---
  final String sellerId;
  final String sellerName;

  // --- Status and Timestamps ---
  final bool isAvailable;
  final Timestamp createdAt;

  // --- Buyer Information (will be null until the item is sold) ---
  final String? buyerId;
  final String? buyerName;
  final Timestamp? purchasedAt;

  ListingModel({
    required this.listingId,
    required this.productName,
    required this.description,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    required this.isAvailable,
    required this.createdAt,
    this.buyerId,
    this.buyerName,
    this.purchasedAt,
  });

  /// Converts a Firestore DocumentSnapshot into a ListingModel object.
  factory ListingModel.fromMap(Map<String, dynamic> map) {
    return ListingModel(
      listingId: map['listingId'] ?? '',
      productName: map['productName'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 0,
      unit: map['unit'] ?? 'kg',
      imageUrl: map['imageUrl'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      isAvailable: map['isAvailable'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      // Safely handle nullable buyer fields
      buyerId: map['buyerId'],
      buyerName: map['buyerName'],
      purchasedAt: map['purchasedAt'],
    );
  }

  /// Converts a ListingModel object into a Map for storing in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'productName': productName,
      'description': description,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
      // Nullable fields
      'buyerId': buyerId,
      'buyerName': buyerName,
      'purchasedAt': purchasedAt,
    };
  }
}
