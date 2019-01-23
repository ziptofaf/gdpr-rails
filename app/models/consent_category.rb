# a general consent category, it can have multiple Consent models (versions of when your ToS change)
class ConsentCategory < ApplicationRecord
  has_many :consents
  has_many :user_consents

  after_create :create_for_users

  def create_for_users
    User.all.each do |user|
      ConsentCategory.build_for_user(user, self)
    end
  end

  def self.create_for_user(user)
    ConsentCategory.all.each do |consent_category|
      ConsentCategory.build_for_user(user, consent_category)
    end
  end

  def self.build_for_user(user, consent_category)
    consent = UserConsent.new
    consent.user = user
    consent.consent_category = consent_category
    # we only set this to true inside consent
    # which includes description and version, not just general category as that's incomplete by itself
    consent.requires_revalidation = false
    consent.save!
  end


end
