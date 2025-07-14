require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    before do
      # 必要な属性を持つ既存のレコードを作成
      create(:user, email: 'test@example.com', provider: 'email', uid: 'test_uid')
    end

    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive.scoped_to(:provider) }
    it { should validate_presence_of(:encrypted_password) }
    it { should validate_length_of(:password).is_at_least(6).on(:create) }
  end

  describe 'Devise modules' do
    it 'includes Devise modules' do
      expect(User.ancestors).to include(Devise::Models::DatabaseAuthenticatable)
      expect(User.ancestors).to include(Devise::Models::Registerable)
      expect(User.ancestors).to include(Devise::Models::Recoverable)
      expect(User.ancestors).to include(Devise::Models::Rememberable)
      expect(User.ancestors).to include(Devise::Models::Trackable)
      expect(User.ancestors).to include(Devise::Models::Validatable)
      expect(User.ancestors).to include(Devise::Models::Confirmable)
      expect(User.ancestors).to include(Devise::Models::Omniauthable)
    end
  end

  describe 'database columns' do
    it { should have_db_column(:username).of_type(:string) }
    it { should have_db_column(:email).of_type(:string) }
    it { should have_db_column(:encrypted_password).of_type(:string) }
    it { should have_db_column(:steam_id).of_type(:string) }
    it { should have_db_column(:sign_in_count).of_type(:integer) }
    it { should have_db_column(:current_sign_in_at).of_type(:datetime) }
    it { should have_db_column(:last_sign_in_at).of_type(:datetime) }
    it { should have_db_column(:current_sign_in_ip).of_type(:string) }
    it { should have_db_column(:last_sign_in_ip).of_type(:string) }
    it { should have_db_column(:confirmation_token).of_type(:string) }
    it { should have_db_column(:confirmed_at).of_type(:datetime) }
    it { should have_db_column(:confirmation_sent_at).of_type(:datetime) }
    it { should have_db_column(:unconfirmed_email).of_type(:string) }
    it { should have_db_column(:tokens).of_type(:json) }
  end
end
