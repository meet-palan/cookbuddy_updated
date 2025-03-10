import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cookbuddy/database/database_helper.dart';
import 'package:cookbuddy/screens/admin/recipe_management_screen.dart';
import 'package:cookbuddy/screens/admin/user_management_screen.dart';
import 'package:cookbuddy/screens/admin/category_management_screen.dart';
import 'package:cookbuddy/screens/general/get_started_screen.dart';
import 'package:iconly/iconly.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _animationCompleted = false;

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
      final userCountResult = await db.rawQuery('SELECT COUNT(*) AS total FROM Users');
      final recipesCount = await db.rawQuery('SELECT COUNT(*) AS total FROM Recipes');
      final commentsCount = await db.rawQuery(
          'SELECT COUNT(*) AS total FROM CommentAndRating WHERE comment IS NOT NULL');
      final feedbackCount = await db.rawQuery('SELECT COUNT(*) AS total FROM CommentAndRating');
      final creditsSum = await db.rawQuery('SELECT SUM(credits) AS total FROM Transactions');
      final purchasesCount = await db.rawQuery('SELECT COUNT(*) AS total FROM Transactions');
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
        backgroundColor: Colors.orangeAccent,
        automaticallyImplyLeading: false,
        title: const Text("Admin Dashboard", style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                _logOut(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Log Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
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
                const Text(
                  "Key Statistics",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard("Total Users", data["totalUsers"].toString(), Colors.blue),
                    _buildStatCard("Total Recipes", data["totalRecipes"].toString(), Colors.green),
                    _buildStatCard("Total Comments", data["totalComments"].toString(), Colors.orange),
                    _buildStatCard("Total Feedback", data["totalFeedback"].toString(), Colors.purple),
                    _buildStatCard("Total Credits", data["totalCredits"].toString(), Colors.teal),
                    _buildStatCard("Total Purchases", data["totalPurchases"].toString(), Colors.red),
                  ],
                ),
                const SizedBox(height: 16),
                _buildKeyStatisticsPieChart(data),
                const SizedBox(height: 32),
                const Text(
                  "Top Categories",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 70),
                _buildCategoryBarChart(data["topCategories"]),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CrystalNavigationBar(
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.black,
          backgroundColor: Colors.black.withOpacity(0.1),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecipeManagementScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryManagementScreen()),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserManagementScreen()),
              );
            }
          },
          items: [
            /// Home
            CrystalNavigationBarItem(
              icon: IconlyBold.home,
              unselectedIcon: IconlyLight.home,
              selectedColor: Colors.orangeAccent,
            ),

            /// Recipes Mgmt
            CrystalNavigationBarItem(
              icon: IconlyBold.paper,
              unselectedIcon: IconlyLight.paper,
              selectedColor: Colors.orangeAccent,
            ),

            /// Categories Sell
            CrystalNavigationBarItem(
              icon: IconlyBold.category,
              unselectedIcon: IconlyLight.category,
              selectedColor: Colors.orangeAccent,
            ),

            /// User mgmt
            CrystalNavigationBarItem(
                icon: IconlyBold.user_2,
                unselectedIcon: IconlyLight.user_1,
                selectedColor: Colors.orangeAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
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
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 300,
          child: _animationCompleted
              ? PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
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
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PieChartSectionData _createPieChartSection(int value, String title, Color color) {
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: title,
      radius: 100,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      badgeWidget: Text(
        '$value',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      badgePositionPercentageOffset: 0.8,
    );
  }

  Widget _buildCategoryBarChart(Map<String, int> categories) {
    List<BarChartGroupData> barGroups = [];
    final colorPalette = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    int index = 0;
    categories.forEach((category, count) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: colorPalette[index % colorPalette.length],
              width: 16,
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
      index++;
    });

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 250,
          child: _animationCompleted
              ? BarChart(
            BarChartData(
              barGroups: barGroups,
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, _) {
                      final style = TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      );
                      return Text(
                        categories.keys.toList()[value.toInt()],
                        style: style,
                      );
                    },
                    reservedSize: 38,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          )
              : AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_animation.value * 0.1),
                child: Opacity(
                  opacity: _animation.value,
                  child: BarChart(
                    BarChartData(
                      barGroups: barGroups,
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, _) {
                              final style = TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              );
                              return Text(
                                categories.keys.toList()[value.toInt()],
                                style: style,
                              );
                            },
                            reservedSize: 38,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                          ),
                        ),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}





/*
import 'package:cookbuddy/screens/admin/category_management_screen.dart';
import 'package:cookbuddy/screens/admin/recipe_management_screen.dart';
import 'package:cookbuddy/screens/admin/user_management_screen.dart';
import 'package:cookbuddy/screens/general/get_started_screen.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cookbuddy/database/database_helper.dart';
import 'package:iconly/iconly.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  int _selectedIndex = 0;

  // Stream for real-time updates
  Stream<Map<String, dynamic>> getStatisticsStream() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 2)); // Poll every 2 seconds
      yield await _fetchStatistics();
    }
  }

  Future<Map<String, dynamic>> _fetchStatistics() async {
    try {
      final db = await _dbHelper.database;

      final userCountResult = await db.rawQuery('SELECT COUNT(*) AS total FROM Users');
      final recipesCount = await db.rawQuery('SELECT COUNT(*) AS total FROM Recipes');
      final commentsCount = await db.rawQuery(
          'SELECT COUNT(*) AS total FROM CommentAndRating WHERE comment IS NOT NULL');
      final feedbackCount = await db.rawQuery('SELECT COUNT(*) AS total FROM CommentAndRating');
      final creditsSum = await db.rawQuery('SELECT SUM(credits) AS total FROM Transactions');
      final purchasesCount = await db.rawQuery('SELECT COUNT(*) AS total FROM Transactions');
      final categoriesResult = await db.rawQuery(
          'SELECT Categories.name, COUNT(Recipes.categoryId) AS count FROM Recipes '
              'JOIN Categories ON Recipes.categoryId = Categories.id '
              'GROUP BY Recipes.categoryId ORDER BY count DESC LIMIT 5');

      final totalActivities = (userCountResult.first['total'] as int) +
          (recipesCount.first['total'] as int) +
          (commentsCount.first['total'] as int) +
          (feedbackCount.first['total'] as int);

      return {
        "totalUsers": userCountResult.first['total'] as int,
        "totalRecipes": recipesCount.first['total'] as int,
        "totalComments": commentsCount.first['total'] as int,
        "totalFeedback": feedbackCount.first['total'] as int,
        "totalCredits": (creditsSum.first['total'] ?? 0) as int,
        "totalPurchases": purchasesCount.first['total'] as int,
        "totalActivities": totalActivities,
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
        backgroundColor: Colors.orangeAccent,
        automaticallyImplyLeading: false,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                _logOut(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Log Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<Map<String, dynamic>>(
        stream: getStatisticsStream(),
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
                const SizedBox(height: 16),
                _buildPieChart(data),
                const SizedBox(height: 32),
                _buildBarChart(data),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CrystalNavigationBar(
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.black,
          backgroundColor: Colors.black.withOpacity(0.1),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecipeManagementScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryManagementScreen()),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserManagementScreen()),
              );
            }
          },
          items: [
            CrystalNavigationBarItem(
              icon: IconlyBold.home,
              unselectedIcon: IconlyLight.home,
              selectedColor: Colors.orangeAccent,
            ),
            CrystalNavigationBarItem(
              icon: IconlyBold.paper,
              unselectedIcon: IconlyLight.paper,
              selectedColor: Colors.orangeAccent,
            ),
            CrystalNavigationBarItem(
              icon: IconlyBold.category,
              unselectedIcon: IconlyLight.category,
              selectedColor: Colors.orangeAccent,
            ),
            CrystalNavigationBarItem(
              icon: IconlyBold.user_2,
              unselectedIcon: IconlyLight.user_1,
              selectedColor: Colors.orangeAccent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, dynamic> data) {
    final totalActivities = data["totalActivities"];
    final pieSections = [
      PieChartSectionData(
        value: data["totalUsers"] / totalActivities * 100,
        title: "Users: ${(data["totalUsers"] / totalActivities * 100).toStringAsFixed(1)}%",
        color: Colors.blue,
      ),
      PieChartSectionData(
        value: data["totalRecipes"] / totalActivities * 100,
        title: "Recipes: ${(data["totalRecipes"] / totalActivities * 100).toStringAsFixed(1)}%",
        color: Colors.green,
      ),
      PieChartSectionData(
        value: data["totalComments"] / totalActivities * 100,
        title: "Comments: ${(data["totalComments"] / totalActivities * 100).toStringAsFixed(1)}%",
        color: Colors.orange,
      ),
      PieChartSectionData(
        value: data["totalFeedback"] / totalActivities * 100,
        title: "Feedback: ${(data["totalFeedback"] / totalActivities * 100).toStringAsFixed(1)}%",
        color: Colors.purple,
      ),
    ];

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pie Chart Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: pieSections,
                  centerSpaceRadius: 50,
                  sectionsSpace: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, dynamic> data) {
    final topCategories = data["topCategories"] as Map<String, int>?;
    if (topCategories == null || topCategories.isEmpty) {
      return const Center(child: Text("No categories available"));
    }

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
    ];

    final barGroups = topCategories.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value.key;
      final count = entry.value.value;

      return BarChartGroupData(
        x: category.hashCode,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            width: 20,
            color: colors[index % colors.length], // Use different colors
          ),
        ],
      );
    }).toList();

    Widget _buildStatCard(String title, String value, Color color) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Top Categories Bar Chart",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  groupsSpace: 10,
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final categoryName = topCategories.keys.firstWhere(
                                (key) => key.hashCode == value.toInt(),
                            orElse: () => '',
                          );
                          return Text(
                            categoryName,
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
