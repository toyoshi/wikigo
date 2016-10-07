User.find_or_create_by(id: 1) do |user|
  user.email = 'wiki@example.com'
  user.password = 'letseditwiki'
end

Word.find_or_create_by(id: 1) do |word|
  word.title = '_main'
  word.body = ""
end

Word.find_or_create_by(title: '_menu') do |word|
  word.body = ""
end
