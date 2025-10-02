import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_provider.dart';
import '../controllers/sales_provider.dart';
import '../models/listing_model.dart';
import 'add_listing_screen.dart';
import 'view_listing_screen.dart';

/// The main marketplace screen where all users can view available listings.
class SalesDashboardScreen extends StatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  State<SalesDashboardScreen> createState() => _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends State<SalesDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch all listings when the screen is first loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesProvider>(context, listen: false).fetchAllListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
      ),
      body: Consumer<SalesProvider>(
        builder: (context, provider, child) {
          // Show a loading spinner while data is being fetched.
          if (provider.isLoading && provider.allListings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show an error message if something went wrong.
          if (provider.errorMessage != null && provider.allListings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          }

          // Show a message if there are no available listings.
          if (provider.allListings.isEmpty) {
            return const Center(
              child: Text(
                'No listings available at the moment.\nPlease check back later.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Display the grid of listings.
          return RefreshIndicator(
            onRefresh: () => provider.fetchAllListings(),
            child: GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // A responsive 2-column grid
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.75, // Adjust for better item proportions
              ),
              itemCount: provider.allListings.length,
              itemBuilder: (context, index) {
                final listing = provider.allListings[index];
                return _ListingCard(listing: listing);
              },
            ),
          );
        },
      ),
      // --- Conditional Floating Action Button ---
      // This button is only visible to users with the 'farmer' role.
      floatingActionButton: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.userModel?.role == 'farmer') {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddListingScreen()),
                );
              },
              child: const Icon(Icons.add),
            );
          } else {
            // Return an empty widget to hide the button for regular users.
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

/// A reusable widget to display a single listing in the grid.
class _ListingCard extends StatelessWidget {
  final ListingModel listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Ensures the image respects the border radius
      child: InkWell(
        onTap: () {
          // Navigate to the detailed view screen, passing the listing data.
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewListingScreen(listing: listing),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image
            Expanded(
              child: Hero(
                tag: 'listing_image_${listing.listingId}',
                child: Image.network(
                  listing.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                ),
              ),
            ),
            // Product Details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // ⭐️ MODIFICATION: Formatted the price for consistency.
                  Text(
                    '₹${listing.price.toStringAsFixed(2)} / ${listing.unit}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'by ${listing.sellerName}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

