require 'rails_helper'

RSpec.describe Custom::YoutubeController, type: :controller do
  describe 'GET #search' do
    context 'ゲームタイトルが指定されている場合' do
      it '成功レスポンスを返す' do
        get :search, params: { game_title: 'Minecraft' }
        expect(response).to have_http_status(:ok)
      end
    end

    context 'ゲームタイトルが指定されていない場合' do
      it '400 Bad Requestを返す' do
        get :search, params: { game_title: '' }
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
