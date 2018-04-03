module GdprExtension

extend ActiveSupport::Concern
  class_methods do
    def has_personal_information?
      false
    end
    def retention_period
      return 3.years
    end

    #by default most types of records should not disappear (eg. Users or Consents definitely should NOT)
    def can_expire?
      false
    end

    def outdated_records
      if self.can_expire?
        return self.where('DATETIME(created_at, \'+? seconds\') < ?', self.retention_period, Time.now)
      else
        return self.none #this way we can safely call this method but it won't delete anything
      end
    end
    def export_personal_information_from_model(user_id)
      raise 'method export_personal_information_from_model not defined'
    end
  end
end

# include the extension
ActiveRecord::Base.send(:include, GdprExtension)
