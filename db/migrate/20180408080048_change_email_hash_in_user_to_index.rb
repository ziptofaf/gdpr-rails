class ChangeEmailHashInUserToIndex < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :email_hash, unique: true
  end
end
