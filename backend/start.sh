#!/bin/bash
# 気象情報可視化システム - バックエンド起動スクリプト

cd "$(dirname "$0")"

# 仮想環境のアクティベート
if [ -d "venv" ]; then
    source venv/bin/activate
fi

# 依存パッケージのインストール
pip install -r requirements.txt

# サーバー起動
echo "🚀 Flask サーバーを起動します..."
echo "📍 URL: http://localhost:5000"
echo "💡 Ctrl+C で停止"
python app.py
