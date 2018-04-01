class AddEncryptedEmailIvToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :encrypted_email_iv, :string
  end
end
