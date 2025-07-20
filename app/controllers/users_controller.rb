class UsersController < ApplicationController
  before_action :authenticate_user! # ユーザー認証を必須にする

  # GET /custom/users/me
  def me
    if current_user
      render json: { user: current_user }, status: :ok
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end
end
