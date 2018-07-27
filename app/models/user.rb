class User < ApplicationRecord
  include Encryptable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  before_validation :downcase_email #, :populate_iv_fields #if you need/want iv to change more often
  before_create :create_encryption_key
  after_create :save_encryption_key
  after_create :build_user_consents
  attr_encrypted :email, key: :encryption_key
  has_many :user_consents

  #entry point for exporting user's personal information
  def self.export_personal_information(user_id)
    return nil unless User.exists?(user_id)
    descendants = ApplicationRecord.descendants.reject{|model| !model.has_personal_information?}
    result = Hash.new
    descendants.each do |descendant|
      result[descendant.name] = descendant.export_personal_information_from_model(user_id)
    end
    return result
  end
  #simplest example, we just export to json
  def self.export_personal_information_from_model(user_id)
    return User.find(user_id).to_json
  end
  #overwrite this to true for methods that you will want to be included in export_personal_information
  def self.has_personal_information?
    true
  end

  #helper method if you are creating a user from console and want them to have all consents set
  def fill_consents
    hash = Hash.new
    ConsentCategory.all.map(&:id).each do |id|
      hash[id]='on'
    end
    self.registration_consents=hash
  end

  #unfortunately not having an email field that you can just "write to" breaks
  #Devise. Below some necessary workarounds

  def email_changed?
    encrypted_email_changed?
  end

  def downcase_email
    self.email = self.email.downcase
  end

  def registration_consents=(consents)
    @consents = consents
  end

  def registration_consents
    @consents
  end

  validate                  :validate_consents_completeness
  validates_presence_of     :email, if: :email_required?
  validates_uniqueness_of   :username, allow_blank: false, if: :username_changed?
  validates_length_of       :username, within: 6..20, allow_blank: true

  validate                  :validate_email_uniqueness #validates_uniqueness_of :email, allow_blank: true, if: :email_changed?
  validates_format_of       :email, with: Devise.email_regexp, allow_blank: true, if: :email_changed?
  validates_presence_of     :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of       :password, within: Devise.password_length, allow_blank: true

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end
  #end original devise

  def email_changed?
    self.encrypted_email_changed?
  end

  def email_required?
    true
  end

  def email_unique?
    records = Array(self.class.find_by_email(self.email))
    records.reject{|u| self.persisted? && u.id == self.id}.empty?
  end
  #unfortunately, this is an O(n) operation now that has to go through ALL the users to see if an email is unique. Sorry!
  #if you need it to ne O(1) then consider adding email_hash field instead
  def self.find_by_email(email)
    users = User.all
    users.each do |user|
      return user if user.email.downcase == email.downcase
    end
    return nil
  end

  protected

  def validate_email_uniqueness
    errors.add(:email, :taken) unless email_unique?
  end

  def validate_consents_completeness
    return if self.id #we assume that already created user has all consents
    errors.add(:registration_consents, 'You need to agree to all required terms to continue') and return unless self.registration_consents
    consents = ConsentCategory.where(mandatory: true).map(&:id)
    ids = self.registration_consents.keys.map(&:to_i) #we are relying on a fact that checkboxes that are not checked are not sent to Rails back-end at all
    consents.each do |consent_type|
      errors.add(:registration_consents, 'You need to agree to all required terms to continue') and return unless ids.include?(consent_type)
    end
  end

  def build_user_consents
    ids = registration_consents.keys
    categories = ConsentCategory.where(id: ids)
    raise 'User submitted list of consents includes objects not existing in the database!' if categories.count != ids.count
    categories.each do |category|
      consent = UserConsent.new
      consent.consent_category = category
      consent.user = self
      consent.requires_revalidation = false
      consent.agreed_at = self.created_at
      consent.save!
    end
  end

end
