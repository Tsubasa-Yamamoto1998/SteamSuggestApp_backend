require 'rails_helper'

RSpec.describe Custom::SessionsController, type: :request do
  let(:user) { create(:user) }

  before do
    token_data = DeviseTokenAuth::TokenFactory.create
    client_id = token_data.client

    user.tokens = {
      client_id => {
        token: token_data.token_hash,
        expiry: (Time.now + 2.weeks).to_i
      }
    }
    user.save!

    @client_id = client_id
    @access_token = token_data.token

    cookies["uid"] = user.uid
    cookies["client"] = @client_id
    cookies["access-token"] = @access_token
  end

  describe "GET #check_auth" do
    context "認証が成功する場合" do
      it "ログイン状態を返す" do
        get "/custom/sessions/check_auth", headers: { "Content-Type" => "application/json" }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["is_logged_in"]).to be true
        expect(json_response["user"]["id"]).to eq(user.id)
      end
    end

    context "認証が失敗する場合" do
      before do
        cookies["access-token"] = "invalid_token"
      end

      it "未ログイン状態を返す" do
        get "/custom/sessions/check_auth", headers: { "Content-Type" => "application/json" }
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["is_logged_in"]).to be false
      end
    end
  end

  describe "POST #logout" do
    context "ログアウトが成功する場合" do
      it "ログアウト成功メッセージを返す" do
        delete "/custom/sessions/logout", headers: { "Content-Type" => "application/json" }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eq("ログアウト成功")
        expect(cookies["access-token"]).to be_blank
        expect(cookies["client"]).to be_blank
        expect(cookies["uid"]).to be_blank
      end
    end

    context "ログアウトが失敗する場合" do
      before do
        cookies["access-token"] = "invalid_token"
      end

      it "エラーメッセージを返す" do
        delete "/custom/sessions/logout", headers: { "Content-Type" => "application/json" }
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response["error"]).to eq("ログアウトできませんでした")
      end
    end
  end
end
