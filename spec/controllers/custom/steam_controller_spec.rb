require 'rails_helper'

RSpec.describe Custom::SteamController, type: :request do
  let(:user) { create(:user, steam_id: nil) }
  let(:headers) { { 'Authorization' => "Bearer #{user.tokens}" } }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end

  describe 'POST #register' do
    context '有効なSteam IDが提供された場合' do
      let(:steam_id) { '1234567890' }

      it 'Steam IDを登録し、成功レスポンスを返す' do
        post '/custom/steam/register', params: { steamID: steam_id }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Steam ID successfully registered')
        expect(user.reload.steam_id).to eq(steam_id)
      end
    end

    context 'Steam IDが提供されていない場合' do
      it 'エラーレスポンスを返す' do
        post '/custom/steam/register', params: {}, headers: headers

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('No Steam ID provided')
      end
    end
  end

  describe 'GET #library' do
    context 'Steam IDが登録されている場合' do
      let(:steam_id) { '1234567890' }
      let(:cache_key) { "steam_library_#{steam_id}" }
      let(:steam_data) { { "games" => [ { "appid" => 123, "name" => "Test Game" } ] } }

      before do
        user.update(steam_id: steam_id)
      end

      context 'キャッシュが存在する場合' do
        before do
          Rails.cache.write(cache_key, steam_data)
          allow(Rails.cache).to receive(:read).with(cache_key).and_return(steam_data)
          allow(HTTParty).to receive(:get).and_raise("Should not be called") # これで未使用確認
        end

        it 'キャッシュされたデータを返す' do
          get '/custom/steam/library', headers: headers

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq(steam_data)
        end
      end

      context 'キャッシュが存在しない場合' do
        let(:response_double) do
          instance_double(HTTParty::Response, code: 200, parsed_response: steam_data)
        end

        before do
          Rails.cache.clear
          allow(HTTParty).to receive(:get).and_return(response_double)
        end

        it 'Steam APIからデータを取得して返す' do
          get '/custom/steam/library', headers: headers

          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq(steam_data)

          cached = Rails.cache.read(cache_key)
          expect(cached).to eq(steam_data), "Cache miss: expected #{steam_data.inspect}, got #{cached.inspect}"
        end
      end

      context 'Steam APIがエラーを返した場合' do
        let(:response_double) do
          instance_double(
            HTTParty::Response,
            code: "500",
            body: 'Internal Server Error',
            parsed_response: false
          )
        end

        before do
          Rails.cache.clear
          allow(HTTParty).to receive(:get).and_return(response_double)
        end

        it 'エラーレスポンスを返す' do
          get '/custom/steam/library', headers: headers
          expect(response).to have_http_status(:bad_gateway)
          expect(JSON.parse(response.body)['error']).to eq('Failed to fetch Steam data')
        end
      end
    end

    context 'Steam IDが登録されていない場合' do
      it 'エラーレスポンスを返す' do
        get '/custom/steam/library', headers: headers

        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to eq('No Steam ID')
      end
    end
  end
end
