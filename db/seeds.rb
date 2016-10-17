#First and Main page
Word.find_or_create_by(title: 'Main Page') do |word|
  word.title = 'Main Page'
  word.body = "Wiki wiki go!"
end

#Site Title
Option.site_title = 'Wiki Go'

#Default User Registration Token
Option.update_registration_token
