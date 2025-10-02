import 'package:agrolink/features/crop_analysis/controllers/crop_analysis_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/theme/app_colors.dart';
import 'features/auth/controllers/auth_provider.dart';
import 'features/auth/views/login_screen.dart';
import 'features/auth/views/signup_screen.dart';
import 'features/home/views/home_screen.dart';
import 'firebase_options.dart';

// Your other provider imports
import 'features/predictions/crop_prediction/controllers/crop_prediction_provider.dart';
import 'features/predictions/yield_prediction/controllers/yield_prediction_provider.dart';
import 'features/predictions/rainfall_prediction/controllers/rainfall_prediction_provider.dart';
import 'features/predictions/fertilizer_recommendation/controllers/fertilizer_recommendation_provider.dart';
import 'features/predictions/crop_prediction/views/crop_prediction_screen.dart';
import 'features/predictions/yield_prediction/views/yield_prediction_screen.dart';
import 'features/predictions/rainfall_prediction/views/rainfall_prediction_screen.dart';
import 'features/market_info/weather/controllers/weather_provider.dart';
import 'features/market_info/news/controllers/news_provider.dart';

// ⭐️ ADDED: Import for the new SalesProvider.
import 'features/crop_sales/controllers/sales_provider.dart';

void main() async {
  // Ensure all necessary services are initialized before running the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    // This will catch and print any critical errors during startup.
    debugPrint('--- FATAL ERROR DURING APP INITIALIZATION ---');
    debugPrint('ERROR: $e');
    debugPrint('---------------------------------------------');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // --- AUTH & DEPENDENT PROVIDERS ---
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        // ⭐️ ADDED: ChangeNotifierProxyProvider for SalesProvider.
        // This makes SalesProvider listen to changes in AuthProvider.
        ChangeNotifierProxyProvider<AuthProvider, SalesProvider>(
          create: (context) => SalesProvider(),
          update: (context, authProvider, previousSalesProvider) =>
              previousSalesProvider!..update(authProvider),
        ),

        // --- INDEPENDENT PROVIDERS ---
        ChangeNotifierProvider(create: (context) => CropPredictionProvider()),
        ChangeNotifierProvider(create: (context) => YieldPredictionProvider()),
        ChangeNotifierProvider(
            create: (context) => RainfallPredictionProvider()),
        ChangeNotifierProvider(
            create: (context) => FertilizerRecommendationProvider()),
        ChangeNotifierProvider(create: (context) => WeatherProvider()),
        ChangeNotifierProvider(create: (context) => NewsProvider()),
        ChangeNotifierProvider(create: (_) => CropAnalysisProvider()),
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
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/signup': (context) => const SignUpScreen(),
          // '/admin_home': (context) => const AdminHomeScreen(), // This can be removed
          // Your other prediction routes
          '/predict_crop': (context) => CropPredictionScreen(),
          '/predict_yield': (context) => YieldPredictionScreen(),
          '/predict_rainfall': (context) => const RainfallPredictionScreen(),
        },
      ),
    );
  }
}
