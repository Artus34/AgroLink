import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_provider.dart';
import '../controllers/sales_provider.dart';

/// A screen that displays a history of the user's past transactions (sales and purchases).
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch transactions when the screen is first loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SalesProvider>(context, listen: false).fetchMyTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    // We need the current user's ID to determine if a transaction was a sale or purchase.
    final currentUserId = Provider.of<AuthProvider>(context, listen: false).userModel?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Consumer<SalesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.myTransactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.myTransactions.isEmpty) {
            return Center(child: Text(provider.errorMessage!));
          }

          if (provider.myTransactions.isEmpty) {
            return const Center(
              child: Text(
                'You have no transaction history yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMyTransactions(),
            child: ListView.builder(
              itemCount: provider.myTransactions.length,
              itemBuilder: (context, index) {
                final transaction = provider.myTransactions[index];
                final bool isSale = transaction.sellerId == currentUserId;
                final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSale ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      child: Icon(
                        isSale ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isSale ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(
                      transaction.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // ⭐️ FIX: Converted the Timestamp to a DateTime before formatting.
                    subtitle: Text(
                      '${isSale ? "Sold to" : "Bought from"} ${isSale ? transaction.buyerName : transaction.sellerName}\n${formatter.format(transaction.timestamp.toDate())}',
                    ),
                    trailing: Text(
                      '${isSale ? "+" : "-"} ₹${transaction.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isSale ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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

