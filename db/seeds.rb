User.find_or_create_by(id: 1) do |user|
  user.email = 'wiki@example.com'
  user.password = 'password'
end

Word.find_or_create_by(title: 'Main Page') do |word|
  word.title = 'Main Page'
  word.body = "Wiki wiki go!"
end
