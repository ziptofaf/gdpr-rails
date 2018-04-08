class AddEmailHashToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :email_hash, :string
  end
end
