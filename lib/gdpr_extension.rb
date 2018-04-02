module GdprExtension

extend ActiveSupport::Concern


  # add your static(class) methods here
  class_methods do
    def has_personal_information?
      false
    end
    #by default most types of records should not disappear (eg. Users or Consents definitely should NOT)
    def retention_period
      return 100.years
    end
    def outdated_records
      return self.where('DATETIME(created_at, \'+? seconds\') < ?', self.retention_period, Time.now)
    end
    def export_personal_information_from_model(user_id)
      raise 'method export_personal_information_from_model not defined'
    end
  end
end

# include the extension
ActiveRecord::Base.send(:include, GdprExtension)
