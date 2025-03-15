# WeatherX App

A comprehensive weather application with dynamic UI, real-time forecasting, air quality monitoring, and interactive weather maps.

## Features

### Weather Forecast Screen
- Current location weather with automatic detection
- City search with autocomplete suggestions API
- Real-time temperature display with condition-appropriate animations
- Dynamic background gradients that adapt to weather conditions and temperature ranges
- Detailed metrics: temperature, humidity, wind speed, pressure, feels like
- Lottie animations that match current weather conditions
- Error handling with visual feedback

### Air Quality Monitoring
- Current Air Quality Index (AQI) with color coding by health risk
- Individual pollutants breakdown (PM2.5, PM10, NO2, SO2, O3, CO)
- Air quality forecasts and historical data
- Multiple visualization options

### Weather Map Screen
- Interactive MSN Weather map integration
- Location search functionality for specific areas
- Temperature map visualization
- Map zooming and panning capabilities
- Custom ad blocking for better user experience
- Smooth loading transitions

### Weather Stations
- Browse data from multiple weather monitoring stations
- Station details including location coordinates
- Current conditions at each station
- Pagination with "Load More" functionality

## Tech Stack

- **Framework**: Flutter/Dart
- **State Management**: Provider pattern
- **UI Rendering**: Custom animations, glassmorphic effects, dynamic theming
- **Data Visualization**: FL Chart library for air quality metrics
- **Web Content**: WebView for map integration
- **Asset Animation**: Lottie for weather animations

## API Integration

- **OpenWeatherMap Weather API**: Current weather and forecasts
- **OpenWeatherMap Air Pollution API**: Air quality data and pollutants
- **OpenWeatherMap Geocoding API**: Location services and city suggestions
- **MSN Weather Maps**: Interactive weather visualization

## UI/UX Features

- Complete dark and light mode support with persistent settings
- Dynamic color schemes that adapt to weather conditions
- Glassmorphic UI with backdrop blur filters
- Responsive design that adapts to different screen sizes
- Loading states and smooth transitions between data states
- Temperature-sensitive color coding (cold blues to hot reds)
- Weather-appropriate iconography and animations

## Setup Instructions

1. Clone the repository
2. Make sure you have Flutter installed
3. Run `flutter pub get` to install dependencies
4. Get an API key from [OpenWeatherMap](https://openweathermap.org/api)
5. Add your API key in the appropriate services files
6. Run the app with `flutter run`

## Dependencies

```yaml
http: ^1.3.0         # API requests
geolocator: ^13.0.2  # Location services
geocoding: ^3.0.0    # Geographic location handling
lottie: ^3.3.1       # Weather animations
intl: ^0.20.2        # Date/time formatting
provider: ^6.1.2     # State management
webview_flutter: ^4.4.2  # Map embeddings
fl_chart: ^0.65.0    # Data visualization
```

## License

This project is open-source and available under the MIT License.
