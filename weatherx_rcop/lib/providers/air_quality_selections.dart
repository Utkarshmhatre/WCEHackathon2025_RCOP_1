import 'package:flutter/foundation.dart';

class AirQualitySelections extends ChangeNotifier {
  String _selectedPollutant = 'PM2.5';
  String _timeFrame = 'Daily';
  bool _showForecast = true;
  bool _showHistorical = false;

  // Added to track which view is active
  String _activeView = 'chart'; // options: 'chart', 'historical', 'forecast'

  String get selectedPollutant => _selectedPollutant;
  String get timeFrame => _timeFrame;
  bool get showForecast => _showForecast;
  bool get showHistorical => _showHistorical;
  String get activeView => _activeView;

  final List<String> pollutants = ['PM2.5', 'PM10', 'O₃', 'NO₂', 'SO₂', 'CO'];
  final List<String> timeFrames = ['Daily', 'Weekly', 'Monthly'];

  void updatePollutant(String pollutant) {
    _selectedPollutant = pollutant;
    notifyListeners();
  }

  void updateTimeFrame(String timeFrame) {
    _timeFrame = timeFrame;
    notifyListeners();
  }

  void toggleForecast(bool value) {
    _showForecast = value;
    if (value) {
      _activeView = 'forecast';
    } else if (!_showHistorical) {
      _activeView = 'chart';
    }
    notifyListeners();
  }

  void toggleHistorical(bool value) {
    _showHistorical = value;
    if (value) {
      _activeView = 'historical';
    } else if (!_showForecast) {
      _activeView = 'chart';
    }
    notifyListeners();
  }

  void setActiveView(String view) {
    _activeView = view;

    // Update toggle states based on active view
    if (view == 'historical') {
      _showHistorical = true;
      _showForecast = false;
    } else if (view == 'forecast') {
      _showForecast = true;
      _showHistorical = false;
    } else {
      // For chart view or any other
      _showForecast = false;
      _showHistorical = false;
    }

    notifyListeners();
  }
}
