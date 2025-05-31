class Custom::SessionsController < DeviseTokenAuth::SessionsController
  include ActionController::Cookies # Cookies機能を有効化

  wrap_parameters format: []

  # 認証状態を確認するエンドポイント
  def check_auth
    Rails.logger.debug "Checking authentication for user: #{current_user.inspect}"
    Rails.logger.debug "Request Headers: #{request.headers.to_h}"
    Rails.logger.debug "Request Cookies: #{cookies.to_hash}"

    if current_user
      # トークンを更新
      token = current_user.create_new_auth_token
      Rails.logger.debug "Generated Token: #{token}"

      # レスポンスヘッダーにトークンを追加
      response.headers.merge!(token)
      Rails.logger.debug "Response Headers: #{response.headers.to_h}"

      render json: {
        is_logged_in: true,
        user: {
          id: current_user.id,
          name: current_user.name,
          email: current_user.email
        }
      }, status: :ok
    else
      Rails.logger.debug "Authentication failed: current_user is nil"
      render json: { is_logged_in: false }, status: :unauthorized
    end
  end

  # ログアウト処理
  def logout
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
    Rails.logger.debug "Creating session for resource: #{@resource.inspect}"
    super # DeviseTokenAuthのデフォルト処理を呼び出す

    # トークン生成
    token = @resource.create_new_auth_token
    Rails.logger.debug "Generated Token: #{token}"

    # レスポンスヘッダーに追加
    response.headers.merge!(token)
    Rails.logger.debug "Response Headers after merge: #{response.headers.to_h}"

    # Cookieにトークンを設定
    self.cookies["access-token"] = {
      value: token["access-token"],
      httponly: true,
      secure: Rails.env.production? && request.ssl?,
      same_site: :none # 異なるオリジン間でクッキーを送信する場合は :none
    }
    self.cookies["client"] = {
      value: token["client"],
      httponly: true,
      secure: Rails.env.production? && request.ssl?,
      same_site: :none
    }
    self.cookies["uid"] = {
      value: token["uid"],
      httponly: true,
      secure: Rails.env.production? && request.ssl?,
      same_site: :none
    }

    Rails.logger.debug "Cookies after setting: #{self.cookies.to_hash}"

    # render json: {
    #   user: resource_data(resource_json: @resource.token_validation_response),
    #   message: "ログイン成功"
    # }
  end
end
