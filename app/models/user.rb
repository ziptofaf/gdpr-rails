class User < ApplicationRecord
  include Encryptable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  def self.export_personal_information(user_id)
    user = User.find(user_id)
    {user: user.to_json} if user
  end
  before_validation :populate_iv_fields, :downcase_email
  before_create :create_encryption_key
  after_create :save_encryption_key


  attr_encrypted :email, key: :encryption_key

  #unfortunately not having an email field that you can just "write to" breaks
  #Devise. Below some necessary workarounds

  def email_changed?
    encrypted_email_changed?
  end

  def self.find_for_authentication(tainted_conditions)
    User.find_by_email(tainted_conditions[:email].downcase)
  end

  def downcase_email
    self.email = self.email.downcase
  end


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

  def self.find_by_email(email) #unfortunately, this is an O(n) operation now that has to go through ALL the users to see if an email is unique. Sorry!
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

end
