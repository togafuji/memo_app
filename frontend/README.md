# Memo App Frontend (Vue 3 + Vite)

Vue 3 (Composition API) と Element Plus を用いた SPA 実装です。GraphQL API と連携してメモの作成、要約リクエスト、タグブラウジングが行えます。

## セットアップ
```bash
npm install
npm run dev
```

Vite の開発サーバーはデフォルトで `http://localhost:5173` で立ち上がり、`vite.config.ts` のプロキシ設定により `/graphql` はバックエンド (http://localhost:9292) へフォワードされます。

## 主な構成
- `src/stores/notes.ts`: Pinia ストア。GraphQL クエリ/ミューテーションの呼び出しや要約ステータスの管理を行います。
- `src/components/*`: UI コンポーネント。タイムライン、メモカード、要約パネル、タグ提案など。
- `src/composables/useRealtimeSummary.ts`: Server-Sent Events で `summaryUpdated` サブスクリプションを購読します。

## テスト
Vitest や Cypress のセットアップは未実施ですが、`npm run type-check` で型チェックを、`npm run lint` で ESLint を実行できます (依存パッケージのインストールが前提)。
