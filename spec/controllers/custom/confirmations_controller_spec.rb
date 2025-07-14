require 'rails_helper'

RSpec.describe 'Confirmations API', type: :request do
  describe 'GET #show' do
    context 'リダイレクトURLが指定されている場合' do
      let(:redirect_url) { 'http://example.com' }
      let(:user) { create(:user, confirmed_at: nil) }

      before do
        allow(User).to receive(:confirm_by_token).and_return(user)
        allow(user).to receive(:errors).and_return(ActiveModel::Errors.new(user)) # エラーなし
      end

      it 'リダイレクトURLにリダイレクトする' do
        get "/auth/confirmation", params: {
          redirect_url: redirect_url,
          confirmation_token: "dummy_token"
        }
        expect(response).to redirect_to("#{redirect_url}?account_confirmation_success=true")
      end
    end

    context 'リダイレクトURLが指定されていない場合' do
      let(:user) { create(:user, confirmed_at: nil) }

      before do
        allow(User).to receive(:confirm_by_token).and_return(user)
        allow(user).to receive(:errors).and_return(ActiveModel::Errors.new(user)) # エラーなし
      end

      it 'root_pathにリダイレクトする' do
        get "/auth/confirmation", params: { redirect_url: nil }
        expect(response).to redirect_to('/')
      end
    end

    context '無効なリダイレクトURLが指定されている場合' do
      let(:invalid_url) { 'invalid_url' }
      let(:user) { create(:user, confirmed_at: nil) }

      before do
        allow(User).to receive(:find_by).and_return(user)
        allow(user).to receive(:errors).and_return(ActiveModel::Errors.new(user)) # エラーなし
      end

      it 'root_pathにリダイレクトする' do
        get "/auth/confirmation", params: { redirect_url: invalid_url }
        expect(response).to redirect_to('/')
      end
    end
  end
end
