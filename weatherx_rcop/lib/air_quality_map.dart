import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'utils/webview_utils.dart';

class AirQualityMap extends StatefulWidget {
  const AirQualityMap({super.key});

  @override
  State<AirQualityMap> createState() => _AirQualityMapState();
}

class _AirQualityMapState extends State<AirQualityMap>
    with SingleTickerProviderStateMixin {
  late WebViewController _webViewController;
  bool _isLoading = true;
  final String _mapUrl = 'https://atmos.urbansciences.in/atmos/maps';
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initWebView();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _initWebView() {
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.black)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                if (progress >= 70 && _isLoading) {
                  setState(() => _isLoading = false);
                  _fadeController.forward();
                }
              },
              onPageStarted: (_) {
                setState(() => _isLoading = true);
                _fadeController.reset();
              },
              onPageFinished: (_) {
                _injectOptimizations();
                setState(() => _isLoading = false);
                _fadeController.forward();
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('WebView error: ${error.description}');
              },
            ),
          )
          ..enableZoom(true)
          ..loadRequest(Uri.parse(_mapUrl));
  }

  Future<void> _injectOptimizations() async {
    const String script = '''
      (function() {
        // Critical fixes only
        document.body.style.margin = '0';
        document.body.style.padding = '0';
        document.body.style.height = '100vh';
        document.body.style.width = '100vw';
        document.documentElement.style.height = '100vh';
        document.documentElement.style.width = '100vw';
        document.documentElement.style.overflow = 'hidden';
        
        // Find and fix the map container
        const mapElements = [
          '#mapContainer',
          '#map',
          '.leaflet-container',
          '.map-container'
        ];
        
        for (const selector of mapElements) {
          const map = document.querySelector(selector);
          if (map) {
            map.style.position = 'fixed';
            map.style.top = '0';
            map.style.left = '0';
            map.style.width = '100vw';
            map.style.height = '100vh';
            map.style.zIndex = '1';
            
            // Fix parent containers
            let parent = map.parentElement;
            while (parent && parent !== document.body) {
              parent.style.width = '100%';
              parent.style.height = '100%';
              parent.style.margin = '0';
              parent.style.padding = '0';
              parent = parent.parentElement;
            }
            break;
          }
        }
        
        // Hide non-essential elements
        const elementsToHide = ['header', 'footer', '.nav', '.banner'];
        elementsToHide.forEach(selector => {
          document.querySelectorAll(selector).forEach(el => {
            el.style.display = 'none';
          });
        });
      })();
    ''';

    await _webViewController.runJavaScript(script);
    await WebViewUtils.injectAdBlocker(_webViewController);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF0A0A1B) : const Color(0xFF87CEEB),
      body: Stack(
        children: [
          // Gradient background for consistent look
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

          // WebView for map (full screen with fade animation)
          FadeTransition(
            opacity: _fadeController,
            child: Positioned.fill(
              child: WebViewWidget(controller: _webViewController),
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
                        color: isDarkMode ? Colors.white : Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading AQI Map...',
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

          // Styled refresh button
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
                heroTag: "aqiMapRefresh",
                backgroundColor:
                    isDarkMode ? const Color(0xFF1A1A2E) : Colors.white,
                elevation: 0,
                tooltip: 'Refresh Map',
                onPressed: () {
                  _webViewController.reload();
                  setState(() => _isLoading = true);
                  _fadeController.reset();
                },
                child: Icon(
                  Icons.refresh_rounded,
                  color: isDarkMode ? Colors.white : Colors.blue,
                  size: 28,
                ),
              ),
            ),
          ),

          // Title label for consistency
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 24),
              child: Text(
                'Air Quality Map',
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
          ),
        ],
      ),
    );
  }
}
