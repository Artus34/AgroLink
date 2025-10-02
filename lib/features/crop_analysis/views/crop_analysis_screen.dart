import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/crop_analysis_provider.dart';
import '../models/commodity_model.dart';

class CropAnalysisScreen extends StatefulWidget {
  const CropAnalysisScreen({super.key});

  @override
  State<CropAnalysisScreen> createState() => _CropAnalysisScreenState();
}

class _CropAnalysisScreenState extends State<CropAnalysisScreen> {
  @override
  void initState() {
    super.initState();
    // Start fetching data immediately when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CropAnalysisProvider>(context, listen: false).fetchCommodities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Market Analysis', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Consumer<CropAnalysisProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: AppColors.backgroundEnd),  //error color
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${provider.errorMessage!}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchCommodities(),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                      child: const Text('Try Again'),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'If the error persists, please ensure your CEDA API Key is correctly configured in crop_analysis_service.dart.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.commodities.isEmpty) {
            return const Center(
              child: Text(
                'No commodities found.',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            );
          }

          return _buildCommodityList(provider.commodities);
        },
      ),
    );
  }

  Widget _buildCommodityList(List<Commodity> commodities) {
    return ListView.builder(
      itemCount: commodities.length,
      itemBuilder: (context, index) {
        final commodity = commodities[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const Icon(Icons.grain, color: AppColors.primaryGreen),
            title: Text(
              commodity.name,
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            subtitle: Text('ID: ${commodity.id}', style: const TextStyle(color: AppColors.textSecondary)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
            onTap: () {
              // Future implementation: Navigate to a detailed trend screen
              Provider.of<CropAnalysisProvider>(context, listen: false).fetchPriceTrend(commodity.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Viewing market trends for ${commodity.name} (ID: ${commodity.id})')),
              );
            },
          ),
        );
      },
    );
  }
}
