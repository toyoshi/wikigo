module AttachmentsHelper
  def uploadable?
    !ENV['CLOUDINARY_URL'].blank?
  end
end
