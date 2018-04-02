class AddUserToUserConsent < ActiveRecord::Migration[5.1]
  def change
    add_reference :user_consents, :user, foreign_key: true
  end
end
