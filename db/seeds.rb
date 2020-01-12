#First and Main page
Word.find_or_create_by(title: 'Main Page') do |word|
  word.title = 'Main Page'
  word.body = "Wiki wiki go!"
end

Word.find_or_create_by(title: 'Side Bar') do |word|
  word.title = 'Side Bar'
  word.body = "--- menu ---"
end

#Site Title
Option.site_title = 'Wiki Go' if Option.site_title.blank?

#Default User Registration Token
Option.update_registration_token if Option.user_registration_token.blank?

#Recent words length
Option.list_size_of_recent_words_parts = 5 if Option.list_size_of_recent_words_parts.blank?

#Header and Footer custome space
%w(theme html_append_head html_append_body).each do |str|
  Option.send("#{str}=", '') if Option.send(str).blank?
end
