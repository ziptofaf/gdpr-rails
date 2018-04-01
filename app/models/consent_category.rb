class ConsentCategory < ApplicationRecord
  has_many :consents
  has_many :user_consents
end
