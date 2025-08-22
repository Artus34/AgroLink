// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/theme/app_colors.dart';
import 'features/auth/controllers/auth_provider.dart';
import 'features/auth/views/login_screen.dart';
import 'features/auth/views/signup_screen.dart';
import 'features/home/views/home_screen.dart';
import 'features/predictions/crop_prediction/controllers/crop_prediction_provider.dart';
import 'features/predictions/crop_prediction/views/crop_prediction_screen.dart';
import 'features/predictions/yield_prediction/controllers/yield_prediction_provider.dart';
import 'features/predictions/yield_prediction/views/yield_prediction_screen.dart';
import 'features/predictions/rainfall_prediction/controllers/rainfall_prediction_provider.dart';
import 'features/predictions/rainfall_prediction/views/rainfall_prediction_screen.dart';
// ➡️ Add this import for the new fertilizer recommendation provider
import 'features/predictions/fertilizer_recommendation/controllers/fertilizer_recommendation_provider.dart';
// ➡️ Add this import for the new fertilizer recommendation screen
import 'features/predictions/fertilizer_recommendation/views/fertilizer_recommendation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CropPredictionProvider()),
        ChangeNotifierProvider(create: (context) => YieldPredictionProvider()),
        ChangeNotifierProvider(create: (context) => RainfallPredictionProvider()),
        // ➡️ Add the new fertilizer recommendation provider here
        ChangeNotifierProvider(create: (context) => FertilizerRecommendationProvider()),
      ],
      child: MaterialApp(
        title: 'Agrolink',
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: AppColors.lightScaffoldBackground,
          primaryColor: AppColors.primaryGreen,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: AppColors.lightScaffoldBackground,
            foregroundColor: AppColors.textPrimary,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/signup': (context) => SignUpScreen(),
          '/predict_crop': (context) => CropPredictionScreen(),
          '/predict_yield': (context) => YieldPredictionScreen(),
          '/predict_rainfall': (context) => const RainfallPredictionScreen(),
        },
      ),
    );
  }
}
