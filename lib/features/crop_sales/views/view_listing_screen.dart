import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/controllers/auth_provider.dart';
import '../controllers/sales_provider.dart';
import '../models/listing_model.dart';

/// A screen that displays the full details of a single sales listing.
class ViewListingScreen extends StatelessWidget {
  final ListingModel listing;
  const ViewListingScreen({super.key, required this.listing});

  /// Handles the mock purchase logic.
  Future<void> _buyNow(BuildContext context) async {
    final salesProvider = context.read<SalesProvider>();
    final success = await salesProvider.purchaseItem(listing);

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase successful!'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
      // Go back two screens (past this one and the dashboard) to the home screen.
      int count = 0;
      Navigator.of(context).popUntil((_) => count++ >= 2);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(salesProvider.errorMessage ?? 'Purchase failed.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.userModel?.uid;
    final bool isMyListing = listing.sellerId == currentUserId;

    return Scaffold(
      appBar: AppBar(
        title: Text(listing.productName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Product Image ---
            Hero(
              tag: 'listing_image_${listing.listingId}',
              child: Image.network(
                listing.imageUrl,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 300,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey)),
                ),
              ),
            ),

            // --- Product Details ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.productName,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Price: ₹${listing.price.toStringAsFixed(2)} / ${listing.unit}',
                    style: const TextStyle(fontSize: 22, color: AppColors.primaryGreen, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Available Quantity: ${listing.quantity} ${listing.unit}',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Seller Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(listing.sellerName),
                    // ⭐️ FIX: Converted the Timestamp to a DateTime before formatting.
                    subtitle: Text('Posted on: ${DateFormat('dd MMM, yyyy').format(listing.createdAt.toDate())}'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // --- Bottom Navigation Bar with "Buy Now" Button ---
      bottomNavigationBar: _buildBottomBar(context, isMyListing),
    );
  }

  /// Builds the bottom bar with a dynamic "Buy Now" button.
  Widget _buildBottomBar(BuildContext context, bool isMyListing) {
    // Determine the button's state and text based on listing status
    String buttonText = 'Buy Now';
    VoidCallback? onPressedAction = () => _buyNow(context);

    if (!listing.isAvailable) {
      buttonText = 'Sold Out';
      onPressedAction = null; // Disable the button
    } else if (isMyListing) {
      buttonText = 'This is your listing';
      onPressedAction = null; // Disable the button
    }

    return Container(
      padding: const EdgeInsets.all(16.0).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Consumer<SalesProvider>(
        builder: (context, provider, child) {
          return provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: onPressedAction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    // Use a grey color for disabled state
                    backgroundColor: onPressedAction == null ? Colors.grey : AppColors.primaryGreen,
                  ),
                  child: Text(buttonText),
                );
        },
      ),
    );
  }
}

