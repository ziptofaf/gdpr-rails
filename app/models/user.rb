class User < ApplicationRecord
  include Encryptable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  before_validation :downcase_email #, :populate_iv_fields #if you need/want iv to change more often
  before_create :create_encryption_key
  before_save :hash_email
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

  def email_was
    User.decrypt_email(encrypted_email_was)
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
    email_hash =  User.create_email_hash(self.email)
    return User.where(email_hash: email_hash).where.not(id: self.id).count == 0
  end

  def self.find_for_authentication(tainted_conditions)
    User.find_by(email_hash: User.create_email_hash(tainted_conditions[:email]))
  end
  #used when you try to use forgot_password form. This is imperfect as it ignores opts arguments but better than nothing
  #a correct solution would probably be to use Arel and create a custom :email field mapped to :email_hash below ActiveRecord layer
  #but unfortunately I frankly am not sure how to do it
  def self.find_first_by_auth_conditions(tainted_conditions, opts={})
    if tainted_conditions['email']
      tainted_conditions['email_hash'] = User.create_email_hash(tainted_conditions[:email])
      tainted_conditions.reject! {|k| k == 'email'}
    end
    to_adapter.find_first(devise_parameter_filter.filter(tainted_conditions).merge(opts))
  end


  def hash_email
    if self.encrypted_email_changed?
      self.email_hash =  User.create_email_hash(self.email)
    end
  end

  #by creating an email_hash field we can make this function work in O(1) once more!
  def self.find_by_email(email)
    email_hash = User.create_email_hash(email.downcase)
    User.find_by email_hash: email_hash
  end

  protected
  #emails are unlike passwords, theres no real point in hashing them 50000 times and then salting
  def self.create_email_hash(email)
    return Digest::SHA256.hexdigest(email)
  end

  def validate_email_uniqueness
    errors.add(:email, :taken) unless email_unique?
  end

  def validate_consents_completeness
    return if self.id #we assume that already created user has all consents
    errors.add(:registration_consents, 'You need to agree to all required terms to continue') and return unless registration_consents
    consents = ConsentCategory.where(mandatory: true).map(&:id)
    ids = registration_consents.keys #we are relying on a fact that checkboxes that are not checked are not sent to Rails back-end at all
    consents.each do |consent_type|
      errors.add(:registration_consents, 'You need to agree to all required terms to continue') and return unless ids.include?(consent_type.to_s)
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
