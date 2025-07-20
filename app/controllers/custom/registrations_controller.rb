class Custom::RegistrationsController < DeviseTokenAuth::RegistrationsController
  wrap_parameters format: []

  private

  def sign_up_params
    params.permit(:username, :email, :password, :password_confirmation, :confirm_success_url)
  end
end
