FactoryBot.define do
  factory :user_consent do
    user
    requires_revalidation { false }
    agreed_at { Time.now }
    consent_category
  end
end
