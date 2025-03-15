import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'utils/webview_utils.dart';

class WeatherMap extends StatefulWidget {
  const WeatherMap({super.key});

  @override
  State<WeatherMap> createState() => _WeatherMapState();
}

class _WeatherMapState extends State<WeatherMap>
    with SingleTickerProviderStateMixin {
  late final WebViewController _controller;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadMap();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _loadMap() {
    setState(() {
      _isLoading = true;
      _fadeController.reset();
    });

    // Base URL for MSN Weather map - using temperature as default
    String url =
        'https://www.msn.com/en-in/weather/maps/temperature/in-India?weadegreetype=C&zoom=6';

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.transparent)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                if (progress == 100 && _isLoading) {
                  setState(() => _isLoading = false);
                  _fadeController.forward();
                }
              },
              onPageStarted: (_) {
                setState(() => _isLoading = true);
                _fadeController.reset();
              },
              onPageFinished: (_) {
                _injectCustomStyles();
                setState(() => _isLoading = false);
                _fadeController.forward();
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('WebView error: ${error.description}');
              },
            ),
          )
          ..enableZoom(true)
          ..loadRequest(Uri.parse(url));
  }

  Future<void> _injectCustomStyles() async {
    // Optimize the webview for mobile and remove ads or unnecessary elements
    const String optimizeScript = '''
      // ...existing code...
    ''';

    await _controller.runJavaScript(optimizeScript);
    await WebViewUtils.injectAdBlocker(_controller);
  }

  void _searchLocation(String query) {
    if (query.isEmpty) return;

    final encodedQuery = Uri.encodeComponent(query);
    final url =
        'https://www.msn.com/en-in/weather/maps/temperature/in-$encodedQuery?weadegreetype=C&zoom=8';

    _controller.loadRequest(Uri.parse(url));
    setState(() {
      _isSearchExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background for consistency
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    isDarkMode
                        ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                        : [const Color(0xFF87CEEB), const Color(0xFF1E90FF)],
              ),
            ),
          ),

          // WebView for map with fade animation
          FadeTransition(
            opacity: _fadeController,
            child: Positioned.fill(
              child: WebViewWidget(controller: _controller),
            ),
          ),

          // Loading indicator with consistent style
          if (_isLoading)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors:
                      isDarkMode
                          ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                          : [const Color(0xFF87CEEB), const Color(0xFF1E90FF)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading Weather Map...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Top search bar with redesigned look
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title text when search is collapsed
                  if (!_isSearchExpanded)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 12),
                      child: Text(
                        'Weather Map',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? Colors.black.withOpacity(0.5)
                                : Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 56),
                          if (_isSearchExpanded)
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search for a location...',
                                  hintStyle: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: _searchLocation,
                              ),
                            )
                          else
                            Expanded(
                              child: Text(
                                'Search locations...',
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
                              ),
                            ),
                          Material(
                            color: Colors.transparent,
                            shape: CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: IconButton(
                              icon: Icon(
                                _isSearchExpanded ? Icons.send : Icons.search,
                                color: isDarkMode ? Colors.white : Colors.blue,
                              ),
                              onPressed: () {
                                if (_isSearchExpanded) {
                                  _searchLocation(_searchController.text);
                                } else {
                                  setState(() {
                                    _isSearchExpanded = true;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Back button for search
          if (_isSearchExpanded)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode ? Colors.black38 : Colors.white70,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDarkMode ? Colors.white : Colors.blue,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearchExpanded = false;
                        _searchController.clear();
                      });
                    },
                  ),
                ),
              ),
            ),

          // Bottom refresh button with consistent design
          Positioned(
            bottom: 24,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                heroTag: "weatherMapRefresh",
                backgroundColor:
                    isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
                elevation: 0,
                tooltip: 'Refresh Map',
                onPressed: () => _controller.reload(),
                child: Icon(
                  Icons.refresh_rounded,
                  color: isDarkMode ? Colors.white : Colors.blue,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
