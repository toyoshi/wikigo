json.extract! attachment, :id, :user_id, :file, :created_at, :updated_at
json.url attachment_url(attachment, format: :json)
