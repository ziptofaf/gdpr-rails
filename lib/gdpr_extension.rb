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
    #records that are safe to delete by now
    def outdated_records
      if self.can_expire?
        arel_table = self.arel_table
        return self.where(arel_table[:created_at].lt(Time.now - self.retention_period))
      else
        return self.none #this way we can safely call this method but it won't delete anything
      end
    end
    #its here just to remind you that a model with has_personal_information HAS to define this method
    def export_personal_information_from_model(user_id)
      raise 'method export_personal_information_from_model not defined'
    end
  end
end

# include the extension
ActiveRecord::Base.send(:include, GdprExtension)
