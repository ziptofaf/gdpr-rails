class AddMandatoryToConsentCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :consent_categories, :mandatory, :boolean, default: true
  end
end
