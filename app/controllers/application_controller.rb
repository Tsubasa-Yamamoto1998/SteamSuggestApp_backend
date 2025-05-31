class ApplicationController < ActionController::API
        include DeviseTokenAuth::Concerns::SetUserByToken

  ## セッション認証を無視してトークン認証のみを使用
  def authenticate_user!
    uid = request.headers["uid"]
    client = request.headers["client"]
    access_token = request.headers["access-token"]

    user = User.find_by(uid: uid)
    if user && user.valid_token?(access_token, client)
      @current_user = user
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end

    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end

# DeviseTokenAuthの内部で呼び出されるbypass_sign_inを無効化、これがセッション認証を前提としたメソッドのため
module DeviseTokenAuth
  module Concerns
    module SetUserByToken
      def set_user_by_token(mapping = nil)
        # bypass_sign_inを無効化
        if @resource && respond_to?(:bypass_sign_in)
          Rails.logger.debug "Skipping bypass_sign_in to avoid session dependency"
        end
      end
    end
  end
end
