class User < ApplicationRecord
  include Encryptable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def self.export_personal_information(user_id)
    user = User.find(user_id)
    {user: user.to_json} if user
  end

before_create :create_encryption_key

attr_encrypted :email, key: :encryption_key

end
