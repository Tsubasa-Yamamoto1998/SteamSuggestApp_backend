class Custom::SteamController < ApplicationController
  before_action :authenticate_user!
  require "httparty"

  def register
    authenticate_user! # 明示的に呼び出し
    Rails.logger.debug "Register action called" # デバッグログ
    Rails.logger.debug "Current User: #{current_user.inspect}" # デバッグログ
    Rails.logger.debug "Headers: #{request.headers['access-token']}, #{request.headers['client']}, #{request.headers['uid']}" # デバッグログ
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

    response = HTTParty.get("https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/", {
      query: {
        key: ENV["STEAM_API_KEY"],
        steamid: steam_id,
        include_appinfo: true,
        include_played_free_games: true
      }
    })

    if response.code == 200
      render json: response.parsed_response
    else
      render json: { error: "Failed to fetch Steam data" }, status: :bad_gateway
    end
  end
end
