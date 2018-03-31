module GdprExtension

extend ActiveSupport::Concern


  # add your static(class) methods here
  class_methods do
    def has_personal_information?
      false
    end
    def retention_period
      return 3.years
    end
    def outdated_records
      return self.where('DATETIME(created_at, \'+? seconds\') < ?', self.retention_period, Time.now)
    end
  end
end

# include the extension
ActiveRecord::Base.send(:include, GdprExtension)
