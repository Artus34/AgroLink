import 'dart:typed_data'; // ⭐️ MODIFICATION: Import for Uint8List
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/image_service.dart';
import '../../auth/controllers/auth_provider.dart';
import '../models/listing_model.dart';
import '../models/transaction_model.dart';

/// Manages all business logic related to crop sales, listings, and transactions.
class SalesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageService _imageService = ImageService();
  final Uuid _uuid = const Uuid();

  // --- Internal State ---
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  List<ListingModel> _allListings = [];
  List<ListingModel> _myListings = [];
  List<TransactionModel> _myTransactions = [];

  // --- Public Getters ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ListingModel> get allListings => _allListings;
  List<ListingModel> get myListings => _myListings;
  List<TransactionModel> get myTransactions => _myTransactions;

  void update(AuthProvider authProvider) {
    _currentUser = authProvider.userModel;
  }

  /// Creates a new sales listing.
  Future<bool> createListing({
    required String productName,
    required String description,
    required double price,
    required int quantity,
    required String unit,
    // ⭐️ MODIFICATION: Changed parameter from File to Uint8List
    required Uint8List imageBytes,
  }) async {
    if (_currentUser == null) {
      _setError("You must be logged in to create a listing.");
      return false;
    }
    _setLoading(true);

    try {
      // 1. Upload the image to ImageKit
      final String fileName = "${_currentUser!.uid}_${DateTime.now().millisecondsSinceEpoch}";
      // ⭐️ MODIFICATION: Pass imageBytes with the correct parameter name
      final String? imageUrl = await _imageService.uploadImage(imageBytes: imageBytes, fileName: fileName);

      if (imageUrl == null) {
        throw Exception("Image upload failed. Please try again.");
      }

      // 2. Create the ListingModel object
      final String listingId = _uuid.v4();
      final newListing = ListingModel(
        listingId: listingId,
        productName: productName,
        description: description,
        price: price,
        quantity: quantity,
        unit: unit,
        imageUrl: imageUrl,
        sellerId: _currentUser!.uid,
        sellerName: _currentUser!.name,
        isAvailable: true,
        createdAt: Timestamp.now(),
      );

      // 3. Save the listing to Firestore
      await _firestore.collection('listings').doc(listingId).set(newListing.toMap());
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // --- All other methods remain the same ---

  Future<void> fetchAllListings() async {
    _setLoading(true);
    try {
      final snapshot = await _firestore
          .collection('listings')
          .where('isAvailable', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      _allListings = snapshot.docs.map((doc) => ListingModel.fromMap(doc.data())).toList();
    } catch (e) {
      _setError("Failed to fetch listings.");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMyListings() async {
    if (_currentUser == null) {
      _setError("You must be logged in to see your listings.");
      return;
    }
    _setLoading(true);
    try {
      final snapshot = await _firestore
          .collection('listings')
          .where('sellerId', isEqualTo: _currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _myListings = snapshot.docs.map((doc) => ListingModel.fromMap(doc.data())).toList();
    } catch (e) {
      _setError("Failed to fetch your listings.");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMyTransactions() async {
    if (_currentUser == null) {
      _setError("You must be logged in to see your transaction history.");
      return;
    }
    _setLoading(true);
    try {
      final salesSnapshot = await _firestore
          .collectionGroup('transactions')
          .where('sellerId', isEqualTo: _currentUser!.uid)
          .get();
      final purchasesSnapshot = await _firestore
          .collectionGroup('transactions')
          .where('buyerId', isEqualTo: _currentUser!.uid)
          .get();

      final List<TransactionModel> transactions = [];
      transactions.addAll(salesSnapshot.docs.map((doc) => TransactionModel.fromMap(doc.data())));
      transactions.addAll(purchasesSnapshot.docs.map((doc) => TransactionModel.fromMap(doc.data())));
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _myTransactions = transactions;
    } catch (e) {
      _setError("Failed to fetch transaction history.");
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> purchaseItem(ListingModel listing) async {
    if (_currentUser == null) {
      _setError("You must be logged in to purchase an item.");
      return false;
    }
    if (listing.sellerId == _currentUser!.uid) {
      _setError("You cannot purchase your own item.");
      return false;
    }
    _setLoading(true);
    try {
      final WriteBatch batch = _firestore.batch();
      final Timestamp purchaseTimestamp = Timestamp.now();
      final listingRef = _firestore.collection('listings').doc(listing.listingId);
      batch.update(listingRef, {
        'isAvailable': false,
        'buyerId': _currentUser!.uid,
        'buyerName': _currentUser!.name,
        'purchasedAt': purchaseTimestamp,
      });

      final transactionId = _uuid.v4();
      final transaction = TransactionModel(
        transactionId: transactionId,
        listingId: listing.listingId,
        productName: listing.productName,
        imageUrl: listing.imageUrl,
        price: listing.price,
        sellerId: listing.sellerId,
        sellerName: listing.sellerName,
        buyerId: _currentUser!.uid,
        buyerName: _currentUser!.name,
        timestamp: purchaseTimestamp,
      );
      final buyerTransactionRef = _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('transactions')
          .doc(transactionId);
      batch.set(buyerTransactionRef, transaction.toMap());

      final sellerTransactionRef = _firestore
          .collection('users')
          .doc(listing.sellerId)
          .collection('transactions')
          .doc(transactionId);
      batch.set(sellerTransactionRef, transaction.toMap());

      await batch.commit();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError("Purchase failed. Please try again.");
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    if (kDebugMode) {
      print("SalesProvider Error: $_errorMessage");
    }
    notifyListeners();
  }
}

