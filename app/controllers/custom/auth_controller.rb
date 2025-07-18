class Custom::AuthController < ApplicationController
  PASSWORD = ENV["ACCESS_PASSWORD"]
  TOKEN = ENV["ACCESS_TOKEN"]

  def guest_login
    if params[:password] == PASSWORD
      render json: { token: TOKEN }
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
