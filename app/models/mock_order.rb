#an example on how little extra overhead is needed to add encryption to a specific model
class MockOrder < ApplicationRecord
  include Encryptable
  belongs_to :user
  attr_encrypted :name, :address, key: :encryption_key

  def self.can_expire?
    true
  end
end
