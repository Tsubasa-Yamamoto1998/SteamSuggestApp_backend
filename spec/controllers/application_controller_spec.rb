require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    # テスト用のダミーアクションを定義
    before_action :authenticate_user!, only: [ :protected_action ]

    def protected_action
      render json: { message: "Success" }, status: :ok
    end
  end

  # テスト用のルートを設定
  before do
    routes.draw do
      get 'protected_action' => 'anonymous#protected_action'
    end
  end

  describe '#authenticate_user!' do
    context 'ユーザーが認証されている場合' do
      before do
        user = create(:user, uid: 'test@example.com')
        cookies['uid'] = user.uid
        cookies['client'] = 'test_client'
        cookies['access-token'] = 'valid_token'

        allow(User).to receive(:find_by).with(uid: 'test@example.com').and_return(user)
        allow(user).to receive(:valid_token?).with('valid_token', 'test_client').and_return(true)
      end

      it '保護されたアクションにアクセスできる' do
        get :protected_action
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Success')
      end
    end

    context 'ユーザーが認証されていない場合' do
      it '401 Unauthorizedを返す' do
        get :protected_action
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to eq('Unauthorized')
      end
    end
  end

  describe '#set_user_by_token' do
    context '有効なトークンが提供されている場合' do
      it 'current_userを設定する' do
        user = create(:user, uid: 'test@example.com')
        cookies['uid'] = { value: 'test@example.com', path: '/' }
        cookies['client'] = { value: 'test_client', path: '/' }
        cookies['access-token'] = { value: 'valid_token', path: '/' }

        allow(User).to receive(:find_by).with(uid: 'test@example.com').and_return(user)
        allow(user).to receive(:valid_token?).with('valid_token', 'test_client').and_return(true)

        get :protected_action
        controller.send(:set_user_by_token)
        expect(controller.send(:current_user)).to eq(user)
      end
    end

    context '無効なトークンが提供されている場合' do
      it 'current_userをnilに設定する' do
        cookies['uid'] = 'invalid_uid'
        cookies['client'] = 'test_client'
        cookies['access-token'] = 'invalid_token'

        allow(User).to receive(:find_by).with(uid: 'invalid_uid').and_return(nil)

        controller.send(:set_user_by_token)
        expect(controller.send(:current_user)).to be_nil
      end
    end
  end
end
