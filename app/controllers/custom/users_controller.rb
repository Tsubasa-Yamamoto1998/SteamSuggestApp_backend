class Custom::UsersController < ApplicationController
  before_action :authenticate_user!
  wrap_parameters :user, include: [ :username, :email, :password, :password_confirmation, :steam_id ]

  def update
    if current_user.update(account_update_params)
      render json: { message: "アカウント情報を更新しました！", user: current_user }, status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def account_update_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation, :steam_id)
  end
end
