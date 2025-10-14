# バックエンド機能詳細

## 要約フロー
1. `NotesController#create` で `Note` と `BulletPoint` を作成。
2. `NoteSummarizationJob` を enqueue。
3. ジョブ内で bullet list を整形し、OpenAI API (gpt-4.1-mini) にプロンプト送信。
4. 返却された要約を `notes.summary` に保存。
5. ActionCable もしくは GraphQL Subscriptions でフロントへ push。

### プロンプト例
```
あなたは箇条書きで書かれたメモを 200 文字以内に要約するアシスタントです。
重要ポイントを 3 つ以内にまとめ、日本語で出力してください。

メモ:
- {bullet_points}
```

## 類似タグ生成
- Embedding: `text-embedding-3-small` を利用。
- 各ノートに対して埋め込みベクトルを生成し、既存タグのベクトルと比較。
- コサイン類似度 > 0.82 のタグを自動付与。
- 新規タグ候補は上位 3 つをユーザーに提示し、承認時に確定。

## 日付ページ集約
- `DailyPage` モデルで日付ごとの要約ヘッダーを生成。
- 1 日単位のメモ数・タグを集約し、`daily_pages.cached_summary` に保存。
- 毎晩 24 時に `DailyDigestJob` を実行し、通知メールと PDF エクスポートを生成。

## API セキュリティ
- JWT を `Authorization: Bearer` で受け取り、`warden-jwt_auth` を利用。
- `notes` テーブルには行レベルセキュリティを適用 (PostgreSQL Row-Level Security)。
- Rate Limit: Rack::Attack で `/summaries` エンドポイントに 1 分あたり 20 リクエスト制限。

## テスト
- RSpec でモデル・ジョブ・GraphQL の統合テスト。
- VCR で外部 API 呼び出しをモック。
- FactoryBot + Faker でテストデータを生成。
