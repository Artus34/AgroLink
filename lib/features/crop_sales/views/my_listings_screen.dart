import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/sales_provider.dart';

/// A screen that displays a list of the currently logged-in farmer's own listings.
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the user's listings when the screen is first loaded.
    // We use addPostFrameCallback to ensure the context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use listen: false because we are in initState.
      Provider.of<SalesProvider>(context, listen: false).fetchMyListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
      ),
      body: Consumer<SalesProvider>(
        builder: (context, provider, child) {
          // Show a loading spinner while data is being fetched.
          if (provider.isLoading && provider.myListings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show an error message if something went wrong.
          if (provider.errorMessage != null && provider.myListings.isEmpty) {
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

          // Show a message if the farmer has no listings.
          if (provider.myListings.isEmpty) {
            return const Center(
              child: Text(
                'You have not posted any listings yet.\nTap the "+" button on the dashboard to create one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Display the list of listings.
          return RefreshIndicator(
            onRefresh: () => provider.fetchMyListings(),
            child: ListView.builder(
              itemCount: provider.myListings.length,
              itemBuilder: (context, index) {
                final listing = provider.myListings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12.0),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        listing.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 60),
                      ),
                    ),
                    title: Text(
                      listing.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Price: ₹${listing.price} / ${listing.unit}'),
                    trailing: Chip(
                      label: Text(
                        listing.isAvailable ? 'Available' : 'Sold',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: listing.isAvailable ? AppColors.primaryGreen : Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
