class Custom::YoutubeController < ApplicationController
  require "httparty"
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
    if api_key.blank?
      raise "YouTube APIキーが設定されていません"
    end

    base_url = "https://www.googleapis.com/youtube/v3/search"
    query_params = {
      part: "snippet",
      q: "#{game_title} 日本語 実況 ゲームプレイ", # 検索キーワードを追加
      type: "video",
      maxResults: 20,
      order: "viewCount", # 再生回数の多い順にソート
      key: api_key
    }

    response = HTTParty.get(base_url, query: query_params)

    if response.success?
      format_youtube_response(response.parsed_response)
    else
      raise "YouTube APIエラー: #{response.message} (HTTP #{response.code})"
    end
  end

  def format_youtube_response(data)
    return [] unless data["items"] # itemsが存在しない場合は空配列を返す

    data["items"].map do |item|
      # 必要なデータが存在するか確認
      next unless item["id"] && item["id"]["kind"] == "youtube#video" && item["id"]["videoId"]
      next unless item["snippet"] && item["snippet"]["thumbnails"]

      # サムネイルの解像度を選択 (high > medium > default)
      thumbnail_url = item["snippet"]["thumbnails"]["high"]&.dig("url") ||
                      item["snippet"]["thumbnails"]["medium"]&.dig("url") ||
                      item["snippet"]["thumbnails"]["default"]&.dig("url")

      next unless thumbnail_url # サムネイルURLが存在しない場合はスキップ

      # データを整形
      {
        title: item["snippet"]["title"].to_s.strip, # タイトルを文字列として扱い、余分な空白を削除
        url: "https://www.youtube.com/watch?v=#{item['id']['videoId']}",
        thumbnail: thumbnail_url.to_s.strip # サムネイルURLを文字列として扱い、余分な空白を削除
      }
    end.compact # nilを除外
  end
end
