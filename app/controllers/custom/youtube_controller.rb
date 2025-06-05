class Custom::YoutubeController < ApplicationController
  require "net/http"
  require "json"

  def search
    game_title = params[:game_title]
    if game_title.blank?
      render json: { error: "ゲームタイトルが必要です" }, status: :bad_request
      return
    end

    begin
      # YouTube APIにリクエストを送信
      response = fetch_youtube_videos(game_title)
      render json: response, status: :ok
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
    end
  end

  private

  def fetch_youtube_videos(game_title)
    api_key = ENV["YOUTUBE_API_KEY"] # 環境変数からAPIキーを取得
    base_url = "https://www.googleapis.com/youtube/v3/search"
    query_params = {
      part: "snippet",
      q: game_title,
      type: "video",
      maxResults: 5,
      key: api_key
    }

    uri = URI(base_url)
    uri.query = URI.encode_www_form(query_params)

    response = Net::HTTP.get_response(uri)
    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      format_youtube_response(data)
    else
      raise "YouTube APIエラー: #{response.message}"
    end
  end

  def format_youtube_response(data)
    data["items"].map do |item|
      {
        title: item["snippet"]["title"],
        url: "https://www.youtube.com/watch?v=#{item['id']['videoId']}",
        thumbnail: item["snippet"]["thumbnails"]["default"]["url"]
      }
    end
  end
end
