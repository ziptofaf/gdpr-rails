module Encryptable
  def redis_connection
    redis = Redis.new
    return Redis::Namespace.new(:encrypt_test, redis: redis) if Rails.env.test?

    Redis::Namespace.new(:encrypt, redis: redis)
  end

  def encryption_key
    namespaced_redis = redis_connection
    if self.class.name == 'User'
      if id
        key = id.to_s
        @encryption_key = Rails.application.secrets.partial_encryption_key + namespaced_redis.get(key).to_s
        return @encryption_key
      else # for new records
        @encryption_key ||= create_encryption_key
        return @encryption_key
      end
    end
    if defined?(user_id)
      key = user_id.to_s
      raise ArgumentError('Invalid user_id') if key.empty?
      @encryption_key = Rails.application.secrets.partial_encryption_key + namespaced_redis.get(key).to_s
    else
      raise 'You need to override an encryption_key method or add user_id - no
        direct connection to user_id needed to locate an encryption key'
    end
  end

  def create_encryption_key # we might only need this in our User model but it's still part of our encryptable library
    # we take 4 bytes of our encryption_key from application secrets file with remaining 28 to be stored inside Redis
    Rails.application.secrets.partial_encryption_key + SecureRandom.random_bytes(28)
  end

  # attr_encrypted requires encrypted_fieldname_iv to exist in the database. This method will automatically populate all of them
  def populate_iv_fields
    fields = attributes.select { |attr| (attr.include?('iv') && attr.include?('encrypted')) }.keys
    fields.each do |field|
      unless public_send(field) # just in case so it's impossible to overwrite our iv
        iv = SecureRandom.random_bytes(12)
        public_send(field + '=', iv)
      end
    end
  end

  # this saves our encryption key in Redis so it's persistent
  def save_encryption_key
    namespaced_redis = redis_connection
    key = if defined?(user_id)
            user_id.to_s
          else
            id.to_s
          end
    # just to stay on safe side
    raise 'Encryption key already exists' if namespaced_redis.get(key)
    namespaced_redis.set(key, @encryption_key[4..-1]) # needed cuz otherwise our encryption key would have Rails secrets
  end

  def delete_encryption_key
    namespaced_redis = redis_connection
    key = if defined?(user_id)
            user_id.to_s
          else
            id.to_s
          end
    namespaced_redis.del(key)
  end

  # what do return in attribute field when there's no key
  def value_when_no_key
    '[deleted]'
  end

  # we need to override attr_encrypted method so rather than throwing an exception
  # it will return a correct value when no key exists
  # you can also consider overriding encrypt in a similar fashion (although for me it makes sense that no key = you cant edit whats inside)
  def decrypt(attribute, encrypted_value)
    encrypted_attributes[attribute.to_sym][:operation] = :decrypting
    encrypted_attributes[attribute.to_sym][:value_present] = self.class.not_empty?(encrypted_value)
    self.class.decrypt(attribute, encrypted_value, evaluated_attr_encrypted_options_for(attribute))
  rescue ArgumentError # must specify a key
    value_when_no_key
  rescue OpenSSL::Cipher::CipherError # if key was altered
    value_when_no_key
  end
end
