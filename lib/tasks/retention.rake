namespace :retention do
  desc "removes records that should no longer be kept inside the database"
  task remove_expired_records: :environment do
    record_types = ApplicationRecord.descendants.reject{|model| !model.can_expire?}
    record_types.each do |record_type|
      record_type.outdated_records.destroy_all
    end
  end

end
