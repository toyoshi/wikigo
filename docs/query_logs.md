# Query Logs — SQL に運航情報の tag を載せる (#139)

development で `config.active_record.query_log_tags_enabled = true` が有効に
なっていると、全ての SQL が末尾の comment tag 付きでログに出る:

```
Word Load (0.0ms)  SELECT "words".* FROM "words" LIMIT 2 /*application='Wikigo'*/
```

request / job の中を走ると tag は増える。Action Controller と Active Job の
railtie が `query_log_tags_enabled` 時にそれぞれ controller/action、job tag を
登録するので、どの action / どの job がこの query を叩いたかが SQL 単体から
復元できる。値が nil の tag は自動で落ちる — request の外では `request_id`
comment はそもそも現れない。

## tag の組み方

`config/environments/development.rb` が設定の場所。既定の有効化に加え、
このアプリは request_id の custom tag を 1 つ足している
(ActiveSupport::CurrentAttributes を context 代わりに使う公式例の形):

```ruby
config.active_record.query_log_tags_format = :sqlcommenter
config.active_record.cache_query_log_tags = true
config.active_record.query_log_tags |= [
  { request_id: ->(context) { context[:controller]&.request&.request_id } },
]
```

- `query_log_tags` — 表示する tag 一覧。既定の `[ :application ]` に、
  railtie が `[ :controller, :action, :job ]` を足す。`pid`, `socket`,
  `db_host`, `database`, `source_location` も選べる
  (`source_location` は重いので本番では慎む)
- `query_log_tags_format` — `:sqlcommenter`(OpenTelemetry 形式)か `:legacy`
- `cache_query_log_tags` — request / job の実行中不変の tag なら再計算を省く

## なぜ参照実装に置くか

structured event reporter (#107) が app 側の構造化 log を担うのに対し、
QueryLogs は **DB 側の監査を machine-readable な comment として SQL 自体に
焼き込む**。ログ行と SQL が分離しても tag は消えない。`verbose_query_logs`
(trigger 行) と tags(comment) の対で、query の「どこから飛んだか」と
「何が叩いたか」が両側から読める。
