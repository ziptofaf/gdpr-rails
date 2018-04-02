class RemoveAgreedsFromUser < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :agreed_to_ip_at, :datetime
    remove_column :users, :agreed_to_email_at, :datetime
  end
end
