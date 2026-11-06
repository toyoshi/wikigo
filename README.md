# WikiGo

<img src='https://cloud.githubusercontent.com/assets/188394/19829766/528c7046-9e25-11e6-9271-0fa6916b770b.png' width='500'>

**A simple, modern wiki engine — a wiki you can self-host with nothing but Rails and a single Docker command.**

WikiGo has two faces. It is a production-ready wiki whose signature is **automatic keyword linking** — mention a page title anywhere in your content and it becomes a link. And it is a **Rails reference app**: living documentation of how modern Rails (Ruby 4.0 / Rails 8.1) is written, in a small, readable codebase. Everything in this repository is judged by one standard:

> **Rails 本体が推奨しているか。読者に 1 分で説明できるか。**

「新しいから足す」は動きません。依存が一つ増えることは、読者にとって負荷が一つ増えることです。

## リファレンスアプリの姿勢

**時点固定**: `main` は Rails を追従して流動します。参照すべき固定点は最新の
release tag (現 v0.1.0 = Rails 8.1.4.1 / Ruby 4.0.8) で、各時点の Rails
バージョンと採用機能は `CHANGELOG.md` が引掛です。

### 採用している Rails 8.1 の型

| 型 | WikiGo での実装 |
|----|----------------|
| **Local CI** | `bin/ci` (`config/ci.rb`) — style・security・tests を一本のコマンドで |
| **Structured Event Reporter** | `Rails.event.notify` による machine-readable events (`config/initializers/event_reporter.rb`) |
| **Markdown rendering** | `GET /words/1.md` が `Word#to_markdown` を直接レンダリング |
| **Propshaft + importmap-rails + Hotwire** | JS ビルド工程なし。Turbo + Stimulus 正規の経路 |
| **Solid Cache / Solid Cable / Solid Queue** | Redis なしの database-backed 三昧セット (ActiveJob バックエンド含む) |
| **トランザクション・コールバック** | `before_commit` ゲート (#137) — webhook の enqueue はコミット成功後にだけ走り、ロールバックは幽霊配信を残さない |
| **ActionText (Trix)** | リッチテキストの本文は `has_rich_text` が唯一の真実 |
| **PaperTrail (JSON serializer)** | 履歴の reify が Psych の制約に躓まない構成 (#82 参照) |
| **minitest + fixtures** | テストは仕様書であり、それ自体が模範であるべき |

計画・追跡は GitHub Issues が台帳です。

### 明示的に採用しないもの (Non-goals)

「入っていないこと」も判断の産物です。以下は方針として入れません:

| 対象 | 理由 | 追跡 |
|------|------|------|
| **Devise** | `has_secure_password` + session が公式推奨経路 — #110 で置き換済み。本家の破壊的変更に振り回された実例あり (#101) | 済み |
| **gon** | JS グローバルへのデータ流し込みは Hotwire 時代のアンチパタン。Turbo Streams / `data-*` 属性へ | #119 / #118 |
| **Sidekiq / Redis** | 答えは database-backed の Solid Queue — webhook 配信が実 job として採用済み (#112) | 済み |
| **RSpec / FactoryBot** | Rails 既定の minitest + fixtures を模範として維持 | — |
| **ViewComponent / StimulusReflex / htmx** | Hotwire 正規の経路に徹する | — |
| **Pundit / CanCanCan** | ロール判定は controller concern の明示的な方法で足りる | — |
| **Rmagick** | image_processing + libvips が現行 | — |
| **spring / webpacker** | Rails 8 のスキャフォールド対象外。webpacker 残骸は #107 で削除済み | #121 |
| **文字列ディスパッチの magic** | `method_missing` + `send` を参照コードに書かない (実際に #105 で priv-esc を修正した同型) | #114 |
| **AI 編集 (main 線)** | OpenAI の例は main の目的から外れる。`AiContentGenerator` は provider interface + deterministic Fake に縮退し、実装は `example/ai-editing` ブランチへ | 済み |
| **beta 追従** | 追随先は stable のみ。Gemfile の制約 (`rails ~> 8.1.4`) が境界のゲート | — |
| **Cloudflare Workers/Pages** | Rails は JS/WASM ランタイム外。載せ方を論じる前に崩れる前提。デプロイ先はコンテナ系 | #111 |

## Features

<img src='https://cloud.githubusercontent.com/assets/188394/19829747/d9d0b680-9e24-11e6-9d1d-40e20604f170.png' width='500'>

- **Auto-linking**: ページタイトルが全ページ上で自動的にリンック化する名物機能
- **Multi-user**: 認証とロール付きアクセスの模範実装
- **Rich text editing**: ActionText + Trix による編集
- **Markdown export**: `/words/1.md` で任意ページを Markdown 出力 (#82 で履歴表示も修正)
- **Tagging system**: acts-as-taggable-on によるタグ
- **Version history**: PaperTrail による履歴・ロールバック
- **Search**: HTML タグにヒットしない本文検索 (`body_plain_text`, #83)
- **REST API**: Bearer token による完全な API
- **Modern UI**: Bootstrap 5 / Propshaft / importmap
- **Rails 8.1 native**: Solid Cache・Solid Cable・Solid Queue・Attribute Encryption (`Option#encrypts`)・Local CI・Structured Event Reporter

## Quick Start

### Local development (requires Ruby 4.0)

```bash
git clone https://github.com/toyoshi/wikigo.git
cd wikigo
bin/setup          # 依存関係のインストールと db:prepare
bin/rails server
```

### Docker (Recommended)

```bash
docker-compose up
```

Visit http://localhost:3000

### 変更 before push

```bash
bin/ci             # gem audit / brakeman / tests / seeds を全部回す
```

## Deployment

SQLite in development/test, PostgreSQL in production (`DATABASE_URL` が primary/cache/cable の三本を引き込む構成)。

```bash
docker build -t wikigo .
docker run -p 3000:3000 wikigo
```

Rails 公式の **Kamal** が既定のデプロイ回答です (#111)。`kamal.yml.sample` を `.kamal.yml` にコピーして hosts/image を埋め、secrets に `SECRET_KEY_BASE`・`DATABASE_URL`・`RAILS_MASTER_KEY` を登録したら `kamal bootstrap && kamal deploy`。アセットの precompile はビルド段にあり (#111)、コンテナは起動直後から完全体です。

```bash
kamal doctor       # 設定と疎通の点検
kamal bootstrap    # 初回のみ
kamal deploy
```

ヘルスチェックは `/up` (Rails 既定の `Rails::HealthController`、public・認証な)。Kamal proxy がトラフィック切替前にポーリングします。Railway 誘導 (#80) は owner トリッジで deferred のまま併存判断。

## Testing & Quality Gates

リファレンスアプリにとってテストと CI は機能ではなく**ドキュメント**です。

```bash
bin/rails test     # suite 全体 (Minitest)
bin/ci             # gem audit + brakeman + tests + seeds
```

- テスト名は仕様語で書き、意図を持つものは Issue 番号を残す — e.g. `"search does not match html tags stored in the body (#83)"`
- GitHub Actions (`.github/workflows/ci.yml`) が `rails test` と `bundle-audit` をゲート
- dependabot 設定は in-tree (`.github/dependabot.yml`, #108): security 即時・週次 patch/minor

## REST API

WikiGo provides a comprehensive REST API for programmatic access to all wiki functionality.

```bash
# Get all pages
curl -H "Authorization: Bearer YOUR_API_TOKEN" \
     https://your-wikigo-instance.com/api/v1/words

# Search pages
curl -H "Authorization: Bearer YOUR_API_TOKEN" \
     "https://your-wikigo-instance.com/api/v1/words/search?q=documentation"

# Create a new page
curl -X POST \
     -H "Authorization: Bearer YOUR_API_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"word":{"title":"API Guide","body":"Content here","tag_list":"api,guide"}}' \
     https://your-wikigo-instance.com/api/v1/words
```

📖 **[Complete REST API Documentation](./WikiGo-REST-API-Documentation.md)**

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes — and keep them explainable in one minute
4. Run `bin/ci` to verify style, security, and tests
5. Submit a pull request

The policy above (Non-goals の一覧と判断基準) is contract. 迷う変更に迷う PR は、まず Issue で方針を相談してください — non-goals の追記・更新は #120 で管理します。

## License

This project is available under the MIT License.

## Support

- Create an issue for bug reports or feature requests
- Review the codebase — it's designed to be readable and educational
- Contribution policy for humans: `CONTRIBUTING.md` (the reference-app standard, the contract, the workflow)
- Agent guidance for AI-assisted contribution: `CLAUDE.md`
