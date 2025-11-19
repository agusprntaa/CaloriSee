import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/exercise_service.dart';

class ExerciseScreen extends StatefulWidget {
  final int userId;
  final double? userWeight;
  
  const ExerciseScreen({
    Key? key,
    required this.userId,
    this.userWeight,
  }) : super(key: key);

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  List<Map<String, dynamic>> exercises = [];
  String selectedCategory = 'all';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    setState(() {
      isLoading = true;
      exercises = _exerciseService.getMockExercises();
      isLoading = false;
    });
  }

  List<Map<String, dynamic>> get filteredExercises {
    if (selectedCategory == 'all') return exercises;
    return exercises.where((e) => e['type'] == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Exercise Tracker',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildExerciseList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWorkoutPlanDialog(),
        backgroundColor: const Color(0xFF6EE7B7),
        icon: const Icon(Icons.fitness_center),
        label: Text(
          'Workout Plan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'id': 'all', 'name': 'Semua', 'icon': '🎯'},
      {'id': 'cardio', 'name': 'Cardio', 'icon': '❤️'},
      {'id': 'strength', 'name': 'Strength', 'icon': '💪'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            bool isSelected = selectedCategory == cat['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() => selectedCategory = cat['id']!);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF6EE7B7), Color(0xFF9AFFC2)],
                          )
                        : null,
                    color: isSelected ? null : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        cat['icon']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cat['name']!,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExerciseList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = filteredExercises[index];
        return _buildExerciseCard(exercise);
      },
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    Color difficultyColor;
    switch (exercise['difficulty']) {
      case 'beginner':
        difficultyColor = const Color(0xFF10B981);
        break;
      case 'intermediate':
        difficultyColor = const Color(0xFFF59E0B);
        break;
      case 'advanced':
        difficultyColor = const Color(0xFFEF4444);
        break;
      default:
        difficultyColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () => _showExerciseDetail(exercise),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6EE7B7), Color(0xFF9AFFC2)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    exercise['icon'],
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: difficultyColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            exercise['difficulty'].toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: difficultyColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${exercise['met']} MET',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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
        ),
      ),
    );
  }

  void _showExerciseDetail(Map<String, dynamic> exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      exercise['icon'],
                      style: const TextStyle(fontSize: 80),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    exercise['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Type', exercise['type']),
                  _buildInfoRow('Muscle', exercise['muscle']),
                  _buildInfoRow('Difficulty', exercise['difficulty']),
                  _buildInfoRow('MET Value', '${exercise['met']}'),
                  const SizedBox(height: 24),
                  Text(
                    'Instructions',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise['instructions'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.userWeight != null) ...[
                    Text(
                      'Calories Burned (estimates)',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCalorieEstimate(exercise, 15),
                    _buildCalorieEstimate(exercise, 30),
                    _buildCalorieEstimate(exercise, 60),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${exercise['name']} added to your workout!',
                            ),
                            backgroundColor: const Color(0xFF6EE7B7),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6EE7B7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        'Add to Workout',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieEstimate(Map<String, dynamic> exercise, int minutes) {
    if (widget.userWeight == null) return const SizedBox.shrink();

    double calories = _exerciseService.calculateCaloriesBurned(
      met: exercise['met'].toDouble(),
      weightKg: widget.userWeight!,
      durationMinutes: minutes,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$minutes minutes',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          Text(
            '${calories.toStringAsFixed(0)} kcal',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6EE7B7),
            ),
          ),
        ],
      ),
    );
  }

  void _showWorkoutPlanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Choose Your Goal',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGoalOption('Weight Loss', 'weight_loss', '🔥'),
            _buildGoalOption('Muscle Gain', 'muscle_gain', '💪'),
            _buildGoalOption('Maintenance', 'maintenance', '⚖️'),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption(String title, String goal, String emoji) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 30)),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      onTap: () {
        Navigator.pop(context);
        final plan = _exerciseService.getWorkoutPlan(goal);
        _showPlanDetail(plan);
      },
    );
  }

  void _showPlanDetail(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          plan['name'],
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                plan['description'],
                style: GoogleFonts.inter(color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              Text(
                'Duration: ${plan['duration_weeks']} weeks',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              Text(
                'Frequency: ${plan['days_per_week']} days/week',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Text(
                'Recommended Exercises:',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              ...List.generate(
                (plan['exercises'] as List).length,
                (index) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '• ${plan['exercises'][index]}',
                    style: GoogleFonts.inter(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Workout plan activated!'),
                  backgroundColor: Color(0xFF6EE7B7),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6EE7B7),
            ),
            child: const Text('Start Plan'),
          ),
        ],
      ),
    );
  }
}