# Memo App Backend (Sinatra + GraphQL)

このディレクトリには、設計ドキュメントに基づいて実装した簡易版のバックエンド API が含まれています。Rails や Sidekiq をフルで導入する代わりに、Sinatra と graphql-ruby を利用して GraphQL API・サブスクリプションを提供します。非同期ジョブはスレッドベースのシンプルなキューで再現しています。

## 主要エンドポイント
- `POST /graphql`: GraphQL クエリ・ミューテーションのエントリーポイント。
- `GET /graphql/subscriptions?noteId=<ID>`: Server-Sent Events を用いた簡易サブスクリプション。要約完了時に `summaryUpdated` イベントを受け取れます。

## セットアップ
1. 依存関係のインストール
   ```bash
   bundle install
   ```
2. サーバーを起動
   ```bash
   bundle exec rackup
   ```

## 実装上の補足
- データストアはインメモリ実装です。アプリ起動中のみデータが保持されます。
- `NoteService` がメモ作成、要約リクエスト、タグ自動提案を担います。
- `SummaryGenerator` は bullet points から簡易的に要約テキストを生成します。実際の OpenAI API 呼び出しに差し替え可能です。
- `TagSuggestionService` はキーワードベースでタグを提案します。Embedding による類似度計算を差し替えられるよう抽象化しています。

## テスト
CI は未設定ですが、GraphQL API の動作確認には以下のようなクエリを利用できます。
```graphql
mutation CreateNote($input: CreateNoteInput!) {
  createNote(input: $input) {
    note { id title summaryStatus }
  }
}
```

```graphql
mutation RequestSummary($noteId: ID!) {
  requestSummary(noteId: $noteId) {
    note { id summary summaryStatus }
  }
}
```
