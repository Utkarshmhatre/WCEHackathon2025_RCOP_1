import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'weather_forecast_screen.dart';
import 'air_quality_screen.dart';
import 'weather_stations_screen.dart';
import 'theme_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  final List<Widget> _screens = [
    WeatherForecastScreen(),
    AirQualityScreen(),
    WeatherStationsScreen(),
  ];

  final List<String> _titles = [
    "Weather Forecast",
    "Air Quality",
    "Weather Stations",
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fabAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _fabAnimationController.reset();
    _fabAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final bgColor = isDarkMode ? Color(0xFF1A1A2E) : Color(0xFF87CEEB);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Content Area with PageView
          Positioned.fill(
            top:
                MediaQuery.of(context).padding.top +
                80, // Account for custom app bar
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: _screens,
              physics: BouncingScrollPhysics(),
            ),
          ),

          // Custom App Bar - Floating at top
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: _buildAppBar(isDarkMode, themeProvider),
          ),

          // Custom Navigation Bar - Floating at bottom
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildModernNavigation(isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDarkMode, ThemeProvider themeProvider) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wb_sunny_outlined,
                  color: isDarkMode ? Colors.white : Colors.blue,
                  size: 22,
                ),
              ),
              SizedBox(width: 12),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _titles[_currentIndex],
                  key: ValueKey<String>(_titles[_currentIndex]),
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return RotationTransition(
                    turns: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey(isDarkMode),
                  color: isDarkMode ? Colors.white : Colors.blue,
                  size: 22,
                ),
              ),
              onPressed: () {
                HapticFeedback.mediumImpact();
                themeProvider.toggleTheme();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernNavigation(bool isDarkMode) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(
          color:
              isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.8),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCustomNavItem(
            0,
            Icons.cloud_outlined,
            Icons.cloud,
            "Weather",
            isDarkMode,
          ),
          _buildCustomNavItem(
            1,
            Icons.air_outlined,
            Icons.air,
            "Air Quality",
            isDarkMode,
          ),
          _buildCustomNavItem(
            2,
            Icons.api_outlined,
            Icons.api,
            "Stations",
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomNavItem(
    int index,
    IconData iconOutlined,
    IconData iconFilled,
    String label,
    bool isDarkMode,
  ) {
    bool isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color:
                isSelected
                    ? (isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: 4,
                width: isSelected ? 24 : 0,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? (isDarkMode ? Colors.white : Colors.blue)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 4),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Icon(
                  isSelected ? iconFilled : iconOutlined,
                  key: ValueKey(isSelected),
                  color:
                      isSelected
                          ? (isDarkMode ? Colors.white : Colors.blue)
                          : (isDarkMode ? Colors.white60 : Colors.black54),
                  size: 24,
                ),
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color:
                      isSelected
                          ? (isDarkMode ? Colors.white : Colors.blue)
                          : (isDarkMode ? Colors.white60 : Colors.black54),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
