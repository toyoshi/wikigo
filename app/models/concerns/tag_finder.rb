concern :TagFinder do
  included do
    def self.active_tags(limit = 10)
      ActsAsTaggableOn::Tag.where('taggings_count >= 0').limit(limit)
    end
  end
end
