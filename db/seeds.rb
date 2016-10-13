User.find_or_create_by(id: 1) do |user|
  user.email = 'wiki@example.com'
  user.password = 'letseditwiki'
end

Word.find_or_create_by(title: '_main') do |word|
  word.title = '_main'
  word.body = ""
end
