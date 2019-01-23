require 'rails_helper'

def build_user
  u = User.new
  u.email = 'sample2@example.com'
  u.password = '12345678'
  u.password_confirmation = '12345678'
  u.username = 'iamauser'
  u
end

describe User do
  context 'user creation'
  it 'works fine if you fill consents' do
    FactoryBot.create(:consent)
    user = build_user
    user.fill_consents
    user.save
    expect(user.id.nil?).to eq(false)
  end

  context 'user creation'
  it 'cannot be saved without filled consents' do
    FactoryBot.create(:consent)
    user = build_user
    user.save
    expect(user.id.nil?).to eq(true)
  end

  context 'accessing users'
  it 'can be accessed in full if encryption key is present' do
    FactoryBot.create(:consent)
    user = build_user
    user.fill_consents
    user.save
    reloaded = User.first
    expect(reloaded.email).to eq('sample2@example.com')
  end

  context 'accessing users'
  it 'cant be accessed in full if encryption key has been deleted' do
    FactoryBot.create(:consent)
    user = build_user
    user.fill_consents
    user.save
    user.delete_encryption_key
    reloaded = User.first
    expect(reloaded.email).to eq('[deleted]')
  end


end