# グルメサーチアプリ

現在地周辺のレストランを簡単に検索できるFlutterアプリケーションです。ホットペッパーグルメAPIを使用して、周辺の飲食店情報を取得し表示します。

## 作者

三島　龍

## コンセプト

食べに行きたいお店がすぐに見つかる、シンプルで使いやすいレストラン検索アプリ。

## 機能

- 現在地を取得し、周辺のレストランを検索
- 検索半径のカスタマイズ（500m〜5000m）
- レストラン情報の一覧表示と詳細表示
- レストランへの電話発信機能
- 地図アプリ連携機能
- Google Mapsによる位置表示

## 使い方

1. アプリを起動すると、位置情報の許可を求められます
2. 許可後、現在地を中心とした検索が可能になります
3. スライダーで検索半径を調整し、「検索」ボタンをタップ
4. 検索結果一覧から気になるお店をタップすると詳細情報が表示されます
5. 詳細画面から電話をかけたり、地図アプリで場所を確認できます

## 開発環境

- Flutter 3.10.0
- Dart 3.0.0
- Android Studio / VS Code

## 動作対象

- iOS 11.0以上
- Android 5.0以上

## 使用ライブラリ

- provider (状態管理)
- dio (HTTP通信)
- geolocator (位置情報取得)
- google_maps_flutter (地図表示)
- url_launcher (電話・地図アプリ連携)
- cached_network_image (画像キャッシュ処理)

## セットアップ

```bash
# リポジトリのクローン
git clone https://github.com/Mishimaxx/fenrir_restaurant_search.git

# 依存関係のインストール
flutter pub get

# アプリケーションの実行
flutter run
```

## 開発期間

7日間

## 仕様書

詳細な仕様については[こちら](docs/SPECIFICATION.md)を参照してください。

## ライセンス

This project is licensed under the MIT License - see the LICENSE file for details.
