import 'package:cookbuddy/screens/admin/admin_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:cookbuddy/database/database_helper.dart';
import 'package:cookbuddy/screens/general/get_started_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../utils/colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _animationCompleted = false;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward().then((_) {
      setState(() {
        _animationCompleted = true;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchStatistics() async {
    try {
      final db = await _dbHelper.database;

      // Fetch statistics from the database
      final userCountResult =
          await db.rawQuery('SELECT COUNT(*) AS total FROM Users');
      final recipesCount =
          await db.rawQuery('SELECT COUNT(*) AS total FROM Recipes');
      final commentsCount = await db.rawQuery(
          'SELECT COUNT(*) AS total FROM CommentAndRating WHERE comment IS NOT NULL');
      final feedbackCount =
          await db.rawQuery('SELECT COUNT(*) AS total FROM CommentAndRating');
      final creditsSum =
          await db.rawQuery('SELECT SUM(credits) AS total FROM Transactions');
      final purchasesCount =
          await db.rawQuery('SELECT COUNT(*) AS total FROM Transactions');
      final categoriesResult = await db.rawQuery(
          'SELECT Categories.name, COUNT(Recipes.categoryId) AS count FROM Recipes '
          'JOIN Categories ON Recipes.categoryId = Categories.id '
          'GROUP BY Recipes.categoryId ORDER BY count DESC LIMIT 5');

      return {
        "totalUsers": userCountResult.first['total'] as int,
        "totalRecipes": recipesCount.first['total'] as int,
        "totalComments": commentsCount.first['total'] as int,
        "totalFeedback": feedbackCount.first['total'] as int,
        "totalCredits": (creditsSum.first['total'] ?? 0) as int,
        "totalPurchases": purchasesCount.first['total'] as int,
        "topCategories": {
          for (var row in categoriesResult)
            row['name'] as String: row['count'] as int,
        },
      };
    } catch (error) {
      print('Error fetching statistics: $error');
      return {};
    }
  }

  void _logOut(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GetStartedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 60,
            backgroundColor: AppColors.appBar,
            automaticallyImplyLeading: false,
            title: Text(
              "Admin Dashboard",
              style: GoogleFonts.lora(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: AppColors.headingText),
            ),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'logout') {
                    _logOut(context);
                  }
                },
                icon: const Icon(Icons.more_vert,
                    color: AppColors.headingText), // Ensure icon matches theme
                color: AppColors.background, // Match dropdown background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    height: 36, // Reduce height for compact look
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout,
                            color: Colors.red, size: 20), // Adjust icon size
                        const SizedBox(width: 6),
                        Text(
                          'Log Out',
                          style: GoogleFonts.lora(
                            fontSize: 14, // Reduce font size for a compact look
                            fontWeight: FontWeight.w600,
                            color: Colors.red, // Match theme
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ]),
        backgroundColor: AppColors.background,
        body: FutureBuilder<Map<String, dynamic>>(
          future: _fetchStatistics(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text("Error fetching statistics."));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No data available."));
            }

            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Key Statistics",
                    style: GoogleFonts.lora(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.headingText),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStatCard("Total Users",
                          data["totalUsers"].toString(), Colors.blue),
                      _buildStatCard("Total Recipes",
                          data["totalRecipes"].toString(), Colors.green),
                      _buildStatCard("Total Comments",
                          data["totalComments"].toString(), Colors.orange),
                      _buildStatCard("Total Feedback",
                          data["totalFeedback"].toString(), Colors.purple),
                      _buildStatCard("Total Credits",
                          data["totalCredits"].toString(), Colors.teal),
                      _buildStatCard("Total Purchases",
                          data["totalPurchases"].toString(), Colors.red),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildKeyStatisticsPieChart(data),
                  const SizedBox(height: 16),
                  Text(
                    "Top Categories",
                    style: GoogleFonts.lora(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.headingText),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryBarChart(data["topCategories"]),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: AdminBottomNavigationBar(
            currentIndex: _selectedIndex, onTap: _onNavItemTapped));
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      color: AppColors.background, // Themed background color
      elevation: 5, // Subtle shadow for depth
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.hintText, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.lora(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.headingText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.lora(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyStatisticsPieChart(Map<String, dynamic> data) {
    List<PieChartSectionData> sections = [
      _createPieChartSection(data["totalUsers"], "Users", Colors.blue),
      _createPieChartSection(data["totalRecipes"], "Recipes", Colors.green),
      _createPieChartSection(data["totalComments"], "Comments", Colors.orange),
      _createPieChartSection(data["totalFeedback"], "Feedback", Colors.purple),
      _createPieChartSection(data["totalCredits"], "Credits", Colors.teal),
      _createPieChartSection(data["totalPurchases"], "Purchases", Colors.red),
    ];

    return Card(
      margin: const EdgeInsets.all(6),
      color: AppColors.background,
      elevation: 6, // Enhanced depth
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.hintText, width: 1)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            Text(
              "Key Statistics",
              style: GoogleFonts.lora(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.headingText,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: _animationCompleted
                  ? PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 50,
                        sectionsSpace: 2,
                        borderData: FlBorderData(show: false),
                      ),
                    )
                  : AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_animation.value * 0.1),
                          child: Opacity(
                            opacity: _animation.value,
                            child: PieChart(
                              PieChartData(
                                sections: sections,
                                centerSpaceRadius: 50,
                                sectionsSpace: 2,
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _createPieChartSection(
      int value, String title, Color color) {
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: value > 0 ? title : "",
      radius: 100,
      titleStyle: GoogleFonts.lora(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      badgeWidget: value > 0
          ? Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 1),
                    color.withValues(alpha: 1)
                  ], // Subtle gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12), // Rounded edges
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3), // Soft shadow matching theme
                    blurRadius: 6,
                    spreadRadius: 1,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: Text(
                '$value',
                style: GoogleFonts.lora(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // White text for better contrast
                ),
                textAlign: TextAlign.center,
              ),
            )
          : null,
      badgePositionPercentageOffset:
          1.1, // Position outside slightly for clarity
    );
  }

  Widget _buildCategoryBarChart(Map<String, int> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          "No data available",
          style: GoogleFonts.lora(fontSize: 16, color: AppColors.hintText),
        ),
      );
    }

    List<BarChartGroupData> barGroups = [];
    final colorPalette = [
      Colors.blueAccent,
      Colors.orangeAccent,
      Colors.tealAccent,
      Colors.purpleAccent,
      Colors.greenAccent,
    ];

    int index = 0;
    categories.forEach((category, count) {
      if (count > 0) {
        // Avoid negative or zero values
        barGroups.add(
          BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: count.toDouble(),
                color: colorPalette[index % colorPalette.length],
                width: 20,
                borderRadius: BorderRadius.circular(6),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: categories.values
                      .reduce((a, b) => a > b ? a : b)
                      .toDouble(),
                  color: AppColors.background.withOpacity(0.3),
                ),
              ),
            ],
            showingTooltipIndicators: [0],
          ),
        );
      }
      index++;
    });

    return Card(
      color: AppColors.background,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: AppColors.hintText, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              barGroups: barGroups,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, _) {
                      if (value.toInt() >= categories.keys.length) {
                        return Container();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          categories.keys.elementAt(value.toInt()),
                          style: GoogleFonts.lora(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.headingText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                    reservedSize: 40, // Space reserved for bottom titles
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40, // Space reserved for left titles
                    interval: 1, // Interval between labels
                    getTitlesWidget: (double value, _) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          value.toInt().toString(),
                          style: GoogleFonts.lora(
                            fontSize: 12, // Increased font size
                            fontWeight: FontWeight.bold,
                            color: AppColors.headingText,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.enabledBorder.withOpacity(0.2),
                    strokeWidth: 2,
                  );
                },
              ),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      "${rod.toY.toInt()}",
                      GoogleFonts.lora(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
