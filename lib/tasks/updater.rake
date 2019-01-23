namespace :updater do
  desc 'fix SQLite3Adapter.represent_boolean_as_integer deprecation (SQLite only)'

  task fix_represent_boolean_as_integer: :environment do
    UserConsent.where("requires_revalidation = 't'").update_all(requires_revalidation: 1)
    UserConsent.where("requires_revalidation = 'f'").update_all(requires_revalidation: 0)
  end

  desc 'fixing a bug that stored entire encryption key inside Redis rather than only first 28 bytes of it'
  task fix_redis_keys: :environment do
    include Encryptable
    namespaced_redis = redis_connection
    User.all.each do |user|
      encryption_key = namespaced_redis.get(user.id.to_s)
      if encryption_key
        secrets_partial_key = Rails.application.secrets.partial_encryption_key
        fixed_key = encryption_key.gsub(secrets_partial_key, '')
        namespaced_redis.set(user.id.to_s, fixed_key)
      end
    end
  end
end
