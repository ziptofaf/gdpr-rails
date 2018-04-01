class CreateUserConsents < ActiveRecord::Migration[5.1]
  def change
    create_table :user_consents do |t|
      t.belongs_to :consent_category, foreign_key: true
      t.datetime :agreed_at

      t.timestamps
    end
  end
end
