require 'rails_helper'

RSpec.describe Custom::RegistrationsController, type: :request do
  describe 'POST #create' do
  let(:valid_params) do
    {
      username: 'testUser',
      email: 'test@example.com',
      password: '1qaz2wsxA@',
      password_confirmation: '1qaz2wsxA@',
      confirm_success_url: 'http://localhost:3000/confirmed'
    }
  end

    let(:invalid_params) do
      {
        username: '',
        email: 'invalid_email',
        password: 'short',
        password_confirmation: 'short',
        confirm_success_url: 'http://localhost:3000/confirmed'
      }
    end

    context '有効なパラメータが提供された場合' do
      it 'ユーザーを作成し、成功レスポンスを返す' do
        expect {
          post '/auth', params: valid_params
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['email']).to eq('test@example.com')
      end
    end

    context '無効なパラメータが提供された場合' do
      it 'ユーザーを作成せず、エラーレスポンスを返す' do
        expect {
          post '/auth', params: invalid_params
        }.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end
end
