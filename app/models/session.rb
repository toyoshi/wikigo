class Session < ApplicationRecord
  belongs_to :user

  # Server-side TTL (#138). The sign-in cookie is signed.permanent, so the
  # browser keeps it for years; expires_at is what bounds the server side.
  # Abandoned rows (no sign-out, user never deleted) are swept by
  # Sessions::CleanupJob via config/recurring.yml. A nil expires_at means
  # "no expiry" and keeps fixtures usable.
  TTL = 30.days

  before_create :set_expires_at

  scope :expired, -> { where.not(expires_at: nil).where('expires_at < ?', Time.current) }

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  private

  def set_expires_at
    self.expires_at ||= Time.current + TTL
  end
end
