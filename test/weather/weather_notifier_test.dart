import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_training/data/weather.dart';
import 'package:flutter_training/weather/use_case/get_weather.dart';
import 'package:flutter_training/weather/weather_screen.dart';

import '../util/create_container.dart';

void main() {
  group('Test WeatherNotifier State', () {
    test('初回の reload で取得成功: null -> Weather', () {
      final date = DateTime(2024, 4);
      final result = Weather(
        condition: WeatherCondition.cloudy,
        maxTemperature: 25,
        minTemperature: 7,
        date: date,
      );
      final container = createContainer(
        overrides: [
          getWeatherProvider.overrideWith((ref) => ({required area}) => result),
        ],
      );
      final initialState = container.read(weatherNotifierProvider);
      expect(initialState, null);

      // Act
      container.read(weatherNotifierProvider.notifier).update(area: 'tokyo');

      // Assert
      final weather = container.read(weatherNotifierProvider);
      expect(weather, result);
    });

    test('成功 → 成功で状態が変わる', () {
      // Arrange
      final date = DateTime(2024, 4);
      final result = Weather(
        condition: WeatherCondition.cloudy,
        maxTemperature: 25,
        minTemperature: 7,
        date: date,
      );
      final results = [
        result,
        result.copyWith(maxTemperature: 100),
      ];

      final container = createContainer(
        overrides: [
          getWeatherProvider.overrideWith((ref) {
            return ({required area}) => results.removeAt(0);
          }),
        ],
      );

      // Act & Assert
      final initialState = container.read(weatherNotifierProvider);
      expect(initialState, null); // 初期状態は null

      container.read(weatherNotifierProvider.notifier).update(area: 'tokyo');

      final weather = container.read(weatherNotifierProvider);
      expect(weather, result); // 成功して状態が変わる

      container.read(weatherNotifierProvider.notifier).update(area: 'tokyo');
      final weather2 = container.read(weatherNotifierProvider);
      final expected2 = result.copyWith(maxTemperature: 100);
      expect(weather2, expected2); // 状態は変わっていない
    });

    test('成功 → 失敗で状態がそのまま', () {
      // Arrange
      final date = DateTime(2024, 4);
      final result = Weather(
        condition: WeatherCondition.cloudy,
        maxTemperature: 25,
        minTemperature: 7,
        date: date,
      );
      final results = [
        () => result,
        () => throw const UnknownException(),
      ];

      final container = createContainer(
        overrides: [
          getWeatherProvider.overrideWith((ref) {
            return ({required area}) => results.removeAt(0).call();
          }),
        ],
      );

      // Act & Assert
      final initialState = container.read(weatherNotifierProvider);
      expect(initialState, null); // 初期状態は null

      container.read(weatherNotifierProvider.notifier).update(area: 'tokyo');

      final weather = container.read(weatherNotifierProvider);
      expect(weather, result); // 成功して状態が変わる

      expect(
        () => container
            .read(weatherNotifierProvider.notifier)
            .update(area: 'tokyo'),
        throwsA(isA<UnknownException>()),
      );
      final weather2 = container.read(weatherNotifierProvider);
      expect(weather2, result); // 状態は変わっていない
    });
  });
}