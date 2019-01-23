FactoryBot.define do
  factory :consent_category do
    name { 'cookies' }
    mandatory { true }
    shortened_description { 'Cookies are great, I want to use them' }
  end
end
