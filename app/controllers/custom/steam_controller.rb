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

    begin
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
      elsif response.code == 429
        Rails.logger.error "Rate limit exceeded: #{response.body}"
        render json: { error: "Rate limit exceeded. Please try again later." }, status: :too_many_requests
      else
        Rails.logger.error "Failed to fetch Steam data: #{response.body}"
        render json: { error: "Failed to fetch Steam data", details: response.body }, status: :bad_gateway
      end
    rescue StandardError => e
      Rails.logger.error "Unexpected error: #{e.message}"
      render json: { error: "Unexpected error occurred" }, status: :internal_server_error
    end
  end
end
