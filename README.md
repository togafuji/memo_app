# Memo App (Rails API + Vue Frontend)

このリポジトリは、Vue をフロントエンド、Rails をバックエンドに採用したメモアプリケーションの設計・実装メモです。ユーザーが箇条書きで記録したメモを効率的に整理し、日付ごとにまとめ、類似トピックを関連付けることで、振り返りや情報整理を支援します。

## 主要機能
- 箇条書きメモの要約: OpenAI API などの自然言語処理サービスを利用して重要ポイントを抽出。
- 日付ごとにページを整理: カレンダー UI や日付別フィルタでメモを俯瞰。
- 類似内容のタグ付け: 類似度計算で共通タグを提案し、関連ページを横断的に閲覧可能に。
- 直感的な UI/UX: Vue3 + Pinia + Vue Router によるスムーズな操作性を実現。

## リポジトリ構成
- `docs/architecture.md`: 全体アーキテクチャ、API 設計、データモデルの詳細設計。
- `docs/frontend-ui.md`: Vue コンポーネント構成と UI/UX ガイドライン。
- `docs/backend-summary.md`: 要約やタグ付けに関するバックエンドロジックの検討。

## 実装
- `backend/`: Sinatra + graphql-ruby で構築した簡易 GraphQL API。`bundle exec rackup` で起動できます。
- `frontend/`: Vite + Vue 3 (TypeScript) の SPA。`npm install && npm run dev` で起動できます。

今後、各ドキュメントを基に実装を進めていきます。
