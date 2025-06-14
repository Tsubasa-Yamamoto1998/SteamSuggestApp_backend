class Custom::SteamController < ApplicationController
  before_action :authenticate_user!
  require "httparty"

  def register
    authenticate_user! # 明示的に呼び出し
    steam_id = params[:steamID]
    return render json: { error: "No Steam ID provided" }, status: :bad_request unless steam_id

    if current_user.update(steam_id: steam_id)
      render json: { message: "Steam ID successfully registered" }, status: :ok
    else
      render json: { error: "Failed to register Steam ID" }, status: :unprocessable_entity
    end
  end

  # Steam APIを利用してユーザーのSteamライブラリ情報を取得
  def library
    steam_id = current_user.steam_id
    return render json: { error: "No Steam ID" }, status: :bad_request unless steam_id

    # キャッシュキーを生成
    cache_key = "steam_library_#{steam_id}"

    # Memcachedからデータを取得
    cached_response = Rails.cache.read(cache_key)
    if cached_response
      return render json: cached_response
    end

    begin
      response = HTTParty.get("https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/", {
        query: {
          key: ENV["STEAM_API_KEY"],
          steamid: steam_id,
          include_appinfo: true,
          include_played_free_games: true
        }
      })

      if response.code == 429
        sleep(5) # 5秒待機して再試行
        response = HTTParty.get("https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/", {
          query: {
            key: ENV["STEAM_API_KEY"],
            steamid: steam_id,
            include_appinfo: true,
            include_played_free_games: true
          }
        })
      end

      if response.code == 200
        parsed_response = response.parsed_response
        Rails.cache.write(cache_key, parsed_response, expires_in: 24.hours)
        render json: parsed_response
      else
        render json: { error: "Failed to fetch Steam data", details: response.body }, status: :bad_gateway
      end
    rescue StandardError => e
      render json: { error: "Unexpected error occurred" }, status: :internal_server_error
    end
  end
end
