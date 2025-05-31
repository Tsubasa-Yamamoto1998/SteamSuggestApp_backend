class Custom::RegistrationsController < DeviseTokenAuth::RegistrationsController
  wrap_parameters format: []

  private

  def sign_up_params
    params.permit(:username, :email, :password, :password_confirmation)
  end
end
