require 'rails_helper'

RSpec.describe Custom::UsersController, type: :request do
  let(:user) { create(:user) }

  describe "PUT #update" do
    context "有効なパラメータの場合" do
      let(:valid_params) do
        {
          user: {
            username: "new_username",
            email: "new_email@example.com",
            password: "newpassword1A@",
            password_confirmation: "newpassword1A@",
            steam_id: "123456789"
          }
        }
      end

      before do
        token_data = DeviseTokenAuth::TokenFactory.create
        client_id = token_data.client

        user.tokens = {
          client_id => {
            token: token_data.token_hash,  # ← token_hash を保存（これがデータベースに保存される形式）
            expiry: (Time.now + 2.weeks).to_i
          }
        }
        user.save!

        @client_id = client_id
        @access_token = token_data.token
      end

      let(:auth_headers) do
        {
          'access-token' => @access_token,
          'client' => @client_id,
          'uid' => user.uid,
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }
      end

      it "アカウント情報を更新し、成功メッセージを返す" do
        put "/custom/users", params: valid_params, headers: auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("アカウント情報を更新しました！")
        expect(user.reload.username).to eq("new_username")
      end
    end

    context "無効なパラメータの場合" do
      let(:invalid_params) do
        {
          user: {
            username: "",
            email: "invalid_email",
            password: "short",
            password_confirmation: "mismatch",
            steam_id: nil
          }
        }
      end

      before do
        token_data = DeviseTokenAuth::TokenFactory.create
        client_id = token_data.client

        user.tokens = {
          client_id => {
            token: token_data.token_hash,  # ← token_hash を保存（これがデータベースに保存される形式）
            expiry: (Time.now + 2.weeks).to_i
          }
        }
        user.save!

        @client_id = client_id
        @access_token = token_data.token
      end

      let(:auth_headers) do
        {
          'access-token' => @access_token,
          'client' => @client_id,
          'uid' => user.uid,
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }
      end

      it "エラーメッセージを返す" do
        put "/custom/users", params: invalid_params, headers: auth_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["errors"]).to include("Email is not an email")
      end
    end
  end
end
