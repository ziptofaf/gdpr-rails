FactoryBot.define do
  factory :user do
    username { 'sample-user' }
    password { 'abc123' }
    password_confirmation { 'abc123' }
    email { 'sample-user@example.com' }
    before(:create) { |user| user.email = 'sample-user@example.com' }
    before(:create, &:fill_consents)
    initialize_with { User.find_or_create_by username: username }
  end
end
