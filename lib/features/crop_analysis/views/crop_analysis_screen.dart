import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/crop_analysis_provider.dart';
import '../../../app/theme/app_colors.dart';

class CropAnalysisScreen extends StatefulWidget {
  const CropAnalysisScreen({super.key});

  @override
  State<CropAnalysisScreen> createState() => _CropAnalysisScreenState();
}

class _CropAnalysisScreenState extends State<CropAnalysisScreen> {
  int? _selectedCommodity = 1; // default Wheat
  int? _selectedState = 8; // default Bihar
  DateTime? _fromDate;
  DateTime? _toDate;

  final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  // --- Helper methods for UI display ---

  String _getCommodityName(int? id) {
    switch (id) {
      case 1: return "Wheat";
      case 2: return "Rice";
      case 3: return "Maize";
      default: return "Selected Commodity";
    }
  }

  String _getStateName(int? id) {
    switch (id) {
      case 8: return "Bihar";
      case 9: return "Gujarat";
      case 10: return "Maharashtra";
      default: return "Selected State";
    }
  }

  // --- Helper Widget for styled Dropdown ---

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: AppColors.lightScaffoldBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10), // Rounded edges
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: AppColors.textSecondary)),
          icon: const Icon(Icons.arrow_drop_down_circle, color: AppColors.primaryGreen, size: 20),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
        ),
      ),
    );
  }

  // --- Helper Widget for styled Date Buttons ---

  Widget _buildDateButton(bool isFrom, BuildContext context) {
    final date = isFrom ? _fromDate : _toDate;
    final label = isFrom ? "From" : "To";
    final text = date == null ? 'Select $label Date' : '$label: ${_formatter.format(date)}';

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: OutlinedButton.icon(
          icon: Icon(Icons.calendar_today, size: 18, color: AppColors.primaryGreen),
          label: Text(text, style: const TextStyle(fontSize: 14)),
          onPressed: () => _pickDate(isFrom),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            foregroundColor: AppColors.textPrimary,
            side: BorderSide(color: AppColors.primaryGreen.withOpacity(0.6), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Soft edges
          ),
        ),
      ),
    );
  }

  // --- Logic remains the same ---

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2026),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryGreen, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: AppColors.textPrimary, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  // --- Chart Building (Enhanced UI) ---

  Widget _buildPriceChart(List priceData) {
    // If no data, return a placeholder (though this check is usually done in the Consumer)
    if (priceData.isEmpty) return Container();
    
    // Logic for spots remains the same
    final spots = priceData.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      // Using dynamic to handle the missing PriceData model definition
      final price = (entry.value as dynamic).modalPrice.toDouble(); 
      return FlSpot(index, price);
    }).toList();

    return Card( // Use Card for rounded corners and elevation
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      elevation: 8, // Added significant elevation for focus
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Soft curve
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 8), // Adjusted padding
        child: SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              backgroundColor: Colors.white,
              // Enhanced Grid Data
              gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.textSecondary.withOpacity(0.15),
                      strokeWidth: 1)),
              // Enhanced Titles Data
              titlesData: FlTitlesData(
                show: true,
                leftTitles: AxisTitles(
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text('Price (₹)', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                        textAlign: TextAlign.right,
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text('Date', style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: (priceData.length / 5).ceilToDouble(),
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= priceData.length) return Container();
                      // Using dynamic to handle the missing PriceData model definition
                      final date = (priceData[value.toInt()] as dynamic).date; 
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('MM-dd').format(date),
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              // Enhanced Border Data
              borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.5), width: 1.5),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 4, // Slightly thicker line
                  // Using Gradient for a smoother look
                  gradient: LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.primaryGreen.withOpacity(0.8)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                      show: true,
                      // Area fill for visual impact
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen.withOpacity(0.3),
                          AppColors.primaryGreen.withOpacity(0.01),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightScaffoldBackground, // Light background for contrast
      appBar: AppBar(
        title: const Text("Crop Price Analysis", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)), // Curved bottom
        ),
      ),
      // --- WRAPPED BODY IN SingleChildScrollView ---
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Filters (Wrapped in a curved Card) ---
            Card(
              margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Select Parameters for Analysis',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen),
                    ),
                    const Divider(height: 20, thickness: 1, color: AppColors.textSecondary),
                    
                    // Commodity Dropdown (using new helper)
                    _buildDropdown<int>(
                      value: _selectedCommodity,
                      hint: "Select Commodity",
                      items: const [
                        DropdownMenuItem(value: 1, child: Text("Wheat")),
                        DropdownMenuItem(value: 2, child: Text("Rice")),
                        DropdownMenuItem(value: 3, child: Text("Maize")),
                      ],
                      onChanged: (val) => setState(() => _selectedCommodity = val),
                    ),

                    // State Dropdown (using new helper)
                    _buildDropdown<int>(
                      value: _selectedState,
                      hint: "Select State",
                      items: const [
                        DropdownMenuItem(value: 8, child: Text("Bihar")),
                        DropdownMenuItem(value: 9, child: Text("Gujarat")),
                        DropdownMenuItem(value: 10, child: Text("Maharashtra")),
                      ],
                      onChanged: (val) => setState(() => _selectedState = val),
                    ),

                    const SizedBox(height: 15),

                    // Date Pickers (using new helper)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDateButton(true, context),
                        _buildDateButton(false, context),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Fetch Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Soft edges
                        elevation: 4,
                      ),
                      onPressed: () {
                        if (_selectedCommodity != null &&
                            _selectedState != null &&
                            _fromDate != null &&
                            _toDate != null) {
                          // Logic remains untouched
                          Provider.of<CropAnalysisProvider>(context, listen: false)
                              .fetchPriceData(
                            commodityId: _selectedCommodity!,
                            stateId: _selectedState!,
                            fromDate: _formatter.format(_fromDate!),
                            toDate: _formatter.format(_toDate!),
                          );
                        }
                      },
                      child: const Text("Fetch Price Trend", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

            // --- Chart / Results (Expanded and ListView removed) ---
            Consumer<CropAnalysisProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50.0, bottom: 50.0),
                        child: CircularProgressIndicator(
                            color: AppColors.primaryGreen),
                      ));
                }
                if (provider.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'Error: ${provider.errorMessage!}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.errorRed, fontSize: 16),
                      ),
                    ),
                  );
                }
                if (provider.priceData.isEmpty) {
                  return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          "No price data available for the selected period/region. Please adjust your filters.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                        ),
                      ));
                }
                
                // Changed from ListView to Column since the outer SingleChildScrollView handles scrolling
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                      child: Text(
                        "📈 Price Trend for ${_getCommodityName(_selectedCommodity)} in ${_getStateName(_selectedState)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                      ),
                    ),
                    _buildPriceChart(provider.priceData),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
