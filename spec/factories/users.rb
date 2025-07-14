FactoryBot.define do
  factory :user do
    username { 'test_user' }
    email { 'test@example.com' }
    provider { 'email' }
    uid { 'test@example.com' }
    password { 'password123' }
    encrypted_password { Devise::Encryptor.digest(User, 'password123') }
  end
end
