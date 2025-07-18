class ApplicationController < ActionController::API
  include ActionController::Cookies # クッキー機能を有効化

  before_action :set_user_by_token, :authenticate

  # 認証が必要なアクションで使用
  def authenticate_user!
    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  private

  # DeviseTokenAuthのset_user_by_tokenをオーバーライド
  def set_user_by_token(mapping = nil)
    # クッキーからトークン情報を取得

    uid = request.headers["uid"] || cookies["uid"]
    client = request.headers["client"] || cookies["client"]
    access_token = request.headers["access-token"] || cookies["access-token"]

    # トークンが存在しない場合は認証失敗
    return unless uid && client && access_token

    # ユーザーを検索してトークンを検証
    user = User.find_by(uid: uid)
    if user && user.valid_token?(access_token, client)
      @current_user = user
    else
      @current_user = nil
    end
  end

  # current_userをオーバーライドして@current_userを返す
  def current_user
    @current_user
  end

  def authenticate
    allowed_paths = [ "/custom/auth/guest_login" ]
    return if allowed_paths.include?(request.path)

    token = request.headers["Authorization"]
    unless token == "Bearer #{ENV["ACCESS_TOKEN"]}"
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
