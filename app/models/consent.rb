class Consent < ApplicationRecord
  belongs_to :consent_category
  validates :consent_category, presence: true

  after_create :notify_users

  #we assume that when a new version of our ToS shows up everyone should see it
  def notify_users
    UserConsent.where(consent_category: self.consent_category).update(requires_revalidation: true)
  end
end
