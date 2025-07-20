class Custom::UsersController < ApplicationController
  before_action :authenticate_user!
  wrap_parameters :user, include: [ :username, :email, :password, :password_confirmation, :steam_id, :profile_image ]

  def me
    if current_user
      image_url = url_for(current_user.profile_image) if current_user.profile_image.attached?
      render json: {
        user: current_user.as_json.merge(profile_image_url: image_url)
      }, status: :ok
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  def update
    if current_user.update(account_update_params)
      image_url = current_user.profile_image.attached? ? url_for(current_user.profile_image) : nil
      render json: {
        message: "アカウント情報を更新しました！",
        user: current_user.as_json.merge(profile_image_url: image_url)
      }, status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def account_update_params
    params.require(:user).permit(:username, :email, :steam_id, :password, :password_confirmation, :profile_image)
  end
end
