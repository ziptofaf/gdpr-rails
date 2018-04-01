class Consent < ApplicationRecord
  belongs_to :consent_category
  validates :consent_category, presence: true
end
