import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../database/database_helper.dart';
import '../services/weather_service.dart';
import 'profile_screen.dart';
import 'camera_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int userId;
  const DashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? userData;
  double todayCalories = 0;
  double targetCalories = 2000;
  List<Map<String, dynamic>> recentFoods = [];
  WeatherModel? weather;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => isLoading = true);

    try {
      DatabaseHelper db = DatabaseHelper();
      
      // Load user data
      userData = await db.getUserById(widget.userId);
      
      // Load today's calories
      todayCalories = await db.getTodayCalories(widget.userId);
      
      // Load target calories
      if (userData != null) {
        targetCalories = userData!['targetCalories'] ?? 2000.0;
      }
      
      // Load recent foods
      List<Map<String, dynamic>> allFoods = await db.getFoodHistory(widget.userId);
      recentFoods = allFoods.take(5).toList();

      // Load weather data
      WeatherService weatherService = WeatherService();
      Map<String, dynamic>? weatherData = await weatherService.getCurrentWeather('Jakarta');
      if (weatherData != null) {
        weather = WeatherModel.fromJson(weatherData);
      }

    } catch (e) {
      print('Error loading dashboard: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildWeatherCard(),
                        const SizedBox(height: 24),
                        _buildCalorieProgress(),
                        const SizedBox(height: 24),
                        _buildScanButton(),
                        const SizedBox(height: 24),
                        _buildRecentFoods(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    String username = userData?['username'] ?? 'User';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $username 👋',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),
            Text(
              'Ayo capai target hari ini!',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: widget.userId),
              ),
            ).then((_) => _loadDashboardData());
          },
          child: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF6EE7B7),
            backgroundImage: userData?['profileImage'] != null
                ? FileImage(userData!['profileImage'])
                : null,
            child: userData?['profileImage'] == null
                ? const Icon(Icons.person, color: Colors.white, size: 32)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherCard() {
    if (weather == null) return const SizedBox.shrink();

    WeatherService weatherService = WeatherService();
    String icon = weatherService.getWeatherIcon(weather!.condition);
    String recommendation = weatherService.getWeatherRecommendation(
      weather!.temperature,
      weather!.condition,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6EE7B7), Color(0xFF9AFFC2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6EE7B7).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather!.city,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    weather!.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Text(
                icon,
                style: const TextStyle(fontSize: 48),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${weather!.temperature.toStringAsFixed(1)}°C',
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              recommendation,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieProgress() {
    double percentage = todayCalories / targetCalories;
    if (percentage > 1) percentage = 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Kalori Hari Ini',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          CircularPercentIndicator(
            radius: 80,
            lineWidth: 15,
            percent: percentage,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${todayCalories.toInt()}',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6EE7B7),
                  ),
                ),
                Text(
                  'kcal',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            progressColor: const Color(0xFF6EE7B7),
            backgroundColor: const Color(0xFFE2E8F0),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 16),
          Text(
            'Target: ${targetCalories.toInt()} kcal',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraScreen(userId: widget.userId),
          ),
        ).then((_) => _loadDashboardData());
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6EE7B7), Color(0xFF9AFFC2)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6EE7B7).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Scan Makanan',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFoods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Makanan Terbaru',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to history page
              },
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6EE7B7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        recentFoods.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada makanan terscan',
                        style: GoogleFonts.inter(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentFoods.length,
                itemBuilder: (context, index) {
                  var food = recentFoods[index];
                  return _buildFoodCard(food);
                },
              ),
      ],
    );
  }

  Widget _buildFoodCard(Map<String, dynamic> food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.restaurant,
              color: Color(0xFF6EE7B7),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food['foodName'] ?? 'Unknown',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${food['calories']?.toInt() ?? 0} kcal',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}