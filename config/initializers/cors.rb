# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "example.com"
#
#     resource "*",
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end

# CORSの設定（Vueからアクセス許可）
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://localhost:5173"  # Vue側のポート

    resource "*",
      headers: :any,
      expose: [ "access-token", "expiry", "token-type", "uid", "client" ],
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true # クッキーや認証情報を許可
  end
end
