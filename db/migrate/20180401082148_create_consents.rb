class CreateConsents < ActiveRecord::Migration[5.1]
  def change
    create_table :consents do |t|
      t.belongs_to :consent_category, foreign_key: true
      t.text :description

      t.timestamps
    end
  end
end
