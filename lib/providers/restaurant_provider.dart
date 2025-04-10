import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';
import 'dart:math' show min;

class Restaurant {
  final String id;
  final String name;
  final String access;
  final String address;
  final String openTime;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String tel;

  Restaurant({
    required this.id,
    required this.name,
    required this.access,
    required this.address,
    required this.openTime,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.tel,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    String imageUrl = '';
    try {
      final photo = json['photo'];
      if (photo is Map<String, dynamic>) {
        final pc = photo['pc'];
        if (pc is Map<String, dynamic>) {
          imageUrl = pc['l']?.toString() ?? '';
        }
      }
    } catch (e) {
      print('画像URL取得エラー: $e');
      imageUrl = '';
    }

    double lat = 0.0;
    double lng = 0.0;
    try {
      final latStr = json['lat']?.toString();
      final lngStr = json['lng']?.toString();
      if (latStr != null) lat = double.tryParse(latStr) ?? 0.0;
      if (lngStr != null) lng = double.tryParse(lngStr) ?? 0.0;
    } catch (e) {
      print('緯度経度取得エラー: $e');
    }

    return Restaurant(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      access: json['access']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      openTime: json['open']?.toString() ?? '',
      imageUrl: imageUrl,
      latitude: lat,
      longitude: lng,
      tel: json['tel']?.toString() ?? '',
    );
  }
}

class RestaurantProvider with ChangeNotifier {
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String _error = '';
  final Dio _dio = Dio();

  RestaurantProvider() {
    if (!kIsWeb && kDebugMode && Platform.isAndroid) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter)
          .onHttpClientCreate = (client) {
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );

      _dio.interceptors.add(
        InterceptorsWrapper(
          onError: (DioException e, ErrorInterceptorHandler handler) {
            print('Dioエラーインターセプター: ${e.type} - ${e.message}');
            return handler.next(e);
          },
        ),
      );
    }
  }

  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> searchRestaurants({
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    if (kIsWeb) {
      _error = 'ウェブブラウザでは直接APIアクセスできません。AndroidかiOSアプリで利用してください。';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      const apiKey = '2b8ccdc9ab7af127';
      final url = 'https://webservice.recruit.co.jp/hotpepper/gourmet/v1/';
      print('リクエスト先URL: $url');

      int rangeValue;
      if (radius <= 300) {
        rangeValue = 1;
      } else if (radius <= 500) {
        rangeValue = 2;
      } else if (radius <= 1000) {
        rangeValue = 3;
      } else if (radius <= 2000) {
        rangeValue = 4;
      } else {
        rangeValue = 5;
      }

      final queryParameters = {
        'key': apiKey,
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'range': rangeValue.toString(),
        'format': 'json',
        'count': '100',
      };

      if (kDebugMode) {
        print('クエリパラメータ: $queryParameters');
        print('検索半径: $radius メートル → API range値: $rangeValue');
      }

      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(
          headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          responseType: ResponseType.plain,
        ),
      );

      print('レスポンスステータス: ${response.statusCode}');

      if (kDebugMode) {
        print('レスポンスタイプ: ${response.data.runtimeType}');

        if (response.data is Map) {
          print('Mapとして受信: ${response.data.keys}');
        } else if (response.data is String) {
          print(
            '文字列として受信（先頭100文字）: ${response.data.substring(0, min(100, (response.data as String).length))}',
          );
        } else if (response.data is List) {
          print('リストとして受信（長さ）: ${(response.data as List).length}');
        } else {
          print('その他の型として受信: ${response.data}');
        }
      }

      if (response.data != null) {
        try {
          final jsonData = _safeJsonDecode(response.data);

          if (_hasValidResults(jsonData)) {
            final shopData = jsonData['results']['shop'];

            if (shopData is List && shopData.isNotEmpty) {
              try {
                _restaurants =
                    shopData
                        .map(
                          (shop) =>
                              Restaurant.fromJson(shop as Map<String, dynamic>),
                        )
                        .toList();
                print('検索結果: ${_restaurants.length}件のレストランが見つかりました');
              } catch (e) {
                _error = 'レストランデータの変換に失敗しました: $e';
                print('変換エラー: $e');

                if (kDebugMode && shopData.isNotEmpty) {
                  print('最初の店舗データサンプル:');
                  print(shopData.first);
                }
              }
            } else {
              _error = '検索結果が0件でした';
              print('shop データがリストではないか空です: $shopData');
            }
          } else {
            _error = 'APIレスポンスの形式が予期しないものでした';
            if (kDebugMode) {
              print('無効なデータ構造: $jsonData');
            }
          }
        } catch (e) {
          _error = 'データの解析に失敗しました: $e';
          if (kDebugMode) {
            print('解析エラー: $e');
            print(
              '受信データ: ${response.data is String ? response.data.substring(0, min(200, (response.data as String).length)) : response.data}',
            );
          }
        }
      } else {
        _error = 'レスポンスデータが空です';
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        _error = 'リクエストがタイムアウトしました: ${e.message}';
      } else if (e.type == DioExceptionType.badResponse) {
        _error =
            '不正なレスポンス: ${e.response?.statusCode} - ${e.response?.statusMessage}';
      } else {
        _error = 'ネットワークエラーが発生しました: ${e.message}';

        if (kDebugMode) {
          print('エラータイプ: ${e.type}');
          print('エラーメッセージ: ${e.message}');
          print('エラースタック: ${e.stackTrace}');
          print('リクエストオプション: ${e.requestOptions.toString()}');
          if (e.response != null) {
            print('レスポンス: ${e.response.toString()}');
          }
        }
      }
    } catch (e) {
      _error = 'エラーが発生しました: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  dynamic _safeJsonDecode(dynamic data) {
    if (data == null) return null;

    try {
      if (data is String) {
        return json.decode(data);
      }
      return data;
    } catch (e) {
      print('JSONパースエラー: $e');
      return null;
    }
  }

  bool _hasValidResults(dynamic data) {
    try {
      if (data == null) {
        print('データがnullです');
        return false;
      }

      if (!(data is Map)) {
        print('データがMap型ではありません: ${data.runtimeType}');
        return false;
      }

      if (!data.containsKey('results')) {
        print("データに'results'キーがありません");
        return false;
      }

      final results = data['results'];

      if (!(results is Map)) {
        print("'results'がMap型ではありません: ${results.runtimeType}");
        return false;
      }
      if (!results.containsKey('shop')) {
        print("'results'に'shop'キーがありません");
        return false;
      }
      return true;
    } catch (e) {
      print('データ構造確認エラー: $e');
      return false;
    }
  }
}
