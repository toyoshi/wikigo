module Words
  class Update
    def initialize(user, id, params)
      @user = user
      @params = params
      @word = Word.find(id)
    end

    def call
      #Save the word
      r = @word.update(@params)

      if r
        #Create Activity
        @word.favorites.each do |f|
          @word.create_activity(key: 'update', owner: @user, recipient: f.user) unless @user.id == f.user.id
          # TODO: Send Notification
        end

        #Add to fav
        @word.favorites.find_or_create_by(user: @user)
      end

      Result.new(r, @word)
    end
  end
end
