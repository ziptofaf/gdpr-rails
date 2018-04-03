class CreateMockOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :mock_orders do |t|
      t.string :encrypted_name
      t.string :encrypted_name_iv
      t.string :encrypted_address
      t.string :encrypted_address_iv
      t.belongs_to :user, foreign_key: true
      t.decimal :price, precision: 5, scale: 2

      t.timestamps
    end
  end
end
