class AddRequiresRevalidationToUserConsent < ActiveRecord::Migration[5.1]
  def change
    add_column :user_consents, :requires_revalidation, :boolean, default: false
  end
end
