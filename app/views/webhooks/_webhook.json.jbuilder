json.extract! webhook, :id, :title, :url, :created_at, :updated_at
json.url webhook_url(webhook, format: :json)