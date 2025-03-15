import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A utility class to help with common WebView operations
class WebViewUtils {
  /// Injects JavaScript to block common ad elements
  static Future<void> injectAdBlocker(WebViewController controller) async {
    const String adBlockerScript = '''
      (function() {
        // Common ad selectors
        const adSelectors = [
          '.adsbygoogle', 
          'ins[class*="adsbygoogle"]', 
          'div[class*="ad-"]', 
          'div[id*="ad-"]',
          'div[class*="ads-"]',
          'div[id*="ads-"]',
          'iframe[src*="googleadservices"]',
          'iframe[src*="doubleclick"]',
          '.adsbox',
          '#banner-ad',
          '.google-ad',
          '.advertisement',
          '.heading-ad',
          '.sponsorship',
          '[id*="taboola"]',
          '[class*="taboola"]'
        ];
        
        // Hide ad elements
        adSelectors.forEach(selector => {
          document.querySelectorAll(selector).forEach(el => {
            el.style.display = 'none';
          });
        });
        
        // Remove cookie notices and overlays
        const overlaySelectors = [
          '[class*="cookie"]',
          '[id*="cookie"]',
          '[class*="consent"]',
          '[class*="popup"]',
          '.overlay',
          '#overlay'
        ];
        
        overlaySelectors.forEach(selector => {
          document.querySelectorAll(selector).forEach(el => {
            el.style.display = 'none';
          });
        });
      })();
    ''';

    await controller.runJavaScript(adBlockerScript);
  }

  /// Optimizes the page for mobile viewing
  static Future<void> optimizeForMobile(WebViewController controller) async {
    const String optimizeScript = '''
      (function() {
        // Set viewport for mobile
        const metaViewport = document.querySelector('meta[name="viewport"]');
        if (!metaViewport) {
          const meta = document.createElement('meta');
          meta.name = 'viewport';
          meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=3.0, user-scalable=yes';
          document.getElementsByTagName('head')[0].appendChild(meta);
        } else {
          metaViewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=3.0, user-scalable=yes';
        }
        
        // Fix iframe sizing issues
        document.querySelectorAll('iframe').forEach(frame => {
          if (frame.width === '100%' && !frame.style.height) {
            frame.style.height = 'auto';
          }
        });
      })();
    ''';

    await controller.runJavaScript(optimizeScript);
  }

  /// Attempts to locate and click on zoom controls
  static Future<void> zoomIn(WebViewController controller) async {
    const String zoomScript = '''
      (function() {
        // Try various zoom controls
        const zoomSelectors = [
          '.zoomin',
          '[aria-label="Zoom in"]',
          '[title="Zoom in"]',
          '.leaflet-control-zoom-in',
          '[data-action="zoomIn"]'
        ];
        
        for (const selector of zoomSelectors) {
          const element = document.querySelector(selector);
          if (element) {
            element.click();
            return;
          }
        }
      })();
    ''';

    await controller.runJavaScript(zoomScript);
  }

  /// Attempts to locate and click on zoom out controls
  static Future<void> zoomOut(WebViewController controller) async {
    const String zoomScript = '''
      (function() {
        // Try various zoom controls
        const zoomSelectors = [
          '.zoomout',
          '[aria-label="Zoom out"]',
          '[title="Zoom out"]',
          '.leaflet-control-zoom-out',
          '[data-action="zoomOut"]'
        ];
        
        for (const selector of zoomSelectors) {
          const element = document.querySelector(selector);
          if (element) {
            element.click();
            return;
          }
        }
      })();
    ''';

    await controller.runJavaScript(zoomScript);
  }
}
