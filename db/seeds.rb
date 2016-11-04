#First and Main page
Word.find_or_create_by(title: 'Main Page') do |word|
  word.title = 'Main Page'
  word.body = "Wiki wiki go!"
end

#Site Title
Option.site_title = 'Wiki Go' if Option.site_title.blank?

#Theme
Option.theme = '' if Option.theme.blank?

#Default User Registration Token
Option.update_registration_token if Option.user_registration_token.blank?
Option.list_size_of_recent_words_parts = 5 if Option.list_size_of_recent_words_parts.blank?
