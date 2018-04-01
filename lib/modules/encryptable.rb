module Encryptable

  def encryption_key
    if self.id #for records that should already exist in the database
      redis = Redis.new
      key = ''
      if defined?(self.user_id)
        key = self.user_id.to_s
      else
        key = self.id.to_s
      end
      val = redis.get(key) or raise RuntimeError.new('Encryption key no longer exists')
    else
      @key ||= self.create_encryption_key
    end
  end

  def create_encryption_key #we might only need this in our User model but it's still part of our encryptable library
    @key || SecureRandom.random_bytes(32)
  end

end
