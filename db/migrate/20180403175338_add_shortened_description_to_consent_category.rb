class AddShortenedDescriptionToConsentCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :consent_categories, :shortened_description, :text
  end
end
