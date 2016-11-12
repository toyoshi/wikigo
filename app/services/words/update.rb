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
      #Add to fav
      @word.favorites.find_or_create_by(user: @user)
      Result.new(r, @word)
    end
  end
end
