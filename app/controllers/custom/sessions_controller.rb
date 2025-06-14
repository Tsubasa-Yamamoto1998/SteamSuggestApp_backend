class Custom::SessionsController < DeviseTokenAuth::SessionsController
  include ActionController::Cookies # Cookies機能を有効化
  wrap_parameters format: []

  # 認証状態を確認するエンドポイント
  def check_auth
    # クッキーから認証情報を取得
    uid = cookies["uid"]
    client = cookies["client"]
    access_token = cookies["access-token"]

    # ユーザーを検索してトークンを検証
    user = User.find_by(uid: uid)
    if user && user.valid_token?(access_token, client)
      @current_user = user

      # トークンを更新（クッキーに保存するため、レスポンスヘッダーには追加しない）
      token = user.create_new_auth_token

      # クッキーにトークンを再設定
      self.cookies["access-token"] = {
        value: token["access-token"],
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax
      }
      self.cookies["client"] = {
        value: token["client"],
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax
      }
      self.cookies["uid"] = {
        value: token["uid"],
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax
      }

      render json: {
        is_logged_in: true,
        is_steam_id: user.steam_id.present?, # steam_idが存在するかを確認
        user: {
          id: user.id,
          name: user.username
        }
      }, status: :ok
    else
      render json: { is_logged_in: false }, status: :unauthorized
    end
  end

  # ログアウト処理
  def logout
    uid = cookies["uid"]
    client = cookies["client"]
    access_token = cookies["access-token"]

    return unless uid && client && access_token

    # ユーザーを検索
    user = User.find_by(uid: uid)
    if user && user.valid_token?(access_token, client)
      current_user = user
    else
      current_user = nil
    end

    if current_user
      # トークンを無効化
      current_user.tokens = {}
      current_user.save

      # クッキーを削除
      cookies.delete("access-token", secure: Rails.env.production?, same_site: :strict)
      cookies.delete("client", secure: Rails.env.production?, same_site: :strict)
      cookies.delete("uid", secure: Rails.env.production?, same_site: :strict)

      render json: { message: "ログアウト成功" }, status: :ok
    else
      render json: { error: "ログアウトできませんでした" }, status: :unauthorized
    end
  end

  private

  def resource_params
    # session キー内の email と password を許可
    params.require(:session).permit(:email, :password)
  rescue ActionController::ParameterMissing
    # session キーがない場合はトップレベルの email と password を許可
    params.permit(:email, :password)
  end

  # レスポンスカスタマイズ
  def render_create_success
    # トークン生成
    token = @resource.create_new_auth_token

    # クッキーにトークンを設定
    self.cookies["access-token"] = {
      value: token["access-token"],
      httponly: true,
      secure: true,
      same_site: :none
    }

    self.cookies["client"] = {
      value: token["client"],
      httponly: true,
      secure: true,
      same_site: :none
    }

    self.cookies["uid"] = {
      value: token["uid"],
      httponly: true,
      secure: true,
      same_site: :none
    }

    render json: {
      user: resource_data(resource_json: @resource.token_validation_response),
      message: "ログイン成功"
    }
  end
end
