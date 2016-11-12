module Words
  class Create
    def initialize(user, params)
      @user = user
      @params = params
      @word = Word.new(@params)
    end

    def call
      #Save the word
      r = @word.save

      if r
        #Add to fav
        @word.favorites.find_or_create_by(user: @user)
      end

      Result.new(r, @word)
    end
  end
end
