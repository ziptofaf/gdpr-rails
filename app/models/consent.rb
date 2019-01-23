# defines a specific version of consent. ConsentCategory is a general category, eg. tracking cookies.
# This however defines eg. the latest version you just made. Used cuz user agrees to a specific
# version after all, not necessarily the latest one.

class Consent < ApplicationRecord
  belongs_to :consent_category
  validates :consent_category, presence: true

  after_create :notify_users

  # we assume that when a new version of our ToS shows up everyone should see it
  def notify_users
    UserConsent.where(consent_category: self.consent_category).update(requires_revalidation: true)
  end

  def self.get_formatted_consents
    list = []
    ConsentCategory.all.each do |category|
      next unless Consent.where(consent_category: category).count > 0
      elem = Hash.new
      elem[:name] = category.name
      elem[:short_description] = category.shortened_description
      elem[:mandatory] = category.mandatory
      elem[:id] = category.id
      current_version = Consent.where(consent_category: category).order(created_at: :desc).first
      elem[:last_changed] = current_version.created_at
      elem[:description] = current_version.description
      list.push(elem)
    end
    return list
  end

end
