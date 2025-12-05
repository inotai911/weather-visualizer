# 気象情報可視化システム

## システム概要
Open Meteo APIから気象データを取得し、地域・時間でフィルタリングしてグラフや表で表示するシステムです。

## システム構成
- **バックエンド**: Python/Flask
- **データベース**: SQLite
- **フロントエンド**: Flutter Web / HTML+JavaScript
- **API**: Open Meteo API

## ディレクトリ構成
```
test_system2/
├── backend/
│   ├── app.py              # Flaskメインアプリケーション
│   ├── requirements.txt    # Python依存パッケージ
│   ├── start.sh           # 起動スクリプト
│   ├── templates/
│   │   └── index.html     # HTML版フロントエンド
│   └── weather.db         # SQLiteデータベース(自動生成)
└── frontend/
    ├── pubspec.yaml       # Flutter設定
    └── lib/
        ├── main.dart      # Flutterメインファイル
        ├── models/        # データモデル
        ├── providers/     # 状態管理
        ├── screens/       # 画面
        ├── services/      # API通信
        └── widgets/       # UIコンポーネント
```

## 起動方法

### バックエンド (Flask)
```bash
cd backend

# 仮想環境の作成（初回のみ）
python -m venv venv
source venv/bin/activate

# 依存パッケージインストール
pip install -r requirements.txt

# サーバー起動
python app.py
```

サーバーが起動したら http://localhost:5000 にアクセス

### フロントエンド (Flutter Web)
```bash
cd frontend

# Flutter依存パッケージインストール
flutter pub get

# Web版で起動
flutter run -d chrome
```

## 機能

### データ取得
- 8つの主要都市（東京、大阪、名古屋、札幌、福岡、仙台、広島、那覇）のデータをプリセット
- Open Meteo APIから7日間の気象予報を取得
- 1時間ごとのデータを自動でDBに保存

### フィルタリング
- 地域別表示
- 日付範囲指定
- 表示時間数選択（24h/48h/72h/7日）

### 可視化
- **グラフ表示**: 気温、湿度、降水量、風速、気圧
- **データ表**: 全項目の一覧表示
- **統計サマリー**: 平均/最高/最低気温、平均湿度、総降水量、平均風速

### ログ記録
- ユーザー操作を自動記録
- 操作種別、詳細、時刻を保存

## API エンドポイント

| メソッド | パス | 説明 |
|---------|------|------|
| GET | `/api/locations` | 地域一覧取得 |
| POST | `/api/locations` | 新規地域追加 |
| POST | `/api/weather/fetch` | 指定地域のデータ取得 |
| POST | `/api/weather/fetch_all` | 全地域データ取得 |
| GET | `/api/weather` | 気象データ取得 |
| GET | `/api/weather/summary` | サマリー取得 |
| GET | `/api/weather/chart_data` | グラフ用データ取得 |
| GET | `/api/logs` | 操作ログ取得 |

## データベーステーブル

### meteo_data (気象データ)
| カラム | 型 | 説明 |
|--------|-----|------|
| id | INTEGER | 主キー |
| location_name | TEXT | 地域名 |
| latitude | REAL | 緯度 |
| longitude | REAL | 経度 |
| timestamp | DATETIME | 日時 |
| temperature | REAL | 気温(℃) |
| humidity | REAL | 湿度(%) |
| precipitation | REAL | 降水量(mm) |
| wind_speed | REAL | 風速(m/s) |
| wind_direction | INTEGER | 風向(度) |
| weather_code | INTEGER | 天気コード |
| pressure | REAL | 気圧(hPa) |

### user_log (操作ログ)
| カラム | 型 | 説明 |
|--------|-----|------|
| id | INTEGER | 主キー |
| action_type | TEXT | 操作種別 |
| action_detail | TEXT | 詳細 |
| timestamp | DATETIME | 日時 |

### locations (地域マスタ)
| カラム | 型 | 説明 |
|--------|-----|------|
| id | INTEGER | 主キー |
| name | TEXT | 地域名 |
| latitude | REAL | 緯度 |
| longitude | REAL | 経度 |
