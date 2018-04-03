#an example on how little extra overhead is needed to add encryption to a specific model
class MockOrder < ApplicationRecord
  include Encryptable
  belongs_to :user
  attr_encrypted :name, :address, key: :encryption_key

  def self.can_expire?
    true
  end

  def self.has_personal_information?
    true
  end

  def self.export_personal_information_from_model(user_id)
    return MockOrder.find_by(user_id: user_id).to_json
  end

end
